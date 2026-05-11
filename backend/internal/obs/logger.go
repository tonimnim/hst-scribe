// Package obs provides observability primitives — primarily a slog.Logger
// that scrubs known PHI fields before they reach any handler.
//
// PHI scrubbing is the catastrophic-failure guardrail. Field IDs may be
// logged (session_id, event_id, patient_id) but PHI values must never be.
// Any code that logs a free-text field potentially containing PHI must
// pass it through one of the redacted keys below.
package obs

import (
	"context"
	"io"
	"log/slog"
	"os"
	"strings"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
)

// redactedKeys is the hard-coded set of attribute keys whose values are
// always replaced with [REDACTED] before logging. Keep this list explicit
// and reviewed — adding a key is a security decision. Must stay aligned
// with mobile/lib/core/obs/logger.dart `_phiKeys`.
var redactedKeys = map[string]struct{}{
	// Transcripts and source utterances (ASR / extractor)
	"transcript":       {},
	"text":             {},
	"note_text":        {},
	"notes":            {},
	"source_utterance": {},
	"audio_b64":        {},

	// Identifiers
	"patient_name":          {},
	"full_name":             {},
	"first_name":            {},
	"last_name":             {},
	"mrn":                   {},
	"medical_record_number": {},
	"dob":                   {},
	"date_of_birth":         {},
	"ssn":                   {},
	"phone":                 {},
	"phone_number":          {},
	"address":               {},
	"email":                 {},

	// Clinical values that read as PHI in narrative form
	"allergies":           {},
	"comorbidities":       {},
	"current_medications": {},
	"medications":         {},
	"indication":          {},
}

const redactedPlaceholder = "[REDACTED]"

// ctxKey is the unexported type used for context-stored loggers.
type ctxKey struct{}

// NewLogger builds a *slog.Logger that scrubs PHI before delegating to a
// JSON handler (prod/staging) or text handler (dev). The returned logger
// has the service_name attribute bound at the root.
func NewLogger(cfg *config.Config) *slog.Logger {
	return newLoggerWithWriter(cfg, os.Stdout)
}

func newLoggerWithWriter(cfg *config.Config, w io.Writer) *slog.Logger {
	opts := &slog.HandlerOptions{Level: parseLevel(cfg.LogLevel)}

	var base slog.Handler
	if cfg.IsDev() {
		base = slog.NewTextHandler(w, opts)
	} else {
		base = slog.NewJSONHandler(w, opts)
	}

	scrub := &scrubHandler{inner: base}
	return slog.New(scrub).With(
		slog.String("service_name", cfg.ServiceName),
		slog.String("env", string(cfg.Env)),
	)
}

func parseLevel(s string) slog.Level {
	switch strings.ToLower(s) {
	case "debug":
		return slog.LevelDebug
	case "warn":
		return slog.LevelWarn
	case "error":
		return slog.LevelError
	default:
		return slog.LevelInfo
	}
}

// ContextWithLogger returns ctx with logger attached.
func ContextWithLogger(ctx context.Context, logger *slog.Logger) context.Context {
	return context.WithValue(ctx, ctxKey{}, logger)
}

// LoggerFromContext returns the logger stored on ctx, or slog.Default()
// if none is present. The returned logger is never nil.
func LoggerFromContext(ctx context.Context) *slog.Logger {
	if logger, ok := ctx.Value(ctxKey{}).(*slog.Logger); ok && logger != nil {
		return logger
	}
	return slog.Default()
}

// scrubHandler wraps another slog.Handler and replaces values for any
// attribute whose key (or final group-qualified key segment) is in
// redactedKeys. Group nesting is preserved.
type scrubHandler struct {
	inner slog.Handler
}

func (h *scrubHandler) Enabled(ctx context.Context, level slog.Level) bool {
	return h.inner.Enabled(ctx, level)
}

func (h *scrubHandler) Handle(ctx context.Context, r slog.Record) error {
	// Build a new record with scrubbed attributes. slog.Record.AddAttrs
	// is mutating so we clone via NewRecord.
	clone := slog.NewRecord(r.Time, r.Level, r.Message, r.PC)
	r.Attrs(func(a slog.Attr) bool {
		clone.AddAttrs(scrubAttr(a))
		return true
	})
	return h.inner.Handle(ctx, clone)
}

func (h *scrubHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	cleaned := make([]slog.Attr, len(attrs))
	for i, a := range attrs {
		cleaned[i] = scrubAttr(a)
	}
	return &scrubHandler{inner: h.inner.WithAttrs(cleaned)}
}

func (h *scrubHandler) WithGroup(name string) slog.Handler {
	return &scrubHandler{inner: h.inner.WithGroup(name)}
}

// scrubAttr returns a copy of a with PHI values redacted. Group values
// are walked recursively. Non-group values whose key is in redactedKeys
// are replaced with the redactedPlaceholder string.
func scrubAttr(a slog.Attr) slog.Attr {
	if a.Value.Kind() == slog.KindGroup {
		group := a.Value.Group()
		cleaned := make([]slog.Attr, len(group))
		for i, ga := range group {
			cleaned[i] = scrubAttr(ga)
		}
		return slog.Attr{Key: a.Key, Value: slog.GroupValue(cleaned...)}
	}

	if _, redact := redactedKeys[a.Key]; redact {
		return slog.String(a.Key, redactedPlaceholder)
	}
	return a
}
