// Package handlers wires the gateway's REST surface to the
// session-manager, eChart, and NATS dependencies. Handlers stay short —
// real work is delegated to internal/gateway clients.
package handlers

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/golang-jwt/jwt/v5"

	"github.com/tonimnim/hst-scribe/backend/internal/auth"
	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/gateway"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

// Deps is the dependency set for the REST surface. All fields must be
// non-nil for the router to be wired correctly.
type Deps struct {
	Logger         *slog.Logger
	SessionClient  *gateway.SessionManagerClient
	EChartClient   *gateway.EChartClient
	Publisher      gateway.Publisher
	Validator      auth.Validator
	Registry       *gateway.SessionRegistry
	JWTSecret      string
	AccessTokenTTL time.Duration
	WSSBaseURL     string
}

// REST wraps Deps with HTTP handlers. Use NewREST.
type REST struct{ Deps }

// NewREST returns a configured REST handler.
func NewREST(d Deps) *REST {
	if d.AccessTokenTTL <= 0 {
		d.AccessTokenTTL = 15 * time.Minute
	}
	return &REST{d}
}

// CreateSession implements POST /api/v1/sessions.
func (h *REST) CreateSession(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	logger := obs.LoggerFromContext(ctx)
	claims := mustClaims(ctx)
	if claims == nil {
		httperr.WriteJSON(w, httperr.AuthInvalid(""))
		return
	}

	var req contract.CreateSessionRequest
	if err := decodeStrict(r.Body, &req); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest(err.Error(), nil))
		return
	}
	if req.PatientID == "" || req.WorkflowType == "" || req.ASCID == "" {
		httperr.WriteJSON(w, httperr.BadRequest(
			"patient_id, workflow_type, and asc_id are required",
			nil,
		))
		return
	}
	if claims.ASCID != "" && req.ASCID != claims.ASCID {
		httperr.WriteJSON(w, httperr.AuthForbidden("asc_id does not match token"))
		return
	}

	smCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	summary, err := h.SessionClient.CreateSession(smCtx, gateway.CreateSessionInput{
		PatientID:    req.PatientID,
		WorkflowType: string(req.WorkflowType),
		ASCID:        req.ASCID,
		UserID:       claims.UserID,
	})
	if err != nil {
		writeWireError(w, logger, err)
		return
	}

	echartCtx, cancel2 := context.WithTimeout(ctx, 5*time.Second)
	defer cancel2()
	patientCtx, err := h.EChartClient.GetPatientContext(echartCtx, summary.PatientID)
	if err != nil {
		writeWireError(w, logger, err)
		return
	}

	resp := contract.CreateSessionResponse{
		SessionID:      summary.SessionID,
		WSSURL:         h.WSSBaseURL + "/api/v1/sessions/" + summary.SessionID + "/stream",
		PatientContext: *patientCtx,
		StartedAt:      summary.StartedAt,
		ExpiresAt:      summary.ExpiresAt,
	}

	logger.Info("session created",
		slog.String("session_id", summary.SessionID),
		slog.String("patient_id", summary.PatientID),
		slog.String("workflow_type", string(req.WorkflowType)),
	)
	writeJSON(w, http.StatusCreated, resp)
}

// GetSession implements GET /api/v1/sessions/{id}.
func (h *REST) GetSession(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	logger := obs.LoggerFromContext(ctx)
	sessionID := chi.URLParam(r, "id")
	if sessionID == "" {
		httperr.WriteJSON(w, httperr.BadRequest("session id is required", nil))
		return
	}
	claims := mustClaims(ctx)
	if claims == nil {
		httperr.WriteJSON(w, httperr.AuthInvalid(""))
		return
	}

	smCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	summary, err := h.SessionClient.GetSession(smCtx, sessionID)
	if err != nil {
		writeWireError(w, logger, err)
		return
	}
	if summary.UserID != "" && summary.UserID != claims.UserID {
		httperr.WriteJSON(w, httperr.AuthForbidden("session does not belong to user"))
		return
	}

	writeJSON(w, http.StatusOK, summary)
}

// EditEvent implements PATCH /api/v1/sessions/{id}/events/{event_id}.
//
// Wave 1 stub: echoes the supplied fields with status="draft_edited".
// Wave 2 will persist via the draft-events store.
func (h *REST) EditEvent(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	logger := obs.LoggerFromContext(ctx)
	eventID := chi.URLParam(r, "event_id")
	if eventID == "" {
		httperr.WriteJSON(w, httperr.BadRequest("event_id is required", nil))
		return
	}

	var req contract.EditEventRequest
	if err := decodeStrict(r.Body, &req); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest(err.Error(), nil))
		return
	}
	if len(req.Fields) == 0 {
		httperr.WriteJSON(w, httperr.BadRequest("fields must not be empty", nil))
		return
	}

	logger.Info("event draft edit (stub)", slog.String("event_id", eventID))
	writeJSON(w, http.StatusOK, contract.EditEventResponse{
		EventID: eventID,
		Status:  contract.EventStatusDraftEdited,
		Fields:  req.Fields,
	})
}

// ConfirmEvent implements POST /api/v1/sessions/{id}/events/{event_id}/confirm.
func (h *REST) ConfirmEvent(w http.ResponseWriter, r *http.Request) {
	h.eventDecision(w, r, contract.EventStatusConfirmed, gateway.SubjectExtractedConfirm)
}

// RejectEvent implements POST /api/v1/sessions/{id}/events/{event_id}/reject.
func (h *REST) RejectEvent(w http.ResponseWriter, r *http.Request) {
	h.eventDecision(w, r, contract.EventStatusRejected, gateway.SubjectExtractedReject)
}

// eventDecision is the shared implementation of confirm/reject. It
// publishes an event_ack-shaped payload on the chart-writer subject and
// returns the canonical EventStatusResponse to the caller.
func (h *REST) eventDecision(w http.ResponseWriter, r *http.Request, status contract.EventStatus, subj func(string) string) {
	ctx := r.Context()
	logger := obs.LoggerFromContext(ctx)
	sessionID := chi.URLParam(r, "id")
	eventID := chi.URLParam(r, "event_id")
	if sessionID == "" || eventID == "" {
		httperr.WriteJSON(w, httperr.BadRequest("session id and event_id are required", nil))
		return
	}

	// Body is allowed to be empty; if present we tolerate but ignore it.
	if r.Body != nil {
		_, _ = io.Copy(io.Discard, io.LimitReader(r.Body, 4096))
	}

	payload := contract.EventAckPayload{EventID: eventID, Status: status}
	data, err := json.Marshal(payload)
	if err != nil {
		writeWireError(w, logger, fmt.Errorf("marshal ack: %w", err))
		return
	}
	pubCtx, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()
	if err := h.Publisher.Publish(pubCtx, subj(sessionID), data); err != nil {
		writeWireError(w, logger, err)
		return
	}
	logger.Info("event decision",
		slog.String("session_id", sessionID),
		slog.String("event_id", eventID),
		slog.String("status", string(status)),
	)
	writeJSON(w, http.StatusOK, contract.EventStatusResponse{EventID: eventID, Status: status})
}

// SignSession implements POST /api/v1/sessions/{id}/sign.
func (h *REST) SignSession(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	logger := obs.LoggerFromContext(ctx)
	sessionID := chi.URLParam(r, "id")
	if sessionID == "" {
		httperr.WriteJSON(w, httperr.BadRequest("session id is required", nil))
		return
	}
	claims := mustClaims(ctx)
	if claims == nil {
		httperr.WriteJSON(w, httperr.AuthInvalid(""))
		return
	}

	var req contract.SignSessionRequest
	if err := decodeStrict(r.Body, &req); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest(err.Error(), nil))
		return
	}
	if req.AuthMethod != contract.SignAuthBiometric && req.AuthMethod != contract.SignAuthPIN {
		httperr.WriteJSON(w, httperr.BadRequest("auth_method must be biometric|pin", nil))
		return
	}
	if !verifyAuthToken(h.JWTSecret, claims.UserID, sessionID, req.AuthToken) {
		httperr.WriteJSON(w, httperr.AuthInvalid("auth_token is invalid"))
		return
	}

	smCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	resp, err := h.SessionClient.SignSession(smCtx, sessionID, req)
	if err != nil {
		writeWireError(w, logger, err)
		return
	}

	// Fan out to chart-writer.
	pubCtx, cancel2 := context.WithTimeout(ctx, 2*time.Second)
	defer cancel2()
	signPayload := map[string]any{
		"session_id": sessionID,
		"user_id":    claims.UserID,
		"signed_at":  time.Now().UTC().Format(time.RFC3339Nano),
	}
	signData, _ := json.Marshal(signPayload)
	if err := h.Publisher.Publish(pubCtx, gateway.SubjectChartSign(sessionID), signData); err != nil {
		// Sign already succeeded server-side; log but do not fail
		// the client response.
		logger.Warn("chart sign publish failed",
			slog.String("session_id", sessionID),
			slog.String("err", err.Error()),
		)
	}

	// Drop the in-memory replay buffer for this session.
	h.Registry.Drop(sessionID)

	logger.Info("session signed",
		slog.String("session_id", sessionID),
		slog.Int("events_written", resp.EventsWritten),
		slog.Int("events_rejected", resp.EventsRejected),
	)
	writeJSON(w, http.StatusOK, resp)
}

// RefreshAuth implements POST /api/v1/auth/refresh.
//
// Wave 1 dev: accept any currently-valid HMAC access token in the
// Authorization header and re-issue with a fresh expiry. Real OAuth2
// refresh-token rotation arrives in Phase 2.
func (h *REST) RefreshAuth(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	logger := obs.LoggerFromContext(ctx)

	claims, err := h.Validator.Validate(ctx, r.Header.Get("Authorization"))
	if err != nil {
		writeWireError(w, logger, err)
		return
	}

	now := time.Now().UTC()
	exp := now.Add(h.AccessTokenTTL)

	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":     claims.Subject,
		"user_id": claims.UserID,
		"asc_id":  claims.ASCID,
		"role":    string(claims.Role),
		"iat":     now.Unix(),
		"exp":     exp.Unix(),
		"jti":     uuidv7.New(),
	})
	signed, err := tok.SignedString([]byte(h.JWTSecret))
	if err != nil {
		writeWireError(w, logger, fmt.Errorf("sign refreshed token: %w", err))
		return
	}

	writeJSON(w, http.StatusOK, contract.RefreshResponse{
		AccessToken:  signed,
		RefreshToken: "",
		ExpiresIn:    int(h.AccessTokenTTL.Seconds()),
		TokenType:    "Bearer",
	})
}

// --- helpers ---

func mustClaims(ctx context.Context) *auth.Claims {
	return auth.ClaimsFromContext(ctx)
}

func decodeStrict(body io.ReadCloser, dst any) error {
	if body == nil {
		return errors.New("missing request body")
	}
	dec := json.NewDecoder(body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		if errors.Is(err, io.EOF) {
			return errors.New("empty request body")
		}
		return fmt.Errorf("invalid request body: %s", err.Error())
	}
	if dec.More() {
		return errors.New("trailing data after JSON object")
	}
	return nil
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(body); err != nil {
		// Headers already written — nothing actionable here.
		_ = err
	}
}

func writeWireError(w http.ResponseWriter, logger *slog.Logger, err error) {
	var werr *httperr.Error
	if errors.As(err, &werr) {
		httperr.WriteJSON(w, werr)
		return
	}
	logger.Warn("downstream error", slog.String("err", err.Error()))
	httperr.WriteJSON(w, httperr.Internal("upstream service error"))
}

// verifyAuthToken validates a Wave-1 sign-step auth_token. The token
// shape is "<base64(user_id|session_id|exp_unix)>.<hex(HMAC-SHA256)>";
// any expired or HMAC-mismatched token fails. In production the mobile
// app obtains a short-lived assertion from the device biometric/PIN
// flow and presents it here.
func verifyAuthToken(secret, userID, sessionID, token string) bool {
	if secret == "" || token == "" {
		return false
	}
	parts := strings.SplitN(token, ".", 2)
	if len(parts) != 2 {
		return false
	}
	rawPayload, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return false
	}
	mac, err := hex.DecodeString(parts[1])
	if err != nil {
		return false
	}
	h := hmac.New(sha256.New, []byte(secret))
	h.Write(rawPayload)
	if !hmac.Equal(mac, h.Sum(nil)) {
		return false
	}
	fields := strings.Split(string(rawPayload), "|")
	if len(fields) != 3 {
		return false
	}
	if fields[0] != userID || fields[1] != sessionID {
		return false
	}
	expUnix, err := parseInt64(fields[2])
	if err != nil {
		return false
	}
	if time.Now().UTC().Unix() > expUnix {
		return false
	}
	return true
}

func parseInt64(s string) (int64, error) {
	var n int64
	if _, err := fmt.Sscanf(s, "%d", &n); err != nil {
		return 0, err
	}
	return n, nil
}
