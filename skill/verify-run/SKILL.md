---
name: verify-run
description: Use after a code change to run the card's verification command and report only the result. Does not fix code and does not write tests.
---

# Verify run

Purpose: tests are not judged by whoever wrote them, and their output does not enter the chief's context in full.

## Sequence
1. Take the verification command from the card. If missing, return `VERIFY: n/a` and stop.
2. Delegate execution to `weeder`.
3. Collect only: the result, and in case of failure the first error.

## Output
```
VERIFY: PASS
```
or
```
VERIFY: FAIL
- file:line
- message (max 15 lines total)
```

## Rules
- Do not re-run the suite in the chief. Do not paste the full output.
- Do not modify code or tests: the fix goes back to `gardener`.
