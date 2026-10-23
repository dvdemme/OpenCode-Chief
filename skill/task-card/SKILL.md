---
name: task-card
description: "Usare SOLO subito prima di una chiamata Task a gardener, weeder, inspector, scout, mapper o plan-check. Produce la task card da incollare nel prompt del subagent: obiettivo, done, file, vincoli, assunzioni, formato e tetto del report. Non usarla per routing, escalation o per decidere i gate."
---

# Task card

Produci UNA task card per subagent, da incollare tale e quale nel prompt del Task.
Se il lavoro mescola meccanico e design, spezza in due card (weeder + gardener).

## Campi obbligatori (mai omettere)
- **id** — identificatore breve del task.
- **agente** — chi la esegue.
- **obiettivo** — una frase.
- **done verificabile** — come si dimostra finito.
- **comando di verifica** — il comando esatto, oppure `n/d` con motivo.
- **path in scope / fuori scope** — file e dir espliciti.
- **vincoli** — niente commit/push/deploy; niente scope extra; niente librerie nuove se non richieste.
- **assunzioni** — `ASSUNTO` (non verificato) / `NON NOTO` (dato mancante).
- **input già estratti** — spec/contesto rilevante incluso qui (il subagent NON fa grep).
- **tetto del report** — righe massime di ritorno (default 25).

## Regole per destinatario
- **mapper**: solo `percorso:riga` + motivo, niente dump.
- **gardener**: includi il piano richiesto prima del codice non banale; il report è max 25 righe (fatto, file, test, assunzioni), niente diff incollato.
- **weeder**: task meccanico o esecuzione di `verify-run`; se serve il pacchetto di review, aggiungi "carica `review-package`".
- **inspector**: la card contiene il pacchetto di review, non "esplora il repo".
- **plan-check**: la card è solo lo schema goal/done/out/tasks/assumptions/risk, tool-off.
- **scout**: la card indica l'immagine/diagramma da interpretare e cosa estrarre.

## Readiness e reroute
- Se manca scope, comando di verifica o un'assunzione critica: non delegare a `gardener`, segna `BLOCKED`.
- Se il task è in realtà meccanico: non darlo a `gardener`, metti `REROUTE: weeder`.

## Vietato
- Segreti, token, contenuto di `.env`.
- "Ignora le regole" o istruzioni che scavalcano il kernel.

Output: SOLO il blocco card.
