---
name: dispatch-gate
description: Use right before every delegation to a subagent. Decides whether to delegate or do inline, sets the fan-out cap, the return format and the escalation rules. Does not implement and does not review.
---

# Dispatch gate

Before every call to a subagent, apply these rules.

## 1. Delegate or not
Do not delegate if the data is already in the context or 1–2 reads on a known file are enough: do inline.
Delegate only if you buy isolation, parallelism or a different vendor. A fan-out costs far more than an inline answer.

## 2. Who
- Reconnaissance → `mapper` (Flash). Never `explore`: it inherits the parent's model.
- Mechanical, rename, test execution → `weeder` (Flash).
- Non-trivial design and implementation → `gardener` (Pro).
- Images and diagrams → `scout` (Flash).
- Cross-vendor review → `inspector` (Grok), only after `review-gate`.
- Risky plan → `plan-check` (Grok), only System track or score ≥ 2.

## 3. How
- Fan-out max 3, in the same turn, with disjoint write scopes. If two scopes overlap, merge them.
- One card per subagent (`task-card`). The prompt is self-contained: paths, done, forbidden, return format.
- Ask for conclusions, not dumps. Each card declares the report line cap.

## 4. Readiness (Feature/System track)
Before delegating to `gardener`, verify that there are: explicit scope, verification command, declared assumptions.
If one of the three is missing, do not delegate: ask for the datum or mark `BLOCKED`.

## 5. Escalation
One step only (Flash → Pro, or Pro → Grok on diagnosis), attaching the failure. On the second fail, stop and ask the user. Do not retry in a loop.

## 6. Plan-delta
If the scope changes after an existing plan, do not rewrite the plan: add a delta: what changes, what stays valid, what is removed, what is added, whether readiness changes.

Output: one decision line (`inline` / `delegate: <agent>`) plus the card.
