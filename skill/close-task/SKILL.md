---
name: close-task
description: Use ONLY at the end of a task or before stopping the session. Writes the handoff (done, pending, next steps, decisions, assumptions, verdicts, lesson). In plan mode the block goes in the plan file, not in the repo. Do not open .env, credentials or databases by hand.
---

# Task closure (handoff)

## Where to write
- BUILD: in the existing worklog (do not rewrite it); if missing, create `WORKLOG.md` at the project root.
- PLAN: in the plan file under `~/.opencode/plan`, not in the repo.

Sections (only these):
- **Done** — completed and verified.
- **Pending** — what remains.
- **Next steps** — concrete actions for the next session.
- **Decisions** — one line each.
- **Open assumptions** — to verify.
- **Verdicts** — inspector/plan-check outcome (if any).
- **Lesson** — optional, one line, only if the same failure repeated.

## Rules
- No diffs, full logs or secrets in the worklog.
- Do not open `.env`, credentials or databases by hand.
- Missing input → `n/a`.

Output: handoff block (6–10 lines) to append.
