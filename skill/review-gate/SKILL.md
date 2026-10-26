---
name: review-gate
description: Use before calling inspector or plan-check. Decides whether to skip the expensive review (SKIP), do a reduced one (LITE) or a full one (FULL). Does not review code.
---

# Review gate

A single output: `SKIP`, `LITE` or `FULL`. You do not review code yourself.

## SKIP
- Small diff, no new logic, green tests.
- Does not touch auth, crypto, external inputs, secrets, shared contracts, hardware or physics/units.
Close without `inspector`.

## LITE
- Local behavior, but non-trivial.
- Truncated package (the ~400 line rule), only the in-scope files.

## FULL
- Auth, secrets, permissions, cross-repo contracts, hardware/bus/dosages, physics or units.
- Or second fail of `gardener`.
- Full package (`review-package`), only in BUILD for `git add -N`.

## plan-check
Only System track, or score ≥ 2 on the chief's triggers. Never on Quick, docs, rename or already-localized bugfix.

## Staleness
An edit after an APPROVED invalidates the verdict. Resend only the delta, not the whole diff.

Output: `GATE: SKIP|LITE|FULL — reason in 10 words`.
