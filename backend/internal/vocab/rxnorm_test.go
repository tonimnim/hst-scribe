package vocab

import (
	"context"
	"testing"
)

func TestRxNormValidator_Validate(t *testing.T) {
	t.Parallel()

	v := NewRxNormValidator()
	cases := []struct {
		code     string
		wantName string
		wantOK   bool
	}{
		{"26225", "Ondansetron", true},
		{"4337", "Fentanyl", true},
		{"7052", "Morphine", true},
		{"7806", "Oxygen", true},
		{"  26225  ", "Ondansetron", true}, // trims
		{"", "", false},
		{"999999", "", false},
	}
	for _, tc := range cases {
		t.Run(tc.code, func(t *testing.T) {
			t.Parallel()
			name, ok := v.Validate(context.Background(), tc.code)
			if ok != tc.wantOK || name != tc.wantName {
				t.Errorf("Validate(%q) = (%q,%v), want (%q,%v)", tc.code, name, ok, tc.wantName, tc.wantOK)
			}
		})
	}
}

func TestRxNormValidator_LookupByName(t *testing.T) {
	t.Parallel()

	v := NewRxNormValidator()
	cases := []struct {
		name     string
		wantCode string
		wantOK   bool
	}{
		{"Zofran", "26225", true},
		{"ondansetron", "26225", true},
		{"  MORPHINE  ", "7052", true},
		{"Versed", "6960", true},
		{"Toradol", "35827", true},
		{"", "", false},
		{"hopefullynotadrug", "", false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			code, _, ok := v.LookupByName(tc.name)
			if ok != tc.wantOK || code != tc.wantCode {
				t.Errorf("LookupByName(%q) = (%q,%v), want (%q,%v)", tc.name, code, ok, tc.wantCode, tc.wantOK)
			}
		})
	}
}
