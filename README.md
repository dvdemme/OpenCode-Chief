# OpenCode Chief

[![XERJ Corpus Hub contributor](https://hub.xerj.org/contributors/dvdemme/badge.svg)](https://hub.xerj.org/contributors/dvdemme)

An AI agent "team" for [opencode](https://opencode.ai): an orchestrator (`chief`) that plans, breaks down, and delegates to a crew of specialized subagents, with multi-vendor cross-review.

Two independent vendors (DeepSeek and xAI/Grok), each used where it fits best. Works on macOS, Linux, and Windows.

Reference patterns for OpenCode multi-agent workflows: plan/build separation, named subagent roles, and review gating.

## Requirements

- [opencode](https://opencode.ai) v2 installed and in the `PATH`.
- One or more API keys: DeepSeek, xAI (see FAQ if you only have one).
- `node` recommended (for install and updates); without `node` there is a native fallback.

## Installation

```bash
git clone https://github.com/dvdemme/OpenCode-Chief.git
cd OpenCode-Chief
./install.sh          # macOS / Linux
```

Windows (PowerShell):

```powershell
git clone https://github.com/dvdemme/OpenCode-Chief.git
cd OpenCode-Chief
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installer links agents, skills, and commands into the global config (`~/.config/opencode`), then tells you what to check. Keys are left to configure with `opencode auth login`, not by this script.

Restart opencode and run:

```bash
opencode
```

`default_agent` is `chief`, so a new session starts in **plan** posture.

## Plan and build, staying Chief

Chief has a single personality, in two postures:

| | `chief` (plan) | `chief-build` |
|---|---|---|
| How you enter | default | `/build` |
| Edit | denied, except `~/.opencode/plan` | allowed in the repo |
| Shell | only `git status`, `diff`, `log`, `rev-parse`, and the linker | allowed; `commit`, `push`, `deploy` to be confirmed |
| Subagent | `mapper`, `scout`, `plan-check`, `inspector` | the whole team |

Return to plan with `/plan`. A prompt saying "we are planning" is not enough: the ban lives in the permissions, so a subagent or the shell cannot bypass it.

## Updating

With the symlink installation (default), **`git pull` is enough**:

```bash
cd OpenCode-Chief && git pull
```

Existing files are symlinks, so they update themselves. **New** files are hooked up by Chief's first action: it runs `scripts/ensure-links.mjs`, which is idempotent and overwrites nothing. No second install, on any OS.

If you install in copy mode, `git pull` does not update: re-run the installer after pulling.

## The team

The models below are this repo's defaults, not a hard requirement — every role can run on any OpenCode-supported provider (see Models & providers).

| Agent | Default model | Role |
|---|---|---|
| `chief` | DeepSeek V4 Pro | orchestrates in plan mode and does not implement |
| `chief-build` | DeepSeek V4 Pro | orchestrates in build mode and delegates implementation |
| `gardener` | DeepSeek V4 Pro | implements code and tests |
| `weeder` | DeepSeek Flash | mechanical tasks, test runs, repo-map |
| `mapper` | DeepSeek Flash | reconnaissance: `file:line`, no dump |
| `scout` | DeepSeek Flash | interprets images/diagrams |
| `inspector` | Grok 4.7 | cross-review of code |
| `plan-check` | Grok 4.7 | micro-review of the plan |

## Automatic skills

They load themselves when needed; you don't invoke them by hand.

- `task-card` — delegation card, with a verification command and report cap.
- `dispatch-gate` — decides whether to delegate, fan-out, and escalation.
- `review-gate` — skips, reduces, or enables the costly cross-vendor review.
- `repo-map` — short repo map, read instead of the code.
- `verify-run` — tests are run by `weeder`, not by whoever wrote the code.
- `review-package` — package for the `inspector` (build only).
- `close-task` — end-of-task handoff.

## Cost awareness

"Cost awareness is handled via model choice and review gating; a dedicated cost skill is planned for later."

`review-gate` is the gating mechanism for costly reviews (SKIP/LITE/FULL). There is no cost-calculation or token-tracking feature in this repo yet.

## Commands

- `/plan` — plan posture.
- `/build` — build posture, and runs the approved plan if there is one.

## Migration from OpenCode-Commander

> **Legacy.** OpenCode-Commander is the predecessor of this repo.

Agent names changed (`commander` → `chief`, `rocket` → `gardener`, `rover` → `weeder`, `hubble` → `scout`, `antenna` → `plan-check`, `quasar` → `inspector`) and the cost calculation was removed. To update:

```bash
cd OpenCode-Commander && git pull && ./install.sh
```

Then restart opencode. References to the old names (prompts, scripts) are not migrated automatically.

## Models & providers

### Roles are model-independent

Every agent can run on any provider OpenCode supports. The `model:` in an agent's frontmatter is only this repo's default, not a constraint on the role.

### Current defaults and why (as reference)

- **DeepSeek V4 Pro** → `chief`/`gardener` (orchestration + implementation).
- **DeepSeek Flash** → `weeder`/`mapper`/`scout` (reconnaissance and mechanical work — cheaper models).
- **Grok 4.7** → `inspector`/`plan-check` (a different vendor from whoever writes the code, for independent review).

### Configuring API keys

Use `opencode auth login` (or `/connect` in the TUI). Examples:

```bash
opencode auth login deepseek
opencode auth login xai
```

Keys never go in the installer. With a single key, the missing provider must be skipped.

### What happens if a key is missing

Only the agent tied to that provider fails with "model unavailable"; the rest keep working. If the top-level `model` in `opencode.jsonc` also points to an absent provider, the whole session won't start — so if you have a single key, make sure the default model and the subagents point to that provider.

### How to assign/change the model per role

- List the real available models with `opencode models`.
- Change the model for a session with `/models` (does not rewrite any files).
- Change a subagent with `model:` in the agent's markdown, or override it in `opencode.jsonc` under `agents.<id>.model`. Example:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "agents": {
    "inspector": {
      "model": "openai/gpt-4o"
    }
  }
}
```

Put overrides in your own config, not in the repo files, so `git pull` won't rewrite them.

### Beginner / advanced tips

- **Beginners** — keep the defaults, run `opencode auth login`, and skip the provider you don't have a key for.
- **Advanced** — override in config, use a gateway (OpenRouter/custom), or local models (Ollama/LM Studio/vLLM). If a model has no tool support, `gardener` and `mapper` won't work. Using a single provider: point every `model:` at that provider, but note the review is no longer cross-vendor.

## FAQ

**I have a single key (e.g. only DeepSeek).** You can install anyway: `inspector` and `plan-check` (xAI) won't respond until you configure that provider with `opencode auth login xai`.

**Can I skip a provider?** Yes. Agents tied to the missing provider stay inactive; the rest keep working.

**Windows?** Supported via `install.ps1`. Symlinks require Developer Mode or elevated permissions; without them, the installer copies the files and tells you.

**Where do the files end up?** In `~/.config/opencode/` (`agents/`, `skills/`, `commands/`).

**How do I update on another machine?** `git pull`. Chief's first action hooks up any new files.

## License

MIT. SPDX-License-Identifier: MIT. Adaptation is allowed; keep the copyright and permission notice. See `LICENSE`.
