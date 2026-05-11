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

// EChartClient fetches patient context from the HST eChart service
// (mock-echart in dev). It exists in the gateway package — not
// internal/echart — because the gateway only needs the read path for
// patient context at session start. internal/echart will own the full
// chart-writer surface in a later wave.
type EChartClient struct {
	baseURL string
	hc      *http.Client
	token   string
}

// EChartOptions configures an EChartClient.
type EChartOptions struct {
	BaseURL       string
	Timeout       time.Duration
	InternalToken string
}

// NewEChartClient constructs a client. Empty BaseURL is rejected.
func NewEChartClient(opts EChartOptions) (*EChartClient, error) {
	if opts.BaseURL == "" {
		return nil, errors.New("echart base URL is required")
	}
	if opts.Timeout <= 0 {
		opts.Timeout = 5 * time.Second
	}
	return &EChartClient{
		baseURL: trimTrailingSlash(opts.BaseURL),
		hc:      &http.Client{Timeout: opts.Timeout},
		token:   opts.InternalToken,
	}, nil
}

// GetPatientContext fetches a patient-context snapshot keyed by patient
// id. The returned value matches contract.PatientContext exactly.
//
// A 404 from the eChart is mapped to httperr.BadRequest with code
// session_not_found-style details so the caller can return it to the
// mobile client unchanged.
func (c *EChartClient) GetPatientContext(ctx context.Context, patientID string) (*contract.PatientContext, error) {
	path := "/api/echart/v1/patients/" + url.PathEscape(patientID) + "/context"
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+path, http.NoBody)
	if err != nil {
		return nil, fmt.Errorf("build echart request: %w", err)
	}
	req.Header.Set("Accept", "application/json")
	if c.token != "" {
		req.Header.Set("Authorization", "Bearer "+c.token)
	}

	resp, err := c.hc.Do(req)
	if err != nil {
		return nil, fmt.Errorf("echart get patient context: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode == http.StatusNotFound {
		return nil, httperr.BadRequest("patient not found in echart", map[string]any{
			"patient_id": patientID,
		})
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 16*1024))
		return nil, httperr.Internal(fmt.Sprintf("echart returned %d: %s", resp.StatusCode, string(body)))
	}

	var out contract.PatientContext
	dec := json.NewDecoder(resp.Body)
	// mock-echart may add fields we do not yet consume; tolerate them.
	if err := dec.Decode(&out); err != nil {
		return nil, fmt.Errorf("decode patient context: %w", err)
	}
	return &out, nil
}

// PostDraftEventInput is the body sent to eChart's draft-events endpoint.
// We keep this internal to the gateway package; the chart-writer service
// will own the full write path in a later wave.
type PostDraftEventInput struct {
	EventType       string         `json:"event_type"`
	Fields          map[string]any `json:"fields"`
	Confidence      float64        `json:"confidence"`
	SourceUtterance string         `json:"source_utterance"`
	ExtractedAt     time.Time      `json:"extracted_at"`
}

// PostDraftEvent is exposed for symmetry; the gateway only uses it from
// tests at the moment, but having it here keeps the eChart surface in
// one place.
func (c *EChartClient) PostDraftEvent(ctx context.Context, patientID string, in PostDraftEventInput) error {
	path := "/api/echart/v1/charts/" + url.PathEscape(patientID) + "/draft-events"
	body, err := json.Marshal(in)
	if err != nil {
		return fmt.Errorf("marshal draft event: %w", err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+path, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("build echart request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json; charset=utf-8")
	if c.token != "" {
		req.Header.Set("Authorization", "Bearer "+c.token)
	}
	resp, err := c.hc.Do(req)
	if err != nil {
		return fmt.Errorf("echart post draft event: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 16*1024))
		return fmt.Errorf("echart returned %d: %s", resp.StatusCode, string(body))
	}
	return nil
}
