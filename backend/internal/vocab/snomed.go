package vocab

import "context"

// SNOMEDValidator is a Phase 2 skeleton. It exists so the extract
// package can already depend on the Validator interface without a
// later type-shuffle once condition extraction lands.
type SNOMEDValidator struct{}

// NewSNOMEDValidator returns a stub validator that resolves nothing.
// Phase 2 will replace the internals with a SNOMED CT browser client.
func NewSNOMEDValidator() *SNOMEDValidator { return &SNOMEDValidator{} }

// Validate implements Validator. The stub always returns ("", false)
// — every code is unknown until the live client is wired in.
func (*SNOMEDValidator) Validate(_ context.Context, _ string) (string, bool) {
	return "", false
}
