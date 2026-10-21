---
name: close-task
description: Usare SOLO a fine task o prima di fermare la sessione. Scrive l'handoff sul worklog (fatto, pendente, prossimi passi, decisioni, assunzioni, verdetti). Non aprire .env, credenziali o database a mano.
---

# Chiusura task (handoff)

Aggiorna il worklog esistente (non riscriverlo); se manca, crea `WORKLOG.md` alla root del progetto.
Sezioni (solo queste):
- **Fatto** — completato e verificato.
- **Pendente** — ciò che resta.
- **Prossimi passi** — azioni concrete per la prossima sessione.
- **Decisioni** — una riga ciascuna.
- **Assunzioni aperte** — da verificare.
- **Verdetti** — esito inspector/plan-check (se presenti).

## Regole
- Niente diff, log interi o segreti nel worklog.
- Non aprire `.env`, credenziali o database a mano.
- Input mancante → `n/d`.

Output: blocco handoff (6–10 righe) da appendere al worklog.
