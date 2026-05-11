# PowerShell equivalent of `make run-gateway`.
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
go run ./cmd/gateway
