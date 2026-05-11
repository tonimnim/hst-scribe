# PowerShell equivalent of `make fmt`.
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
gofmt -s -w .
if (Get-Command goimports -ErrorAction SilentlyContinue) {
  goimports -w .
}
