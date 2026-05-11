package auth

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rsa"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"net/url"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"

	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
)

// JWKSConfig configures the JWKS validator. When IssuerURL is set and
// JWKSURL is empty, the validator discovers the JWKS URL from
// IssuerURL/.well-known/jwks.json.
type JWKSConfig struct {
	// IssuerURL is the OIDC issuer URL. Required. Also used to validate
	// the `iss` claim on every token.
	IssuerURL string

	// JWKSURL overrides the default IssuerURL/.well-known/jwks.json
	// discovery path. Optional.
	JWKSURL string

	// Audience is the expected `aud` claim value. Required in non-dev
	// environments; empty disables audience checking.
	Audience string

	// CacheTTL is how long a successfully fetched JWKS document is kept
	// before a synchronous refresh. Default: 1h.
	CacheTTL time.Duration

	// RefreshTimeout caps each HTTP fetch of the JWKS document.
	// Default: 5s.
	RefreshTimeout time.Duration

	// AllowedAlgorithms restricts the signing algorithms the validator
	// will trust. JWKS validation explicitly rejects `none` and all
	// HS* algorithms regardless of this setting. Default:
	// {RS256, ES256}.
	AllowedAlgorithms []string

	// HTTPClient overrides the HTTP client used for JWKS fetches.
	// Mostly useful in tests. Default: a client with a 5s timeout.
	HTTPClient *http.Client
}

// Enabled reports whether the JWKS validator should be wired up. The
// gateway falls back to HMAC-only auth when this is false.
func (c JWKSConfig) Enabled() bool {
	return c.IssuerURL != "" || c.JWKSURL != ""
}

// LoadJWKSConfigFromEnv reads JWKS settings from the standard env vars.
// Returns an empty (disabled) config when no JWKS vars are set.
func LoadJWKSConfigFromEnv() JWKSConfig {
	return JWKSConfig{
		IssuerURL:      strings.TrimSpace(os.Getenv("JWKS_ISSUER_URL")),
		JWKSURL:        strings.TrimSpace(os.Getenv("JWKS_URL")),
		Audience:       strings.TrimSpace(os.Getenv("JWKS_AUDIENCE")),
		CacheTTL:       envDuration("JWKS_CACHE_TTL", time.Hour),
		RefreshTimeout: envDuration("JWKS_REFRESH_TIMEOUT", 5*time.Second),
	}
}

func envDuration(name string, def time.Duration) time.Duration {
	raw := strings.TrimSpace(os.Getenv(name))
	if raw == "" {
		return def
	}
	d, err := time.ParseDuration(raw)
	if err != nil || d <= 0 {
		return def
	}
	return d
}

// JWKSValidator validates RS256/ES256 tokens against a remote JWKS
// document. The key set is cached in memory and refreshed asynchronously
// before TTL expiry; a `kid` cache miss triggers a synchronous refresh
// in case a freshly-rotated key was added.
type JWKSValidator struct {
	cfg     JWKSConfig
	jwksURL string

	client *http.Client
	parser *jwt.Parser

	mu       sync.RWMutex
	keys     map[string]jwksKey // by `kid`
	fetched  time.Time
	refreshM sync.Mutex // serializes background refreshes
}

type jwksKey struct {
	kid       string
	alg       string
	use       string
	publicKey any // *rsa.PublicKey or *ecdsa.PublicKey
}

// NewJWKSValidator builds a validator and performs the initial JWKS
// fetch. It fails closed: if the document can't be retrieved or parsed,
// gateway startup aborts.
func NewJWKSValidator(cfg JWKSConfig) (*JWKSValidator, error) {
	if cfg.IssuerURL == "" && cfg.JWKSURL == "" {
		return nil, errors.New("jwks: IssuerURL or JWKSURL required")
	}
	if cfg.CacheTTL <= 0 {
		cfg.CacheTTL = time.Hour
	}
	if cfg.RefreshTimeout <= 0 {
		cfg.RefreshTimeout = 5 * time.Second
	}
	algos := cfg.AllowedAlgorithms
	if len(algos) == 0 {
		algos = []string{jwt.SigningMethodRS256.Name, jwt.SigningMethodES256.Name}
	}
	for _, a := range algos {
		if a == "none" || strings.HasPrefix(strings.ToUpper(a), "HS") {
			return nil, fmt.Errorf("jwks: algorithm %q is not allowed on the JWKS path", a)
		}
	}

	jwksURL := strings.TrimSpace(cfg.JWKSURL)
	if jwksURL == "" {
		u, err := buildDiscoveryURL(cfg.IssuerURL)
		if err != nil {
			return nil, fmt.Errorf("jwks: deriving discovery URL: %w", err)
		}
		jwksURL = u
	}

	client := cfg.HTTPClient
	if client == nil {
		client = &http.Client{Timeout: cfg.RefreshTimeout}
	}

	v := &JWKSValidator{
		cfg:     cfg,
		jwksURL: jwksURL,
		client:  client,
		keys:    map[string]jwksKey{},
		parser: jwt.NewParser(
			jwt.WithValidMethods(algos),
			jwt.WithExpirationRequired(),
		),
	}

	ctx, cancel := context.WithTimeout(context.Background(), cfg.RefreshTimeout)
	defer cancel()
	if err := v.refresh(ctx); err != nil {
		return nil, fmt.Errorf("jwks: initial fetch %s: %w", jwksURL, err)
	}
	return v, nil
}

// JWKSURL returns the resolved JWKS endpoint. Exported for diagnostics
// and tests.
func (v *JWKSValidator) JWKSURL() string { return v.jwksURL }

// Validate parses the bearer token, looks up its `kid` against the
// cached JWKS, verifies signature + iss/aud/exp/nbf, and returns the
// typed claims. Returns a *httperr.Error on every failure path so
// callers can write the wire envelope directly.
func (v *JWKSValidator) Validate(ctx context.Context, bearer string) (*Claims, error) {
	raw := stripBearer(bearer)
	if raw == "" {
		return nil, httperr.AuthInvalid("missing bearer token")
	}

	// Refresh asynchronously before TTL expires so steady-state
	// requests never block on the network.
	v.maybeAsyncRefresh(ctx)

	token, err := v.parser.Parse(raw, v.keyFunc(ctx))
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

	if v.cfg.IssuerURL != "" {
		if iss, _ := mc["iss"].(string); iss != v.cfg.IssuerURL {
			return nil, httperr.AuthInvalid("iss claim mismatch")
		}
	}
	if v.cfg.Audience != "" {
		if !audienceMatches(mc["aud"], v.cfg.Audience) {
			return nil, httperr.AuthInvalid("aud claim mismatch")
		}
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
	if sub == "" {
		return nil, httperr.AuthInvalid("missing sub")
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

// keyFunc looks up the signing key by `kid`. On miss it triggers a
// synchronous refresh once — the IdP may have rotated keys between our
// last cached fetch and this token's issuance.
func (v *JWKSValidator) keyFunc(ctx context.Context) jwt.Keyfunc {
	return func(token *jwt.Token) (any, error) {
		// Defense in depth: the parser already enforces WithValidMethods,
		// but reject HS* / none here too so a misconfigured AllowedAlgorithms
		// can't ever accept a symmetric token on the JWKS path.
		alg, _ := token.Header["alg"].(string)
		if alg == "" || alg == "none" || strings.HasPrefix(strings.ToUpper(alg), "HS") {
			return nil, fmt.Errorf("disallowed algorithm %q", alg)
		}

		kid, _ := token.Header["kid"].(string)
		if kid == "" {
			return nil, errors.New("missing kid header")
		}

		if k, ok := v.lookup(kid); ok {
			return k.publicKey, nil
		}

		// kid miss — try one synchronous refresh.
		rctx, cancel := context.WithTimeout(ctx, v.cfg.RefreshTimeout)
		defer cancel()
		if err := v.refresh(rctx); err != nil {
			return nil, fmt.Errorf("refresh on kid miss: %w", err)
		}
		if k, ok := v.lookup(kid); ok {
			return k.publicKey, nil
		}
		return nil, fmt.Errorf("kid %q not found in JWKS", kid)
	}
}

func (v *JWKSValidator) lookup(kid string) (jwksKey, bool) {
	v.mu.RLock()
	defer v.mu.RUnlock()
	k, ok := v.keys[kid]
	return k, ok
}

// maybeAsyncRefresh kicks off a background refresh when the cached
// JWKS is older than 80% of CacheTTL. Only one refresh runs at a time;
// callers don't block.
func (v *JWKSValidator) maybeAsyncRefresh(ctx context.Context) {
	v.mu.RLock()
	age := time.Since(v.fetched)
	v.mu.RUnlock()

	threshold := v.cfg.CacheTTL * 4 / 5
	if age < threshold {
		return
	}
	if !v.refreshM.TryLock() {
		return
	}
	go func() {
		defer v.refreshM.Unlock()
		// Detach from the caller's ctx — its deadline is the request's,
		// not the refresh's. We still cap at RefreshTimeout.
		rctx, cancel := context.WithTimeout(context.WithoutCancel(ctx), v.cfg.RefreshTimeout)
		defer cancel()
		_ = v.refresh(rctx) // background; on failure we keep serving cached keys until expiry
	}()
}

// refresh pulls the JWKS document and atomically swaps the cache.
func (v *JWKSValidator) refresh(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, v.jwksURL, nil)
	if err != nil {
		return fmt.Errorf("building request: %w", err)
	}
	req.Header.Set("Accept", "application/json")

	resp, err := v.client.Do(req)
	if err != nil {
		return fmt.Errorf("fetching: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unexpected status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20)) // 1 MiB cap
	if err != nil {
		return fmt.Errorf("reading body: %w", err)
	}

	var doc jwksDocument
	if err := json.Unmarshal(body, &doc); err != nil {
		return fmt.Errorf("decoding JWKS: %w", err)
	}

	parsed := make(map[string]jwksKey, len(doc.Keys))
	for _, k := range doc.Keys {
		if k.Use != "" && k.Use != "sig" {
			continue
		}
		if k.Kid == "" {
			continue
		}
		pub, err := k.publicKey()
		if err != nil {
			// Skip keys we can't parse; don't fail the whole refresh —
			// a single bad key shouldn't take down auth.
			continue
		}
		parsed[k.Kid] = jwksKey{
			kid:       k.Kid,
			alg:       k.Alg,
			use:       k.Use,
			publicKey: pub,
		}
	}
	if len(parsed) == 0 {
		return errors.New("JWKS document contained no usable signing keys")
	}

	v.mu.Lock()
	v.keys = parsed
	v.fetched = time.Now()
	v.mu.Unlock()
	return nil
}

// --- JWKS document parsing ---

type jwksDocument struct {
	Keys []jwksRawKey `json:"keys"`
}

type jwksRawKey struct {
	Kty string `json:"kty"`
	Kid string `json:"kid"`
	Alg string `json:"alg"`
	Use string `json:"use"`

	// RSA
	N string `json:"n,omitempty"`
	E string `json:"e,omitempty"`

	// EC
	Crv string `json:"crv,omitempty"`
	X   string `json:"x,omitempty"`
	Y   string `json:"y,omitempty"`
}

// publicKey decodes the JWK into a Go crypto key. Only RSA and EC keys
// are recognized — symmetric (oct) keys are rejected explicitly so a
// JWKS document can never deliver an HMAC secret to this validator.
func (k jwksRawKey) publicKey() (any, error) {
	switch strings.ToUpper(k.Kty) {
	case "RSA":
		nBytes, err := base64.RawURLEncoding.DecodeString(k.N)
		if err != nil {
			return nil, fmt.Errorf("decoding n: %w", err)
		}
		eBytes, err := base64.RawURLEncoding.DecodeString(k.E)
		if err != nil {
			return nil, fmt.Errorf("decoding e: %w", err)
		}
		// e is usually 3 bytes; promote to a 4-byte big-endian int.
		if len(eBytes) > 8 {
			return nil, errors.New("rsa exponent too large")
		}
		padded := make([]byte, 8)
		copy(padded[8-len(eBytes):], eBytes)
		e := int(binary.BigEndian.Uint64(padded))
		if e == 0 {
			return nil, errors.New("rsa exponent is zero")
		}
		return &rsa.PublicKey{
			N: new(big.Int).SetBytes(nBytes),
			E: e,
		}, nil

	case "EC":
		curve, err := ecCurve(k.Crv)
		if err != nil {
			return nil, err
		}
		xBytes, err := base64.RawURLEncoding.DecodeString(k.X)
		if err != nil {
			return nil, fmt.Errorf("decoding x: %w", err)
		}
		yBytes, err := base64.RawURLEncoding.DecodeString(k.Y)
		if err != nil {
			return nil, fmt.Errorf("decoding y: %w", err)
		}
		return &ecdsa.PublicKey{
			Curve: curve,
			X:     new(big.Int).SetBytes(xBytes),
			Y:     new(big.Int).SetBytes(yBytes),
		}, nil

	case "OCT":
		return nil, errors.New("symmetric (oct) keys are not permitted on the JWKS path")
	default:
		return nil, fmt.Errorf("unsupported kty %q", k.Kty)
	}
}

func ecCurve(crv string) (elliptic.Curve, error) {
	switch crv {
	case "P-256":
		return elliptic.P256(), nil
	case "P-384":
		return elliptic.P384(), nil
	case "P-521":
		return elliptic.P521(), nil
	default:
		return nil, fmt.Errorf("unsupported curve %q", crv)
	}
}

// --- helpers ---

func stripBearer(s string) string {
	raw := strings.TrimSpace(s)
	if strings.HasPrefix(strings.ToLower(raw), "bearer ") {
		raw = strings.TrimSpace(raw[len("bearer "):])
	}
	return raw
}

func audienceMatches(claim any, expected string) bool {
	switch v := claim.(type) {
	case string:
		return v == expected
	case []any:
		for _, a := range v {
			if s, ok := a.(string); ok && s == expected {
				return true
			}
		}
	case []string:
		for _, s := range v {
			if s == expected {
				return true
			}
		}
	}
	return false
}

func buildDiscoveryURL(issuer string) (string, error) {
	u, err := url.Parse(issuer)
	if err != nil {
		return "", err
	}
	if u.Scheme == "" || u.Host == "" {
		return "", fmt.Errorf("invalid issuer URL %q", issuer)
	}
	u.Path = strings.TrimRight(u.Path, "/") + "/.well-known/jwks.json"
	return u.String(), nil
}
