package asr

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"sync"
	"time"

	"nhooyr.io/websocket"
	"nhooyr.io/websocket/wsjson"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
)

// MockProviderConfig tunes the WSS client. Zero values are valid for
// every field except URL.
type MockProviderConfig struct {
	// URL is the dev/mock-asr WSS endpoint, e.g.
	// ws://localhost:8091/asr/v1/stream. Required.
	URL string

	// AuthToken is sent as `Authorization: Bearer <token>` on upgrade.
	// dev/mock-asr accepts any non-empty token; default is "dev".
	AuthToken string

	// DialTimeout caps the websocket.Dial call. Default 5s.
	DialTimeout time.Duration

	// WriteTimeout caps each frame write. Default 5s.
	WriteTimeout time.Duration

	// HTTPClient overrides the default http.Client used for the WSS
	// upgrade. Tests inject a custom transport.
	HTTPClient *http.Client
}

// MockProvider is a Provider that proxies a session's audio chunks to a
// dev/mock-asr WSS server and translates that server's
// transcript_partial/transcript_final frames back into Transcripts.
//
// The mock-asr does not actually consume audio — it emits a scripted
// utterance stream on its own cadence. We still forward audio_chunk
// frames so the wire shape matches what a real ASR will require, which
// keeps this provider exercising the same code paths as Phase 2's
// transcribe_medical_provider.
type MockProvider struct {
	cfg    MockProviderConfig
	logger *slog.Logger
}

// NewMockProvider validates cfg and returns a ready provider. The
// logger is bound with provider=mock so downstream lines are
// attributable without extra plumbing.
func NewMockProvider(cfg MockProviderConfig, logger *slog.Logger) (*MockProvider, error) {
	if cfg.URL == "" {
		return nil, errors.New("mock provider: URL is empty")
	}
	if cfg.AuthToken == "" {
		cfg.AuthToken = "dev"
	}
	if cfg.DialTimeout <= 0 {
		cfg.DialTimeout = 5 * time.Second
	}
	if cfg.WriteTimeout <= 0 {
		cfg.WriteTimeout = 5 * time.Second
	}
	if logger == nil {
		return nil, errors.New("mock provider: nil logger")
	}
	return &MockProvider{
		cfg:    cfg,
		logger: logger.With(slog.String("provider", "mock")),
	}, nil
}

// Name implements Provider.
func (*MockProvider) Name() string { return "mock" }

// Stream dials the mock-asr WSS endpoint and runs the per-session I/O
// loop. The returned `in` channel is forwarded as audio_chunk frames;
// the returned `out` channel receives every transcript_partial /
// transcript_final the server emits, translated to domain Transcripts.
//
// On any I/O error the goroutines close out and return; the orchestrator
// service treats that as a reconnect signal.
func (p *MockProvider) Stream(ctx context.Context, sessionID string) (chan<- AudioChunk, <-chan Transcript, error) {
	dialCtx, cancel := context.WithTimeout(ctx, p.cfg.DialTimeout)
	defer cancel()

	conn, _, err := websocket.Dial(dialCtx, p.cfg.URL, &websocket.DialOptions{
		HTTPClient: p.cfg.HTTPClient,
		HTTPHeader: http.Header{
			"Authorization": []string{"Bearer " + p.cfg.AuthToken},
		},
	})
	if err != nil {
		return nil, nil, fmt.Errorf("dialing mock-asr %s: %w", p.cfg.URL, err)
	}

	// nhooyr's read buffer caps frames at 32KiB by default. Audio chunks
	// are ~16KB at 250ms/16kHz/PCM16, partials are tiny, finals smaller
	// still — 64KiB gives headroom for occasional larger finals without
	// burning memory.
	conn.SetReadLimit(64 * 1024)

	logger := p.logger.With(slog.String("session_id", sessionID))
	logger.Info("mock-asr stream opened", slog.String("url", p.cfg.URL))

	in := make(chan AudioChunk, 16)
	out := make(chan Transcript, 16)

	// streamCtx is canceled when either pump returns, so the other
	// pump unblocks via its `select <-ctx.Done()`. The websocket close
	// is deferred to the reader pump's goroutine to avoid double-close.
	streamCtx, streamCancel := context.WithCancel(ctx)
	var wg sync.WaitGroup
	wg.Add(2)

	// Writer pump: serialize chunks and pings into JSON frames.
	go func() {
		defer wg.Done()
		defer streamCancel()
		if err := p.writePump(streamCtx, conn, sessionID, in, logger); err != nil {
			logger.Warn("mock-asr write pump exited", slog.String("err", err.Error()))
		}
	}()

	// Reader pump: decode incoming envelopes and translate to Transcripts.
	go func() {
		defer wg.Done()
		defer close(out)
		defer streamCancel()
		// Closing the conn is the reader's responsibility — Read() must
		// return before Close() to avoid racing.
		defer func() {
			_ = conn.Close(websocket.StatusNormalClosure, "stream done")
		}()
		if err := p.readPump(streamCtx, conn, sessionID, out, logger); err != nil {
			logger.Warn("mock-asr read pump exited", slog.String("err", err.Error()))
		}
	}()

	// Detached goroutine to join both pumps and log final state. We can
	// not block in Stream() because callers expect it to return
	// immediately with the wired channels.
	go func() {
		wg.Wait()
		logger.Info("mock-asr stream closed")
	}()

	return in, out, nil
}

// writePump reads from `in` and writes audio_chunk envelopes. Closing
// `in` is the signal to send a final session_end frame and exit.
func (p *MockProvider) writePump(ctx context.Context, conn *websocket.Conn, sessionID string, in <-chan AudioChunk, logger *slog.Logger) error {
	var seq uint64
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case chunk, ok := <-in:
			if !ok {
				// Caller closed `in`. Try a polite session_end before
				// returning — the server uses it to flush in-flight
				// emissions. Best-effort: a write timeout here just
				// returns and lets the reader observe the close.
				return p.sendSessionEnd(ctx, conn, sessionID, &seq)
			}
			if err := p.sendAudioChunk(ctx, conn, sessionID, &seq, chunk); err != nil {
				logger.Warn("audio_chunk write failed",
					slog.String("chunk_id", chunk.ChunkID),
					slog.String("err", err.Error()),
				)
				return err
			}
		}
	}
}

// sendAudioChunk encodes one chunk into the contract Envelope and
// writes it. The audio bytes are re-encoded to base64 because that is
// the wire format the mock-asr expects (per CONTRACT.md §2).
func (p *MockProvider) sendAudioChunk(ctx context.Context, conn *websocket.Conn, sessionID string, seq *uint64, chunk AudioChunk) error {
	*seq++
	payload := contract.AudioChunkPayload{
		ChunkID:    chunk.ChunkID,
		AudioB64:   base64.StdEncoding.EncodeToString(chunk.Audio),
		SampleRate: chunk.SampleRate,
		Format:     contract.AudioFormat(chunk.Format),
		DurationMS: chunk.DurationMS,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshaling audio_chunk payload: %w", err)
	}
	env := contract.Envelope{
		Type:      contract.MsgAudioChunk,
		SessionID: sessionID,
		Seq:       *seq,
		TS:        time.Now().UTC(),
		Payload:   raw,
	}
	writeCtx, cancel := context.WithTimeout(ctx, p.cfg.WriteTimeout)
	defer cancel()
	if err := wsjson.Write(writeCtx, conn, env); err != nil {
		return fmt.Errorf("writing audio_chunk: %w", err)
	}
	return nil
}

// sendSessionEnd writes the graceful close frame. Errors are not
// elevated past the caller — the reader will observe the conn close
// regardless.
func (p *MockProvider) sendSessionEnd(ctx context.Context, conn *websocket.Conn, sessionID string, seq *uint64) error {
	*seq++
	env := contract.Envelope{
		Type:      contract.MsgSessionEnd,
		SessionID: sessionID,
		Seq:       *seq,
		TS:        time.Now().UTC(),
		Payload:   json.RawMessage(`{}`),
	}
	writeCtx, cancel := context.WithTimeout(ctx, p.cfg.WriteTimeout)
	defer cancel()
	if err := wsjson.Write(writeCtx, conn, env); err != nil {
		// Don't wrap; the conn is likely already torn down.
		return nil
	}
	return nil
}

// readPump decodes envelopes off the WSS and emits Transcripts to out.
// Frames it does not recognize are logged at debug and ignored — the
// mock currently also sends `pong` and `session_started` which are
// uninteresting to the orchestrator.
func (p *MockProvider) readPump(ctx context.Context, conn *websocket.Conn, sessionID string, out chan<- Transcript, logger *slog.Logger) error {
	for {
		if err := ctx.Err(); err != nil {
			return err
		}
		var env contract.Envelope
		if err := wsjson.Read(ctx, conn, &env); err != nil {
			if isExpectedClose(err) {
				return nil
			}
			return fmt.Errorf("reading frame: %w", err)
		}

		switch env.Type {
		case contract.MsgTranscriptPartial:
			var pl contract.TranscriptPartialPayload
			if err := json.Unmarshal(env.Payload, &pl); err != nil {
				logger.Warn("dropping malformed transcript_partial", slog.String("err", err.Error()))
				continue
			}
			t := Transcript{
				SessionID: sessionID,
				Text:      pl.Text,
				Speaker:   speakerFromContract(pl.Speaker),
				StartMS:   pl.StartMS,
				EndMS:     pl.EndMS,
				IsFinal:   false,
				EmittedAt: env.TS,
			}
			if err := sendTranscript(ctx, out, t); err != nil {
				return err
			}

		case contract.MsgTranscriptFinal:
			var pl contract.TranscriptFinalPayload
			if err := json.Unmarshal(env.Payload, &pl); err != nil {
				logger.Warn("dropping malformed transcript_final", slog.String("err", err.Error()))
				continue
			}
			t := Transcript{
				SessionID:     sessionID,
				TranscriptID:  pl.TranscriptID,
				Text:          pl.Text,
				Speaker:       speakerFromContract(pl.Speaker),
				StartMS:       pl.StartMS,
				EndMS:         pl.EndMS,
				AudioChunkIDs: pl.AudioChunkIDs,
				IsFinal:       true,
				EmittedAt:     env.TS,
			}
			// PHI: log id only, never text.
			logger.Debug("transcript_final received",
				slog.String("transcript_id", pl.TranscriptID),
			)
			if err := sendTranscript(ctx, out, t); err != nil {
				return err
			}

		case contract.MsgSessionEnded:
			logger.Info("mock-asr session_ended received")
			return nil

		case contract.MsgSessionStarted,
			contract.MsgPong,
			contract.MsgError:
			// Uninteresting / out-of-scope frames; skip.
			continue

		default:
			logger.Debug("unknown frame type from mock-asr",
				slog.String("type", string(env.Type)),
			)
		}
	}
}

// sendTranscript forwards t to out with ctx cancellation honored. The
// channel has a small buffer; if the consumer is slower than the
// producer we'd rather block briefly than drop transcripts.
func sendTranscript(ctx context.Context, out chan<- Transcript, t Transcript) error {
	select {
	case <-ctx.Done():
		return ctx.Err()
	case out <- t:
		return nil
	}
}

// speakerFromContract narrows a free-form contract.Speaker value into
// our domain enum. Unknown labels collapse to SpeakerUnknown so the
// downstream schema is preserved.
func speakerFromContract(s contract.Speaker) Speaker {
	switch s {
	case contract.SpeakerNurse:
		return SpeakerNurse
	case contract.SpeakerPatient:
		return SpeakerPatient
	case contract.SpeakerSurgeon:
		return SpeakerSurgeon
	case contract.SpeakerAnesthesia:
		return SpeakerAnesthesia
	default:
		return SpeakerUnknown
	}
}

// isExpectedClose collapses the close-error variants nhooyr can return
// on a clean remote shutdown into a single boolean. Distinguishing
// "the server hung up cleanly" from "the network died mid-frame"
// matters for whether we reconnect or accept the close.
func isExpectedClose(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, context.Canceled) || errors.Is(err, context.DeadlineExceeded) {
		return true
	}
	var ce websocket.CloseError
	if errors.As(err, &ce) {
		switch ce.Code {
		case websocket.StatusNormalClosure, websocket.StatusGoingAway:
			return true
		}
	}
	return false
}

// Compile-time check that *MockProvider satisfies Provider.
var _ Provider = (*MockProvider)(nil)
