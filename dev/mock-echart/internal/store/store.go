// Package store is the in-memory state for the mock-echart service.
//
// Two slices live here:
//
//   - draft entries keyed by patient_id (chart entries the AI extractor
//     proposed and the nurse has not yet signed).
//   - final entries keyed by patient_id (promoted on POST sign-session).
//
// State is process-local and resets on restart — by design. The real eChart
// owns durable storage; we just need a faithful wire-compatible mock.
package store

import (
	"sync"
	"time"
)

// EntryStatus is the lifecycle status of a chart entry.
type EntryStatus string

const (
	// StatusDraft means the AI proposed this entry; awaiting nurse sign.
	StatusDraft EntryStatus = "draft"
	// StatusFinal means the entry was promoted by a sign-session call.
	StatusFinal EntryStatus = "final"
)

// Entry is a single chart entry as stored in memory.
//
// We keep the original incoming fields plus our server-generated id, status,
// and timestamps. Source utterance is retained for audit-trail completeness;
// the real eChart would persist it too.
type Entry struct {
	ChartEntryID    string         `json:"chart_entry_id"`
	PatientID       string         `json:"patient_id"`
	EventType       string         `json:"event_type"`
	Fields          map[string]any `json:"fields"`
	Confidence      float64        `json:"confidence"`
	SourceUtterance string         `json:"source_utterance"`
	ExtractedAt     time.Time      `json:"extracted_at"`
	Status          EntryStatus    `json:"status"`
	CreatedAt       time.Time      `json:"created_at"`
	SignedAt        *time.Time     `json:"signed_at,omitempty"`
}

// Store is the thread-safe in-memory chart-entry registry.
//
// Use NewStore to construct. All methods are safe for concurrent use.
type Store struct {
	mu      sync.RWMutex
	entries map[string]*Entry // keyed by chart_entry_id (global)
	// byPatient indexes entry ids by patient_id for fast lookup of a single
	// patient's history. The first slot is the insertion order so callers
	// iterating it get deterministic output.
	byPatient map[string][]string
}

// NewStore constructs an empty Store.
func NewStore() *Store {
	return &Store{
		entries:   map[string]*Entry{},
		byPatient: map[string][]string{},
	}
}

// AddDraft inserts a new draft entry and returns the stored copy.
//
// The caller is responsible for generating chart_entry_id (UUIDv7) and the
// created_at timestamp; we accept them as fields on the input so all id /
// time generation lives in one place at the handler boundary.
func (s *Store) AddDraft(e Entry) Entry {
	s.mu.Lock()
	defer s.mu.Unlock()

	e.Status = StatusDraft
	stored := e // copy
	s.entries[e.ChartEntryID] = &stored
	s.byPatient[e.PatientID] = append(s.byPatient[e.PatientID], e.ChartEntryID)
	return stored
}

// Get returns the entry for chart_entry_id, or false if unknown.
func (s *Store) Get(chartEntryID string) (Entry, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	e, ok := s.entries[chartEntryID]
	if !ok {
		return Entry{}, false
	}
	return *e, true
}

// SignResult is the outcome of a sign-session promotion.
type SignResult struct {
	Written  int
	Rejected int
	SignedAt time.Time
}

// PromoteToFinal promotes the given chart_entry_ids belonging to patientID
// to StatusFinal at signedAt. Entries that don't exist, belong to a different
// patient, or are already final are counted as rejected.
//
// Promotion is atomic with respect to other Store callers (single Lock).
func (s *Store) PromoteToFinal(patientID string, chartEntryIDs []string, signedAt time.Time) SignResult {
	s.mu.Lock()
	defer s.mu.Unlock()

	result := SignResult{SignedAt: signedAt}
	for _, id := range chartEntryIDs {
		e, ok := s.entries[id]
		if !ok || e.PatientID != patientID || e.Status != StatusDraft {
			result.Rejected++
			continue
		}
		e.Status = StatusFinal
		t := signedAt
		e.SignedAt = &t
		result.Written++
	}
	return result
}
