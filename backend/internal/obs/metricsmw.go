package obs

import (
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

// MetricsMiddleware returns chi middleware that records HTTPRequestsTotal
// and HTTPRequestDuration for every request. The middleware MUST be
// mounted after chi's route-matching pass (i.e. as part of the standard
// `r.Use(...)` stack) so chi.RouteContext returns the matched pattern.
//
// Routes that do not match are labeled "unmatched" instead of the raw
// request path, because an unmatched path is unbounded (attackers will
// generate cardinality otherwise).
//
// The /metrics endpoint itself is excluded from instrumentation: it is
// scraped on a tight interval, would dominate the histogram, and is not
// part of the service's own SLO.
func MetricsMiddleware(serviceName string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Skip self-instrumentation of the scrape endpoint.
			if r.URL.Path == "/metrics" {
				next.ServeHTTP(w, r)
				return
			}

			start := time.Now()
			ww := middleware.NewWrapResponseWriter(w, r.ProtoMajor)
			next.ServeHTTP(ww, r)

			route := routeLabel(r)
			method := r.Method
			class := StatusClass(ww.Status())

			HTTPRequestsTotal.WithLabelValues(serviceName, route, method, class).Inc()
			HTTPRequestDuration.WithLabelValues(serviceName, route, method).Observe(time.Since(start).Seconds())
		})
	}
}

// routeLabel returns the chi route pattern (e.g. `/api/v1/sessions/{id}`)
// for the current request, falling back to "unmatched" when no route
// matched. This keeps cardinality bounded by the number of declared
// routes instead of the number of unique URLs the world sends us.
func routeLabel(r *http.Request) string {
	if rctx := chi.RouteContext(r.Context()); rctx != nil {
		if pat := rctx.RoutePattern(); pat != "" {
			// chi sometimes returns a wildcard pattern like
			// "/api/v1/*"; that is fine — still bounded.
			return strings.TrimSpace(pat)
		}
	}
	return "unmatched"
}
