#!/usr/bin/env bash
#
# install.sh — install "OpenCode Chief" into your global opencode.
#
# Interactive guide: configures the providers (deepseek/xai), links the files
# (agents + skills + commands), and optionally sets chief as the default agent.
#
# Usage:
#   ./install.sh           symlink (recommended: `git pull` updates everything)
#   ./install.sh --copy    copy the files (no automatic updates)
#
# Supported: macOS + Linux (bash 3.2+). Windows: use install.ps1.

set -u

BOLD="$(tput bold 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
RESET="$(tput sgr0 2>/dev/null || printf '')"

CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="symlink"

PROVIDERS="deepseek xai"

say()  { printf '%b\n' "$*"; }
ok()   { say "${GREEN}✓${RESET} $*"; }
warn() { say "${YELLOW}⚠${RESET} $*"; }
err()  { say "${RED}✗${RESET} $*"; }
step() { say ""; say "${BOLD}── $* ──${RESET}"; }

provider_label() { case "$1" in
  deepseek) echo "DeepSeek" ;;
  xai)      echo "xAI (Grok)" ;;
  *)        echo "$1" ;;
esac; }

provider_agents() { case "$1" in
  deepseek) echo "chief, gardener, weeder, mapper, scout" ;;
  xai)      echo "inspector, plan-check" ;;
  *)        echo "?" ;;
esac; }

is_authenticated() { opencode auth list 2>/dev/null | grep -qi "$1"; }

usage() {
  say "Usage: ./install.sh [--copy] [--help]"
  say "  --copy   copy the files instead of creating symlinks"
}

provider_setup() {
  step "Providers (API keys)"
  say "The team uses two vendors; each agent has its own model:"
  say "  ${BOLD}DeepSeek${RESET}  → chief, gardener, weeder, mapper, scout"
  say "  ${BOLD}xAI${RESET}       → inspector, plan-check"
  say "Configure the providers you have a key for; you can skip the others."
  say ""
  local id label agents skipped=""
  for id in $PROVIDERS; do
    label="$(provider_label "$id")"
    agents="$(provider_agents "$id")"
    if is_authenticated "$id"; then
      ok "$label already configured."
      continue
    fi
    say "  ${BOLD}$label${RESET} is not configured (agents: $agents)."
    local ans
    while true; do
      read -r -p "  [s] configure now · [N] skip · [q] quit — choice: " ans
      case "${ans:-N}" in
        s|S)
          say "  Starting opencode for $label: enter the key in the screen that opens."
          opencode auth login "$id" || true
          if is_authenticated "$id"; then
            ok "$label configured."
            break
          fi
          say "  ${YELLOW}You do not appear to be authenticated to $label yet.${RESET}"
          read -r -p "  [r] retry · [q] quit (resume later) — choice: " ans
          case "${ans:-r}" in
            q|Q) say "  Installation interrupted. Resume with: ./install.sh"; exit 1 ;;
            *)   continue ;;
          esac
          ;;
        n|N)
          warn "Skipped $label → the $agents agents will not respond until you configure it."
          skipped="$skipped $id"
          break
          ;;
        q|Q)
          say "  Installation interrupted. Resume with: ./install.sh"
          exit 1
          ;;
        *) say "  Invalid choice." ;;
      esac
    done
  done
  [ -n "$skipped" ] && warn "Skipped providers:$skipped. Configure them later with: opencode auth login <id>"
}

install_files() {
  step "Installing files ($MODE)"

  # ensure-links creates the agents/, skills/, commands/ directories itself.
  # Migration from OpenCode-Commander: remove the old names (idempotent).
  for a in commander rocket rover hubble antenna quasar; do
    if [ -e "$CONFIG_DIR/agent/$a.md" ] || [ -L "$CONFIG_DIR/agent/$a.md" ]; then
      rm -f "$CONFIG_DIR/agent/$a.md" && say "  removed old agent: $a.md"
    fi
  done
  for f in "$CONFIG_DIR/pricing.md" "$CONFIG_DIR/scripts/telemetry.py"; do
    if [ -e "$f" ] || [ -L "$f" ]; then
      rm -f "$f" && say "  removed legacy file: $f"
    fi
  done

  # Link agents, skills, and commands (same logic used after every git pull).
  if command -v node >/dev/null 2>&1; then
    node "$SCRIPT_DIR/scripts/ensure-links.mjs" || warn "linking incomplete: re-run ./install.sh"
  else
    bash "$SCRIPT_DIR/scripts/ensure-links.sh" || warn "linking incomplete: re-run ./install.sh"
  fi
}

config_setup() {
  step "Config (optional)"
  local a
  read -r -p "  Set chief as the default (model + default_agent)? [y/N]: " a
  case "${a:-N}" in
    y|Y) ;;
    *) say "  Skipped. Chief still works: each agent carries its own model."; return ;;
  esac
  if [ -e "$CONFIG_DIR/opencode.jsonc" ] || [ -e "$CONFIG_DIR/opencode.json" ]; then
    say "  Found an existing config: leaving it untouched. Add these lines by hand to ${CONFIG_DIR}/opencode.jsonc:"
    say ""
    say '    "model": "deepseek/deepseek-v4-pro",'
    say '    "default_agent": "chief"'
    say ""
  else
    cp "$SCRIPT_DIR/config/opencode.jsonc.example" "$CONFIG_DIR/opencode.jsonc"
    ok "Created ${CONFIG_DIR}/opencode.jsonc"
  fi
}

verify() {
  step "Verification"
  if opencode agent list 2>/dev/null | grep -q '^chief'; then
    ok "Agent 'chief' detected."
  else
    warn "'chief' not found. Restart opencode and re-run ./install.sh."
  fi
  local id
  for id in $PROVIDERS; do
    is_authenticated "$id" && ok "Provider $id: configured."
  done
  local missing="" m
  for m in deepseek/deepseek-v4-pro deepseek/deepseek-flash xai/grok-4.7; do
    opencode models 2>/dev/null | grep -qF "$m" || missing="$missing $m"
  done
  if [ -n "$missing" ]; then
    warn "Models not found in your opencode:$missing (different version?)."
  else
    ok "Team models: all available."
  fi
}

main() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --copy) MODE="copy"; shift ;;
      --help|-h) usage; exit 0 ;;
      *) warn "unknown argument: $1"; shift ;;
    esac
  done

  say "${BOLD}OpenCode Chief${RESET} — installation"

  if ! command -v opencode >/dev/null 2>&1; then
    err "opencode not found in PATH."
    say "  Install it:  curl -fsSL https://opencode.ai/install | bash"
    exit 1
  fi
  ok "opencode found ($(opencode --version 2>/dev/null | head -1))."

  provider_setup
  install_files
  config_setup
  verify

  say ""
  say "${BOLD}Done.${RESET} Restart opencode and run:  ${GREEN}opencode${RESET}"
}

main "$@"
