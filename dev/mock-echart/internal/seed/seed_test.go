package seed_test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/seed"
)

func writeTempFile(t *testing.T, name, body string) string {
	t.Helper()
	dir := t.TempDir()
	path := filepath.Join(dir, name)
	if err := os.WriteFile(path, []byte(body), 0o644); err != nil {
		t.Fatalf("write temp: %v", err)
	}
	return path
}

func TestLoadPatients_OK(t *testing.T) {
	t.Parallel()
	path := writeTempFile(t, "patients.json", `[
		{
			"patient_id": "01931e00-0000-7000-8000-000000000001",
			"mrn": "X1",
			"display_name_initials": "J.D.",
			"mrn_last4": "0001",
			"full_name": "Jane Doe",
			"date_of_birth": "1968-03-14",
			"sex": "female",
			"procedure": "P",
			"asc_id": "01931e00-0000-7000-8000-00000000aaaa",
			"current_medications": [],
			"allergies": [],
			"comorbidities": []
		}
	]`)
	ps, err := seed.LoadPatients(path)
	if err != nil {
		t.Fatalf("LoadPatients: %v", err)
	}
	if len(ps) != 1 {
		t.Fatalf("len = %d, want 1", len(ps))
	}
	if ps[0].DisplayNameInitials != "J.D." {
		t.Errorf("initials = %q", ps[0].DisplayNameInitials)
	}
}

func TestLoadPatients_MissingFile(t *testing.T) {
	t.Parallel()
	if _, err := seed.LoadPatients("/nope/does-not-exist.json"); err == nil {
		t.Fatal("expected error for missing file")
	}
}

func TestLoadPatients_EmptyArray(t *testing.T) {
	t.Parallel()
	path := writeTempFile(t, "empty.json", `[]`)
	if _, err := seed.LoadPatients(path); err == nil {
		t.Fatal("expected error for empty array")
	}
}

func TestLoadPatients_RejectsUnknownFields(t *testing.T) {
	t.Parallel()
	path := writeTempFile(t, "patients.json", `[{
		"patient_id": "01931e00-0000-7000-8000-000000000001",
		"mystery_field": "boom"
	}]`)
	if _, err := seed.LoadPatients(path); err == nil {
		t.Fatal("expected error for unknown field")
	}
}
