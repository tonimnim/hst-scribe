// Package auth validates JWT bearer tokens for HST Scribe services.
//
// Phase 0 uses HMAC (HS256) against config.JWTSecret for local/pilot.
// Phase B will swap this for JWKS-backed RS256/ES256 from the HST IdP;
// the Validator interface is the extension point.
package auth

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
)

// Role names recognized in the JWT claim "role".
type Role string

// Role values recognized in the JWT "role" claim.
const (
	RoleNurse  Role = "nurse"
	RoleAdmin  Role = "admin"
	RoleSystem Role = "system"
)

// Claims is the verified, type-safe view of an HST Scribe access token.
type Claims struct {
	UserID    string
	ASCID     string
	Role      Role
	Subject   string
	ExpiresAt time.Time
}

// Validator verifies a raw bearer token and returns the typed Claims.
// Implementations must be safe for concurrent use.
type Validator interface {
	Validate(ctx context.Context, bearer string) (*Claims, error)
}

// HMACValidator validates HS256 tokens against a shared secret. This is
// the dev/pilot default; production replaces it with a JWKS validator.
type HMACValidator struct {
	secret []byte
	parser *jwt.Parser
}

// NewHMACValidator builds an HMAC-based Validator from cfg.JWTSecret.
// An empty secret returns an error — fail-closed.
func NewHMACValidator(cfg *config.Config) (*HMACValidator, error) {
	if cfg.JWTSecret == "" {
		return nil, errors.New("JWT_SECRET is empty; refusing to start fail-open auth")
	}
	return &HMACValidator{
		secret: []byte(cfg.JWTSecret),
		parser: jwt.NewParser(
			jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Name}),
			jwt.WithExpirationRequired(),
		),
	}, nil
}

// Validate parses a token of the form "Bearer <jwt>" (or bare "<jwt>")
// and returns typed claims. The wrapped error is always a *httperr.Error
// so handlers can return it directly.
func (v *HMACValidator) Validate(_ context.Context, bearer string) (*Claims, error) {
	raw := strings.TrimSpace(bearer)
	if raw == "" {
		return nil, httperr.AuthInvalid("missing bearer token")
	}
	if strings.HasPrefix(strings.ToLower(raw), "bearer ") {
		raw = strings.TrimSpace(raw[len("bearer "):])
	}
	if raw == "" {
		return nil, httperr.AuthInvalid("empty bearer token")
	}

	token, err := v.parser.Parse(raw, func(_ *jwt.Token) (any, error) {
		return v.secret, nil
	})
	if err != nil {
		return nil, httperr.AuthInvalid(fmt.Sprintf("invalid token: %s", err.Error()))
	}
	if !token.Valid {
		return nil, httperr.AuthInvalid("token rejected")
	}

	mc, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, httperr.AuthInvalid("unexpected claims shape")
	}

	sub, _ := mc["sub"].(string)
	userID, _ := mc["user_id"].(string)
	if userID == "" {
		userID = sub
	}
	ascID, _ := mc["asc_id"].(string)
	role, _ := mc["role"].(string)

	exp, err := mc.GetExpirationTime()
	if err != nil || exp == nil {
		return nil, httperr.AuthInvalid("missing exp")
	}
	if userID == "" || ascID == "" || role == "" {
		return nil, httperr.AuthInvalid("missing required claim (user_id, asc_id, role)")
	}

	return &Claims{
		UserID:    userID,
		ASCID:     ascID,
		Role:      Role(role),
		Subject:   sub,
		ExpiresAt: exp.Time,
	}, nil
}

// --- context plumbing ---

type ctxKey struct{}

// ContextWithClaims returns ctx with claims attached.
func ContextWithClaims(ctx context.Context, c *Claims) context.Context {
	return context.WithValue(ctx, ctxKey{}, c)
}

// ClaimsFromContext returns the claims previously attached to ctx, or
// nil if none. Callers must check for nil.
func ClaimsFromContext(ctx context.Context) *Claims {
	c, _ := ctx.Value(ctxKey{}).(*Claims)
	return c
}
