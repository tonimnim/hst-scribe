package wss

import (
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"nhooyr.io/websocket"
	"nhooyr.io/websocket/wsjson"

	"github.com/tonimnim/hst-scribe/dev/mock-asr/internal/seed"
)

// fixtureUtterances is a minimal scripted set used by all tests in this file.
// We deliberately pick short text so partials are exercised.
var fixtureUtterances = []seed.Utterance{
	{ID: "utt-test-1", Text: "BP one thirty over eighty two", Speaker: "nurse"},
	{ID: "utt-test-2", Text: "Heart rate seventy two", Speaker: "nurse"},
}

func newTestServer(t *testing.T) *httptest.Server {
	t.Helper()

	srv, err := NewServer(Config{
		Addr:           "", // ignored — httptest supplies the listener
		Logger:         slog.New(slog.NewJSONHandler(io.Discard, nil)),
		EmitInterval:   200 * time.Millisecond, // fast cadence for tests
		PartialLeadIn:  20 * time.Millisecond,
		PartialToFinal: 30 * time.Millisecond,
		Utterances:     fixtureUtterances,
	})
	if err != nil {
		t.Fatalf("NewServer: %v", err)
	}

	hs := httptest.NewServer(srv.Router())
	t.Cleanup(hs.Close)
	return hs
}

// dialWSS converts an http://host URL into ws://host and dials with a bearer.
func dialWSS(t *testing.T, ctx context.Context, hs *httptest.Server, path string, withAuth bool) (*websocket.Conn, *http.Response, error) {
	t.Helper()
	u := strings.Replace(hs.URL, "http://", "ws://", 1) + path
	headers := http.Header{}
	if withAuth {
		headers.Set("Authorization", "Bearer test-token")
	}
	return websocket.Dial(ctx, u, &websocket.DialOptions{
		HTTPHeader: headers,
	})
}

func readEnvelope(t *testing.T, ctx context.Context, conn *websocket.Conn) Envelope {
	t.Helper()
	var env Envelope
	if err := wsjson.Read(ctx, conn, &env); err != nil {
		t.Fatalf("read: %v", err)
	}
	return env
}

// TestHealthz — sanity that the HTTP route is up.
func TestHealthz(t *testing.T) {
	hs := newTestServer(t)
	resp, err := http.Get(hs.URL + "/healthz")
	if err != nil {
		t.Fatalf("get /healthz: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("healthz status = %d, want 200", resp.StatusCode)
	}
}

// TestStreamRejectsMissingAuth — handler should refuse upgrade without bearer.
func TestStreamRejectsMissingAuth(t *testing.T) {
	hs := newTestServer(t)
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	_, resp, err := dialWSS(t, ctx, hs, "/asr/v1/stream", false)
	if err == nil {
		t.Fatalf("dial without auth succeeded, want failure")
	}
	if resp == nil {
		t.Fatalf("expected HTTP response for handshake failure, got nil")
	}
	if resp.StatusCode != http.StatusUnauthorized {
		t.Fatalf("status = %d, want 401", resp.StatusCode)
	}
}

// TestStreamRoundTrip — end-to-end happy path:
//
//  1. connect (auth header present)
//  2. receive session_started
//  3. send audio_chunk → receive pong
//  4. receive at least one transcript_partial and transcript_final
//  5. send session_end → receive session_ended
func TestStreamRoundTrip(t *testing.T) {
	hs := newTestServer(t)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	conn, _, err := dialWSS(t, ctx, hs, "/asr/v1/stream", true)
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	defer conn.Close(websocket.StatusNormalClosure, "test done")

	// 1. session_started must be the first frame.
	first := readEnvelope(t, ctx, conn)
	if first.Type != TypeSessionStarted {
		t.Fatalf("first frame type = %q, want %q", first.Type, TypeSessionStarted)
	}
	if first.Seq != 1 {
		t.Fatalf("first frame seq = %d, want 1", first.Seq)
	}
	if first.SessionID == "" {
		t.Fatalf("session_id empty on session_started")
	}
	var started SessionStartedPayload
	if err := json.Unmarshal(first.Payload, &started); err != nil {
		t.Fatalf("decode session_started payload: %v", err)
	}
	if started.ProtocolVersion != ProtocolVersion {
		t.Fatalf("protocol_version = %q, want %q", started.ProtocolVersion, ProtocolVersion)
	}
	if !started.ServerCapabilities.Diarization {
		t.Fatalf("diarization capability not advertised")
	}
	if started.ServerCapabilities.VoiceCommands {
		t.Fatalf("voice_commands should be false on mock")
	}

	// 2. send an audio_chunk and expect a pong ACK.
	chunkEnv := Envelope{
		Type:      TypeAudioChunk,
		SessionID: first.SessionID,
		Seq:       1,
		TS:        time.Now().UTC().Format(time.RFC3339Nano),
		Payload:   mustJSON(t, map[string]any{"chunk_id": "client-chunk-1", "audio_b64": "ZmFrZQ==", "sample_rate": 16000, "format": "pcm16", "duration_ms": 250}),
	}
	if err := wsjson.Write(ctx, conn, chunkEnv); err != nil {
		t.Fatalf("write audio_chunk: %v", err)
	}

	// 3. drain frames until we've seen pong + at least one partial + one final.
	gotPong := false
	gotPartial := false
	gotFinal := false
	deadline := time.Now().Add(5 * time.Second)
	for !(gotPong && gotPartial && gotFinal) {
		if time.Now().After(deadline) {
			t.Fatalf("did not receive pong+partial+final in time (pong=%v partial=%v final=%v)",
				gotPong, gotPartial, gotFinal)
		}
		readCtx, readCancel := context.WithTimeout(ctx, 2*time.Second)
		var env Envelope
		err := wsjson.Read(readCtx, conn, &env)
		readCancel()
		if err != nil {
			t.Fatalf("read: %v", err)
		}
		switch env.Type {
		case TypePong:
			gotPong = true
		case TypeTranscriptPartial:
			gotPartial = true
			var p TranscriptPartialPayload
			if err := json.Unmarshal(env.Payload, &p); err != nil {
				t.Fatalf("decode partial: %v", err)
			}
			if p.Text == "" {
				t.Fatalf("partial text empty")
			}
			if p.Speaker != "nurse" {
				t.Fatalf("partial speaker = %q, want nurse", p.Speaker)
			}
		case TypeTranscriptFinal:
			gotFinal = true
			var f TranscriptFinalPayload
			if err := json.Unmarshal(env.Payload, &f); err != nil {
				t.Fatalf("decode final: %v", err)
			}
			if f.TranscriptID == "" {
				t.Fatalf("transcript_id empty on final")
			}
			if f.Text == "" {
				t.Fatalf("final text empty")
			}
			if f.Speaker != "nurse" {
				t.Fatalf("final speaker = %q, want nurse", f.Speaker)
			}
		}
	}

	// 4. send session_end and expect session_ended.
	endEnv := Envelope{
		Type:      TypeSessionEnd,
		SessionID: first.SessionID,
		Seq:       2,
		TS:        time.Now().UTC().Format(time.RFC3339Nano),
	}
	if err := wsjson.Write(ctx, conn, endEnv); err != nil {
		t.Fatalf("write session_end: %v", err)
	}

	// Read until session_ended; tolerate any in-flight frames in the meantime.
	endDeadline := time.Now().Add(3 * time.Second)
	for {
		if time.Now().After(endDeadline) {
			t.Fatalf("did not receive session_ended in time")
		}
		readCtx, readCancel := context.WithTimeout(ctx, 2*time.Second)
		var env Envelope
		err := wsjson.Read(readCtx, conn, &env)
		readCancel()
		if err != nil {
			t.Fatalf("read after session_end: %v", err)
		}
		if env.Type == TypeSessionEnded {
			var p SessionEndedPayload
			if err := json.Unmarshal(env.Payload, &p); err != nil {
				t.Fatalf("decode session_ended: %v", err)
			}
			if p.Reason != "client_requested" {
				t.Fatalf("session_ended reason = %q, want client_requested", p.Reason)
			}
			return
		}
	}
}

// TestPauseResume — pause stops emissions, resume continues them.
func TestPauseResume(t *testing.T) {
	hs := newTestServer(t)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	conn, _, err := dialWSS(t, ctx, hs, "/asr/v1/stream", true)
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	defer conn.Close(websocket.StatusNormalClosure, "test done")

	// consume session_started
	first := readEnvelope(t, ctx, conn)
	if first.Type != TypeSessionStarted {
		t.Fatalf("first = %s", first.Type)
	}

	// pause immediately
	pauseEnv := Envelope{
		Type:      TypeSessionPause,
		SessionID: first.SessionID,
		Seq:       1,
		TS:        time.Now().UTC().Format(time.RFC3339Nano),
	}
	if err := wsjson.Write(ctx, conn, pauseEnv); err != nil {
		t.Fatalf("write pause: %v", err)
	}

	// During pause, no transcript frames should arrive within a window
	// generously larger than EmitInterval.
	quietCtx, quietCancel := context.WithTimeout(ctx, 600*time.Millisecond)
	defer quietCancel()
	for {
		var env Envelope
		err := wsjson.Read(quietCtx, conn, &env)
		if err != nil {
			break // timeout — expected
		}
		if env.Type == TypeTranscriptPartial || env.Type == TypeTranscriptFinal {
			t.Fatalf("got %s while paused", env.Type)
		}
	}

	// resume and expect a transcript_final within a reasonable window.
	resumeEnv := Envelope{
		Type:      TypeSessionResume,
		SessionID: first.SessionID,
		Seq:       2,
		TS:        time.Now().UTC().Format(time.RFC3339Nano),
	}
	if err := wsjson.Write(ctx, conn, resumeEnv); err != nil {
		t.Fatalf("write resume: %v", err)
	}

	resumeDeadline := time.Now().Add(3 * time.Second)
	gotFinal := false
	for !gotFinal {
		if time.Now().After(resumeDeadline) {
			t.Fatalf("no transcript_final after resume")
		}
		readCtx, readCancel := context.WithTimeout(ctx, 2*time.Second)
		var env Envelope
		err := wsjson.Read(readCtx, conn, &env)
		readCancel()
		if err != nil {
			t.Fatalf("read after resume: %v", err)
		}
		if env.Type == TypeTranscriptFinal {
			gotFinal = true
		}
	}
}

func mustJSON(t *testing.T, v any) json.RawMessage {
	t.Helper()
	b, err := json.Marshal(v)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	return b
}
