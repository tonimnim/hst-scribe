package obs

import (
	"github.com/go-chi/chi/v5"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// MountMetrics mounts the Prometheus scrape endpoint at GET /metrics on
// the given router. The endpoint is intentionally unauthenticated: the
// Prometheus server reaches it over the cluster network only, and the
// payload exposes no PHI (metric label rules in metrics.go enforce
// that).
//
// Mount this at the top-level router, before any sub-router-scoped auth
// middleware applies, so a scraper does not need a JWT to read metrics.
func MountMetrics(r chi.Router) {
	r.Method("GET", "/metrics", promhttp.Handler())
}
