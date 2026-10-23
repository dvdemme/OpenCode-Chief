# Worklog

## 2026-10-23 — Frontmatter V2 (Fix 1 + Fix 2)

- **Fatto**: migrati 8 agent a frontmatter V2 (`permissions` lista, `bash`→`shell`, `task`→`subagent`, `temperature`→`request.body.temperature`); quotate 3 `description` con `: ` (scout, gardener, task-card); aggiornato `render-chief.mjs` e rigenerati `chief.md`/`chief-build.md`. Commit `a83c5da`, push su `main`.
- **Pendente**: n/d.
- **Prossimi passi**: eventuale follow-up su `external_directory` (vedi assunzioni).
- **Decisioni**: conversione 1:1 fedele (nessun cambio di permessi); `temperature` → `request.body.temperature` (inerte in V2, preserva l'intento).
- **Assunzioni aperte**: `external_directory` passa da *ask* (V1) ad *allow* (V2 default) — delta accettato, non mitigato; se serve, policy globale in `opencode.json`.
- **Verdetti**: plan-check GO-CON-VINCOLI (5 GAP assorbiti nel piano).
- **Lezione**: uno scalar YAML non quotato con `: ` (due punti+spazio) rompe il parsing del frontmatter → sempre quotare le `description` con `:`.
