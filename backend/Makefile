# HST Scribe backend — Make targets
# Windows devs without make: see scripts/*.ps1 for PowerShell equivalents.

GO        ?= go
GOLINT    ?= golangci-lint

.PHONY: all build run-gateway test lint fmt tidy vet migrate-up migrate-down clean

all: fmt vet lint test build

build:
	$(GO) build ./...

run-gateway:
	$(GO) run ./cmd/gateway

test:
	$(GO) test -race -cover ./...

lint:
	$(GOLINT) run ./...

fmt:
	gofmt -s -w .
	@command -v goimports >/dev/null 2>&1 && goimports -w . || true

vet:
	$(GO) vet ./...

tidy:
	$(GO) mod tidy

# TODO(phase-b): wire to pressly/goose. We will commit to goose because it
# supports embedded SQL + a Go-callable migration runner from main, which we
# want for one-shot dev bootstrap. golang-migrate is the runner-up.
migrate-up:
	@echo "migrate-up: not implemented yet (planned: pressly/goose against ./migrations)"

migrate-down:
	@echo "migrate-down: not implemented yet (planned: pressly/goose against ./migrations)"

clean:
	$(GO) clean ./...
