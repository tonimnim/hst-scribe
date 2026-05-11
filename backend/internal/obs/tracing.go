package obs

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"os"
	"strconv"
	"strings"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
)

// BuildVersion is the build identifier reported as service.version on
// OTel resources. The build pipeline overrides it via -ldflags
// "-X github.com/tonimnim/hst-scribe/backend/internal/obs.BuildVersion=...";
// dev binaries keep "dev".
var BuildVersion = "dev"

// TracingConfig captures the subset of process configuration the tracing
// stack needs. We deliberately do not import internal/config here so the
// obs package stays consumable from tests that build a *Config inline.
type TracingConfig struct {
	// ServiceName populates the OTel service.name resource attribute.
	ServiceName string
	// Env populates deployment.environment (dev|staging|prod).
	Env string
	// Endpoint is the OTLP gRPC collector address (host:port). When
	// empty, tracing falls back to a no-op exporter so the service
	// still starts cleanly in environments without a collector.
	Endpoint string
	// Insecure forces plaintext gRPC. Defaults to true when Endpoint
	// is set to a localhost address; otherwise false.
	Insecure bool
	// SampleRatio is the parent-based trace-id-ratio fraction in [0,1].
	// When zero, defaults to 0.1 (10% head sampling).
	SampleRatio float64
}

// InitTracing configures the global OpenTelemetry tracer provider and
// W3C propagators. The returned shutdown function flushes spans and
// releases the exporter; callers MUST defer it. Repeated calls within a
// process replace the global provider.
//
// Configuration precedence:
//   - explicit cfg fields win when non-zero;
//   - then OTEL_EXPORTER_OTLP_ENDPOINT for endpoint;
//   - then OTEL_TRACES_SAMPLER_ARG for the sample ratio
//     (OTEL_TRACES_SAMPLER itself is informational here — we always use
//     parent-based trace-id-ratio because that is the only sane default
//     for an HTTP-fanout architecture).
//
// When no endpoint resolves, the function still sets the propagators
// and a noop-exporter SDK provider so context propagation continues to
// work for downstream services. That is important: a missing collector
// must never break inter-service correlation.
func InitTracing(ctx context.Context, cfg TracingConfig) (func(context.Context) error, error) {
	endpoint := strings.TrimSpace(cfg.Endpoint)
	if endpoint == "" {
		endpoint = strings.TrimSpace(os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"))
	}

	ratio := cfg.SampleRatio
	if ratio <= 0 {
		ratio = parseSamplerArg(os.Getenv("OTEL_TRACES_SAMPLER_ARG"), 0.1)
	}
	if ratio > 1 {
		ratio = 1
	}

	res, err := buildResource(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("building otel resource: %w", err)
	}

	// Propagators are mandatory regardless of exporter: a service that
	// does not export still needs to forward trace context to peers.
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))

	if endpoint == "" {
		// No collector configured — install a SDK provider with no
		// exporters. Sampling still applies; spans are recorded but
		// dropped on export. Callers see real span IDs in logs and
		// peers receive valid traceparent headers.
		tp := sdktrace.NewTracerProvider(
			sdktrace.WithResource(res),
			sdktrace.WithSampler(sdktrace.ParentBased(sdktrace.TraceIDRatioBased(ratio))),
		)
		otel.SetTracerProvider(tp)
		return tp.Shutdown, nil
	}

	exporter, err := newOTLPExporter(ctx, endpoint, cfg.Insecure)
	if err != nil {
		return nil, fmt.Errorf("building otlp exporter: %w", err)
	}

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithResource(res),
		sdktrace.WithSampler(sdktrace.ParentBased(sdktrace.TraceIDRatioBased(ratio))),
		sdktrace.WithBatcher(
			exporter,
			sdktrace.WithBatchTimeout(5*time.Second),
			sdktrace.WithMaxExportBatchSize(512),
		),
	)
	otel.SetTracerProvider(tp)

	return func(shutdownCtx context.Context) error {
		// Shutdown drains the batcher and closes the exporter.
		if err := tp.Shutdown(shutdownCtx); err != nil {
			return fmt.Errorf("tracer provider shutdown: %w", err)
		}
		return nil
	}, nil
}

// buildResource produces the OTel Resource carrying service identity.
// We rely on semconv constants so collectors and SaaS backends pick up
// the attributes by name.
func buildResource(ctx context.Context, cfg TracingConfig) (*resource.Resource, error) {
	attrs := []resource.Option{
		resource.WithAttributes(
			semconv.ServiceName(cfg.ServiceName),
			semconv.ServiceVersion(BuildVersion),
			semconv.DeploymentEnvironment(stringOr(cfg.Env, "dev")),
		),
		// Pull host/process metadata from the OS automatically. These
		// are bounded values and useful for fleet-level dashboards.
		resource.WithHost(),
		resource.WithProcessRuntimeName(),
		resource.WithProcessRuntimeVersion(),
		resource.WithFromEnv(),
	}
	r, err := resource.New(ctx, attrs...)
	if err != nil {
		// resource.New returns partial results on some errors; only
		// fail when we did not even get a service name back.
		if r == nil {
			return nil, err
		}
	}
	return r, nil
}

// newOTLPExporter dials the configured collector. The endpoint format
// is `host:port`; an `http://` or `grpc://` prefix is stripped so users
// can paste either form into OTEL_EXPORTER_OTLP_ENDPOINT.
func newOTLPExporter(ctx context.Context, endpoint string, insecure bool) (sdktrace.SpanExporter, error) {
	endpoint, scheme := stripScheme(endpoint)
	useInsecure := insecure || scheme == "http" || isLocalEndpoint(endpoint)

	opts := []otlptracegrpc.Option{
		otlptracegrpc.WithEndpoint(endpoint),
		otlptracegrpc.WithTimeout(10 * time.Second),
	}
	if useInsecure {
		opts = append(opts, otlptracegrpc.WithInsecure())
	}

	dialCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	client := otlptracegrpc.NewClient(opts...)
	exp, err := otlptrace.New(dialCtx, client)
	if err != nil {
		return nil, fmt.Errorf("creating otlp client for %s: %w", endpoint, err)
	}
	return exp, nil
}

// LogTracingInit emits a single structured log line summarizing the
// tracing configuration that was applied. Calling it is optional but
// recommended from main() so operators can confirm the collector wiring
// without grepping env-var dumps.
func LogTracingInit(logger *slog.Logger, cfg TracingConfig) {
	endpoint := cfg.Endpoint
	if endpoint == "" {
		endpoint = os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
	}
	exporter := "otlp_grpc"
	if endpoint == "" {
		exporter = "noop"
	}
	logger.Info("tracing initialized",
		slog.String("exporter", exporter),
		slog.String("endpoint", endpoint),
		slog.String("service_name", cfg.ServiceName),
		slog.Float64("sample_ratio", effectiveRatio(cfg)),
		slog.String("build_version", BuildVersion),
	)
}

func effectiveRatio(cfg TracingConfig) float64 {
	if cfg.SampleRatio > 0 {
		return cfg.SampleRatio
	}
	return parseSamplerArg(os.Getenv("OTEL_TRACES_SAMPLER_ARG"), 0.1)
}

func parseSamplerArg(s string, fallback float64) float64 {
	if s == "" {
		return fallback
	}
	v, err := strconv.ParseFloat(s, 64)
	if err != nil || v < 0 {
		return fallback
	}
	return v
}

func stringOr(v, fallback string) string {
	if v == "" {
		return fallback
	}
	return v
}

func stripScheme(endpoint string) (string, string) {
	for _, scheme := range []string{"http://", "https://", "grpc://", "grpcs://"} {
		if strings.HasPrefix(endpoint, scheme) {
			return strings.TrimPrefix(endpoint, scheme), strings.TrimSuffix(scheme, "://")
		}
	}
	return endpoint, ""
}

func isLocalEndpoint(endpoint string) bool {
	host := endpoint
	if idx := strings.LastIndex(host, ":"); idx >= 0 {
		host = host[:idx]
	}
	switch host {
	case "localhost", "127.0.0.1", "::1", "[::1]":
		return true
	default:
		return false
	}
}

// errTracingNotConfigured is returned by callers that want to assert a
// collector is reachable. We do not return it from InitTracing today —
// silently degrading to noop is the right MVP behavior — but expose the
// sentinel so future health checks have something to reference.
var errTracingNotConfigured = errors.New("tracing endpoint not configured")

// ErrTracingNotConfigured is the exported alias for callers.
func ErrTracingNotConfigured() error { return errTracingNotConfigured }
