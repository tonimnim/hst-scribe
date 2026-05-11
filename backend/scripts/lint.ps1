# PowerShell equivalent of `make lint`.
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
golangci-lint run ./...
