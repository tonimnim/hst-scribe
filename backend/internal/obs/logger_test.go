package obs

import (
	"bytes"
	"context"
	"encoding/json"
	"log/slog"
	"strings"
	"testing"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
)

func TestScrubHandler_RedactsTopLevelKeys(t *testing.T) {
	t.Parallel()

	var buf bytes.Buffer
	cfg := &config.Config{
		ServiceName: "test",
		Env:         config.EnvStaging, // JSON output
		LogLevel:    "info",
	}
	logger := newLoggerWithWriter(cfg, &buf)

	logger.Info("vital",
		slog.String("session_id", "01931d80"),
		slog.String("transcript", "BP one thirty over"),
		slog.String("source_utterance", "patient says BP normal"),
		slog.String("mrn", "1234"),
		slog.String("note_text", "leg numb"),
	)

	var got map[string]any
	if err := json.Unmarshal(buf.Bytes(), &got); err != nil {
		t.Fatalf("unmarshal log line: %v\n%s", err, buf.String())
	}

	for _, key := range []string{"transcript", "source_utterance", "mrn", "note_text"} {
		if v, ok := got[key]; !ok {
			t.Errorf("expected key %q in log line", key)
		} else if v != redactedPlaceholder {
			t.Errorf("key %q = %v, want %q", key, v, redactedPlaceholder)
		}
	}

	if got["session_id"] != "01931d80" {
		t.Errorf("session_id should not be redacted, got %v", got["session_id"])
	}
}

func TestScrubHandler_RedactsInsideGroups(t *testing.T) {
	t.Parallel()

	var buf bytes.Buffer
	cfg := &config.Config{
		ServiceName: "test",
		Env:         config.EnvStaging,
		LogLevel:    "info",
	}
	logger := newLoggerWithWriter(cfg, &buf)

	logger.Info("extracted",
		slog.Group("event",
			slog.String("event_id", "01931d83"),
			slog.String("source_utterance", "BP 130 over 82"),
			slog.Group("patient",
				slog.String("patient_id", "01931d7e"),
				slog.String("patient_name", "Jane Doe"),
			),
		),
	)

	out := buf.String()
	if strings.Contains(out, "BP 130 over 82") {
		t.Errorf("source_utterance leaked: %s", out)
	}
	if strings.Contains(out, "Jane Doe") {
		t.Errorf("patient_name leaked: %s", out)
	}
	if !strings.Contains(out, "01931d83") {
		t.Errorf("event_id should be present: %s", out)
	}
	if !strings.Contains(out, "01931d7e") {
		t.Errorf("patient_id should be present: %s", out)
	}
}

func TestLoggerFromContext_Default(t *testing.T) {
	t.Parallel()

	got := LoggerFromContext(context.Background())
	if got == nil {
		t.Fatal("LoggerFromContext returned nil")
	}
}

func TestLoggerFromContext_RoundTrip(t *testing.T) {
	t.Parallel()

	cfg := &config.Config{ServiceName: "test", Env: config.EnvDev, LogLevel: "info"}
	want := NewLogger(cfg)
	ctx := ContextWithLogger(context.Background(), want)

	if got := LoggerFromContext(ctx); got != want {
		t.Errorf("logger not round-tripped through context")
	}
}
