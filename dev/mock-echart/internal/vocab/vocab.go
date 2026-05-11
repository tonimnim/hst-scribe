// Package vocab holds the bundled RxNorm subset the mock service recognises.
//
// In production this would be a real vocabulary service; here we hard-code
// the minimal set referenced by seed patients and the PACU workflow.
package vocab

// Entry is a single RxNorm record.
type Entry struct {
	RxNormCode string `json:"rxnorm_code"`
	Name       string `json:"name"`
	Valid      bool   `json:"valid"`
}

// rxnorm is the bundled subset. Keys are RxNorm codes.
//
// Kept private and accessed via Lookup so callers cannot mutate the map.
var rxnorm = map[string]Entry{
	"26225": {RxNormCode: "26225", Name: "Ondansetron", Valid: true},
	"4337":  {RxNormCode: "4337", Name: "Fentanyl", Valid: true},
	"6960":  {RxNormCode: "6960", Name: "Midazolam", Valid: true},
	"7052":  {RxNormCode: "7052", Name: "Morphine", Valid: true},
	"8782":  {RxNormCode: "8782", Name: "Propofol", Valid: true},
	"6387":  {RxNormCode: "6387", Name: "Lidocaine", Valid: true},
	"6130":  {RxNormCode: "6130", Name: "Ketamine", Valid: true},
	"7806":  {RxNormCode: "7806", Name: "Oxygen", Valid: true},
}

// Lookup returns the Entry for code and true if known, zero value and false
// otherwise. Callers must not mutate the returned Entry — it is a copy.
func Lookup(code string) (Entry, bool) {
	e, ok := rxnorm[code]
	return e, ok
}
