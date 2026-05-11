// Package gateway holds gateway-service-specific glue: HTTP clients for
// downstream services (session-manager, mock-echart), the WSS server,
// and the per-session replay ring buffer used for reconnection.
//
// Wire types are imported from internal/contract — this package never
// defines new on-the-wire structs. Internal-service shapes that are not
// part of the public contract live here (e.g. the session-manager
// /internal/v1/sessions response).
package gateway

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
)

// SessionManagerClient is the HTTP client used by the gateway to talk to
// the session-manager service's internal /internal/v1 API. The client is
// safe for concurrent use.
type SessionManagerClient struct {
	baseURL       string
	internalToken string
	hc            *http.Client
}

// SessionManagerOptions configures a SessionManagerClient.
type SessionManagerOptions struct {
	// BaseURL is the root of the session-manager service. Trailing
	// slashes are trimmed by the constructor.
	BaseURL string
	// InternalToken is sent as Authorization: Bearer for internal RPCs.
	InternalToken string
	// Timeout is the per-request timeout. Defaults to 5s.
	Timeout time.Duration
}

// NewSessionManagerClient builds a SessionManagerClient from opts.
func NewSessionManagerClient(opts SessionManagerOptions) (*SessionManagerClient, error) {
	if opts.BaseURL == "" {
		return nil, errors.New("session-manager base URL is required")
	}
	if opts.Timeout <= 0 {
		opts.Timeout = 5 * time.Second
	}
	return &SessionManagerClient{
		baseURL:       trimTrailingSlash(opts.BaseURL),
		internalToken: opts.InternalToken,
		hc:            &http.Client{Timeout: opts.Timeout},
	}, nil
}

// SessionSummary is the gateway-side projection of a session-manager
// session. The session-manager owns the canonical shape; this struct
// mirrors only the fields the gateway needs.
type SessionSummary struct {
	SessionID    string     `json:"session_id"`
	PatientID    string     `json:"patient_id"`
	ASCID        string     `json:"asc_id"`
	UserID       string     `json:"user_id"`
	WorkflowType string     `json:"workflow_type"`
	Status       string     `json:"status"`
	StartedAt    time.Time  `json:"started_at"`
	ExpiresAt    time.Time  `json:"expires_at"`
	EndedAt      *time.Time `json:"ended_at,omitempty"`
	SignedAt     *time.Time `json:"signed_at,omitempty"`
}

// CreateSessionInput is the body sent to session-manager. It is a
// superset of contract.CreateSessionRequest plus the authenticated
// user_id (which the session-manager does not infer from the JWT).
type CreateSessionInput struct {
	PatientID    string `json:"patient_id"`
	WorkflowType string `json:"workflow_type"`
	ASCID        string `json:"asc_id"`
	UserID       string `json:"user_id"`
}

// CreateSession asks the session-manager to create or resume a session
// for (asc_id, patient_id, user_id). The session-manager is responsible
// for enforcing the patient lock and idempotency rules in PRD FR7–FR8.
func (c *SessionManagerClient) CreateSession(ctx context.Context, in CreateSessionInput) (*SessionSummary, error) {
	var out SessionSummary
	if err := c.doJSON(ctx, http.MethodPost, "/internal/v1/sessions", in, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

// GetSession returns a session summary by id. 404 is mapped to
// httperr.SessionNotFound.
func (c *SessionManagerClient) GetSession(ctx context.Context, sessionID string) (*SessionSummary, error) {
	var out SessionSummary
	path := "/internal/v1/sessions/" + url.PathEscape(sessionID)
	if err := c.doJSON(ctx, http.MethodGet, path, nil, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

// SignSession marks the session as signed and returns the resulting
// SignSessionResponse contract body.
func (c *SessionManagerClient) SignSession(ctx context.Context, sessionID string, req contract.SignSessionRequest) (*contract.SignSessionResponse, error) {
	var out contract.SignSessionResponse
	path := "/internal/v1/sessions/" + url.PathEscape(sessionID) + "/sign"
	if err := c.doJSON(ctx, http.MethodPost, path, req, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

// TouchActivity is a fire-and-forget activity update used by the WSS
// loop to keep idle timeouts honest. It uses a 1s deadline so it never
// blocks the message pump.
func (c *SessionManagerClient) TouchActivity(ctx context.Context, sessionID string) error {
	tctx, cancel := context.WithTimeout(ctx, 1*time.Second)
	defer cancel()
	path := "/internal/v1/sessions/" + url.PathEscape(sessionID) + "/activity"
	return c.doJSON(tctx, http.MethodPost, path, nil, nil)
}

// doJSON is the internal request helper. It marshals reqBody if non-nil,
// sends the request with the internal bearer token, and decodes the
// response into respBody if non-nil. Wire-error envelopes returned by
// the session-manager are propagated to the caller as *httperr.Error.
func (c *SessionManagerClient) doJSON(ctx context.Context, method, path string, reqBody, respBody any) error {
	var body io.Reader
	if reqBody != nil {
		b, err := json.Marshal(reqBody)
		if err != nil {
			return fmt.Errorf("marshal session-manager request: %w", err)
		}
		body = bytes.NewReader(b)
	}

	req, err := http.NewRequestWithContext(ctx, method, c.baseURL+path, body)
	if err != nil {
		return fmt.Errorf("build session-manager request: %w", err)
	}
	if reqBody != nil {
		req.Header.Set("Content-Type", "application/json; charset=utf-8")
	}
	req.Header.Set("Accept", "application/json")
	if c.internalToken != "" {
		req.Header.Set("Authorization", "Bearer "+c.internalToken)
	}

	resp, err := c.hc.Do(req)
	if err != nil {
		return fmt.Errorf("session-manager %s %s: %w", method, path, err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		if respBody == nil || resp.StatusCode == http.StatusNoContent {
			_, _ = io.Copy(io.Discard, resp.Body)
			return nil
		}
		dec := json.NewDecoder(resp.Body)
		dec.DisallowUnknownFields()
		if err := dec.Decode(respBody); err != nil && !errors.Is(err, io.EOF) {
			return fmt.Errorf("decode session-manager response: %w", err)
		}
		return nil
	}

	return decodeRemoteError(resp)
}

func trimTrailingSlash(s string) string {
	for len(s) > 0 && s[len(s)-1] == '/' {
		s = s[:len(s)-1]
	}
	return s
}

// decodeRemoteError converts a non-2xx response into a typed *httperr.Error.
// If the body matches the canonical wire envelope we propagate it; if
// not, we wrap with a generic error keyed by status code.
func decodeRemoteError(resp *http.Response) error {
	body, _ := io.ReadAll(io.LimitReader(resp.Body, 64*1024))
	var wire struct {
		Code    string         `json:"code"`
		Message string         `json:"message"`
		Details map[string]any `json:"details,omitempty"`
	}
	if len(body) > 0 {
		if err := json.Unmarshal(body, &wire); err == nil && wire.Code != "" {
			return mapRemoteWireError(resp.StatusCode, wire.Code, wire.Message, wire.Details)
		}
	}
	switch {
	case resp.StatusCode == http.StatusNotFound:
		return httperr.SessionNotFound("")
	case resp.StatusCode == http.StatusConflict:
		return &httperrConflict{StatusCode: resp.StatusCode, Body: string(body)}
	case resp.StatusCode >= 500:
		return httperr.Internal(fmt.Sprintf("session-manager returned %d", resp.StatusCode))
	default:
		return httperr.BadRequest(fmt.Sprintf("session-manager returned %d", resp.StatusCode), nil)
	}
}

// mapRemoteWireError converts a remote wire-error envelope into the
// corresponding *httperr.Error constructor so HTTP status and details
// flow through unchanged.
func mapRemoteWireError(_ int, code, msg string, details map[string]any) *httperr.Error {
	switch httperr.Code(code) {
	case httperr.CodeAuthInvalid:
		return httperr.AuthInvalid(msg)
	case httperr.CodeAuthForbidden:
		return httperr.AuthForbidden(msg)
	case httperr.CodeSessionNotFound:
		id, _ := details["session_id"].(string)
		return httperr.SessionNotFound(id)
	case httperr.CodeSessionExpired:
		id, _ := details["session_id"].(string)
		return httperr.SessionExpired(id)
	case httperr.CodePatientLocked:
		pid, _ := details["patient_id"].(string)
		sid, _ := details["active_session_id"].(string)
		return httperr.PatientLocked(pid, sid)
	case httperr.CodeRateLimited:
		scope, _ := details["scope"].(string)
		return httperr.RateLimited(scope)
	case httperr.CodeBadRequest:
		return httperr.BadRequest(msg, details)
	}
	return httperr.Internal("session-manager error: " + msg)
}

// httperrConflict is a tiny adapter to surface a 409 that did not parse
// as a wire error. It is exported only via the error interface.
type httperrConflict struct {
	StatusCode int
	Body       string
}

func (e *httperrConflict) Error() string {
	return fmt.Sprintf("session-manager conflict %d: %s", e.StatusCode, e.Body)
}
