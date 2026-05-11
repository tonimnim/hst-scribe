package echart

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

// HTTPClientConfig captures the runtime knobs for httpClient. Defaults
// are filled in by NewHTTPClient when zero. Constructed via env in main.
type HTTPClientConfig struct {
	// BaseURL is the eChart base URL (no trailing slash). ECHART_BASE_URL.
	BaseURL string

	// ServiceToken is the bearer token sent on every request.
	// ECHART_SVC_TOKEN. The mock-echart ignores it; production validates.
	ServiceToken string

	// PerAttemptTimeout caps a single HTTP attempt. 10s default.
	PerAttemptTimeout time.Duration

	// ConnectTimeout caps the TCP dial portion of an attempt. 5s default.
	ConnectTimeout time.Duration

	// MaxAttempts caps the retry loop. 5 default.
	MaxAttempts int

	// Backoff returns the sleep duration before the (attempt+1)th call.
	// attempt is 1-indexed: Backoff(1) is the wait after the first
	// failure. Nil uses the default 250ms,500ms,1s,2s,5s schedule.
	Backoff func(attempt int) time.Duration
}

// defaultBackoff is the exponential schedule mandated by the PRD:
// 250ms -> 500ms -> 1s -> 2s -> 5s.
func defaultBackoff(attempt int) time.Duration {
	schedule := []time.Duration{
		250 * time.Millisecond,
		500 * time.Millisecond,
		1 * time.Second,
		2 * time.Second,
		5 * time.Second,
	}
	if attempt < 1 {
		attempt = 1
	}
	if attempt > len(schedule) {
		return schedule[len(schedule)-1]
	}
	return schedule[attempt-1]
}

// HTTPClient is the production Client implementation. Construct via
// NewHTTPClient. Concurrency-safe — the underlying http.Client is.
type HTTPClient struct {
	cfg    HTTPClientConfig
	logger *slog.Logger
	http   *http.Client
	sleep  func(context.Context, time.Duration) error
}

// LoadHTTPClientConfigFromEnv reads ECHART_BASE_URL and ECHART_SVC_TOKEN
// from the process environment. Defaults match the dev mock-echart:
//
//	ECHART_BASE_URL  default "http://localhost:8090"
//	ECHART_SVC_TOKEN default ""  (dev mock-echart ignores it)
//
// Timeouts and retry caps are also taken from env when set, otherwise
// the defaults baked into NewHTTPClient apply.
func LoadHTTPClientConfigFromEnv() HTTPClientConfig {
	cfg := HTTPClientConfig{
		BaseURL:      strings.TrimRight(envOr("ECHART_BASE_URL", "http://localhost:8090"), "/"),
		ServiceToken: os.Getenv("ECHART_SVC_TOKEN"),
	}
	return cfg
}

// NewHTTPClient builds an HTTPClient honoring cfg defaults. logger MUST
// be non-nil; nil causes a panic at construction (caller bug).
func NewHTTPClient(cfg HTTPClientConfig, logger *slog.Logger) *HTTPClient {
	if logger == nil {
		panic("echart.NewHTTPClient: logger is nil")
	}
	if cfg.PerAttemptTimeout <= 0 {
		cfg.PerAttemptTimeout = 10 * time.Second
	}
	if cfg.ConnectTimeout <= 0 {
		cfg.ConnectTimeout = 5 * time.Second
	}
	if cfg.MaxAttempts <= 0 {
		cfg.MaxAttempts = 5
	}
	if cfg.Backoff == nil {
		cfg.Backoff = defaultBackoff
	}
	cfg.BaseURL = strings.TrimRight(cfg.BaseURL, "/")

	transport := &http.Transport{
		DialContext: (&net.Dialer{
			Timeout:   cfg.ConnectTimeout,
			KeepAlive: 30 * time.Second,
		}).DialContext,
		MaxIdleConns:          50,
		MaxIdleConnsPerHost:   10,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   5 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
		ForceAttemptHTTP2:     true,
	}

	return &HTTPClient{
		cfg:    cfg,
		logger: logger,
		http: &http.Client{
			Timeout:   cfg.PerAttemptTimeout,
			Transport: transport,
		},
		sleep: ctxSleep,
	}
}

// Compile-time check.
var _ Client = (*HTTPClient)(nil)

// --- Client interface implementations ---

// GetPatientContext returns the locked patient snapshot from eChart.
// Returns ErrPatientNotFound on HTTP 404.
func (c *HTTPClient) GetPatientContext(ctx context.Context, patientID string) (*PatientContext, error) {
	if patientID == "" {
		return nil, errors.New("echart: patient_id is empty")
	}
	path := fmt.Sprintf("/api/echart/v1/patients/%s/context", url.PathEscape(patientID))

	var out PatientContext
	err := c.do(ctx, http.MethodGet, path, nil, &out)
	if err != nil {
		var apiErr *APIError
		if errors.As(err, &apiErr) && apiErr.Status == http.StatusNotFound {
			return nil, ErrPatientNotFound
		}
		return nil, err
	}
	return &out, nil
}

// PostDraftEvent records a draft chart entry for a confirmed event.
func (c *HTTPClient) PostDraftEvent(ctx context.Context, patientID string, req DraftEventRequest) (*DraftEventResponse, error) {
	if patientID == "" {
		return nil, errors.New("echart: patient_id is empty")
	}
	path := fmt.Sprintf("/api/echart/v1/charts/%s/draft-events", url.PathEscape(patientID))

	var out DraftEventResponse
	if err := c.do(ctx, http.MethodPost, path, req, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

// SignSession promotes the supplied event_ids to final entries.
func (c *HTTPClient) SignSession(ctx context.Context, patientID string, req SignSessionRequest) (*SignSessionResponse, error) {
	if patientID == "" {
		return nil, errors.New("echart: patient_id is empty")
	}
	path := fmt.Sprintf("/api/echart/v1/charts/%s/sign-session", url.PathEscape(patientID))

	var out SignSessionResponse
	if err := c.do(ctx, http.MethodPost, path, req, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

// ValidateRxNorm resolves an RxNorm code. Returns ErrRxNormNotFound on
// HTTP 404.
func (c *HTTPClient) ValidateRxNorm(ctx context.Context, code string) (*RxNormEntry, error) {
	if code == "" {
		return nil, errors.New("echart: rxnorm code is empty")
	}
	path := fmt.Sprintf("/api/echart/v1/vocabularies/rxnorm/%s", url.PathEscape(code))

	var raw json.RawMessage
	err := c.do(ctx, http.MethodGet, path, nil, &raw)
	if err != nil {
		var apiErr *APIError
		if errors.As(err, &apiErr) && apiErr.Status == http.StatusNotFound {
			return nil, ErrRxNormNotFound
		}
		return nil, err
	}

	var entry RxNormEntry
	if err := json.Unmarshal(raw, &entry); err != nil {
		return nil, fmt.Errorf("decoding rxnorm body: %w", err)
	}
	entry.Raw = raw
	return &entry, nil
}

// --- Retry-aware HTTP plumbing ---

// do executes method+path with optional JSON body, decoding the response
// into out (which may be nil). It retries on retryable failures up to
// MaxAttempts, sleeping per Backoff between attempts. Honors ctx
// cancellation between attempts.
func (c *HTTPClient) do(ctx context.Context, method, path string, body, out any) error {
	var bodyBytes []byte
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			return fmt.Errorf("marshalling request body: %w", err)
		}
		bodyBytes = b
	}

	target := c.cfg.BaseURL + path

	var lastErr error
	for attempt := 1; attempt <= c.cfg.MaxAttempts; attempt++ {
		if err := ctx.Err(); err != nil {
			return fmt.Errorf("echart request aborted: %w", err)
		}

		attemptErr := c.doOnce(ctx, method, target, bodyBytes, out)
		if attemptErr == nil {
			return nil
		}

		// Non-retryable errors bail immediately.
		if !isRetryable(attemptErr) {
			return attemptErr
		}

		lastErr = attemptErr
		if attempt == c.cfg.MaxAttempts {
			break
		}

		wait := c.cfg.Backoff(attempt)
		c.logger.Warn("echart retry scheduled",
			slog.String("method", method),
			slog.String("path", path),
			slog.Int("attempt", attempt),
			slog.Duration("wait", wait),
			slog.String("err", attemptErr.Error()),
		)
		if err := c.sleep(ctx, wait); err != nil {
			return fmt.Errorf("echart retry sleep: %w", err)
		}
	}

	return fmt.Errorf("%w after %d attempts: %w", ErrRetryExhausted, c.cfg.MaxAttempts, lastErr)
}

// doOnce performs a single HTTP attempt: build request, send, parse.
func (c *HTTPClient) doOnce(ctx context.Context, method, target string, body []byte, out any) error {
	var reader io.Reader
	if body != nil {
		reader = bytes.NewReader(body)
	}
	req, err := http.NewRequestWithContext(ctx, method, target, reader)
	if err != nil {
		return fmt.Errorf("building request: %w", err)
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	req.Header.Set("Accept", "application/json")
	if c.cfg.ServiceToken != "" {
		req.Header.Set("Authorization", "Bearer "+c.cfg.ServiceToken)
	}

	resp, err := c.http.Do(req)
	if err != nil {
		return fmt.Errorf("http: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode >= 400 {
		return decodeAPIError(resp)
	}

	if out == nil {
		// Drain so the connection can be reused.
		_, _ = io.Copy(io.Discard, resp.Body)
		return nil
	}

	dec := json.NewDecoder(resp.Body)
	if err := dec.Decode(out); err != nil && !errors.Is(err, io.EOF) {
		return fmt.Errorf("decoding response body: %w", err)
	}
	return nil
}

// decodeAPIError reads the response body as the canonical error envelope
// and returns an *APIError. Bodies that don't parse are still surfaced —
// the Status is the source of truth for retry decisions.
func decodeAPIError(resp *http.Response) error {
	apiErr := &APIError{Status: resp.StatusCode}
	body, err := io.ReadAll(io.LimitReader(resp.Body, 64*1024))
	if err == nil && len(body) > 0 {
		var env ErrorResponse
		if jerr := json.Unmarshal(body, &env); jerr == nil && (env.Code != "" || env.Message != "") {
			apiErr.Body = &env
		}
	}
	return apiErr
}

// isRetryable reports whether err warrants another attempt.
//
// Retry on:
//   - Network errors (DNS, connection refused, timeout)
//   - APIError.Retryable (5xx, 408, 429)
//
// Do not retry on:
//   - context cancellation / deadline (caller decides)
//   - 4xx (other than 408/429) — the request is wrong
//   - JSON encode/decode errors — body shape is wrong
func isRetryable(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, context.Canceled) || errors.Is(err, context.DeadlineExceeded) {
		return false
	}
	var apiErr *APIError
	if errors.As(err, &apiErr) {
		return apiErr.Retryable()
	}
	// net.Error covers DNS, connection refused, i/o timeout, etc.
	var netErr net.Error
	if errors.As(err, &netErr) {
		return true
	}
	// http.Client errors that don't satisfy net.Error are typically
	// transient (server hung up, EOF mid-read).
	msg := err.Error()
	switch {
	case strings.Contains(msg, "EOF"),
		strings.Contains(msg, "connection reset"),
		strings.Contains(msg, "connection refused"),
		strings.Contains(msg, "broken pipe"),
		strings.Contains(msg, "no such host"):
		return true
	}
	return false
}

// ctxSleep blocks for d or until ctx is done, whichever first.
func ctxSleep(ctx context.Context, d time.Duration) error {
	if d <= 0 {
		return nil
	}
	t := time.NewTimer(d)
	defer t.Stop()
	select {
	case <-t.C:
		return nil
	case <-ctx.Done():
		return ctx.Err()
	}
}

// envOr returns os.Getenv(k) when set, otherwise fallback.
func envOr(k, fallback string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return fallback
}
