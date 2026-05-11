// Package contract contains Go types matching the JSON shapes defined in
// contract/CONTRACT.md and contract/schemas/. These types are the
// authoritative wire representation — anything serialized to mobile or
// to eChart goes through this package.
//
// Rules:
//   - snake_case JSON tags.
//   - RFC3339 timestamps with timezone (time.Time, RFC3339 default).
//   - UUIDv7 IDs as strings.
//   - Pointer or omitempty on optional fields.
//
// A typed decoder for the WSS envelope lives in wss_decode.go.
package contract

import "time"

// ProtocolVersion is the version advertised in session_started.
const ProtocolVersion = "v1"

// --- REST: POST /sessions ---

// WorkflowType is the captured-clinical-context flavor.
type WorkflowType string

// WorkflowType values matching contract/CONTRACT.md §1.
const (
	WorkflowPACU    WorkflowType = "pacu"
	WorkflowPreop   WorkflowType = "preop"
	WorkflowIntraop WorkflowType = "intraop"
)

// CreateSessionRequest is the body of POST /api/v1/sessions.
type CreateSessionRequest struct {
	PatientID    string       `json:"patient_id"`
	WorkflowType WorkflowType `json:"workflow_type"`
	ASCID        string       `json:"asc_id"`
}

// PatientContext is the snapshot of patient state at session start. The
// only patient identifiers that leak to the client are display_name_initials
// and mrn_last4 — full name/MRN must never appear here.
type PatientContext struct {
	PatientID           string       `json:"patient_id"`
	DisplayNameInitials string       `json:"display_name_initials"`
	MRNLast4            string       `json:"mrn_last4"`
	Procedure           string       `json:"procedure"`
	CurrentMedications  []Medication `json:"current_medications"`
	Allergies           []Allergy    `json:"allergies"`
	Comorbidities       []string     `json:"comorbidities"`
}

// Medication is a structured medication reference. Used in patient
// context and as part of extracted medication events.
type Medication struct {
	RxNormCode string `json:"rxnorm_code"`
	Name       string `json:"name"`
	Dose       string `json:"dose,omitempty"`
	Route      string `json:"route,omitempty"`
}

// Allergy is a structured allergy reference.
type Allergy struct {
	Name     string `json:"name"`
	Severity string `json:"severity,omitempty"`
}

// CreateSessionResponse is the 201 body of POST /api/v1/sessions.
type CreateSessionResponse struct {
	SessionID      string         `json:"session_id"`
	WSSURL         string         `json:"wss_url"`
	PatientContext PatientContext `json:"patient_context"`
	StartedAt      time.Time      `json:"started_at"`
	ExpiresAt      time.Time      `json:"expires_at"`
}

// --- REST: event mutation ---

// EditEventRequest is the body of PATCH /sessions/{id}/events/{event_id}.
type EditEventRequest struct {
	Fields map[string]any `json:"fields"`
}

// EditEventResponse is the body returned on a successful edit.
type EditEventResponse struct {
	EventID string         `json:"event_id"`
	Status  EventStatus    `json:"status"`
	Fields  map[string]any `json:"fields"`
}

// EventStatusResponse is shared by confirm/reject endpoints.
type EventStatusResponse struct {
	EventID string      `json:"event_id"`
	Status  EventStatus `json:"status"`
}

// EventStatus matches the WSS event_ack status enum.
type EventStatus string

// EventStatus values matching contract/CONTRACT.md §2.
const (
	EventStatusConfirmed   EventStatus = "confirmed"
	EventStatusRejected    EventStatus = "rejected"
	EventStatusDraftEdited EventStatus = "draft_edited"
)

// --- REST: session sign ---

// SignAuthMethod identifies how the nurse authenticated the sign step.
type SignAuthMethod string

// SignAuthMethod values matching contract/CONTRACT.md §1.
const (
	SignAuthBiometric SignAuthMethod = "biometric"
	SignAuthPIN       SignAuthMethod = "pin"
)

// SignSessionRequest is the body of POST /sessions/{id}/sign.
type SignSessionRequest struct {
	AuthMethod SignAuthMethod `json:"auth_method"`
	AuthToken  string         `json:"auth_token"`
}

// SignSessionResponse is the response body of a successful sign.
type SignSessionResponse struct {
	SessionID      string    `json:"session_id"`
	Status         string    `json:"status"`
	SignedAt       time.Time `json:"signed_at"`
	EventsWritten  int       `json:"events_written"`
	EventsRejected int       `json:"events_rejected"`
}

// --- Auth ---

// RefreshRequest is the body of POST /auth/refresh.
type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

// RefreshResponse is the body returned by /auth/refresh.
type RefreshResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int    `json:"expires_in"`
	TokenType    string `json:"token_type"`
}
