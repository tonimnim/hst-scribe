package uuidv7

import (
	"testing"

	"github.com/google/uuid"
)

func TestNew_ReturnsValidV7(t *testing.T) {
	t.Parallel()

	id := New()
	parsed, err := uuid.Parse(id)
	if err != nil {
		t.Fatalf("New() returned invalid uuid %q: %v", id, err)
	}
	if v := parsed.Version(); v != 7 {
		t.Errorf("expected v7, got v%d", v)
	}
}

func TestNew_Unique(t *testing.T) {
	t.Parallel()

	seen := make(map[string]struct{}, 1000)
	for i := 0; i < 1000; i++ {
		id := New()
		if _, dup := seen[id]; dup {
			t.Fatalf("duplicate uuid generated: %s", id)
		}
		seen[id] = struct{}{}
	}
}

func TestParse(t *testing.T) {
	t.Parallel()

	if _, err := Parse("not-a-uuid"); err == nil {
		t.Error("Parse should reject garbage")
	}
	if _, err := Parse(New()); err != nil {
		t.Errorf("Parse rejected a valid v7: %v", err)
	}
}
