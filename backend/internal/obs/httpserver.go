package obs

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os/signal"
	"syscall"
	"time"
)

// RunHTTPServer starts srv on a background goroutine and blocks until
// ctx is done OR a SIGTERM/SIGINT is received. On shutdown it waits up
// to shutdownTimeout for in-flight requests to finish.
//
// Returns nil on clean shutdown, error otherwise.
func RunHTTPServer(parent context.Context, logger *slog.Logger, srv *http.Server, shutdownTimeout time.Duration) error {
	ctx, stop := signal.NotifyContext(parent, syscall.SIGINT, syscall.SIGTERM)
	defer stop()

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
	case <-ctx.Done():
		logger.Info("shutdown signal received; draining",
			slog.Duration("timeout", shutdownTimeout),
		)
	case err := <-errCh:
		return err
	}

	// Intentional fresh context: at this point the parent ctx is Done
	// (that's how we got here), but we still want to give in-flight
	// requests up to shutdownTimeout to finish.
	shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(parent), shutdownTimeout)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		return fmt.Errorf("shutdown: %w", err)
	}
	// Wait for ListenAndServe to return after Shutdown.
	if err := <-errCh; err != nil {
		return err
	}
	logger.Info("http server stopped cleanly")
	return nil
}
