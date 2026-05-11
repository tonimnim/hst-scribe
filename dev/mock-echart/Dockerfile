# syntax=docker/dockerfile:1.7

# --- build stage --------------------------------------------------------
FROM golang:1.24-alpine AS build

WORKDIR /src

# Cache modules first so source edits don't bust the layer.
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Static, stripped binary. CGO off so the resulting binary works in scratch.
ENV CGO_ENABLED=0 GOOS=linux
RUN go build -trimpath -ldflags="-s -w" -o /out/mock-echart .

# --- runtime stage ------------------------------------------------------
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app
COPY --from=build /out/mock-echart /app/mock-echart

ENV PORT=8090 \
    SEED_PATH=/seed/patients.json

EXPOSE 8090

USER nonroot:nonroot
ENTRYPOINT ["/app/mock-echart"]
