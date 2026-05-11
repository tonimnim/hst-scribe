package llm

import (
	"context"
	"encoding/json"
	"errors"
)

// ErrNotImplemented is returned by skeleton providers (e.g. the Bedrock
// Claude provider in Wave 1) so callers can errors.Is-check it and
// either fall back or surface a clear "wire me up" message.
var ErrNotImplemented = errors.New("llm provider not implemented")

// Provider is the contract every LLM backend implements. Extract takes
// an already-rendered prompt and a JSON schema describing the expected
// output. Implementations must return JSON that decodes into
// ExtractResponse — anything else is an error.
//
// The schema parameter is the bytes of the JSON schema, ready to pass
// through to Bedrock's tool/function-calling APIs. Providers that do
// not honor schemas (e.g. the fake) may ignore it; they must still
// produce output that conforms.
//
// Implementations must be safe for concurrent use.
type Provider interface {
	Extract(ctx context.Context, prompt string, schema json.RawMessage) (json.RawMessage, error)
}

// ExtractResponse is the agreed shape Provider.Extract returns. The
// outer object is `{ "events": [...] }` so the LLM can return zero,
// one, or many events from a single transcript without ambiguity.
//
// Events is a []json.RawMessage so the extract package can decode each
// element through contract.ExtractedEvent after schema-validation —
// keeping the wire/domain split inside one type.
type ExtractResponse struct {
	Events []json.RawMessage `json:"events"`
}

// DecodeResponse is a small helper around json.Unmarshal so callers
// don't repeat the same boilerplate. Returns an empty (non-nil) slice
// when raw is empty.
func DecodeResponse(raw json.RawMessage) (*ExtractResponse, error) {
	resp := &ExtractResponse{Events: []json.RawMessage{}}
	if len(raw) == 0 {
		return resp, nil
	}
	if err := json.Unmarshal(raw, resp); err != nil {
		return nil, err
	}
	if resp.Events == nil {
		resp.Events = []json.RawMessage{}
	}
	return resp, nil
}
