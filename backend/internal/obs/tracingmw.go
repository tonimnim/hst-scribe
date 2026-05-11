package obs

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

// TracingMiddleware returns chi middleware that extracts W3C trace
// context from incoming requests and starts a server span for each
// handler. The span name uses the chi route pattern (e.g.
// "GET /api/v1/sessions/{id}") to keep span cardinality at the route
// level — never the per-request URL — and to make the SLO dashboard
// usable.
//
// The /metrics scrape endpoint is excluded from tracing on purpose:
// it is high-frequency and would dilute service-level signals.
//
// Spans created by this middleware become the parent of any span
// created during the request, including outbound otelhttp client spans.
// That is how a gateway → session-manager request hop forms a single
// connected trace.
func TracingMiddleware(serviceName string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		// otelhttp.NewHandler does the heavy lifting: extract
		// traceparent, start span, record status, propagate ctx. We
		// wrap it so we can compute the chi route pattern as the span
		// name once chi has matched.
		instrumented := otelhttp.NewHandler(
			http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				// Attach chi route pattern as the span name and add
				// service.name as an attribute. We do this *after*
				// otelhttp has started the span so the span is in
				// flight.
				if span := trace.SpanFromContext(r.Context()); span.IsRecording() {
					if rctx := chi.RouteContext(r.Context()); rctx != nil {
						if pat := rctx.RoutePattern(); pat != "" {
							span.SetName(r.Method + " " + pat)
							span.SetAttributes(attribute.String("http.route", pat))
						}
					}
					span.SetAttributes(attribute.String("service.name", serviceName))
				}
				next.ServeHTTP(w, r)
			}),
			serviceName,
			otelhttp.WithSpanNameFormatter(func(_ string, r *http.Request) string {
				// Initial name before chi has matched; the inner
				// handler renames the span once the pattern is known.
				return r.Method + " " + r.URL.Path
			}),
		)

		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if r.URL.Path == "/metrics" || r.URL.Path == "/healthz" {
				next.ServeHTTP(w, r)
				return
			}
			instrumented.ServeHTTP(w, r)
		})
	}
}

// PHI-safe attribute helpers. Use these in code paths that want to
// annotate spans with HST Scribe identifiers without anyone ever
// accidentally adding a transcript or patient name as a span attribute.

// SpanAttrSessionID is the canonical attribute key for a session id on
// any HST Scribe span.
const SpanAttrSessionID = "hst.session_id"

// SpanAttrEventID is the canonical attribute key for an extracted
// event id.
const SpanAttrEventID = "hst.event_id"

// SpanAttrPatientID is the canonical attribute key for a patient id.
// Patient IDs are opaque UUIDs — never names, MRNs, or dates of birth.
const SpanAttrPatientID = "hst.patient_id"

// SpanAttrASCID is the canonical attribute key for an ASC tenant id.
const SpanAttrASCID = "hst.asc_id"

// SpanAttrEventType is the canonical attribute key for an extracted
// event's type enum (vital_sign, medication, ...).
const SpanAttrEventType = "hst.event_type"

// AnnotateSpan attaches HST Scribe identifiers to the active span in
// ctx. Empty values are skipped so callers can pass partial attribute
// sets without polluting the span. This helper is the *only* sanctioned
// way to attach HST-scoped identifiers to a span; any direct
// `span.SetAttributes("text", ...)` call will be rejected in review.
func AnnotateSpan(span trace.Span, attrs HSTSpanAttrs) {
	if span == nil || !span.IsRecording() {
		return
	}
	kvs := make([]attribute.KeyValue, 0, 5)
	if attrs.SessionID != "" {
		kvs = append(kvs, attribute.String(SpanAttrSessionID, attrs.SessionID))
	}
	if attrs.EventID != "" {
		kvs = append(kvs, attribute.String(SpanAttrEventID, attrs.EventID))
	}
	if attrs.PatientID != "" {
		kvs = append(kvs, attribute.String(SpanAttrPatientID, attrs.PatientID))
	}
	if attrs.ASCID != "" {
		kvs = append(kvs, attribute.String(SpanAttrASCID, attrs.ASCID))
	}
	if attrs.EventType != "" {
		kvs = append(kvs, attribute.String(SpanAttrEventType, attrs.EventType))
	}
	if len(kvs) > 0 {
		span.SetAttributes(kvs...)
	}
}

// HSTSpanAttrs bundles the HST-scoped identifier set in a single struct
// so callers cannot accidentally swap argument order on the AnnotateSpan
// call. Every field is an opaque identifier — none of them are PHI.
type HSTSpanAttrs struct {
	SessionID string
	EventID   string
	PatientID string
	ASCID     string
	EventType string
}
