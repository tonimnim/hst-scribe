package httperr

import (
	"log/slog"
	"net/http"
	"runtime/debug"
)

// Recoverer is a panic-trapping middleware that writes a wire-shaped
// 500 response. Replacement for chi's default Recoverer so we keep
// control over the body shape.
func Recoverer(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if rec := recover(); rec != nil {
					logger.Error("panic recovered",
						slog.Any("panic", rec),
						slog.String("path", r.URL.Path),
						slog.String("stack", string(debug.Stack())),
					)
					WriteJSON(w, Internal("panic recovered"))
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}
