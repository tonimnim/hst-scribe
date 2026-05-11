package chart

import (
	"context"
	"errors"
)

// Registry selects the chart.Adapter for a given asc_id. The chart-writer
// and gateway look up an adapter per request so a fleet running mixed
// EHR backends (HST in some ASCs, FHIR in others) routes correctly.
//
// Phase 2 swap-in: a DB-backed registry keyed on the ascs.ehr_adapter
// column. The interface is small so the swap is a one-file change.
type Registry interface {
	// For returns the adapter responsible for the given asc_id. An
	// empty asc_id is treated as a programming error; the
	// implementation returns an error rather than guessing.
	For(ctx context.Context, ascID string) (Adapter, error)
}

// StaticRegistry returns the same adapter for every asc_id. This is the
// Wave 2 default — every ASC runs HST. NewStaticRegistry validates that
// the adapter is non-nil at construction; runtime lookups never fail.
type StaticRegistry struct {
	adapter Adapter
}

// NewStaticRegistry returns a registry that resolves every asc_id to
// adapter. Panics on nil — that's a caller bug; we'd rather crash at
// startup than silently mis-route at runtime.
func NewStaticRegistry(adapter Adapter) *StaticRegistry {
	if adapter == nil {
		panic("chart.NewStaticRegistry: adapter is nil")
	}
	return &StaticRegistry{adapter: adapter}
}

// For implements Registry.
func (r *StaticRegistry) For(_ context.Context, ascID string) (Adapter, error) {
	if ascID == "" {
		return nil, errors.New("chart.StaticRegistry: asc_id is empty")
	}
	return r.adapter, nil
}

// Compile-time check.
var _ Registry = (*StaticRegistry)(nil)
