package obs

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
)

// RunSkeleton boots a minimal HST Scribe service: load config (with
// serviceName + defaultAddr fallbacks), build a logger, expose
// /healthz, and block until SIGTERM. Used by all cmd/<service>/main.go
// skeletons other than the gateway.
//
// It exists so each Phase-B service entrypoint stays ~5 lines, and so
// the standard health/shutdown/log shape is identical across services.
//
// Environment overrides (SERVICE_NAME, HTTP_ADDR) always win over the
// arguments — operators can pin any port at deploy time.
func RunSkeleton(serviceName, defaultAddr string) {
	cfg, err := config.Load()
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s: config: %v\n", serviceName, err)
		os.Exit(1)
	}
	// If the operator did not set SERVICE_NAME, default to the binary
	// identity. config.Load defaults SERVICE_NAME to "gateway", so we
	// treat that as "unset" for non-gateway binaries.
	if os.Getenv("SERVICE_NAME") == "" {
		cfg.ServiceName = serviceName
	}
	// Likewise, if HTTP_ADDR was not set, use this binary's default port.
	if os.Getenv("HTTP_ADDR") == "" && defaultAddr != "" {
		cfg.HTTPAddr = defaultAddr
	}

	logger := NewLogger(cfg)
	logger.Info("service starting",
		slog.String("addr", cfg.HTTPAddr),
		slog.String("env", string(cfg.Env)),
	)

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(LoggingMiddleware(logger))
	r.Use(httperr.Recoverer(logger))
	r.Get("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]string{
			"status":  "ok",
			"service": serviceName,
		})
	})

	srv := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           r,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}
	shutdownTimeout := time.Duration(cfg.ShutdownTimeoutSeconds) * time.Second
	if err := RunHTTPServer(context.Background(), logger, srv, shutdownTimeout); err != nil {
		logger.Error("server stopped with error", slog.String("err", err.Error()))
		os.Exit(1)
	}
}
