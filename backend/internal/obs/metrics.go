package obs

// This file holds the Prometheus metric registry for HST Scribe.
//
// Every metric is prefixed `hst_scribe_`. Label cardinality is kept low
// on purpose: per-route + status-class for HTTP, subject *patterns* (not
// individual session-scoped subjects) for NATS, and a coarse target tag
// for external calls. Anything that could explode (session_id,
// patient_id, request_id) belongs in traces or logs, never in metric
// labels.
//
// All vectors are exported as package-level variables so callers can do
// `obs.HTTPRequestsTotal.WithLabelValues(...).Inc()` without coordinating
// through a constructor. promauto registers them into the default
// Prometheus registry at package init — that is intentional: metrics are
// a process-wide concern and there is exactly one /metrics surface per
// service.
//
// PHI safety: no metric label may ever carry transcript text, utterance
// content, drug names, MRN, patient name, or any other free-text value.
// Reviewers should reject any new label whose value space is unbounded
// or PHI-adjacent.

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

// metricNamespace is the prefix applied to every HST Scribe metric.
const metricNamespace = "hst_scribe"

// HTTPRequestsTotal counts inbound HTTP requests. Labeled with the
// service emitting the metric, the chi route pattern (low cardinality —
// `/sessions/{id}` not `/sessions/01931d80-...`), the HTTP method, and a
// coarse status class (2xx|4xx|5xx|other).
var HTTPRequestsTotal = promauto.NewCounterVec(
	prometheus.CounterOpts{
		Namespace: metricNamespace,
		Name:      "http_requests_total",
		Help:      "Count of HTTP requests handled, labeled by route, method, and status class.",
	},
	[]string{"service", "route", "method", "status_class"},
)

// HTTPRequestDuration measures handler latency in seconds. Uses the
// default Prometheus buckets, which span typical web-service latencies
// (5ms..10s). Route label uses chi's matched pattern; unmatched
// requests fall back to "unmatched".
var HTTPRequestDuration = promauto.NewHistogramVec(
	prometheus.HistogramOpts{
		Namespace: metricNamespace,
		Name:      "http_request_duration_seconds",
		Help:      "Latency of HTTP handlers in seconds, labeled by route and method.",
		Buckets:   prometheus.DefBuckets,
	},
	[]string{"service", "route", "method"},
)

// NATSPublishTotal counts NATS publishes. `subject_pattern` MUST be a
// bounded pattern such as `audio.chunks.*` — never the materialized
// per-session subject — so cardinality stays constant. `status` is
// `ok|error`.
var NATSPublishTotal = promauto.NewCounterVec(
	prometheus.CounterOpts{
		Namespace: metricNamespace,
		Name:      "nats_publish_total",
		Help:      "Count of NATS publishes, labeled by subject pattern and outcome.",
	},
	[]string{"service", "subject_pattern", "status"},
)

// NATSConsumeTotal counts NATS message deliveries handled by a consumer.
// `ack_status` is one of `ack|nak|term|error` so an operator can chart
// retry rates and poison messages.
var NATSConsumeTotal = promauto.NewCounterVec(
	prometheus.CounterOpts{
		Namespace: metricNamespace,
		Name:      "nats_consume_total",
		Help:      "Count of NATS messages consumed, labeled by subject pattern and ack outcome.",
	},
	[]string{"service", "subject_pattern", "ack_status"},
)

// WSSConnectionsActive tracks the current count of open WebSocket
// sessions per service. The gateway is the only writer today; the gauge
// is exposed everywhere so dashboards do not have to special-case it.
var WSSConnectionsActive = promauto.NewGaugeVec(
	prometheus.GaugeOpts{
		Namespace: metricNamespace,
		Name:      "wss_connections_active",
		Help:      "Gauge of currently open WebSocket sessions per service.",
	},
	[]string{"service"},
)

// ExternalCallTotal counts outbound HTTP calls to a named target (e.g.
// `session_manager`, `echart`, `bedrock`). Status class is the coarse
// `2xx|4xx|5xx|other` bucket; transport errors map to `error`.
var ExternalCallTotal = promauto.NewCounterVec(
	prometheus.CounterOpts{
		Namespace: metricNamespace,
		Name:      "external_call_total",
		Help:      "Count of outbound calls to external services, labeled by target and status class.",
	},
	[]string{"service", "target", "status_class"},
)

// ExternalCallDuration measures outbound-call latency. The `target`
// label is operator-named (not the full URL) to keep cardinality bounded
// across regions, paths, and tenants.
var ExternalCallDuration = promauto.NewHistogramVec(
	prometheus.HistogramOpts{
		Namespace: metricNamespace,
		Name:      "external_call_duration_seconds",
		Help:      "Latency of outbound calls to external services in seconds, labeled by target.",
		Buckets:   prometheus.DefBuckets,
	},
	[]string{"service", "target"},
)

// ExtractionEventsTotal counts extracted clinical events. `event_type`
// is the discrete enum from the contract (vital_sign, medication,
// disposition, ...) — bounded by definition. `confidence_band` buckets
// the per-event confidence into low|medium|high so dashboards can
// chart the model's calibration without surfacing raw scores.
var ExtractionEventsTotal = promauto.NewCounterVec(
	prometheus.CounterOpts{
		Namespace: metricNamespace,
		Name:      "extraction_events_total",
		Help:      "Count of extracted clinical events, labeled by event type and confidence band.",
	},
	[]string{"event_type", "confidence_band"},
)

// StatusClass returns the coarse 2xx|4xx|5xx|other bucket for a status
// code. Used as a metric label to keep cardinality at 4 instead of 60+.
func StatusClass(status int) string {
	switch {
	case status >= 200 && status < 300:
		return "2xx"
	case status >= 300 && status < 400:
		// 3xx folded into "other" so the four-bucket invariant holds.
		return "other"
	case status >= 400 && status < 500:
		return "4xx"
	case status >= 500 && status < 600:
		return "5xx"
	default:
		return "other"
	}
}

// ConfidenceBand maps a confidence score in [0,1] to one of three
// bands. Boundaries match the contract's review thresholds: <0.5 is
// auto-flagged, 0.5..0.8 is medium-confidence review territory, >=0.8
// is high confidence.
func ConfidenceBand(score float64) string {
	switch {
	case score < 0.5:
		return "low"
	case score < 0.8:
		return "medium"
	default:
		return "high"
	}
}

// RecordNATSPublish is a convenience wrapper that records a publish
// outcome with the canonical label ordering. Internal packages that own
// publish call sites can call this without taking a hard dependency on
// the metric variable shape.
func RecordNATSPublish(service, subjectPattern string, err error) {
	status := "ok"
	if err != nil {
		status = "error"
	}
	NATSPublishTotal.WithLabelValues(service, subjectPattern, status).Inc()
}

// RecordNATSConsume records a consume outcome. ackStatus must be one of
// the documented values (ack|nak|term|error).
func RecordNATSConsume(service, subjectPattern, ackStatus string) {
	NATSConsumeTotal.WithLabelValues(service, subjectPattern, ackStatus).Inc()
}

// RecordExternalCall records a single outbound call. duration is in
// seconds; status is the HTTP status code (0 on transport error).
func RecordExternalCall(service, target string, status int, durationSeconds float64) {
	class := StatusClass(status)
	if status == 0 {
		class = "error"
	}
	ExternalCallTotal.WithLabelValues(service, target, class).Inc()
	ExternalCallDuration.WithLabelValues(service, target).Observe(durationSeconds)
}
