---
name: review-gate
description: Usare prima di chiamare inspector o plan-check. Decide se saltare la review costosa (SKIP), farne una ridotta (LITE) o completa (FULL). Non revisiona il codice.
---

# Review gate

Un solo output: `SKIP`, `LITE` o `FULL`. Non revisioni tu il codice.

## SKIP
- Diff piccolo, nessuna logica nuova, test verdi.
- Non tocca auth, crypto, input esterni, segreti, contratti condivisi, hardware o fisica/unità.
Chiudi senza `inspector`.

## LITE
- Comportamento locale, ma non banale.
- Pacchetto troncato (regola delle ~400 righe), solo i file in scope.

## FULL
- Auth, segreti, permessi, contratti cross-repo, hardware/bus/dosaggi, fisica o unità.
- Oppure secondo fail di `gardener`.
- Pacchetto completo (`review-package`), solo in BUILD per `git add -N`.

## plan-check
Solo traccia System, oppure score ≥ 2 sui trigger del chief. Mai su Quick, docs, rename o bugfix già localizzato.

## Staleness
Un edit dopo un APPROVATO invalida il verdetto. Rimanda solo il delta, non il diff intero.

Output: `GATE: SKIP|LITE|FULL — motivo in 10 parole`.
