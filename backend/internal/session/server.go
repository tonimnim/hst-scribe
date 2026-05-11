package session

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

// internalAuthHeader is the header carrying the shared inter-service
// token. The gateway forwards user JWTs but session-manager itself only
// trusts this token from peers inside the cluster.
const internalAuthHeader = "X-Internal-Token"

// Server wires the session.Service to chi HTTP handlers under
// /internal/v1/sessions. The gateway is the sole intended caller.
type Server struct {
	svc           *Service
	logger        *slog.Logger
	internalToken string
}

// NewServer builds a Server. internalToken is the value handlers require
// in the X-Internal-Token header; empty means auth is disabled (dev
// loopback only — production must set it).
func NewServer(svc *Service, logger *slog.Logger, internalToken string) (*Server, error) {
	if svc == nil {
		return nil, errors.New("session.NewServer: svc is nil")
	}
	if logger == nil {
		logger = slog.Default()
	}
	return &Server{
		svc:           svc,
		logger:        logger,
		internalToken: internalToken,
	}, nil
}

// Mount attaches handlers to r. /healthz lives at the root so platform
// probes don't need to know the internal path prefix.
func (s *Server) Mount(r chi.Router) {
	r.Get("/healthz", s.handleHealth)

	r.Route("/internal/v1/sessions", func(r chi.Router) {
		r.Use(s.internalAuth)
		r.Post("/", s.handleCreate)
		r.Get("/{id}", s.handleGet)
		r.Post("/{id}/end", s.handleEnd)
		r.Post("/{id}/sign", s.handleSign)
	})
}

func (s *Server) handleHealth(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{
		"status":  "ok",
		"service": "session-manager",
	})
}

// internalAuth enforces X-Internal-Token equality. Empty internalToken
// in the Server skips the check (dev only). The check is a constant-time
// string compare via subtle? Not needed here — the token is short and
// the timing leak is irrelevant inside the cluster, but if you need it
// later swap in crypto/subtle.ConstantTimeCompare.
func (s *Server) internalAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if s.internalToken == "" {
			next.ServeHTTP(w, r)
			return
		}
		got := r.Header.Get(internalAuthHeader)
		if got == "" || got != s.internalToken {
			httperr.WriteJSON(w, httperr.AuthInvalid("missing or invalid internal token"))
			return
		}
		next.ServeHTTP(w, r)
	})
}

// --- create ---

// createRequest is the inter-service body of POST /internal/v1/sessions.
// It mirrors contract.CreateSessionRequest plus user_id (which the
// gateway extracts from the user JWT before forwarding here).
type createRequest struct {
	ASCID        string       `json:"asc_id"`
	PatientID    string       `json:"patient_id"`
	UserID       string       `json:"user_id"`
	WorkflowType WorkflowType `json:"workflow_type"`
}

func (s *Server) handleCreate(w http.ResponseWriter, r *http.Request) {
	var req createRequest
	if err := decodeJSON(r.Body, &req); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest("invalid request body", map[string]any{
			"err": err.Error(),
		}))
		return
	}

	if err := validateUUIDs(map[string]string{
		"asc_id":     req.ASCID,
		"patient_id": req.PatientID,
		"user_id":    req.UserID,
	}); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest(err.Error(), nil))
		return
	}

	sess, err := s.svc.CreateSession(r.Context(), CreateSessionInput{
		ASCID:        req.ASCID,
		PatientID:    req.PatientID,
		UserID:       req.UserID,
		WorkflowType: req.WorkflowType,
	})
	if err != nil {
		var lockErr *PatientLockError
		if errors.As(err, &lockErr) {
			lockedID := ""
			if lockErr.Existing != nil {
				lockedID = lockErr.Existing.ID
			}
			httperr.WriteJSON(w, httperr.PatientLocked(req.PatientID, lockedID))
			return
		}
		s.logErr(r, "create session", err)
		httperr.WriteJSON(w, mapDomainErr(err))
		return
	}

	writeJSON(w, http.StatusCreated, sess)
}

// --- get ---

func (s *Server) handleGet(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if _, err := uuidv7.Parse(id); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest("invalid session id", nil))
		return
	}
	sess, err := s.svc.GetSession(r.Context(), id)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			httperr.WriteJSON(w, httperr.SessionNotFound(id))
			return
		}
		s.logErr(r, "get session", err)
		httperr.WriteJSON(w, httperr.Internal("get session failed"))
		return
	}
	writeJSON(w, http.StatusOK, sess)
}

// --- end ---

type endRequest struct {
	UserID string `json:"user_id"`
	Reason string `json:"reason"`
}

func (s *Server) handleEnd(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if _, err := uuidv7.Parse(id); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest("invalid session id", nil))
		return
	}
	var req endRequest
	if err := decodeJSON(r.Body, &req); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest("invalid request body", map[string]any{
			"err": err.Error(),
		}))
		return
	}
	if req.Reason == "" {
		req.Reason = "client_requested"
	}

	sess, err := s.svc.EndSession(r.Context(), id, req.UserID, req.Reason)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			httperr.WriteJSON(w, httperr.SessionNotFound(id))
			return
		}
		if errors.Is(err, ErrInvalidTransition) {
			httperr.WriteJSON(w, httperr.BadRequest("invalid state transition", map[string]any{
				"err": err.Error(),
			}))
			return
		}
		s.logErr(r, "end session", err)
		httperr.WriteJSON(w, httperr.Internal("end session failed"))
		return
	}
	writeJSON(w, http.StatusOK, sess)
}

// --- sign ---

type signRequest struct {
	UserID string `json:"user_id"`
}

func (s *Server) handleSign(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if _, err := uuidv7.Parse(id); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest("invalid session id", nil))
		return
	}
	var req signRequest
	if err := decodeJSON(r.Body, &req); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest("invalid request body", map[string]any{
			"err": err.Error(),
		}))
		return
	}
	if req.UserID == "" {
		httperr.WriteJSON(w, httperr.BadRequest("user_id is required", nil))
		return
	}
	if _, err := uuidv7.Parse(req.UserID); err != nil {
		httperr.WriteJSON(w, httperr.BadRequest("invalid user_id", nil))
		return
	}

	sess, err := s.svc.SignSession(r.Context(), id, req.UserID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			httperr.WriteJSON(w, httperr.SessionNotFound(id))
			return
		}
		if errors.Is(err, ErrInvalidTransition) {
			httperr.WriteJSON(w, httperr.BadRequest("invalid state transition", map[string]any{
				"err": err.Error(),
			}))
			return
		}
		s.logErr(r, "sign session", err)
		httperr.WriteJSON(w, httperr.Internal("sign session failed"))
		return
	}
	writeJSON(w, http.StatusOK, sess)
}

// --- helpers ---

func decodeJSON(body io.Reader, dst any) error {
	dec := json.NewDecoder(body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		return err
	}
	return nil
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

// validateUUIDs returns the first non-UUID field as a single error.
func validateUUIDs(m map[string]string) error {
	for name, val := range m {
		if val == "" {
			return errors.New(name + " is required")
		}
		if _, err := uuidv7.Parse(val); err != nil {
			return errors.New("invalid " + name)
		}
	}
	return nil
}

// mapDomainErr translates a domain error into the canonical wire shape.
// Patient lock is special-cased upstream because it carries the existing
// session id.
func mapDomainErr(err error) *httperr.Error {
	switch {
	case errors.Is(err, ErrNotFound):
		return httperr.SessionNotFound("")
	case errors.Is(err, ErrInvalidTransition):
		return httperr.BadRequest(err.Error(), nil)
	}
	// Validation errors raised by Service have lowercase first-word
	// messages we can pass through safely.
	msg := err.Error()
	if strings.Contains(msg, "is required") || strings.Contains(msg, "invalid workflow_type") {
		return httperr.BadRequest(msg, nil)
	}
	return httperr.Internal("internal error")
}

// logErr logs at error level with request context but no PHI. The body
// of failing requests is not logged (it might contain ids the operator
// shouldn't see in plaintext logs).
func (s *Server) logErr(r *http.Request, op string, err error) {
	obs.LoggerFromContext(r.Context()).Error(op+" failed",
		slog.String("path", r.URL.Path),
		slog.String("err", err.Error()),
	)
}
