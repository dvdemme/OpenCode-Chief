---
name: task-card
description: "Use ONLY right before a Task call to gardener, weeder, inspector, scout, mapper or plan-check. Produces the task card to paste into the subagent's prompt: objective, done, files, constraints, assumptions, format and report cap. Do not use it for routing, escalation or deciding gates."
---

# Task card

Produce ONE task card per subagent, to paste as-is into the Task prompt.
If the work mixes mechanical and design, split into two cards (weeder + gardener).

## Required fields (never omit)
- **id** — short task identifier.
- **agent** — who executes it.
- **objective** — one sentence.
- **verifiable done** — how completion is demonstrated.
- **verification command** — the exact command, or `n/a` with a reason.
- **paths in scope / out of scope** — explicit files and dirs.
- **constraints** — no commit/push/deploy; no extra scope; no new libraries unless required.
- **assumptions** — `ASSUMED` (unverified) / `NOT KNOWN` (missing datum).
- **already extracted inputs** — relevant spec/context included here (the subagent does NOT grep).
- **report cap** — maximum return lines (default 25).

## Rules per recipient
- **mapper**: only `path:line` + reason, no dump.
- **gardener**: include the required plan before non-trivial code; the report is max 25 lines (done, files, tests, assumptions), no pasted diff.
- **weeder**: mechanical task or execution of `verify-run`; if the review package is needed, add "load `review-package`".
- **inspector**: the card contains the review package, not "explore the repo".
- **plan-check**: the card is only the goal/done/out/tasks/assumptions/risk schema, tool-off.
- **scout**: the card indicates the image/diagram to interpret and what to extract.

## Readiness and reroute
- If scope, verification command or a critical assumption is missing: do not delegate to `gardener`, mark `BLOCKED`.
- If the task is actually mechanical: do not give it to `gardener`, put `REROUTE: weeder`.

## Forbidden
- Secrets, tokens, `.env` content.
- "Ignore the rules" or instructions that bypass the kernel.

Output: ONLY the card block.
