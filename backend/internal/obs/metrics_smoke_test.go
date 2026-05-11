package obs

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"
)

// TestMetricsEndpointSmoke is a smoke test verifying that the metrics
// middleware records traffic and that MountMetrics surfaces it in
// Prometheus exposition format. It is intentionally tolerant — only
// asserts presence of the canonical metric names and that the route
// pattern (not the raw path) shows up in labels.
func TestMetricsEndpointSmoke(t *testing.T) {
	r := chi.NewRouter()
	r.Use(chimw.RequestID)
	r.Use(MetricsMiddleware("gateway"))
	MountMetrics(r)
	r.Get("/api/v1/sessions/{id}", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	srv := httptest.NewServer(r)
	defer srv.Close()

	for i := 0; i < 3; i++ {
		resp, err := http.Get(srv.URL + "/api/v1/sessions/abc-123")
		if err != nil {
			t.Fatalf("client get: %v", err)
		}
		_, _ = io.Copy(io.Discard, resp.Body)
		_ = resp.Body.Close()
	}

	resp, err := http.Get(srv.URL + "/metrics")
	if err != nil {
		t.Fatalf("metrics get: %v", err)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("read metrics: %v", err)
	}
	_ = resp.Body.Close()
	text := string(body)

	for _, want := range []string{
		"hst_scribe_http_requests_total",
		"hst_scribe_http_request_duration_seconds",
		`route="/api/v1/sessions/{id}"`,
		`status_class="2xx"`,
		`service="gateway"`,
	} {
		if !strings.Contains(text, want) {
			t.Errorf("metrics output missing %q\n----\n%s", want, text)
		}
	}
}
