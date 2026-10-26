# Worklog

## 2026-10-26 — Public readiness: English docs (XERJ Corpus Hub)

- **Done**: translated `README.md` and `WORKLOG.md` to English; added "Cost awareness" and "Models & providers" sections; translated agents, skills, commands, and install scripts; regenerated `chief.md`/`chief-build.md` from `prompts/chief.md`; removed `small_model` from the example config; fixed `install.sh` (auth without `-p`, added `mapper` to the DeepSeek list, dropped the premature `agent`/`skill` mkdir); added the legacy cleanup to `install.ps1`.
- **Pending**: commit and merge `docs/public-ready` into `main` (to be confirmed by the user).
- **Next steps**: publish; optionally verify `install.sh` on macOS/Linux (bash `-n` not available on this Windows box).
- **Decisions**: no parallel Italian README; report protocol tokens translated to English in one pass.
- **Open assumptions**: `agents.<id>.model` override in `opencode.jsonc` works as documented for local overrides.
- **Verdicts**: n/a (docs task, no review gate).
- **Lesson**: OpenCode V2 reads `agents/`, `skills/`, `commands/` (plural); the installer must not pre-create the singular dirs.

## 2026-10-23 — Frontmatter V2 (Fix 1 + Fix 2)

- **Done**: migrated 8 agents to frontmatter V2 (`permissions` list, `bash`→`shell`, `task`→`subagent`, `temperature`→`request.body.temperature`); quoted 3 `description` with `: ` (scout, gardener, task-card); updated `render-chief.mjs` and regenerated `chief.md`/`chief-build.md`. Commit `a83c5da`, pushed to `main`.
- **Pending**: n/a.
- **Next steps**: possible follow-up on `external_directory` (see assumptions).
- **Decisions**: faithful 1:1 conversion (no permission changes); `temperature` → `request.body.temperature` (inert in V2, preserves intent).
- **Open assumptions**: `external_directory` moves from *ask* (V1) to *allow* (V2 default) — accepted delta, not mitigated; if needed, a global policy in `opencode.json`.
- **Verdicts**: plan-check GO-WITH-CONSTRAINTS (5 GAPs absorbed into the plan).
- **Lesson**: an unquoted YAML scalar with `: ` (colon+space) breaks frontmatter parsing → always quote `description` values containing `:`.
