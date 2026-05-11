package extract

import (
	"context"
	"regexp"
	"strings"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/vocab"
)

// Confidence caps applied by the validator. Centralized so behavior is
// traceable from one place.
const (
	// ConfidenceUnresolvedRxNorm caps a medication event whose
	// rxnorm_code does not resolve via the bundled validator. The
	// nurse must review before confirm.
	ConfidenceUnresolvedRxNorm = 0.5

	// ConfidenceBurstCap is the per-event cap when the LLM returned
	// more than burstThreshold high-confidence events from a single
	// transcript (likely hallucination).
	ConfidenceBurstCap = 0.7

	// burstThreshold is the count above which we apply ConfidenceBurstCap.
	burstThreshold = 3
)

// imperativeRE matches utterances that start with an imperative verb.
// The pipeline applies this as a SAFETY NET on top of the prompt-level
// rule — a real LLM occasionally slips up on "give"/"hold"/"start"/"stop".
//
// The match is anchored to the first word and case-insensitive.
var imperativeRE = regexp.MustCompile(`(?i)^\s*(give|hold|start|stop)\b`)

// IsImperative reports whether utterance starts with a verb that
// signals an instruction rather than a recorded action. Used by both
// the validator (drop) and exported so callers (tests, future audit
// logging) can ask the same question.
func IsImperative(utterance string) bool {
	return imperativeRE.MatchString(utterance)
}

// doseSanityRule limits the single-dose value for known medications.
// Bounds are deliberately conservative — they catch hallucinations
// (e.g. "morphine 200 mg") without rejecting legitimate values. The
// numbers reflect PACU single-dose ceilings, not the literal max
// recommended in any formulary.
type doseSanityRule struct {
	RxNormCode string
	Unit       contract.DoseUnit
	MaxValue   float64
}

var doseSanityRules = []doseSanityRule{
	{RxNormCode: "7052", Unit: contract.DoseMg, MaxValue: 50},   // morphine
	{RxNormCode: "4337", Unit: contract.DoseMcg, MaxValue: 500}, // fentanyl
	{RxNormCode: "6960", Unit: contract.DoseMg, MaxValue: 20},   // midazolam
	{RxNormCode: "8782", Unit: contract.DoseMg, MaxValue: 500},  // propofol single bolus
	{RxNormCode: "26225", Unit: contract.DoseMg, MaxValue: 16},  // ondansetron
	{RxNormCode: "35827", Unit: contract.DoseMg, MaxValue: 60},  // ketorolac
	{RxNormCode: "161", Unit: contract.DoseMg, MaxValue: 1000},  // acetaminophen
	{RxNormCode: "3264", Unit: contract.DoseMg, MaxValue: 10},   // dexamethasone
}

// EventValidator post-processes a slice of extracted events:
//   - Drops events whose source utterance is imperative.
//   - Caps confidence on medication events whose rxnorm_code is
//     unresolved, and flags them needs_review.
//   - Backfills rxnorm_code from medication_name where possible (LLMs
//     drop the code more often than the name).
//   - Caps confidence per event when the LLM returned a suspicious
//     burst from a single transcript.
//   - Sanity-checks dose values against doseSanityRules; out-of-range
//     events are flagged needs_review.
//
// EventValidator is stateless and safe for concurrent use.
type EventValidator struct {
	rx *vocab.RxNormValidator
}

// NewEventValidator returns an EventValidator backed by rx. Passing
// nil disables RxNorm checks but the imperative drop still applies.
func NewEventValidator(rx *vocab.RxNormValidator) *EventValidator {
	return &EventValidator{rx: rx}
}

// Validate applies every rule above to events and returns a new slice.
// The input is not mutated.
//
// burstSource identifies the transcript this batch came from for
// logging upstream; we don't use it here but the signature anchors
// "one transcript = one validate call".
func (v *EventValidator) Validate(ctx context.Context, events []ExtractedEvent) []ExtractedEvent {
	if len(events) == 0 {
		return events
	}

	out := make([]ExtractedEvent, 0, len(events))
	for _, e := range events {
		ev := CloneEvent(e)

		// Imperative drop — safety net for the prompt rule.
		if IsImperative(ev.SourceUtterance) {
			continue
		}

		switch ev.EventType {
		case contract.EventTypeMedicationAdministered:
			v.validateMedication(ctx, &ev)
		case contract.EventTypeVitalSign,
			contract.EventTypeDispo,
			contract.EventTypeNote:
			// No type-specific validation at this layer (the JSON schema
			// already enforces the shape). Future: range checks on vitals.
		}
		out = append(out, ev)
	}

	// Burst cap: if the surviving batch is too large, the model is
	// probably over-extracting. Lower confidence so the UI surfaces
	// each event as low-confidence (nurse must explicitly confirm).
	if len(out) > burstThreshold {
		for i := range out {
			if out[i].Confidence > ConfidenceBurstCap {
				out[i].Confidence = ConfidenceBurstCap
			}
		}
	}

	return out
}

// validateMedication runs the medication-specific checks on ev in-place.
// Confidence may be capped and NeedsReview may be set; the underlying
// fields map is rewritten if rxnorm_code is backfilled.
func (v *EventValidator) validateMedication(ctx context.Context, ev *ExtractedEvent) {
	fields, err := ev.FieldsMap()
	if err != nil {
		// Malformed fields — flag for review at minimum.
		ev.NeedsReview = true
		if ev.Confidence > ConfidenceUnresolvedRxNorm {
			ev.Confidence = ConfidenceUnresolvedRxNorm
		}
		return
	}

	code, _ := fields["rxnorm_code"].(string)
	name, _ := fields["medication_name"].(string)
	resolved := false

	if v.rx != nil {
		if canonical, ok := v.rx.Validate(ctx, code); ok {
			resolved = true
			// Normalize medication_name to the canonical display.
			if canonical != "" {
				fields["medication_name"] = canonical
			}
		} else if name != "" {
			// Backfill from name if the LLM only gave us a name.
			if backCode, canonical, ok := v.rx.LookupByName(name); ok {
				fields["rxnorm_code"] = backCode
				if canonical != "" {
					fields["medication_name"] = canonical
				}
				resolved = true
			}
		}
	}

	if !resolved {
		ev.NeedsReview = true
		fields["needs_review"] = true
		if ev.Confidence > ConfidenceUnresolvedRxNorm {
			ev.Confidence = ConfidenceUnresolvedRxNorm
		}
	}

	// Dose sanity. We only apply rules when the rxnorm code resolved
	// — for unresolved meds we've already capped confidence.
	if resolved {
		v.applyDoseSanity(ev, fields)
	}

	// Persist any field mutations back onto the event.
	_ = ev.SetFields(fields)
}

func (v *EventValidator) applyDoseSanity(ev *ExtractedEvent, fields map[string]any) {
	code, _ := fields["rxnorm_code"].(string)
	if code == "" {
		return
	}
	unit, _ := fields["dose_unit"].(string)
	rawValue, ok := fields["dose_value"].(float64)
	if !ok {
		return
	}
	for _, rule := range doseSanityRules {
		if rule.RxNormCode != code {
			continue
		}
		if string(rule.Unit) != strings.ToLower(unit) {
			continue
		}
		if rawValue > rule.MaxValue {
			ev.NeedsReview = true
			fields["needs_review"] = true
			fields["dose_out_of_range"] = true
			if ev.Confidence > ConfidenceUnresolvedRxNorm {
				ev.Confidence = ConfidenceUnresolvedRxNorm
			}
		}
		return
	}
}
