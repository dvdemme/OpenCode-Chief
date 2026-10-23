# install.ps1 — installa "OpenCode Chief" nel tuo opencode globale (Windows / PowerShell).
#
# Collega agenti, skill e comandi e verifica l'installazione.
# Le chiavi API si configurano con `opencode auth login`, non da questo script.
#
# Uso:  powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = "Stop"

function Say($m) { Write-Host $m }
function Ok($m)  { Write-Host "OK  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "!   $m" -ForegroundColor Yellow }

Say "OpenCode Chief — installazione (Windows)"

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
  Warn "opencode non trovato nel PATH. Installalo prima da https://opencode.ai"
  exit 1
}
Ok "opencode trovato ($(opencode --version 2>$null | Select-Object -First 1))"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Warn "node non trovato: uso il fallback PowerShell."
  & (Join-Path $PSScriptRoot "scripts\ensure-links.ps1")
} else {
  & node (Join-Path $PSScriptRoot "scripts\ensure-links.mjs")
}

Say ""
Say "Fatto. Riavvia opencode e lancia:  opencode"
Say "Le chiavi si configurano con:  opencode auth login"
