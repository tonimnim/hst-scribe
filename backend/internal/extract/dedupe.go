package extract

import (
	"math"
	"sync"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
)

// dedupeWindow is the time window inside which two semantically-equal
// events are treated as duplicates. Chosen to comfortably cover
// overlapping ASR-window emissions (typically 250–500 ms apart but we
// budget for jitter and reordering).
const dedupeWindow = 10 * time.Second

// vitalValueTolerance is the relative tolerance (fraction) used when
// comparing vital values for semantic equality. ±5 % matches the
// spec.
const vitalValueTolerance = 0.05

// Dedupe is a per-session sliding-window cache of recently-emitted
// events. New events are checked against the cache; duplicates are
// dropped, novel events are added.
//
// The cache automatically evicts entries older than dedupeWindow on
// every operation, so memory stays bounded to "events within the last
// 10 seconds per session". Safe for concurrent use.
type Dedupe struct {
	mu     sync.Mutex
	recent map[string][]ExtractedEvent // session_id -> recent events
}

// NewDedupe returns an empty Dedupe cache.
func NewDedupe() *Dedupe {
	return &Dedupe{recent: map[string][]ExtractedEvent{}}
}

// Filter walks events and returns only the ones not already present in
// the cache for this session. Cache state is mutated: surviving events
// are added so future calls dedupe against them.
//
// now is injected so tests can pin time. Production callers pass
// time.Now().
func (d *Dedupe) Filter(sessionID string, now time.Time, events []ExtractedEvent) []ExtractedEvent {
	if len(events) == 0 {
		return events
	}
	d.mu.Lock()
	defer d.mu.Unlock()

	d.evictLocked(sessionID, now)

	survivors := make([]ExtractedEvent, 0, len(events))
	for _, e := range events {
		dup := false
		for _, prior := range d.recent[sessionID] {
			if isDuplicate(prior, e) {
				dup = true
				break
			}
		}
		if dup {
			continue
		}
		survivors = append(survivors, e)
		d.recent[sessionID] = append(d.recent[sessionID], e)
	}
	return survivors
}

// Reset clears the per-session cache. Used on session_ended so we
// don't leak state across long-lived workers.
func (d *Dedupe) Reset(sessionID string) {
	d.mu.Lock()
	defer d.mu.Unlock()
	delete(d.recent, sessionID)
}

// evictLocked drops entries older than dedupeWindow. Must be called
// with d.mu held.
func (d *Dedupe) evictLocked(sessionID string, now time.Time) {
	entries := d.recent[sessionID]
	if len(entries) == 0 {
		return
	}
	cutoff := now.Add(-dedupeWindow)
	kept := entries[:0]
	for _, e := range entries {
		if e.ExtractedAt.After(cutoff) {
			kept = append(kept, e)
		}
	}
	if len(kept) == 0 {
		delete(d.recent, sessionID)
		return
	}
	d.recent[sessionID] = kept
}

// isDuplicate implements the spec'd semantic match per event type.
// Same SessionID is implicit (the caller already keys on it).
func isDuplicate(a, b ExtractedEvent) bool {
	if a.EventType != b.EventType {
		return false
	}
	if absDuration(a.ExtractedAt.Sub(b.ExtractedAt)) > dedupeWindow {
		return false
	}

	af, errA := a.FieldsMap()
	bf, errB := b.FieldsMap()
	if errA != nil || errB != nil {
		return false
	}

	switch a.EventType {
	case contract.EventTypeMedicationAdministered:
		return medsMatch(af, bf)
	case contract.EventTypeVitalSign:
		return vitalsMatch(af, bf)
	case contract.EventTypeDispo:
		return dispoMatch(af, bf)
	case contract.EventTypeNote:
		// Notes are free-text. Two notes within 10 s with the SAME
		// source_utterance are duplicates; otherwise keep both.
		return a.SourceUtterance != "" && a.SourceUtterance == b.SourceUtterance
	default:
		return false
	}
}

func medsMatch(a, b map[string]any) bool {
	codeA, _ := a["rxnorm_code"].(string)
	codeB, _ := b["rxnorm_code"].(string)
	if codeA == "" || codeA != codeB {
		return false
	}
	valA, okA := a["dose_value"].(float64)
	valB, okB := b["dose_value"].(float64)
	if !okA || !okB || valA != valB {
		return false
	}
	unitA, _ := a["dose_unit"].(string)
	unitB, _ := b["dose_unit"].(string)
	if unitA != unitB {
		return false
	}
	routeA, _ := a["route"].(string)
	routeB, _ := b["route"].(string)
	return routeA == routeB
}

func vitalsMatch(a, b map[string]any) bool {
	typeA, _ := a["vital_type"].(string)
	typeB, _ := b["vital_type"].(string)
	if typeA == "" || typeA != typeB {
		return false
	}
	valA, okA := a["value"].(float64)
	valB, okB := b["value"].(float64)
	if !okA || !okB {
		return false
	}
	if valA == valB {
		return true
	}
	// ±5 % tolerance — symmetric around the larger value so the
	// relation is order-independent.
	denom := math.Max(math.Abs(valA), math.Abs(valB))
	if denom == 0 {
		return true
	}
	return math.Abs(valA-valB)/denom <= vitalValueTolerance
}

func dispoMatch(a, b map[string]any) bool {
	tA, _ := a["disposition_type"].(string)
	tB, _ := b["disposition_type"].(string)
	return tA != "" && tA == tB
}

func absDuration(d time.Duration) time.Duration {
	if d < 0 {
		return -d
	}
	return d
}
