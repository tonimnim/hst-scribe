// Package asr is the ASR provider abstraction and the asr-orchestrator
// service core: it consumes audio chunks from NATS, drives a streaming
// ASR provider per active session, and republishes partial and final
// transcripts back to NATS.
//
// The package layers:
//
//   - Provider — small interface for "open a per-session streaming ASR
//     channel". One implementation per upstream (mock, transcribe_medical,
//     a fake for tests).
//   - AudioChunk / Transcript — domain types matching the wire payloads
//     in internal/contract. Decoded once at the NATS boundary.
//   - Repository — persists is_final=true transcripts to Postgres.
//   - Service — the orchestrator. Subscribes to audio.chunks.>, lazily
//     opens provider streams per session, publishes transcripts.> and
//     persists finals. Reconnects with exponential backoff on stream
//     failure; emits audit.events.{asc_id} on terminal "asr_failed".
//
// Subjects (internal to backend; not part of CONTRACT.md):
//
//	audio.chunks.{session_id}     — gateway → asr-orchestrator  (durable)
//	sessions.events.{session_id}  — session-manager → broadcast  (lifecycle)
//	transcripts.{session_id}      — asr-orchestrator → consumers
//	audit.events.{asc_id}         — services → audit
//
// PHI rules: transcript text is PHI and never appears in log records,
// metrics, or traces. Only session_id, transcript_id, and counts may be
// logged. The wire `audio_b64` field is decoded to bytes and forwarded
// once; the base64 string itself is never logged.
package asr

import (
	"context"
	"errors"
	"time"
)

// ErrNotImplemented is returned by provider stubs that have not been
// wired yet (currently the AWS Transcribe Medical implementation).
// Callers select a different provider via ASR_PROVIDER env to make
// progress in dev/staging until the real impl lands.
var ErrNotImplemented = errors.New("asr provider not implemented")

// ErrStreamClosed is returned when a provider's input channel is written
// to after the stream has closed. Senders treat this as a signal to
// reopen the stream rather than as a hard failure.
var ErrStreamClosed = errors.New("asr provider stream closed")

// AudioFormat enumerates the codecs the orchestrator accepts. Mirrors
// contract.AudioFormat so the wire and domain types align without an
// extra translation step.
type AudioFormat string

// AudioFormat values. PCM16 is the only MVP codec; opus arrives in Phase 2.
const (
	AudioFormatPCM16 AudioFormat = "pcm16"
)

// AudioChunk is one decoded audio frame ready to ship to a provider.
// It mirrors contract.AudioChunkPayload but holds raw bytes instead of
// the wire base64 so providers can re-encode for their own protocol.
//
// SessionID is carried alongside the payload so providers that fan in
// multiple streams (or fakes that record traffic) can route the chunk.
type AudioChunk struct {
	// SessionID is the UUIDv7 of the owning session.
	SessionID string

	// ChunkID is the publisher-minted UUIDv7. Used for dedupe and for
	// transcript provenance (Transcript.AudioChunkIDs).
	ChunkID string

	// Audio is the decoded PCM16 bytes (or whatever Format declares).
	// Never logged.
	Audio []byte

	// SampleRate in Hz (16000 for PCM16 MVP).
	SampleRate int

	// Format is the codec the bytes encode.
	Format AudioFormat

	// DurationMS is the chunk's wall duration. Useful for budgeting.
	DurationMS int

	// ReceivedAt is when the orchestrator decoded the chunk off NATS.
	// Providers that timestamp their own output may ignore this.
	ReceivedAt time.Time
}

// Speaker labels for diarized transcripts. Mirrors contract.Speaker.
type Speaker string

// Speaker values matching contract/CONTRACT.md §2.
const (
	SpeakerNurse      Speaker = "nurse"
	SpeakerPatient    Speaker = "patient"
	SpeakerSurgeon    Speaker = "surgeon"
	SpeakerAnesthesia Speaker = "anesthesia"
	SpeakerUnknown    Speaker = "unknown"
)

// Transcript is one ASR result — either a partial (IsFinal=false) or a
// final (IsFinal=true). Mirrors contract.TranscriptPartialPayload and
// contract.TranscriptFinalPayload merged into one domain type.
//
// TranscriptID is required for finals and ignored for partials (per
// CONTRACT.md §2 — partials don't carry an id).
type Transcript struct {
	// SessionID is the UUIDv7 of the owning session.
	SessionID string

	// TranscriptID is the UUIDv7 minted by the producer when IsFinal.
	// Empty for partials.
	TranscriptID string

	// Text is the recognized utterance verbatim. PHI — never logged.
	Text string

	// Speaker is the diarization label. Defaults to SpeakerUnknown when
	// the provider does not diarize.
	Speaker Speaker

	// StartMS / EndMS bound the utterance within the session timeline.
	StartMS int64
	EndMS   int64

	// AudioChunkIDs is the provenance back to the source audio bytes.
	// Empty for partials; required for finals.
	AudioChunkIDs []string

	// IsFinal distinguishes partial (false) from final (true) results.
	IsFinal bool

	// EmittedAt is the producer's wall clock at emission time. Used as
	// the envelope `ts` when republishing on NATS.
	EmittedAt time.Time
}

// Provider is the per-session streaming ASR contract. Implementations:
//
//   - mock_provider     — WSS client against dev/mock-asr
//   - transcribe_medical_provider — AWS Transcribe Medical (Phase 2)
//   - fake_provider     — scripted echo, tests only
//
// Stream opens a fresh ASR session for sessionID and returns two
// channels: callers send AudioChunk on `in`, callers receive Transcript
// on `out`. Closing `in` (or canceling ctx) tears the stream down; the
// provider closes `out` once draining is complete.
//
// Errors during the lifetime of the stream are reported by closing
// `out` early. Callers detect this with a `_, ok := <-out` read and
// reconnect with backoff (see service.go).
//
// Implementations MUST NOT log AudioChunk.Audio or Transcript.Text;
// PHI discipline applies inside provider impls too.
type Provider interface {
	// Stream opens a streaming ASR connection for sessionID. The
	// returned `in` channel is owned by the caller (close to signal
	// EOF); the `out` channel is owned by the provider (closed when
	// the stream ends, error or clean).
	Stream(ctx context.Context, sessionID string) (in chan<- AudioChunk, out <-chan Transcript, err error)

	// Name is the provider's identifier for logging and metrics.
	Name() string
}
