package extract

import (
	"fmt"
	"strings"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
)

// utteranceMarkerStart and utteranceMarkerEnd bracket the utterance the
// model must classify. They are intentionally simple XML-style tags so
// the FakeProvider can locate them with strings.LastIndex.
//
// MUST stay in sync with llm.utteranceMarkerStart / End. We avoid the
// cross-package import to keep llm leaf-level.
const (
	utteranceMarkerStart = "<utterance>"
	utteranceMarkerEnd   = "</utterance>"
)

// TranscriptWindowEntry is a recent final transcript used as context
// for the new utterance. Speaker may be empty if diarization missed.
type TranscriptWindowEntry struct {
	TS      time.Time
	Speaker contract.Speaker
	Text    string
}

// PromptInput is the typed input to Build. All fields except Utterance
// are optional — the system prompt and schema instructions are still
// emitted on a bare call.
type PromptInput struct {
	// Now is the wall-clock time used for the "now" anchor in the
	// system prompt. Injected so tests pin the value.
	Now time.Time

	// PatientContext is the locked-at-session-start chart context used
	// for RAG. Nil means no patient context cached yet — the prompt
	// will note that and ask the model to refuse cross-patient
	// inference.
	PatientContext *contract.PatientContext

	// Recent is the rolling 5-minute window of final transcripts before
	// Utterance. Ordered oldest → newest.
	Recent []TranscriptWindowEntry

	// Utterance is the new final transcript to classify. Required.
	Utterance string
}

// Build assembles the LLM prompt. The order matters: high-priority
// rules go first so they survive context-window truncation in
// production with long sessions.
//
// Structure:
//  1. Role + clinical context
//  2. Output schema instructions (event-schema.json, function-calling)
//  3. Past-tense vs imperative rule (this is the most common failure
//     mode in early eval runs — leave it conspicuous)
//  4. Patient context (RAG — meds, allergies, comorbidities)
//  5. Recent transcript window
//  6. The new utterance, in <utterance>...</utterance> markers
//
// The function is pure: no I/O, no clocks beyond what's passed in.
func Build(in PromptInput) string {
	var b strings.Builder
	b.Grow(2048)

	// 1. Role.
	b.WriteString("You are a clinical scribe assistant for a PACU (post-anesthesia care unit) ")
	b.WriteString("nurse at an ambulatory surgery center. You listen to nurse-spoken transcripts ")
	b.WriteString("and extract structured chart events. You DO NOT diagnose, prescribe, or advise.\n\n")

	// 2. Output schema.
	b.WriteString("OUTPUT FORMAT:\n")
	b.WriteString("Return a single JSON object: { \"events\": [ ... ] }.\n")
	b.WriteString("Each event MUST conform to event-schema.json with these fields:\n")
	b.WriteString("  - event_type: one of vital_sign | medication_administered | dispo | note\n")
	b.WriteString("  - fields: per-type shape (see below)\n")
	b.WriteString("  - confidence: 0..1 — how sure are you THIS utterance produced THIS event\n")
	b.WriteString("Event field shapes:\n")
	b.WriteString("  vital_sign: { vital_type, value, unit }\n")
	b.WriteString("    vital_type ∈ blood_pressure_systolic|blood_pressure_diastolic|heart_rate|spo2|respiratory_rate|temperature_c|temperature_f|pain_score\n")
	b.WriteString("  medication_administered: { medication_name, rxnorm_code, dose_value, dose_unit, route, indication? }\n")
	b.WriteString("    dose_unit ∈ mg|mcg|g|ml|unit ; route ∈ iv|im|po|sublingual|topical|inhaled|intranasal|rectal|subcutaneous\n")
	b.WriteString("    ALWAYS include rxnorm_code. If you cannot resolve one, drop the event.\n")
	b.WriteString("  dispo: { disposition_type, discharge_criteria_met?, notes? }\n")
	b.WriteString("    disposition_type ∈ discharge_home|transfer_to_hospital|admit_observation|transfer_to_floor\n")
	b.WriteString("  note: { note_text, tags? } — free-text fallback only when nothing structured matches.\n\n")

	// 3. The fact-vs-intent rule. This is the most load-bearing rule.
	b.WriteString("RULE — PAST-TENSE / FACT vs IMPERATIVE / INTENT:\n")
	b.WriteString("Only completed actions and observed facts produce events.\n")
	b.WriteString("  PRODUCE: \"gave 4 of Zofran\", \"BP one thirty over eighty two\", \"pain is a 2\", \"saturation dropped to 91\"\n")
	b.WriteString("  DO NOT PRODUCE: \"give 4 of Zofran\", \"let's give morphine\", \"hold the next dose\", \"start fluids\", \"going to bolus\"\n")
	b.WriteString("If unsure whether an utterance is a fact or an intent, return no event.\n\n")

	// 3b. Misc safety rules.
	b.WriteString("RULES — SAFETY:\n")
	b.WriteString("  - Do not invent values. If the number is ambiguous, drop the event.\n")
	b.WriteString("  - Compound vitals like \"BP 132 over 84\" → emit two events (systolic + diastolic).\n")
	b.WriteString("  - Reconciliation phrases (\"that's 6 total today\") are NOT new events.\n")
	b.WriteString("  - Self-corrections (\"strike that\", \"I meant\") are handled out-of-band; do not emit.\n")
	b.WriteString("  - Patient-context facts (existing allergies, current meds) are NOT new events.\n")
	b.WriteString("  - When in doubt, return { \"events\": [] }.\n\n")

	// 4. Patient context (RAG).
	writePatientContext(&b, in.PatientContext)

	// 5. Recent transcript window.
	writeRecent(&b, in.Recent)

	// 6. Now timestamp anchor.
	if !in.Now.IsZero() {
		fmt.Fprintf(&b, "CURRENT TIME: %s\n\n", in.Now.UTC().Format(time.RFC3339))
	}

	// 7. The utterance to classify.
	b.WriteString("UTTERANCE TO CLASSIFY:\n")
	b.WriteString(utteranceMarkerStart)
	b.WriteString(strings.TrimSpace(in.Utterance))
	b.WriteString(utteranceMarkerEnd)
	b.WriteString("\n")
	b.WriteString("Respond with the JSON object only. No prose, no markdown.\n")

	return b.String()
}

func writePatientContext(b *strings.Builder, pc *contract.PatientContext) {
	b.WriteString("PATIENT CONTEXT (RAG — already-known facts, do NOT re-emit):\n")
	if pc == nil {
		b.WriteString("  (unavailable — refuse to infer patient identity from audio)\n\n")
		return
	}
	if pc.Procedure != "" {
		fmt.Fprintf(b, "  procedure: %s\n", pc.Procedure)
	}
	if len(pc.CurrentMedications) > 0 {
		b.WriteString("  current_medications:\n")
		for _, m := range pc.CurrentMedications {
			fmt.Fprintf(b, "    - %s (rxnorm %s)", m.Name, m.RxNormCode)
			if m.Dose != "" {
				fmt.Fprintf(b, " %s", m.Dose)
			}
			if m.Route != "" {
				fmt.Fprintf(b, " %s", m.Route)
			}
			b.WriteString("\n")
		}
	}
	if len(pc.Allergies) > 0 {
		b.WriteString("  allergies:\n")
		for _, a := range pc.Allergies {
			fmt.Fprintf(b, "    - %s (%s)\n", a.Name, a.Severity)
		}
	}
	if len(pc.Comorbidities) > 0 {
		b.WriteString("  comorbidities:\n")
		for _, c := range pc.Comorbidities {
			fmt.Fprintf(b, "    - %s\n", c)
		}
	}
	b.WriteString("\n")
}

func writeRecent(b *strings.Builder, recent []TranscriptWindowEntry) {
	b.WriteString("RECENT TRANSCRIPT WINDOW (last 5 min, oldest first):\n")
	if len(recent) == 0 {
		b.WriteString("  (empty)\n\n")
		return
	}
	for _, e := range recent {
		speaker := e.Speaker
		if speaker == "" {
			speaker = contract.SpeakerUnknown
		}
		fmt.Fprintf(b, "  [%s][%s] %s\n", e.TS.UTC().Format(time.RFC3339), speaker, e.Text)
	}
	b.WriteString("\n")
}
