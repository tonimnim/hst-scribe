# PowerShell equivalent of `make test`.
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
go test -race -cover ./...
