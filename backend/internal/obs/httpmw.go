package obs

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5/middleware"

	"github.com/tonimnim/hst-scribe/backend/internal/auth"
)

// LoggingMiddleware emits one structured log line per request with
// method, path, status, duration, request_id, and (when authenticated)
// user_id + asc_id. Never logs request/response bodies — they may
// carry PHI.
func LoggingMiddleware(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			ww := middleware.NewWrapResponseWriter(w, r.ProtoMajor)
			ctx := ContextWithLogger(r.Context(), logger.With(
				slog.String("request_id", middleware.GetReqID(r.Context())),
			))

			next.ServeHTTP(ww, r.WithContext(ctx))

			attrs := []any{
				slog.String("method", r.Method),
				slog.String("path", r.URL.Path),
				slog.Int("status", ww.Status()),
				slog.Int64("duration_ms", time.Since(start).Milliseconds()),
				slog.Int("bytes", ww.BytesWritten()),
				slog.String("request_id", middleware.GetReqID(r.Context())),
			}
			if c := auth.ClaimsFromContext(r.Context()); c != nil {
				attrs = append(attrs,
					slog.String("user_id", c.UserID),
					slog.String("asc_id", c.ASCID),
				)
			}

			switch {
			case ww.Status() >= 500:
				logger.Error("request completed", attrs...)
			case ww.Status() >= 400:
				logger.Warn("request completed", attrs...)
			default:
				logger.Info("request completed", attrs...)
			}
		})
	}
}
