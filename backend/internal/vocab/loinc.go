package vocab

import "context"

// LOINCValidator is a Phase 2 skeleton. Labs are not part of the PACU
// MVP surface but we still need the symbol present so future callers
// can take a Validator dependency without churn.
type LOINCValidator struct{}

// NewLOINCValidator returns a stub validator that resolves nothing.
// Phase 2 will replace the internals with a LOINC FHIR client.
func NewLOINCValidator() *LOINCValidator { return &LOINCValidator{} }

// Validate implements Validator. The stub always returns ("", false).
func (*LOINCValidator) Validate(_ context.Context, _ string) (string, bool) {
	return "", false
}
