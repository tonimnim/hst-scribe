// Package auth validates JWT bearer tokens for HST Scribe services.
//
// Two validator paths are wired into the gateway:
//
//   - HMACValidator validates HS256 tokens against config.JWTSecret. It
//     is the local/dev default and the only path used in unit tests.
//   - JWKSValidator validates RS256/ES256 tokens against a remote JWKS
//     document published by the HST IdP. It is the production path.
//
// In environments where both are configured, MultiValidator tries the
// JWKS path first and falls back to HMAC only in dev — production
// surfaces the primary error directly and never lets a dev-minted token
// in.
package auth

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
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

// --- MultiValidator: JWKS primary with HMAC fallback in dev ---

// MultiValidator tries Primary first; on failure it falls back to
// Fallback iff Env == dev. In staging/prod the Primary error is
// returned directly so a leaked dev secret can never validate a token.
type MultiValidator struct {
	Primary  Validator
	Fallback Validator
	Env      config.Env
	Logger   *slog.Logger
}

// Validate implements Validator. The fallback path is only attempted in
// dev so non-dev environments fail closed if JWKS itself is the
// configured path.
func (m MultiValidator) Validate(ctx context.Context, bearer string) (*Claims, error) {
	if m.Primary == nil {
		if m.Fallback == nil {
			return nil, httperr.AuthInvalid("no validator configured")
		}
		return m.Fallback.Validate(ctx, bearer)
	}

	c, err := m.Primary.Validate(ctx, bearer)
	if err == nil {
		return c, nil
	}
	if m.Fallback == nil || m.Env != config.EnvDev {
		return nil, err
	}

	fc, ferr := m.Fallback.Validate(ctx, bearer)
	if ferr != nil {
		// Surface the primary error: it's the canonical configured
		// path. Fallback is a dev convenience, not a parallel system.
		return nil, err
	}
	if m.Logger != nil {
		m.Logger.Warn("auth: dev HMAC fallback accepted a token rejected by JWKS",
			slog.String("user_id", fc.UserID),
			slog.String("asc_id", fc.ASCID),
			slog.String("role", string(fc.Role)),
		)
	}
	return fc, nil
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
