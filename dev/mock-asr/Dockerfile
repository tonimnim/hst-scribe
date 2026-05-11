# syntax=docker/dockerfile:1.7
#
# mock-asr — multi-stage build that produces a tiny static binary.
# Build context is dev/mock-asr/ (this folder); seed file is mounted at run time.

FROM golang:1.24-alpine AS build
WORKDIR /src

# Cache deps separately so source edits don't bust the module download layer.
COPY go.mod go.sum ./
RUN go mod download

COPY . .
# CGO_ENABLED=0 → static binary; -trimpath strips build host paths from binaries.
ENV CGO_ENABLED=0 GOOS=linux GOFLAGS=-trimpath
RUN go build -ldflags="-s -w" -o /out/mock-asr ./cmd/mock-asr

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=build /out/mock-asr /app/mock-asr

ENV PORT=8091 \
    SEED_PATH=/seed/utterances.json \
    EMIT_INTERVAL_MS=5000

EXPOSE 8091
USER nonroot:nonroot
ENTRYPOINT ["/app/mock-asr"]
