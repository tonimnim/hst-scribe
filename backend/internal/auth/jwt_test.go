package auth

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
)

func mustValidator(t *testing.T, secret string) *HMACValidator {
	t.Helper()
	v, err := NewHMACValidator(&config.Config{JWTSecret: secret})
	if err != nil {
		t.Fatalf("NewHMACValidator: %v", err)
	}
	return v
}

func mintToken(t *testing.T, secret string, claims jwt.MapClaims) string {
	t.Helper()
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := tok.SignedString([]byte(secret))
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	return signed
}

func TestNewHMACValidator_RejectsEmptySecret(t *testing.T) {
	t.Parallel()
	if _, err := NewHMACValidator(&config.Config{}); err == nil {
		t.Error("expected error for empty secret")
	}
}

func TestValidate_HappyPath(t *testing.T) {
	t.Parallel()

	const secret = "test-secret-with-enough-bytes"
	v := mustValidator(t, secret)
	tok := mintToken(t, secret, jwt.MapClaims{
		"sub":     "user-1",
		"asc_id":  "asc-1",
		"role":    "nurse",
		"user_id": "user-1",
		"exp":     time.Now().Add(15 * time.Minute).Unix(),
	})

	c, err := v.Validate(context.Background(), "Bearer "+tok)
	if err != nil {
		t.Fatalf("validate: %v", err)
	}
	if c.UserID != "user-1" || c.ASCID != "asc-1" || c.Role != RoleNurse {
		t.Errorf("claims off: %#v", c)
	}
}

func TestValidate_ExpiredToken(t *testing.T) {
	t.Parallel()

	const secret = "test-secret-with-enough-bytes"
	v := mustValidator(t, secret)
	tok := mintToken(t, secret, jwt.MapClaims{
		"sub":     "user-1",
		"asc_id":  "asc-1",
		"role":    "nurse",
		"user_id": "user-1",
		"exp":     time.Now().Add(-1 * time.Minute).Unix(),
	})

	_, err := v.Validate(context.Background(), tok)
	if err == nil {
		t.Fatal("expected error for expired token")
	}
	var werr *httperr.Error
	if !errors.As(err, &werr) || werr.Code != httperr.CodeAuthInvalid {
		t.Errorf("expected auth_invalid wire error, got %v", err)
	}
}

func TestValidate_MissingClaims(t *testing.T) {
	t.Parallel()

	const secret = "test-secret-with-enough-bytes"
	v := mustValidator(t, secret)
	tok := mintToken(t, secret, jwt.MapClaims{
		"sub": "user-1",
		"exp": time.Now().Add(15 * time.Minute).Unix(),
	})

	if _, err := v.Validate(context.Background(), tok); err == nil {
		t.Error("expected error for missing claims")
	}
}

func TestContextRoundTrip(t *testing.T) {
	t.Parallel()
	c := &Claims{UserID: "u"}
	ctx := ContextWithClaims(context.Background(), c)
	if got := ClaimsFromContext(ctx); got != c {
		t.Errorf("claims not retrieved")
	}
}
