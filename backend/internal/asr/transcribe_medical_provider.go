package asr

import (
	"context"
	"fmt"
)

// TranscribeMedicalProvider is the AWS Transcribe Medical implementation.
//
// Phase 2 — real streaming integration via the AWS SDK Transcribe
// Streaming client. The current skeleton exists so:
//
//   - The ASR_PROVIDER=transcribe_medical config path resolves to a
//     well-typed provider rather than nil.
//   - Operators get a deterministic, recoverable error at stream open
//     instead of a runtime nil dereference somewhere later.
//   - The interface assertion below catches drift if Provider changes
//     before Phase 2 lands.
//
// Construction takes no arguments today because we have nothing to
// validate. When the real client lands, this struct grows fields for
// region, language code, vocabulary name, and (optionally) a custom
// medical specialty model.
type TranscribeMedicalProvider struct {
	// Region is the AWS region of the Transcribe Medical endpoint. Set
	// by the constructor when the real impl lands; ignored today.
	Region string

	// LanguageCode (e.g. "en-US"). Default "en-US" in Phase 2.
	LanguageCode string

	// Specialty is the Transcribe Medical specialty model
	// (PRIMARYCARE, CARDIOLOGY, NEUROLOGY, ONCOLOGY, RADIOLOGY,
	// UROLOGY). MVP uses PRIMARYCARE.
	Specialty string
}

// NewTranscribeMedicalProvider builds the (still-stub) AWS provider.
// Returns the value rather than a pointer so callers can construct it
// in a config table; methods are pointer-receiver-free until state
// arrives in Phase 2.
func NewTranscribeMedicalProvider(region, languageCode, specialty string) *TranscribeMedicalProvider {
	return &TranscribeMedicalProvider{
		Region:       region,
		LanguageCode: languageCode,
		Specialty:    specialty,
	}
}

// Name implements Provider.
func (*TranscribeMedicalProvider) Name() string { return "transcribe_medical" }

// Stream is a stub. It returns ErrNotImplemented so the service layer
// can route around it (ASR_PROVIDER=mock) or escalate to ops.
//
// TODO(phase-2): implement against
// github.com/aws/aws-sdk-go-v2/service/transcribestreaming. The shape
// will be:
//
//  1. StartMedicalStreamTranscription with PCM/16kHz config.
//  2. Pump AudioChunk.Audio into the request event stream.
//  3. Translate ResultStream events into Transcript (partial vs final
//     keyed off result.IsPartial).
//  4. Close the request stream on ctx cancellation; close `out` after
//     the final response event.
func (*TranscribeMedicalProvider) Stream(_ context.Context, sessionID string) (chan<- AudioChunk, <-chan Transcript, error) {
	return nil, nil, fmt.Errorf("transcribe_medical provider not wired (session %s): %w", sessionID, ErrNotImplemented)
}

// Compile-time check that *TranscribeMedicalProvider satisfies Provider.
var _ Provider = (*TranscribeMedicalProvider)(nil)
