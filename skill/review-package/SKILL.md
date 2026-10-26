---
name: review-package
description: Use ONLY to assemble the inspector's review package (diff with untracked, status, test/build output, call-graph) or just the delta after a non-APPROVED verdict. Only in build posture. Does not implement code and does not read .env or secrets.
---

# Review package (for inspector)

Load this skill only if `review-gate` gave LITE or FULL. In PLAN posture `git add -N` is denied: if the diff is not already available, report `INCOMPLETE PACKAGE` and skip the review.

## Deterministic sequence (BUILD only)
1. `git add -N .` to include untracked in the diff (NEVER `git add` without `-N`, NEVER commit).
2. `git status --porcelain` → file list (modified + untracked).
3. `git diff` → the diff.
4. Relevant test/build output (or `n/a` with a reason if there is no code).
5. Call-graph one hop on the symbols/functions named in the card (or `call-graph: n/a` + reason).

## Completeness
One of the five is missing → declare "INCOMPLETE PACKAGE" at the top, do not hide it.

## Editing
- If the diff shows keys, tokens, `*.pem` or `.env`: replace with `[REDACTED]` and report the path. Do NOT open the file to verify.
- Above ~400 lines: `stat`, file list, diff of only the in-scope files, truncation note.

## Delta mode (after a non-APPROVED verdict)
Only the files cited in the blocking reservations + the test results of the fixes. Not the whole diff.

## Constraints
weeder does NOT call inspector: the package goes up to the chief, who pastes it into the inspector's Task.

Output: a PACKAGE block.
