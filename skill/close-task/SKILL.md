---
name: close-task
description: Usare SOLO a fine task o prima di fermare la sessione. Scrive l'handoff (fatto, pendente, prossimi passi, decisioni, assunzioni, verdetti, lezione). In plan mode il blocco va nel file di piano, non nel repo. Non aprire .env, credenziali o database a mano.
---

# Chiusura task (handoff)

## Dove scrivere
- BUILD: nel worklog esistente (non riscriverlo); se manca, crea `WORKLOG.md` alla root del progetto.
- PLAN: nel file di piano sotto `~/.opencode/plan`, non nel repo.

Sezioni (solo queste):
- **Fatto** — completato e verificato.
- **Pendente** — ciò che resta.
- **Prossimi passi** — azioni concrete per la prossima sessione.
- **Decisioni** — una riga ciascuna.
- **Assunzioni aperte** — da verificare.
- **Verdetti** — esito inspector/plan-check (se presenti).
- **Lezione** — opzionale, una riga, solo se lo stesso fallimento si è ripetuto.

## Regole
- Niente diff, log interi o segreti nel worklog.
- Non aprire `.env`, credenziali o database a mano.
- Input mancante → `n/d`.

Output: blocco handoff (6–10 righe) da appendere.
