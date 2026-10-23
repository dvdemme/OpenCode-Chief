#!/usr/bin/env bash
#
# install.sh — installa "OpenCode Chief" nel tuo opencode globale.
#
# Guida interattiva: configura i provider (deepseek/xai), collega i file
# (agenti + skill) e opzionalmente imposta chief come default.
#
# Uso:
#   ./install.sh           symlink (consigliato: `git pull` aggiorna tutto da solo)
#   ./install.sh --copy    copia i file (nessun aggiornamento automatico)
#
# Supportato: macOS + Linux (bash 3.2+). Windows: non ancora (v2).

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
  deepseek) echo "chief, gardener, weeder, scout" ;;
  xai)      echo "inspector, plan-check" ;;
  *)        echo "?" ;;
esac; }

is_authenticated() { opencode auth list 2>/dev/null | grep -qi "$1"; }

usage() {
  say "Uso: ./install.sh [--copy] [--help]"
  say "  --copy   copia i file invece di creare symlink"
}

provider_setup() {
  step "Provider (chiavi API)"
  say "Il team usa due vendor; ogni agente ha un suo modello:"
  say "  ${BOLD}DeepSeek${RESET}  → chief, gardener, weeder, scout"
  say "  ${BOLD}xAI${RESET}       → inspector, plan-check"
  say "Configura i provider per cui hai una chiave; gli altri puoi saltarli."
  say ""
  local id label agents skipped=""
  for id in $PROVIDERS; do
    label="$(provider_label "$id")"
    agents="$(provider_agents "$id")"
    if is_authenticated "$id"; then
      ok "$label già configurato."
      continue
    fi
    say "  ${BOLD}$label${RESET} non risulta configurato (agenti: $agents)."
    local ans
    while true; do
      read -r -p "  [s] configura ora · [N] salta · [q] esci — scelta: " ans
      case "${ans:-N}" in
        s|S)
          say "  Avvio opencode per $label: inserisci la chiave nella schermata che si apre."
          opencode auth login -p "$id" || true
          if is_authenticated "$id"; then
            ok "$label configurato."
            break
          fi
          say "  ${YELLOW}Non risulti ancora autenticato a $label.${RESET}"
          read -r -p "  [r] ritenta · [q] esci (riprendi dopo) — scelta: " ans
          case "${ans:-r}" in
            q|Q) say "  Installazione interrotta. Riprendi con: ./install.sh"; exit 1 ;;
            *)   continue ;;
          esac
          ;;
        n|N)
          warn "Saltato $label → gli agenti $agents non risponderanno finché non lo configuri."
          skipped="$skipped $id"
          break
          ;;
        q|Q)
          say "  Installazione interrotta. Riprendi con: ./install.sh"
          exit 1
          ;;
        *) say "  Scelta non valida." ;;
      esac
    done
  done
  [ -n "$skipped" ] && warn "Provider saltati:$skipped. Configurali poi con: opencode auth login -p <id>"
}

install_files() {
  step "Installazione file ($MODE)"
  mkdir -p "$CONFIG_DIR/agent" "$CONFIG_DIR/skill"

  # Migrazione da OpenCode-Commander: rimuovi i vecchi nomi (idempotente).
  for a in commander rocket rover hubble antenna quasar; do
    if [ -e "$CONFIG_DIR/agent/$a.md" ] || [ -L "$CONFIG_DIR/agent/$a.md" ]; then
      rm -f "$CONFIG_DIR/agent/$a.md" && say "  rimosso vecchio agente: $a.md"
    fi
  done
  for f in "$CONFIG_DIR/pricing.md" "$CONFIG_DIR/scripts/telemetry.py"; do
    if [ -e "$f" ] || [ -L "$f" ]; then
      rm -f "$f" && say "  rimosso vecchio: $f"
    fi
  done

  # Collega agenti, skill e comandi (stessa logica usata dopo ogni git pull).
  if command -v node >/dev/null 2>&1; then
    node "$SCRIPT_DIR/scripts/ensure-links.mjs" || warn "collegamento incompleto: riesegui ./install.sh"
  else
    bash "$SCRIPT_DIR/scripts/ensure-links.sh" || warn "collegamento incompleto: riesegui ./install.sh"
  fi
}

config_setup() {
  step "Config (opzionale)"
  local a
  read -r -p "  Impostare chief come modello di default (model + small_model)? [s/N]: " a
  case "${a:-N}" in
    s|S) ;;
    *) say "  Saltato. Chief funziona comunque: i modelli sono nei singoli agenti."; return ;;
  esac
  if [ -e "$CONFIG_DIR/opencode.jsonc" ] || [ -e "$CONFIG_DIR/opencode.json" ]; then
    say "  Trovato un config esistente: non lo tocco. Aggiungi a mano queste righe a ${CONFIG_DIR}/opencode.jsonc:"
    say ""
    say '    "model": "deepseek/deepseek-v4-pro",'
    say '    "small_model": "deepseek/deepseek-flash"'
    say ""
  else
    cp "$SCRIPT_DIR/config/opencode.jsonc.example" "$CONFIG_DIR/opencode.jsonc"
    ok "Creato ${CONFIG_DIR}/opencode.jsonc"
  fi
}

verify() {
  step "Verifica"
  if opencode agent list 2>/dev/null | grep -q '^chief'; then
    ok "Agente 'chief' rilevato."
  else
    warn "'chief' non trovato. Riavvia opencode e riesegui ./install.sh."
  fi
  local id
  for id in $PROVIDERS; do
    is_authenticated "$id" && ok "Provider $id: configurato."
  done
  local missing="" m
  for m in deepseek/deepseek-v4-pro deepseek/deepseek-flash xai/grok-4.7; do
    opencode models 2>/dev/null | grep -qF "$m" || missing="$missing $m"
  done
  if [ -n "$missing" ]; then
    warn "Modelli non trovati nel tuo opencode:$missing (versione diversa?)."
  else
    ok "Modelli del team: tutti disponibili."
  fi
}

main() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --copy) MODE="copy"; shift ;;
      --help|-h) usage; exit 0 ;;
      *) warn "argomento ignoto: $1"; shift ;;
    esac
  done

  say "${BOLD}OpenCode Chief${RESET} — installazione"

  if ! command -v opencode >/dev/null 2>&1; then
    err "opencode non trovato nel PATH."
    say "  Installalo:  curl -fsSL https://opencode.ai/install | bash"
    exit 1
  fi
  ok "opencode trovato ($(opencode --version 2>/dev/null | head -1))."

  provider_setup
  install_files
  config_setup
  verify

  say ""
  say "${BOLD}Fatto.${RESET} Riavvia opencode e lancia:  ${GREEN}opencode --agent chief${RESET}"
}

main "$@"
