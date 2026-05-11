package contract

import (
	"encoding/json"
	"testing"
)

func TestDecodePayload_AudioChunk(t *testing.T) {
	t.Parallel()

	raw := []byte(`{
		"type": "audio_chunk",
		"session_id": "01931d80",
		"seq": 1,
		"ts": "2026-05-11T14:30:00-04:00",
		"payload": {
			"chunk_id": "01931d81",
			"audio_b64": "AAAA",
			"sample_rate": 16000,
			"format": "pcm16",
			"duration_ms": 250
		}
	}`)

	var env Envelope
	if err := json.Unmarshal(raw, &env); err != nil {
		t.Fatalf("unmarshal envelope: %v", err)
	}

	got, err := DecodePayload(&env)
	if err != nil {
		t.Fatalf("DecodePayload: %v", err)
	}
	p, ok := got.(AudioChunkPayload)
	if !ok {
		t.Fatalf("payload type = %T, want AudioChunkPayload", got)
	}
	if p.ChunkID != "01931d81" || p.SampleRate != 16000 || p.Format != AudioFormatPCM16 {
		t.Errorf("payload fields off: %#v", p)
	}
}

func TestDecodePayload_UnknownType(t *testing.T) {
	t.Parallel()

	env := Envelope{Type: "made_up", Payload: json.RawMessage(`{}`)}
	if _, err := DecodePayload(&env); err == nil {
		t.Error("expected error for unknown type")
	}
}

func TestDecodeEventFields_VitalSign(t *testing.T) {
	t.Parallel()

	e := &ExtractedEvent{
		EventType: EventTypeVitalSign,
		Fields:    json.RawMessage(`{"vital_type":"heart_rate","value":72,"unit":"bpm"}`),
	}
	got, err := DecodeEventFields(e)
	if err != nil {
		t.Fatalf("decode: %v", err)
	}
	v, ok := got.(VitalSignFields)
	if !ok {
		t.Fatalf("got %T", got)
	}
	if v.VitalType != VitalHeartRate || v.Value != 72 {
		t.Errorf("fields off: %#v", v)
	}
}

func TestDecodeEventFields_Medication(t *testing.T) {
	t.Parallel()

	e := &ExtractedEvent{
		EventType: EventTypeMedicationAdministered,
		Fields: json.RawMessage(`{
			"medication_name":"Ondansetron",
			"rxnorm_code":"26225",
			"dose_value":4,
			"dose_unit":"mg",
			"route":"iv"
		}`),
	}
	got, err := DecodeEventFields(e)
	if err != nil {
		t.Fatalf("decode: %v", err)
	}
	m, ok := got.(MedicationAdministeredFields)
	if !ok {
		t.Fatalf("got %T", got)
	}
	if m.RxNormCode != "26225" || m.Route != RouteIV {
		t.Errorf("fields off: %#v", m)
	}
}
