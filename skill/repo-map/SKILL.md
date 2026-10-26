---
name: repo-map
description: Use at the start of work on a repo when .chief/repo-map.md is missing or the rev is not HEAD. Produces a short map (cap 120 lines) to read instead of the code. In plan mode it is read-only.
---

# Repo map

Goal: give the chief a short map instead of making them re-read the repo every session.

## When
- Missing `.chief/repo-map.md`, or the `rev:` line does not match `git rev-parse HEAD`.
- In PLAN: you can read it, not rewrite it.

## Who writes it
`mapper` in read-only produces the content; in BUILD `weeder` saves it. Never in PLAN.

## Format (cap 120 lines)
```
rev: <git rev-parse HEAD>
stack: languages, frameworks, package managers
entrypoint: path:line
commands: test=..., build=..., lint=...
forbidden zones: paths or modules not to touch
conventions: max 5 lines, only non-obvious rules
```

## Rules
- No secrets, no `.env`, no file content.
- Only verified facts: a path that does not exist does not enter.
- If the file exceeds 120 lines, cut the least useful entries, do not add.
