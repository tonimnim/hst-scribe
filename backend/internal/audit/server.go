package audit

import (
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/tonimnim/hst-scribe/backend/internal/auth"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
)

// Pagination defaults / caps for ListByUser. Kept here (not on Repository)
// because they describe HTTP-layer policy, not storage capability.
const (
	defaultLimit = 100
	maxLimit     = 500
)

// Compliance roles permitted to query the audit log. The skeleton check
// matches against auth.Claims.Role — Phase B may swap to a scope list.
var allowedRoles = map[auth.Role]struct{}{
	auth.Role("compliance"): {},
	auth.RoleAdmin:          {},
}

// Server bundles the HTTP handlers for the audit query API.
type Server struct {
	repo      Repository
	validator auth.Validator
	logger    *slog.Logger
}

// NewServer constructs a Server. The caller owns the repo, validator,
// and logger.
func NewServer(repo Repository, v auth.Validator, logger *slog.Logger) *Server {
	return &Server{repo: repo, validator: v, logger: logger}
}

// Routes returns an http.Handler with all audit routes mounted. The
// caller can wrap this with cross-cutting middleware (logging, recover,
// request-id) before serving.
func (s *Server) Routes() http.Handler {
	r := chi.NewRouter()

	r.Get("/healthz", healthHandler)

	r.Route("/api/v1/audit", func(r chi.Router) {
		r.Use(auth.Authenticator(s.validator))
		r.Use(requireComplianceRole)
		r.Get("/sessions/{session_id}", s.listBySession)
		r.Get("/users/{user_id}", s.listByUser)
	})

	return r
}

// listResponse is the JSON wire shape for both list endpoints.
type listResponse struct {
	Events     []Event `json:"events"`
	NextCursor string  `json:"next_cursor,omitempty"`
}

func (s *Server) listBySession(w http.ResponseWriter, r *http.Request) {
	sessionID := chi.URLParam(r, "session_id")
	if sessionID == "" {
		httperr.WriteJSON(w, httperr.BadRequest("session_id required", nil))
		return
	}

	events, err := s.repo.ListBySession(r.Context(), sessionID)
	if err != nil {
		s.writeError(r, w, "ListBySession", err)
		return
	}
	writeJSON(w, http.StatusOK, listResponse{Events: events})
}

func (s *Server) listByUser(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "user_id")
	if userID == "" {
		httperr.WriteJSON(w, httperr.BadRequest("user_id required", nil))
		return
	}

	q, werr := parseUserQuery(r, userID)
	if werr != nil {
		httperr.WriteJSON(w, werr)
		return
	}

	events, nextCursor, err := s.repo.ListByUser(r.Context(), q)
	if err != nil {
		s.writeError(r, w, "ListByUser", err)
		return
	}

	if nextCursor != "" {
		// RFC5988 Link header. Mobile/web clients can follow rel="next"
		// transparently; the JSON body also carries the cursor.
		nextURL := buildNextURL(r, nextCursor)
		w.Header().Set("Link", fmt.Sprintf(`<%s>; rel="next"`, nextURL))
	}
	writeJSON(w, http.StatusOK, listResponse{Events: events, NextCursor: nextCursor})
}

// parseUserQuery extracts the from/to/limit/cursor params and validates.
func parseUserQuery(r *http.Request, userID string) (UserQuery, *httperr.Error) {
	qs := r.URL.Query()

	fromStr := qs.Get("from")
	toStr := qs.Get("to")
	if fromStr == "" || toStr == "" {
		return UserQuery{}, httperr.BadRequest("from and to are required (RFC3339)", nil)
	}
	from, err := time.Parse(time.RFC3339, fromStr)
	if err != nil {
		return UserQuery{}, httperr.BadRequest("invalid 'from' (RFC3339)", map[string]any{"err": err.Error()})
	}
	to, err := time.Parse(time.RFC3339, toStr)
	if err != nil {
		return UserQuery{}, httperr.BadRequest("invalid 'to' (RFC3339)", map[string]any{"err": err.Error()})
	}
	if !to.After(from) {
		return UserQuery{}, httperr.BadRequest("'to' must be after 'from'", nil)
	}

	limit := defaultLimit
	if s := qs.Get("limit"); s != "" {
		n, err := strconv.Atoi(s)
		if err != nil || n <= 0 {
			return UserQuery{}, httperr.BadRequest("invalid 'limit'", nil)
		}
		if n > maxLimit {
			n = maxLimit
		}
		limit = n
	}

	return UserQuery{
		ActorUserID: userID,
		From:        from,
		To:          to,
		Limit:       limit,
		Cursor:      qs.Get("cursor"),
	}, nil
}

// buildNextURL replicates the inbound URL with the cursor param swapped.
// Existing query params (from, to, limit) are preserved.
func buildNextURL(r *http.Request, cursor string) string {
	u := *r.URL
	q := u.Query()
	q.Set("cursor", cursor)
	u.RawQuery = q.Encode()
	// Use the request URI as the path so the Link is self-relative; the
	// host is omitted on purpose — proxies may rewrite it.
	return u.RequestURI()
}

// writeError maps a Repository error into the canonical wire shape.
func (s *Server) writeError(r *http.Request, w http.ResponseWriter, op string, err error) {
	logger := obs.LoggerFromContext(r.Context())
	switch {
	case errors.Is(err, ErrInvalidEvent):
		httperr.WriteJSON(w, httperr.BadRequest(err.Error(), nil))
	case errors.Is(err, ErrInvalidCursor):
		httperr.WriteJSON(w, httperr.BadRequest("invalid cursor", nil))
	default:
		logger.Error("audit handler failed",
			slog.String("op", op),
			slog.String("err", err.Error()),
		)
		httperr.WriteJSON(w, httperr.Internal("audit query failed"))
	}
}

// requireComplianceRole gates the audit API on a compliance/admin role.
// Phase B may swap to a scope check; today we trust the JWT claim.
func requireComplianceRole(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		c := auth.ClaimsFromContext(r.Context())
		if c == nil {
			httperr.WriteJSON(w, httperr.AuthInvalid(""))
			return
		}
		if _, ok := allowedRoles[c.Role]; !ok {
			httperr.WriteJSON(w, httperr.AuthForbidden("role not permitted to access audit log"))
			return
		}
		next.ServeHTTP(w, r)
	})
}

// healthHandler is the unauthenticated liveness probe.
func healthHandler(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok", "service": "audit"})
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
