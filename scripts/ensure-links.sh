#!/usr/bin/env bash
# Node-free fallback for macOS/Linux: links the team's new files after a git pull.
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
CFG="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

if [ -d "$CFG/agents" ]; then AG="$CFG/agents"; elif [ -d "$CFG/agent" ]; then AG="$CFG/agent"; else AG="$CFG/agents"; fi
if [ -d "$CFG/skills" ]; then SK="$CFG/skills"; elif [ -d "$CFG/skill" ]; then SK="$CFG/skill"; else SK="$CFG/skills"; fi
if [ -d "$CFG/commands" ]; then CM="$CFG/commands"; elif [ -d "$CFG/command" ]; then CM="$CFG/command"; else CM="$CFG/commands"; fi

mkdir -p "$AG" "$SK" "$CM"
n=0
link_one() {
  src="$1"; dst="$2"; dir="$3"
  if [ -L "$dst" ]; then return 0; fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    if [ "$src" -nt "$dst" ]; then
      rm -rf "$dst"
      if [ "$dir" = "1" ]; then cp -R "$src" "$dst"; else cp "$src" "$dst"; fi
      n=$((n+1))
    fi
    return 0
  fi
  ln -s "$src" "$dst" 2>/dev/null && n=$((n+1))
}

for f in "$REPO"/agent/*.md; do [ -e "$f" ] || continue; link_one "$f" "$AG/$(basename "$f")" 0; done
for d in "$REPO"/skill/*/; do [ -e "${d}SKILL.md" ] || continue; link_one "${d%/}" "$SK/$(basename "$d")" 1; done
for f in "$REPO"/command/*.md; do [ -e "$f" ] || continue; link_one "$f" "$CM/$(basename "$f")" 0; done

echo "CHIEF-LINK: OK — linked $n"
