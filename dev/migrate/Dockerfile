# syntax=docker/dockerfile:1.7
#
# One-shot migration runner. Builds pressly/goose v3 from source into a
# distroless container. We build our own because there is no official
# ghcr.io/pressly/goose image — community images exist but pinning to a
# locally-built binary keeps the supply chain inside this repo's control.
#
# Usage (from docker-compose):
#   command: ["-dir", "/migrations", "postgres", "$POSTGRES_DSN", "up"]

FROM golang:1.24-alpine AS build

# Pin to a concrete v3 release rather than @latest so reproducible builds
# don't drift. Bump deliberately when goose v3 ships fixes we want.
ARG GOOSE_VERSION=v3.22.1

WORKDIR /src
ENV CGO_ENABLED=0 GOOS=linux GOFLAGS=-trimpath
RUN go install -ldflags="-s -w" github.com/pressly/goose/v3/cmd/goose@${GOOSE_VERSION}

# --- runtime ---
FROM gcr.io/distroless/static:nonroot

# /go/bin is goose's install destination from GOPATH default.
COPY --from=build /go/bin/goose /app/goose

USER nonroot:nonroot
ENTRYPOINT ["/app/goose"]
