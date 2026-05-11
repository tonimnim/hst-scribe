package echart

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"testing"
	"time"
)

// --- fakes ---

type fakeRepo struct {
	mu       sync.Mutex
	rows     map[string]*ChartWrite // keyed by event_id
	insertN  int
	writtenN int
	failedN  int
	promN    int
}

func newFakeRepo() *fakeRepo {
	return &fakeRepo{rows: map[string]*ChartWrite{}}
}

func (r *fakeRepo) InsertPending(_ context.Context, w ChartWrite) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := r.rows[w.EventID]; ok {
		return ErrDuplicateEventID
	}
	cp := w
	cp.Status = StatusPending
	r.rows[w.EventID] = &cp
	r.insertN++
	return nil
}

func (r *fakeRepo) InsertRejected(_ context.Context, w ChartWrite) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := r.rows[w.EventID]; ok {
		return ErrDuplicateEventID
	}
	cp := w
	cp.Status = StatusRejected
	r.rows[w.EventID] = &cp
	return nil
}

func (r *fakeRepo) MarkWritten(_ context.Context, eventID, echartEntryID string, attempts int, writtenAt time.Time) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	row, ok := r.rows[eventID]
	if !ok {
		return fmt.Errorf("no row for %s", eventID)
	}
	row.Status = StatusWritten
	row.EChartEntryID = &echartEntryID
	row.Attempts = attempts
	row.WrittenAt = &writtenAt
	r.writtenN++
	return nil
}

func (r *fakeRepo) MarkFailed(_ context.Context, eventID string, attempts int, lastError string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	row, ok := r.rows[eventID]
	if !ok {
		return fmt.Errorf("no row for %s", eventID)
	}
	row.Status = StatusFailed
	row.Attempts = attempts
	row.LastError = &lastError
	r.failedN++
	return nil
}

func (r *fakeRepo) ListWrittenBySession(_ context.Context, sessionID string) ([]ChartWrite, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []ChartWrite
	for _, row := range r.rows {
		if row.SessionID == sessionID && row.Status == StatusWritten {
			out = append(out, *row)
		}
	}
	return out, nil
}

func (r *fakeRepo) MarkPromoted(_ context.Context, eventIDs []string, promotedAt time.Time) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, eid := range eventIDs {
		row, ok := r.rows[eid]
		if !ok || row.Status != StatusWritten {
			continue
		}
		row.Status = StatusPromoted
		row.PromotedAt = &promotedAt
		r.promN++
	}
	return nil
}

type fakeClient struct {
	postDraft  func(ctx context.Context, patientID string, req DraftEventRequest) (*DraftEventResponse, error)
	signSess   func(ctx context.Context, patientID string, req SignSessionRequest) (*SignSessionResponse, error)
	patientCtx func(ctx context.Context, patientID string) (*PatientContext, error)
	rxnorm     func(ctx context.Context, code string) (*RxNormEntry, error)
}

func (c *fakeClient) GetPatientContext(ctx context.Context, p string) (*PatientContext, error) {
	if c.patientCtx == nil {
		return nil, errors.New("not impl")
	}
	return c.patientCtx(ctx, p)
}
func (c *fakeClient) PostDraftEvent(ctx context.Context, p string, r DraftEventRequest) (*DraftEventResponse, error) {
	if c.postDraft == nil {
		return nil, errors.New("not impl")
	}
	return c.postDraft(ctx, p, r)
}
func (c *fakeClient) SignSession(ctx context.Context, p string, r SignSessionRequest) (*SignSessionResponse, error) {
	if c.signSess == nil {
		return nil, errors.New("not impl")
	}
	return c.signSess(ctx, p, r)
}
func (c *fakeClient) ValidateRxNorm(ctx context.Context, code string) (*RxNormEntry, error) {
	if c.rxnorm == nil {
		return nil, errors.New("not impl")
	}
	return c.rxnorm(ctx, code)
}

type fakeAudit struct {
	mu  sync.Mutex
	evs []AuditEvent
}

func (f *fakeAudit) Publish(_ context.Context, _ string, e AuditEvent) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.evs = append(f.evs, e)
	return nil
}
func (f *fakeAudit) actions() []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := make([]string, len(f.evs))
	for i, e := range f.evs {
		out[i] = e.Action
	}
	return out
}

type fakeDLQ struct {
	mu     sync.Mutex
	bodies [][]byte
}

func (f *fakeDLQ) Publish(_ context.Context, b []byte) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.bodies = append(f.bodies, b)
	return nil
}
func (f *fakeDLQ) count() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return len(f.bodies)
}

// stableID returns a deterministic UUID generator for tests.
func stableID() IDGen {
	var n int64
	return func() string {
		n++
		return fmt.Sprintf("0193ffff-0000-7000-8000-%012d", n)
	}
}

func newTestWriter(t *testing.T, fc *fakeClient, repo *fakeRepo) (*Writer, *fakeAudit, *fakeDLQ) {
	t.Helper()
	audit := &fakeAudit{}
	dlq := &fakeDLQ{}
	w, err := NewWriter(
		WriterConfig{DLQReplayInterval: time.Hour, DLQReplayMinAge: time.Hour},
		fc, repo, nil, audit, dlq, newTestLogger(), stableID(),
		WithClock(func() time.Time { return time.Date(2026, 5, 11, 14, 32, 0, 0, time.UTC) }),
	)
	if err != nil {
		t.Fatalf("NewWriter: %v", err)
	}
	return w, audit, dlq
}

func sampleConfirmed() ConfirmedEvent {
	return ConfirmedEvent{
		EventID:         "01931d83-0000-7000-8000-000000000001",
		SessionID:       "01931d80-0000-7000-8000-000000000001",
		PatientID:       "01931d7e-0000-7000-8000-000000000001",
		ASCID:           "01931d7d-0000-7000-8000-000000000001",
		ActorUserID:     "01931d7c-0000-7000-8000-000000000001",
		EventType:       "vital_sign",
		Fields:          json.RawMessage(`{"vital_type":"heart_rate","value":72,"unit":"bpm"}`),
		Confidence:      0.94,
		SourceUtterance: "HR seventy two",
		ExtractedAt:     time.Date(2026, 5, 11, 14, 32, 0, 0, time.UTC),
	}
}

// --- HandleConfirmed ---

func TestHandleConfirmed_HappyPath(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	fc := &fakeClient{
		postDraft: func(_ context.Context, p string, r DraftEventRequest) (*DraftEventResponse, error) {
			if p == "" {
				t.Errorf("empty patient_id")
			}
			if r.EventType != "vital_sign" {
				t.Errorf("event_type = %q", r.EventType)
			}
			return &DraftEventResponse{
				ChartEntryID: "0193cccc-0000-7000-8000-000000000001",
				Status:       "draft",
				CreatedAt:    time.Now().UTC(),
			}, nil
		},
	}
	w, audit, dlq := newTestWriter(t, fc, repo)

	if err := w.HandleConfirmed(context.Background(), sampleConfirmed()); err != nil {
		t.Fatalf("HandleConfirmed: %v", err)
	}

	if repo.writtenN != 1 {
		t.Errorf("writtenN = %d, want 1", repo.writtenN)
	}
	if dlq.count() != 0 {
		t.Errorf("dlq count = %d, want 0", dlq.count())
	}
	want := []string{"chart_write_attempted", "chart_write_succeeded"}
	got := audit.actions()
	if len(got) != len(want) || got[0] != want[0] || got[1] != want[1] {
		t.Errorf("audit actions = %v, want %v", got, want)
	}
}

func TestHandleConfirmed_IdempotentDuplicate(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	var posts int32
	fc := &fakeClient{
		postDraft: func(context.Context, string, DraftEventRequest) (*DraftEventResponse, error) {
			posts++
			return &DraftEventResponse{ChartEntryID: "cee", Status: "draft"}, nil
		},
	}
	w, _, _ := newTestWriter(t, fc, repo)

	ev := sampleConfirmed()
	if err := w.HandleConfirmed(context.Background(), ev); err != nil {
		t.Fatalf("first: %v", err)
	}
	// Second confirmed for same event_id must NOT POST again.
	if err := w.HandleConfirmed(context.Background(), ev); err != nil {
		t.Fatalf("second: %v", err)
	}
	if posts != 1 {
		t.Errorf("posts = %d, want 1", posts)
	}
}

func TestHandleConfirmed_RetryExhaustedRoutesToDLQ(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	fc := &fakeClient{
		postDraft: func(context.Context, string, DraftEventRequest) (*DraftEventResponse, error) {
			return nil, fmt.Errorf("%w: simulated", ErrRetryExhausted)
		},
	}
	w, audit, dlq := newTestWriter(t, fc, repo)

	if err := w.HandleConfirmed(context.Background(), sampleConfirmed()); err != nil {
		t.Fatalf("HandleConfirmed returned non-nil: %v", err)
	}

	if repo.failedN != 1 {
		t.Errorf("failedN = %d, want 1", repo.failedN)
	}
	if dlq.count() != 1 {
		t.Errorf("dlq count = %d, want 1", dlq.count())
	}
	got := audit.actions()
	if len(got) < 2 || got[len(got)-1] != "chart_write_failed" {
		t.Errorf("audit actions = %v; want last 'chart_write_failed'", got)
	}
}

func TestHandleConfirmed_4xxRoutesToDLQ(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	apiErr := &APIError{Status: 400, Body: &ErrorResponse{Code: "invalid_request", Message: "bad event_type"}}
	fc := &fakeClient{
		postDraft: func(context.Context, string, DraftEventRequest) (*DraftEventResponse, error) {
			return nil, apiErr
		},
	}
	w, _, dlq := newTestWriter(t, fc, repo)

	if err := w.HandleConfirmed(context.Background(), sampleConfirmed()); err != nil {
		t.Fatalf("HandleConfirmed: %v", err)
	}
	if dlq.count() != 1 {
		t.Errorf("dlq count = %d, want 1", dlq.count())
	}
}

func TestHandleConfirmed_BadFieldsRoutesToDLQ(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	fc := &fakeClient{
		postDraft: func(context.Context, string, DraftEventRequest) (*DraftEventResponse, error) {
			t.Errorf("PostDraftEvent should not be called for bad fields")
			return nil, nil
		},
	}
	w, _, dlq := newTestWriter(t, fc, repo)

	ev := sampleConfirmed()
	ev.Fields = json.RawMessage(`not json`)
	if err := w.HandleConfirmed(context.Background(), ev); err != nil {
		t.Fatalf("HandleConfirmed: %v", err)
	}
	if dlq.count() != 1 {
		t.Errorf("dlq count = %d, want 1", dlq.count())
	}
}

// --- HandleRejected ---

func TestHandleRejected_HappyPath(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	w, _, _ := newTestWriter(t, &fakeClient{}, repo)
	ev := RejectedEvent{
		EventID:    "01931d83-0000-7000-8000-000000000001",
		SessionID:  "01931d80-0000-7000-8000-000000000001",
		PatientID:  "01931d7e-0000-7000-8000-000000000001",
		ASCID:      "01931d7d-0000-7000-8000-000000000001",
		RejectedAt: time.Now().UTC(),
	}
	if err := w.HandleRejected(context.Background(), ev); err != nil {
		t.Fatalf("HandleRejected: %v", err)
	}
	if len(repo.rows) != 1 || repo.rows[ev.EventID].Status != StatusRejected {
		t.Errorf("repo state = %#v", repo.rows)
	}
}

// --- HandleSign ---

func TestHandleSign_PromotesWrittenRows(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	// Pre-seed: 2 written rows + 1 promoted row from a prior sign.
	now := time.Now().UTC()
	entry1 := "01931ddd-0000-7000-8000-000000000001"
	entry2 := "01931ddd-0000-7000-8000-000000000002"
	repo.rows["e1"] = &ChartWrite{
		EventID: "e1", SessionID: "sess", PatientID: "pid",
		EChartEntryID: &entry1, Status: StatusWritten, WrittenAt: &now,
	}
	repo.rows["e2"] = &ChartWrite{
		EventID: "e2", SessionID: "sess", PatientID: "pid",
		EChartEntryID: &entry2, Status: StatusWritten, WrittenAt: &now,
	}
	repo.rows["e0"] = &ChartWrite{
		EventID: "e0", SessionID: "sess", PatientID: "pid",
		Status: StatusPromoted,
	}

	var got SignSessionRequest
	fc := &fakeClient{
		signSess: func(_ context.Context, _ string, r SignSessionRequest) (*SignSessionResponse, error) {
			got = r
			return &SignSessionResponse{EventsWritten: len(r.EventIDs), SignedAt: time.Now().UTC()}, nil
		},
	}
	w, audit, _ := newTestWriter(t, fc, repo)

	err := w.HandleSign(context.Background(), SignEvent{
		SessionID: "sess", PatientID: "pid", ASCID: "asc", SignedAt: time.Now().UTC(),
	})
	if err != nil {
		t.Fatalf("HandleSign: %v", err)
	}

	if got.SessionID != "sess" || len(got.EventIDs) != 2 {
		t.Errorf("sign request = %#v", got)
	}
	if repo.rows["e1"].Status != StatusPromoted || repo.rows["e2"].Status != StatusPromoted {
		t.Errorf("not promoted: %#v %#v", repo.rows["e1"], repo.rows["e2"])
	}
	acts := audit.actions()
	if len(acts) != 1 || acts[0] != "chart_write_succeeded" {
		t.Errorf("audit = %v", acts)
	}
}

func TestHandleSign_SignFailureLeavesWrittenIntact(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	now := time.Now().UTC()
	entryX := "x"
	repo.rows["e1"] = &ChartWrite{
		EventID: "e1", SessionID: "sess", PatientID: "pid",
		EChartEntryID: &entryX, Status: StatusWritten, WrittenAt: &now,
	}

	fc := &fakeClient{
		signSess: func(context.Context, string, SignSessionRequest) (*SignSessionResponse, error) {
			return nil, errors.New("upstream 500")
		},
	}
	w, audit, _ := newTestWriter(t, fc, repo)

	if err := w.HandleSign(context.Background(), SignEvent{
		SessionID: "sess", PatientID: "pid", ASCID: "asc",
	}); err != nil {
		t.Fatalf("HandleSign: %v", err)
	}
	if repo.rows["e1"].Status != StatusWritten {
		t.Errorf("row should remain 'written', got %v", repo.rows["e1"].Status)
	}
	acts := audit.actions()
	if len(acts) != 1 || acts[0] != "chart_write_failed" {
		t.Errorf("audit = %v", acts)
	}
}

func TestHandleSign_NoWrittenRowsNoOp(t *testing.T) {
	t.Parallel()

	repo := newFakeRepo()
	fc := &fakeClient{
		signSess: func(context.Context, string, SignSessionRequest) (*SignSessionResponse, error) {
			t.Errorf("SignSession should not be called when there are no written rows")
			return nil, nil
		},
	}
	w, _, _ := newTestWriter(t, fc, repo)
	if err := w.HandleSign(context.Background(), SignEvent{
		SessionID: "sess", PatientID: "pid", ASCID: "asc",
	}); err != nil {
		t.Fatalf("HandleSign: %v", err)
	}
}

// --- validation ---

func TestValidateConfirmed(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name string
		mut  func(*ConfirmedEvent)
		ok   bool
	}{
		{"valid", func(*ConfirmedEvent) {}, true},
		{"no event_id", func(e *ConfirmedEvent) { e.EventID = "" }, false},
		{"no session_id", func(e *ConfirmedEvent) { e.SessionID = "" }, false},
		{"no patient_id", func(e *ConfirmedEvent) { e.PatientID = "" }, false},
		{"no asc_id", func(e *ConfirmedEvent) { e.ASCID = "" }, false},
		{"no event_type", func(e *ConfirmedEvent) { e.EventType = "" }, false},
	}
	for _, tc := range cases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			ev := sampleConfirmed()
			tc.mut(&ev)
			err := validateConfirmed(&ev)
			if tc.ok && err != nil {
				t.Errorf("want ok, got %v", err)
			}
			if !tc.ok && err == nil {
				t.Errorf("want err")
			}
		})
	}
}
