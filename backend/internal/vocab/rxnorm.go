package vocab

import (
	"context"
	"strings"
)

// Validator is the contract every clinical-vocabulary backend implements.
// It maps a raw code (string — RxNorm uses numeric strings; SNOMED uses
// "concept ids" that are also numeric strings) to its canonical display
// name. The ok return discriminates a real "not found" from an empty
// canonical, and lets the caller cap confidence / flag for review.
//
// Implementations must be safe for concurrent use.
type Validator interface {
	Validate(ctx context.Context, code string) (canonical string, ok bool)
}

// RxNormValidator is the medication-code validator. The bundled
// implementation is an in-memory map covering the meds the PACU eval
// set actually mentions. A live AWS Comprehend Medical / RxNav HTTP
// client can implement the same interface in Phase 2 without touching
// any caller — the extract package only sees Validator.
type RxNormValidator struct {
	// codes maps the canonical RxNorm code (string) to its display name.
	codes map[string]string

	// names maps a lowercased medication name (generic or brand) to its
	// canonical RxNorm code, so the LLM can return "Zofran" and we can
	// resolve it to 26225 even when it omits the code itself.
	names map[string]string
}

// NewRxNormValidator returns the bundled PACU-subset RxNorm validator.
//
// Codes here are the bare RxNorm RXCUI as numeric strings — matching
// `rxnorm_code` shape on the wire (contract/CONTRACT.md §3 and
// dev/seed/patients.json). Adding a code is a clinical-review decision;
// keep this list small and defensible.
func NewRxNormValidator() *RxNormValidator {
	codes := map[string]string{
		"26225": "Ondansetron",
		"4337":  "Fentanyl",
		"6960":  "Midazolam",
		"7052":  "Morphine",
		"8782":  "Propofol",
		"6387":  "Lidocaine",
		"6130":  "Ketamine",
		"7806":  "Oxygen",
		"3264":  "Dexamethasone",
		"161":   "Acetaminophen",
		"35827": "Ketorolac",
	}

	// Brand/synonym → canonical generic. The values here MUST exist as
	// keys above, otherwise canonical lookups will silently disagree.
	synonyms := map[string]string{
		"ondansetron":   "26225",
		"zofran":        "26225",
		"fentanyl":      "4337",
		"sublimaze":     "4337",
		"midazolam":     "6960",
		"versed":        "6960",
		"morphine":      "7052",
		"propofol":      "8782",
		"diprivan":      "8782",
		"lidocaine":     "6387",
		"xylocaine":     "6387",
		"ketamine":      "6130",
		"ketalar":       "6130",
		"oxygen":        "7806",
		"o2":            "7806",
		"dexamethasone": "3264",
		"decadron":      "3264",
		"acetaminophen": "161",
		"tylenol":       "161",
		"paracetamol":   "161",
		"ketorolac":     "35827",
		"toradol":       "35827",
	}

	return &RxNormValidator{codes: codes, names: synonyms}
}

// Validate implements Validator. The lookup is case-insensitive on the
// code (RxNorm codes are pure digits but we still trim).
func (v *RxNormValidator) Validate(_ context.Context, code string) (string, bool) {
	if v == nil {
		return "", false
	}
	c := strings.TrimSpace(code)
	if c == "" {
		return "", false
	}
	name, ok := v.codes[c]
	return name, ok
}

// LookupByName resolves a medication name (generic or brand, any case)
// to its RxNorm code and canonical display name. It exists primarily so
// the FakeProvider and post-processing validator can backfill a missing
// rxnorm_code when the LLM returned only a name. Returns ("", "", false)
// on miss.
func (v *RxNormValidator) LookupByName(name string) (code, canonical string, ok bool) {
	if v == nil {
		return "", "", false
	}
	n := strings.ToLower(strings.TrimSpace(name))
	if n == "" {
		return "", "", false
	}
	if c, found := v.names[n]; found {
		return c, v.codes[c], true
	}
	return "", "", false
}
