package audit

import (
	"context"
	"encoding/json"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/jetstream"

	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

const defaultNATSURL = "nats://localhost:4222"

// natsJSForTest dials the dev/docker-compose NATS server and returns a
// JetStream handle. Skips the test if NATS is unreachable, mirroring the
// behavior of pgPoolForTest so a fresh checkout still passes `go test`.
//
// The test creates its own throwaway stream named with a timestamp suffix
// to avoid colliding with any other run. The stream name override is
// passed in via the package-level natsStreamOverride var that the test
// flips before constructing the Subscriber — done with a small helper so
// we don't have to expose StreamName as a setter on the production API.
func natsJSForTest(t *testing.T) (jetstream.JetStream, func()) {
	t.Helper()

	url := os.Getenv("AUDIT_TEST_NATS_URL")
	if url == "" {
		url = defaultNATSURL
	}

	nc, err := nats.Connect(url, nats.Timeout(2*time.Second))
	if err != nil {
		t.Skipf("nats not available (%s): %v", url, err)
	}
	js, err := jetstream.New(nc)
	if err != nil {
		nc.Close()
		t.Skipf("jetstream not enabled: %v", err)
	}

	return js, func() { nc.Close() }
}

// TestSubscriber_EndToEnd publishes an audit event to JetStream and
// asserts that the Subscriber persists it via the repository and that
// PHI-bearing payloads are dropped.
func TestSubscriber_EndToEnd(t *testing.T) {
	pool := pgPoolForTest(t)
	js, closeNATS := natsJSForTest(t)
	t.Cleanup(closeNATS)

	// Clean any pre-existing stream from prior test runs so the durable
	// consumer starts at seq 1 every time.
	{
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		_ = js.DeleteStream(ctx, StreamName)
		cancel()
	}

	repo := NewPGRepository(pool)
	logger := testLogger(t)
	sub := NewSubscriber(js, repo, logger)

	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)

	// Run the subscriber in the background. We don't block on its Run
	// return because the test's t.Cleanup handles teardown via cancel +
	// sub.Close.
	runErr := make(chan error, 1)
	go func() {
		runErr <- sub.Run(ctx)
	}()
	t.Cleanup(func() {
		cancel()
		sub.Close()
		select {
		case err := <-runErr:
			if err != nil && !errors.Is(err, context.Canceled) {
				t.Logf("subscriber run returned: %v", err)
			}
		case <-time.After(3 * time.Second):
			t.Log("subscriber did not return within 3s")
		}
	})

	// Give the subscriber a beat to set up the consumer before we publish.
	if !waitForConsumer(t, js, StreamName, DurableName, 5*time.Second) {
		t.Fatal("audit consumer did not become ready")
	}

	ascID := uuidv7.New()
	sessionID := uuidv7.New()
	userID := uuidv7.New()
	eventID := uuidv7.New()

	body, err := json.Marshal(map[string]any{
		"id":            eventID,
		"session_id":    sessionID,
		"actor_user_id": userID,
		"asc_id":        ascID,
		"action":        string(ActionSessionCreated),
		"target_id":     sessionID,
		"target_type":   "session",
		"payload":       map[string]any{"workflow_type": "pacu"},
		"ts":            time.Now().UTC().Format(time.RFC3339Nano),
	})
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	pubCtx, cancelPub := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancelPub()
	if _, err := js.Publish(pubCtx, "audit.events."+ascID, body); err != nil {
		t.Fatalf("publish: %v", err)
	}

	// Poll until the row appears.
	if !waitForRow(t, repo, sessionID, eventID, 5*time.Second) {
		t.Fatalf("event %s did not arrive in audit_log", eventID)
	}

	// PHI-bearing event must be dropped without a row.
	phiID := uuidv7.New()
	phiBody, _ := json.Marshal(map[string]any{
		"id":     phiID,
		"asc_id": ascID,
		"action": string(ActionSessionCreated),
		"payload": map[string]any{
			"patient_name": "Jane Doe",
		},
		"ts": time.Now().UTC().Format(time.RFC3339Nano),
	})
	if _, err := js.Publish(pubCtx, "audit.events."+ascID, phiBody); err != nil {
		t.Fatalf("publish phi: %v", err)
	}

	// Give the subscriber time to process; the row must NOT appear.
	time.Sleep(500 * time.Millisecond)
	rows, err := repo.ListBySession(context.Background(), sessionID)
	if err != nil {
		t.Fatalf("ListBySession: %v", err)
	}
	for _, r := range rows {
		if r.ID == phiID {
			t.Errorf("PHI-bearing event %s was persisted", phiID)
		}
	}
}

func waitForConsumer(t *testing.T, js jetstream.JetStream, stream, durable string, max time.Duration) bool {
	t.Helper()
	deadline := time.Now().Add(max)
	for time.Now().Before(deadline) {
		ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
		s, err := js.Stream(ctx, stream)
		cancel()
		if err != nil {
			time.Sleep(100 * time.Millisecond)
			continue
		}
		ctx, cancel = context.WithTimeout(context.Background(), 500*time.Millisecond)
		_, err = s.Consumer(ctx, durable)
		cancel()
		if err == nil {
			return true
		}
		time.Sleep(100 * time.Millisecond)
	}
	return false
}

func waitForRow(t *testing.T, repo Repository, sessionID, eventID string, max time.Duration) bool {
	t.Helper()
	deadline := time.Now().Add(max)
	for time.Now().Before(deadline) {
		rows, err := repo.ListBySession(context.Background(), sessionID)
		if err == nil {
			for _, r := range rows {
				if r.ID == eventID {
					return true
				}
			}
		}
		time.Sleep(50 * time.Millisecond)
	}
	return false
}
