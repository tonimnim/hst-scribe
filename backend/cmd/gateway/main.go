// Command gateway is the public-facing HST Scribe ingress: REST API +
// WebSocket session stream. It owns the contract surface between the
// mobile app and the rest of the backend.
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/caarlos0/env/v11"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"

	"github.com/tonimnim/hst-scribe/backend/cmd/gateway/handlers"
	"github.com/tonimnim/hst-scribe/backend/internal/auth"
	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/gateway"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/natsbroker"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
)

// gatewayConfig augments the shared config with gateway-only env vars.
// Keeping the structure here avoids polluting internal/config with
// fields no other service uses.
type gatewayConfig struct {
	// SessionManagerURL is the base URL of the session-manager
	// service. Used for internal RPCs (create session, sign, etc.).
	SessionManagerURL string `env:"SESSION_MANAGER_URL" envDefault:"http://localhost:8081"`

	// EChartBaseURL is the base URL of the eChart service (or the
	// dev mock).
	EChartBaseURL string `env:"ECHART_BASE_URL" envDefault:"http://localhost:8090"`

	// InternalSvcToken is the bearer presented on inter-service HTTP
	// calls (session-manager, eChart). Empty in dev disables the
	// header.
	InternalSvcToken string `env:"INTERNAL_SVC_TOKEN" envDefault:""`

	// WSSPublicBaseURL is the externally-routable base used to mint
	// wss_url in POST /sessions responses (e.g. wss://api.example).
	WSSPublicBaseURL string `env:"WSS_PUBLIC_BASE_URL" envDefault:"ws://localhost:8080"`

	// WSAllowedOrigins is a comma-separated list of host patterns the
	// WSS Accept will trust for cross-origin upgrades. Same-host
	// upgrades are always allowed.
	WSAllowedOrigins []string `env:"WS_ALLOWED_ORIGINS" envSeparator:"," envDefault:""`

	// AccessTokenTTLSeconds bounds refreshed access tokens.
	AccessTokenTTLSeconds int `env:"ACCESS_TOKEN_TTL_SECONDS" envDefault:"900"`
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "gateway: fatal: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}
	if cfg.ServiceName == "" {
		cfg.ServiceName = "gateway"
	}

	var gwCfg gatewayConfig
	if err := env.Parse(&gwCfg); err != nil {
		return fmt.Errorf("loading gateway config: %w", err)
	}

	logger := obs.NewLogger(cfg)
	logger.Info("gateway starting",
		slog.String("env", string(cfg.Env)),
		slog.String("session_manager_url", gwCfg.SessionManagerURL),
		slog.String("echart_url", gwCfg.EChartBaseURL),
	)

	validator, err := auth.NewHMACValidator(cfg)
	if err != nil {
		return fmt.Errorf("building auth validator: %w", err)
	}

	rootCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	// Tracing first: every downstream constructor below may emit spans,
	// and inter-service HTTP clients need the global propagator wired.
	tracingCfg := obs.TracingConfig{ServiceName: cfg.ServiceName, Env: string(cfg.Env)}
	shutdownTracing, err := obs.InitTracing(rootCtx, tracingCfg)
	if err != nil {
		return fmt.Errorf("init tracing: %w", err)
	}
	obs.LogTracingInit(logger, tracingCfg)
	defer func() {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := shutdownTracing(shutdownCtx); err != nil {
			logger.Warn("tracing shutdown", slog.String("err", err.Error()))
		}
	}()

	// Inter-service HTTP clients in gateway/* construct http.Client values
	// without an explicit Transport, so they pick up http.DefaultTransport.
	// Wrapping the default transport here propagates W3C traceparent on
	// gateway → session-manager and gateway → eChart calls. One-line wrap.
	http.DefaultTransport = otelhttp.NewTransport(http.DefaultTransport)

	nc, err := natsbroker.NewConn(rootCtx, cfg, logger)
	if err != nil {
		return fmt.Errorf("connecting nats: %w", err)
	}
	defer func() {
		if err := nc.Close(); err != nil {
			logger.Warn("nats close", slog.String("err", err.Error()))
		}
	}()

	sessionClient, err := gateway.NewSessionManagerClient(gateway.SessionManagerOptions{
		BaseURL:       gwCfg.SessionManagerURL,
		InternalToken: gwCfg.InternalSvcToken,
		Timeout:       5 * time.Second,
	})
	if err != nil {
		return fmt.Errorf("building session-manager client: %w", err)
	}

	echartClient, err := gateway.NewEChartClient(gateway.EChartOptions{
		BaseURL:       gwCfg.EChartBaseURL,
		Timeout:       5 * time.Second,
		InternalToken: gwCfg.InternalSvcToken,
	})
	if err != nil {
		return fmt.Errorf("building echart client: %w", err)
	}

	publisher, subscriber := gateway.FromConn(nc)
	registry := gateway.NewSessionRegistry()

	wsServer := &gateway.WSServer{
		Logger:        logger,
		SessionClient: sessionClient,
		EChartClient:  echartClient,
		Publisher:     publisher,
		Subscriber:    subscriber,
		Validator:     validator,
		Registry:      registry,
		Capabilities: contract.ServerCapabilities{
			VoiceCommands: true,
			Diarization:   true,
		},
		OriginPatterns: gwCfg.WSAllowedOrigins,
	}

	rest := handlers.NewREST(handlers.Deps{
		Logger:         logger,
		SessionClient:  sessionClient,
		EChartClient:   echartClient,
		Publisher:      publisher,
		Validator:      validator,
		Registry:       registry,
		JWTSecret:      cfg.JWTSecret,
		AccessTokenTTL: time.Duration(gwCfg.AccessTokenTTLSeconds) * time.Second,
		WSSBaseURL:     gwCfg.WSSPublicBaseURL,
	})

	r := buildRouter(logger, validator, rest, wsServer)

	srv := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           r,
		ReadHeaderTimeout: 5 * time.Second,
		// No ReadTimeout / WriteTimeout — those would forcibly kill
		// long-running WSS upgrades. Per-frame deadlines live in
		// the WSS handler.
		IdleTimeout: 120 * time.Second,
	}

	shutdownTimeout := time.Duration(cfg.ShutdownTimeoutSeconds) * time.Second
	return runWithGracefulShutdown(rootCtx, logger, srv, wsServer, shutdownTimeout)
}

func buildRouter(logger *slog.Logger, validator auth.Validator, rest *handlers.REST, ws *gateway.WSServer) http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(obs.TracingMiddleware("gateway"))
	r.Use(obs.LoggingMiddleware(logger))
	r.Use(obs.MetricsMiddleware("gateway"))
	r.Use(httperr.Recoverer(logger))

	r.Get("/healthz", healthHandler)
	obs.MountMetrics(r)

	// Authenticated REST surface.
	r.Route("/api/v1", func(r chi.Router) {
		r.Group(func(r chi.Router) {
			r.Use(auth.Authenticator(validator))

			r.Post("/sessions", rest.CreateSession)
			r.Get("/sessions/{id}", rest.GetSession)
			r.Patch("/sessions/{id}/events/{event_id}", rest.EditEvent)
			r.Post("/sessions/{id}/events/{event_id}/confirm", rest.ConfirmEvent)
			r.Post("/sessions/{id}/events/{event_id}/reject", rest.RejectEvent)
			r.Post("/sessions/{id}/sign", rest.SignSession)

			r.Post("/auth/refresh", rest.RefreshAuth)
		})

		// WSS: header auth attempts first; the handler falls back to
		// ?token= if no claims are on the context.
		r.Group(func(r chi.Router) {
			r.Use(optionalAuth(validator))
			r.Get("/sessions/{session_id}/stream", ws.HandleStream)
		})
	})

	return r
}

// optionalAuth runs the validator if Authorization is present, but
// does NOT return 401 on failure — the WSS handler will retry against
// ?token= and fail-closed there.
func optionalAuth(v auth.Validator) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if hdr := r.Header.Get("Authorization"); hdr != "" {
				if c, err := v.Validate(r.Context(), hdr); err == nil {
					r = r.WithContext(auth.ContextWithClaims(r.Context(), c))
				}
			}
			next.ServeHTTP(w, r)
		})
	}
}

func healthHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(map[string]string{"status": "ok"}); err != nil {
		_ = err
	}
}

// runWithGracefulShutdown mirrors obs.RunHTTPServer but with a pre-step
// that closes every live WSS session before HTTP shutdown drains.
func runWithGracefulShutdown(parent context.Context, logger *slog.Logger, srv *http.Server, ws *gateway.WSServer, timeout time.Duration) error {
	errCh := make(chan error, 1)
	go func() {
		logger.Info("http server listening", slog.String("addr", srv.Addr))
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- fmt.Errorf("listen: %w", err)
			return
		}
		errCh <- nil
	}()

	select {
	case <-parent.Done():
		logger.Info("shutdown signal received; draining", slog.Duration("timeout", timeout))
	case err := <-errCh:
		return err
	}

	shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(parent), timeout)
	defer cancel()

	// Tell every open WSS client we are going away so the mobile app
	// can reconnect to whoever takes over.
	ws.CloseAll(shutdownCtx)

	if err := srv.Shutdown(shutdownCtx); err != nil {
		return fmt.Errorf("shutdown: %w", err)
	}
	if err := <-errCh; err != nil {
		return err
	}
	logger.Info("http server stopped cleanly")
	return nil
}
