// Package seed loads canned patient records from a JSON file.
//
// Note: even though the seed file is synthetic, the loader treats it as
// PHI-shaped. Callers must surface only the contract-safe projection
// (PatientContext) to clients, never the raw record.
package seed

import (
	"encoding/json"
	"fmt"
	"os"
)

// Medication is a single current medication entry on a patient record.
type Medication struct {
	RxNormCode string `json:"rxnorm_code"`
	Name       string `json:"name"`
	Dose       string `json:"dose"`
	Route      string `json:"route"`
}

// Allergy is a single allergy entry on a patient record.
type Allergy struct {
	Name     string `json:"name"`
	Severity string `json:"severity"`
}

// Patient is the raw seed record. Includes fields that must NEVER leak past
// the service boundary (FullName, MRN, DateOfBirth, Sex).
type Patient struct {
	PatientID           string       `json:"patient_id"`
	MRN                 string       `json:"mrn"`
	DisplayNameInitials string       `json:"display_name_initials"`
	MRNLast4            string       `json:"mrn_last4"`
	FullName            string       `json:"full_name"`
	DateOfBirth         string       `json:"date_of_birth"`
	Sex                 string       `json:"sex"`
	Procedure           string       `json:"procedure"`
	ASCID               string       `json:"asc_id"`
	CurrentMedications  []Medication `json:"current_medications"`
	Allergies           []Allergy    `json:"allergies"`
	Comorbidities       []string     `json:"comorbidities"`
}

// LoadPatients reads the seed JSON file at path and returns the parsed slice.
func LoadPatients(path string) ([]Patient, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading seed file %s: %w", path, err)
	}

	var patients []Patient
	dec := json.NewDecoder(bytesReader(b))
	dec.DisallowUnknownFields()
	if err := dec.Decode(&patients); err != nil {
		return nil, fmt.Errorf("decoding seed file %s: %w", path, err)
	}

	if len(patients) == 0 {
		return nil, fmt.Errorf("seed file %s contained zero patients", path)
	}

	for i, p := range patients {
		if p.PatientID == "" {
			return nil, fmt.Errorf("seed patient at index %d missing patient_id", i)
		}
	}
	return patients, nil
}
