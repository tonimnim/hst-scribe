package auth

import (
	"errors"
	"net/http"

	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
)

// Authenticator is HTTP middleware that requires a valid bearer token.
// Validated claims are stuffed into the request context via
// ContextWithClaims. Unauthenticated requests get a 401 with the
// canonical wire-error body.
func Authenticator(v Validator) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			claims, err := v.Validate(r.Context(), r.Header.Get("Authorization"))
			if err != nil {
				var werr *httperr.Error
				if errors.As(err, &werr) {
					httperr.WriteJSON(w, werr)
					return
				}
				httperr.WriteJSON(w, httperr.AuthInvalid(""))
				return
			}
			next.ServeHTTP(w, r.WithContext(ContextWithClaims(r.Context(), claims)))
		})
	}
}
