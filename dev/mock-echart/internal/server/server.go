// Package server wires HTTP routes for the mock-echart service.
//
// Routes (see contract/CONTRACT.md):
//
//   GET  /healthz
//   GET  /api/echart/v1/patients/{patient_id}/context
//   POST /api/echart/v1/charts/{patient_id}/draft-events
//   POST /api/echart/v1/charts/{patient_id}/sign-session
//   GET  /api/echart/v1/vocabularies/rxnorm/{code}
package server

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/google/uuid"

	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/httperr"
	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/seed"
	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/store"
	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/vocab"
)

// Clock returns the current time. Injected so tests can pin timestamps.
type Clock func() time.Time

// IDGen returns a fresh UUIDv7 string. Injected so tests can pin ids.
type IDGen func() (string, error)

// Server bundles handler dependencies. Construct via New.
type Server struct {
	patients map[string]seed.Patient // keyed by patient_id
	store    *store.Store
	logger   *slog.Logger
	clock    Clock
	idGen    IDGen
}

// New builds a Server from already-loaded seed data.
//
// logger MUST be non-nil. clock and idGen may be nil; production defaults
// (time.Now, UUIDv7) are wired automatically.
func New(patients []seed.Patient, st *store.Store, logger *slog.Logger, clock Clock, idGen IDGen) *Server {
	if clock == nil {
		clock = time.Now
	}
	if idGen == nil {
		idGen = func() (string, error) {
			id, err := uuid.NewV7()
			if err != nil {
				return "", err
			}
			return id.String(), nil
		}
	}
	idx := make(map[string]seed.Patient, len(patients))
	for _, p := range patients {
		idx[p.PatientID] = p
	}
	return &Server{
		patients: idx,
		store:    st,
		logger:   logger,
		clock:    clock,
		idGen:    idGen,
	}
}

// Router returns the configured chi router.
func (s *Server) Router() http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.Recoverer)
	r.Use(s.requestLogger)

	r.Get("/healthz", s.handleHealth)

	r.Route("/api/echart/v1", func(r chi.Router) {
		r.Get("/patients/{patient_id}/context", s.handleGetPatientContext)
		r.Post("/charts/{patient_id}/draft-events", s.handlePostDraftEvent)
		r.Post("/charts/{patient_id}/sign-session", s.handleSignSession)
		r.Get("/vocabularies/rxnorm/{code}", s.handleGetRxNorm)
	})

	return r
}

// requestLogger writes a structured log line per request.
// PHI rule: only patient_id is logged. URL path is logged as-is because the
// only identifier it contains is the patient_id (already permitted).
func (s *Server) requestLogger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := s.clock()
		ww := middleware.NewWrapResponseWriter(w, r.ProtoMajor)
		next.ServeHTTP(ww, r)
		s.logger.Info("request",
			"method", r.Method,
			"path", r.URL.Path,
			"status", ww.Status(),
			"bytes", ww.BytesWritten(),
			"duration_ms", time.Since(start).Milliseconds(),
			"request_id", middleware.GetReqID(r.Context()),
		)
	})
}

// --- /healthz -----------------------------------------------------------

func (s *Server) handleHealth(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

// --- GET /patients/{patient_id}/context ---------------------------------

// patientContextResponse is the contract-safe projection of a Patient.
// Fields excluded by design: full_name, mrn, date_of_birth, sex, asc_id.
type patientContextResponse struct {
	PatientID           string            `json:"patient_id"`
	DisplayNameInitials string            `json:"display_name_initials"`
	MRNLast4            string            `json:"mrn_last4"`
	Procedure           string            `json:"procedure"`
	CurrentMedications  []seed.Medication `json:"current_medications"`
	Allergies           []seed.Allergy    `json:"allergies"`
	Comorbidities       []string          `json:"comorbidities"`
}

func (s *Server) handleGetPatientContext(w http.ResponseWriter, r *http.Request) {
	patientID := chi.URLParam(r, "patient_id")

	p, ok := s.patients[patientID]
	if !ok {
		s.logger.Warn("patient not found", "patient_id", patientID)
		httperr.Write(w, http.StatusNotFound,
			"patient_not_found",
			"no patient with that id is loaded in the mock eChart",
			map[string]any{"patient_id": patientID},
		)
		return
	}

	// Make sure list fields are never nil on the wire.
	meds := p.CurrentMedications
	if meds == nil {
		meds = []seed.Medication{}
	}
	allergies := p.Allergies
	if allergies == nil {
		allergies = []seed.Allergy{}
	}
	comorbidities := p.Comorbidities
	if comorbidities == nil {
		comorbidities = []string{}
	}

	writeJSON(w, http.StatusOK, patientContextResponse{
		PatientID:           p.PatientID,
		DisplayNameInitials: p.DisplayNameInitials,
		MRNLast4:            p.MRNLast4,
		Procedure:           p.Procedure,
		CurrentMedications:  meds,
		Allergies:           allergies,
		Comorbidities:       comorbidities,
	})
}

// --- POST /charts/{patient_id}/draft-events -----------------------------

type draftEventRequest struct {
	EventType       string         `json:"event_type"`
	Fields          map[string]any `json:"fields"`
	Confidence      float64        `json:"confidence"`
	SourceUtterance string         `json:"source_utterance"`
	ExtractedAt     time.Time      `json:"extracted_at"`
}

type draftEventResponse struct {
	ChartEntryID string    `json:"chart_entry_id"`
	Status       string    `json:"status"`
	CreatedAt    time.Time `json:"created_at"`
}

func (s *Server) handlePostDraftEvent(w http.ResponseWriter, r *http.Request) {
	patientID := chi.URLParam(r, "patient_id")
	if _, ok := s.patients[patientID]; !ok {
		httperr.Write(w, http.StatusNotFound,
			"patient_not_found",
			"no patient with that id is loaded in the mock eChart",
			map[string]any{"patient_id": patientID},
		)
		return
	}

	var req draftEventRequest
	if err := decodeStrict(r, &req); err != nil {
		httperr.Write(w, http.StatusBadRequest,
			"invalid_request",
			err.Error(),
			nil,
		)
		return
	}
	if req.EventType == "" {
		httperr.Write(w, http.StatusBadRequest,
			"invalid_request",
			"event_type is required",
			nil,
		)
		return
	}

	id, err := s.idGen()
	if err != nil {
		s.logger.Error("uuid generation failed", "err", err, "patient_id", patientID)
		httperr.Write(w, http.StatusInternalServerError,
			"internal",
			"could not generate chart_entry_id",
			nil,
		)
		return
	}
	now := s.clock().UTC()

	entry := s.store.AddDraft(store.Entry{
		ChartEntryID:    id,
		PatientID:       patientID,
		EventType:       req.EventType,
		Fields:          req.Fields,
		Confidence:      req.Confidence,
		SourceUtterance: req.SourceUtterance,
		ExtractedAt:     req.ExtractedAt,
		CreatedAt:       now,
	})

	s.logger.Info("draft event stored",
		"patient_id", patientID,
		"chart_entry_id", entry.ChartEntryID,
		"event_type", entry.EventType,
	)

	writeJSON(w, http.StatusCreated, draftEventResponse{
		ChartEntryID: entry.ChartEntryID,
		Status:       string(entry.Status),
		CreatedAt:    entry.CreatedAt,
	})
}

// --- POST /charts/{patient_id}/sign-session -----------------------------

type signSessionRequest struct {
	SessionID string   `json:"session_id"`
	EventIDs  []string `json:"event_ids"`
}

type signSessionResponse struct {
	EventsWritten  int       `json:"events_written"`
	EventsRejected int       `json:"events_rejected"`
	SignedAt       time.Time `json:"signed_at"`
}

func (s *Server) handleSignSession(w http.ResponseWriter, r *http.Request) {
	patientID := chi.URLParam(r, "patient_id")
	if _, ok := s.patients[patientID]; !ok {
		httperr.Write(w, http.StatusNotFound,
			"patient_not_found",
			"no patient with that id is loaded in the mock eChart",
			map[string]any{"patient_id": patientID},
		)
		return
	}

	var req signSessionRequest
	if err := decodeStrict(r, &req); err != nil {
		httperr.Write(w, http.StatusBadRequest,
			"invalid_request",
			err.Error(),
			nil,
		)
		return
	}
	if req.SessionID == "" {
		httperr.Write(w, http.StatusBadRequest,
			"invalid_request",
			"session_id is required",
			nil,
		)
		return
	}

	signedAt := s.clock().UTC()
	result := s.store.PromoteToFinal(patientID, req.EventIDs, signedAt)

	s.logger.Info("session signed",
		"patient_id", patientID,
		"session_id", req.SessionID,
		"events_written", result.Written,
		"events_rejected", result.Rejected,
	)

	writeJSON(w, http.StatusOK, signSessionResponse{
		EventsWritten:  result.Written,
		EventsRejected: result.Rejected,
		SignedAt:       signedAt,
	})
}

// --- GET /vocabularies/rxnorm/{code} ------------------------------------

func (s *Server) handleGetRxNorm(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")
	entry, ok := vocab.Lookup(code)
	if !ok {
		httperr.Write(w, http.StatusNotFound,
			"rxnorm_not_found",
			"code is not in the bundled mock vocabulary",
			map[string]any{"rxnorm_code": code},
		)
		return
	}
	writeJSON(w, http.StatusOK, entry)
}

// --- helpers ------------------------------------------------------------

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(body); err != nil {
		slog.Error("encoding response body", "err", err)
	}
}

// decodeStrict reads JSON from r.Body into dst with DisallowUnknownFields
// and a "no trailing data" check. Returns a wrapped error suitable for
// surfacing to the client as message text.
func decodeStrict(r *http.Request, dst any) error {
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		return errors.New("invalid JSON body: " + err.Error())
	}
	if dec.More() {
		return errors.New("invalid JSON body: trailing data after object")
	}
	return nil
}
