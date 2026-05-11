package contract

import (
	"encoding/json"
	"fmt"
	"time"
)

// EventType is the kind of clinical event extracted from a transcript.
type EventType string

// EventType values matching contract/schemas/event-schema.json.
const (
	EventTypeVitalSign              EventType = "vital_sign"
	EventTypeMedicationAdministered EventType = "medication_administered"
	EventTypeDispo                  EventType = "dispo"
	EventTypeNote                   EventType = "note"
)

// ExtractedEvent is the canonical extractor output, matching
// contract/schemas/event-schema.json. Fields is held as json.RawMessage
// so the type-specific decode happens via DecodeEventFields.
type ExtractedEvent struct {
	EventID             string          `json:"event_id"`
	EventType           EventType       `json:"event_type"`
	Fields              json.RawMessage `json:"fields"`
	Confidence          float64         `json:"confidence"`
	SourceUtterance     string          `json:"source_utterance"`
	SourceTranscriptIDs []string        `json:"source_transcript_ids"`
	ExtractedAt         time.Time       `json:"extracted_at"`
	EventTime           time.Time       `json:"event_time"`
}

// --- Per-event fields ---

// VitalType enumerates the vital_sign discriminator values.
type VitalType string

// VitalType values matching contract/CONTRACT.md §3.
const (
	VitalBPSystolic   VitalType = "blood_pressure_systolic"
	VitalBPDiastolic  VitalType = "blood_pressure_diastolic"
	VitalHeartRate    VitalType = "heart_rate"
	VitalSpO2         VitalType = "spo2"
	VitalRespRate     VitalType = "respiratory_rate"
	VitalTemperatureC VitalType = "temperature_c"
	VitalTemperatureF VitalType = "temperature_f"
	VitalPainScore    VitalType = "pain_score"
)

// VitalSignFields are the typed fields for an EventTypeVitalSign event.
type VitalSignFields struct {
	VitalType VitalType `json:"vital_type"`
	Value     float64   `json:"value"`
	Unit      string    `json:"unit"`
}

// MedicationRoute enumerates the medication route values.
type MedicationRoute string

// MedicationRoute values matching contract/CONTRACT.md §3.
const (
	RouteIV           MedicationRoute = "iv"
	RouteIM           MedicationRoute = "im"
	RoutePO           MedicationRoute = "po"
	RouteSublingual   MedicationRoute = "sublingual"
	RouteTopical      MedicationRoute = "topical"
	RouteInhaled      MedicationRoute = "inhaled"
	RouteIntranasal   MedicationRoute = "intranasal"
	RouteRectal       MedicationRoute = "rectal"
	RouteSubcutaneous MedicationRoute = "subcutaneous"
)

// DoseUnit enumerates the dose_unit values.
type DoseUnit string

// DoseUnit values matching contract/CONTRACT.md §3.
const (
	DoseMg   DoseUnit = "mg"
	DoseMcg  DoseUnit = "mcg"
	DoseG    DoseUnit = "g"
	DoseML   DoseUnit = "ml"
	DoseEach DoseUnit = "unit"
)

// MedicationAdministeredFields are the typed fields for a medication event.
type MedicationAdministeredFields struct {
	MedicationName string          `json:"medication_name"`
	RxNormCode     string          `json:"rxnorm_code"`
	DoseValue      float64         `json:"dose_value"`
	DoseUnit       DoseUnit        `json:"dose_unit"`
	Route          MedicationRoute `json:"route"`
	Indication     string          `json:"indication,omitempty"`
}

// DispositionType enumerates the disposition_type values.
type DispositionType string

// DispositionType values matching contract/CONTRACT.md §3.
const (
	DispoDischargeHome      DispositionType = "discharge_home"
	DispoTransferToHospital DispositionType = "transfer_to_hospital"
	DispoAdmitObservation   DispositionType = "admit_observation"
	DispoTransferToFloor    DispositionType = "transfer_to_floor"
)

// DispoFields are the typed fields for a disposition event.
type DispoFields struct {
	DispositionType      DispositionType `json:"disposition_type"`
	DischargeCriteriaMet bool            `json:"discharge_criteria_met,omitempty"`
	Notes                string          `json:"notes,omitempty"`
}

// NoteFields are the typed fields for a free-text note event.
type NoteFields struct {
	NoteText string   `json:"note_text"`
	Tags     []string `json:"tags,omitempty"`
}

// DecodeEventFields decodes e.Fields into the typed struct for its
// EventType. Callers receive an any whose concrete type is one of
// VitalSignFields, MedicationAdministeredFields, DispoFields, NoteFields.
func DecodeEventFields(e *ExtractedEvent) (any, error) {
	switch e.EventType {
	case EventTypeVitalSign:
		var f VitalSignFields
		if err := json.Unmarshal(e.Fields, &f); err != nil {
			return nil, fmt.Errorf("decoding vital_sign fields: %w", err)
		}
		return f, nil
	case EventTypeMedicationAdministered:
		var f MedicationAdministeredFields
		if err := json.Unmarshal(e.Fields, &f); err != nil {
			return nil, fmt.Errorf("decoding medication fields: %w", err)
		}
		return f, nil
	case EventTypeDispo:
		var f DispoFields
		if err := json.Unmarshal(e.Fields, &f); err != nil {
			return nil, fmt.Errorf("decoding dispo fields: %w", err)
		}
		return f, nil
	case EventTypeNote:
		var f NoteFields
		if err := json.Unmarshal(e.Fields, &f); err != nil {
			return nil, fmt.Errorf("decoding note fields: %w", err)
		}
		return f, nil
	default:
		return nil, fmt.Errorf("unknown event_type %q", e.EventType)
	}
}
