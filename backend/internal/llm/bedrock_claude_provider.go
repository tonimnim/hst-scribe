package llm

import (
	"context"
	"encoding/json"
	"fmt"
)

// BedrockClaudeConfig captures the AWS-side knobs needed by the live
// provider. Kept here as a typed value (not pulled from env) so the
// extraction-worker main.go is the single integration point.
//
// Region and ModelID are required when wired in Phase 2. AccessKey /
// SecretKey / SessionToken may be empty when running under an IAM role
// (preferred). The AWS SDK loads these via aws.Config at construction
// time once the Bedrock client is plumbed in.
type BedrockClaudeConfig struct {
	Region          string
	ModelID         string
	AccessKeyID     string
	SecretAccessKey string
	SessionToken    string
}

// BedrockClaudeProvider is the Phase 2 production extractor — Claude
// 3.5 Sonnet via AWS Bedrock with structured-output tool use against
// the event-schema.
//
// In Wave 1 this is a skeleton: the constructor records the config so
// it can be inspected (e.g. for /healthz reporting), but Extract
// returns ErrNotImplemented. The intent is that the only change
// needed to flip on the real provider is a body for Extract that
// invokes bedrockruntime.InvokeModel — every other piece of the
// pipeline (prompt, validators, dedupe, persistence) is already
// production-shaped.
type BedrockClaudeProvider struct {
	cfg BedrockClaudeConfig
}

// NewBedrockClaudeProvider validates required config fields and
// returns a provider that will fail loudly when called until the AWS
// SDK wiring lands.
//
// Region and ModelID are required; missing values are rejected so a
// misconfigured deploy fails at startup, not at first transcript.
func NewBedrockClaudeProvider(cfg BedrockClaudeConfig) (*BedrockClaudeProvider, error) {
	if cfg.Region == "" {
		return nil, fmt.Errorf("bedrock: Region is required")
	}
	if cfg.ModelID == "" {
		return nil, fmt.Errorf("bedrock: ModelID is required")
	}
	return &BedrockClaudeProvider{cfg: cfg}, nil
}

// Config returns a copy of the underlying config. Used by
// extraction-worker's health endpoint to surface "wired but not yet
// implemented" without leaking secrets.
func (p *BedrockClaudeProvider) Config() BedrockClaudeConfig {
	cp := p.cfg
	// Never leak credentials, even to operators reading /healthz.
	cp.AccessKeyID = ""
	cp.SecretAccessKey = ""
	cp.SessionToken = ""
	return cp
}

// Extract is the Phase 2 entrypoint. Currently returns ErrNotImplemented
// so callers can errors.Is-check and fall back. The signature mirrors
// the FakeProvider so the swap is a constructor change.
func (p *BedrockClaudeProvider) Extract(_ context.Context, _ string, _ json.RawMessage) (json.RawMessage, error) {
	return nil, fmt.Errorf("bedrock claude (%s, %s): %w", p.cfg.Region, p.cfg.ModelID, ErrNotImplemented)
}
