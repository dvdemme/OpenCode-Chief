# install.ps1 - install "OpenCode Chief" into your global opencode (Windows / PowerShell).
#
# Links agents, skills, and commands, cleans up OpenCode-Commander leftovers,
# and verifies the install.
# API keys are configured with `opencode auth login`, not by this script.
#
# Usage:  powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = "Stop"

function Say($m) { Write-Host $m }
function Ok($m)  { Write-Host "OK  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "!   $m" -ForegroundColor Yellow }

$Cfg = if ($env:OPENCODE_CONFIG_DIR) { $env:OPENCODE_CONFIG_DIR } else { Join-Path $HOME ".config\opencode" }

Say "OpenCode Chief - installation (Windows)"

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
  Warn "opencode not found in PATH. Install it first from https://opencode.ai"
  exit 1
}
Ok "opencode found ($(opencode --version 2>$null | Select-Object -First 1))"

# Migration from OpenCode-Commander: remove the old names (idempotent).
foreach ($a in @("commander","rocket","rover","hubble","antenna","quasar")) {
  $old = Join-Path $Cfg "agent\$a.md"
  if (Test-Path $old) { Remove-Item $old -Force; Say "  removed old agent: $a.md" }
}
foreach ($f in @((Join-Path $Cfg "pricing.md"), (Join-Path $Cfg "scripts\telemetry.py"))) {
  if (Test-Path $f) { Remove-Item $f -Force; Say "  removed legacy file: $f" }
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Warn "node not found: using the PowerShell fallback."
  & (Join-Path $PSScriptRoot "scripts\ensure-links.ps1")
} else {
  & node (Join-Path $PSScriptRoot "scripts\ensure-links.mjs")
}

Say ""
Say "Done. Restart opencode and run:  opencode"
Say "API keys are configured with:  opencode auth login"
