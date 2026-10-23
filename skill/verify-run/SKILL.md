---
name: verify-run
description: Usare dopo una modifica di codice per eseguire il comando di verifica della card e riportare solo l'esito. Non corregge il codice e non scrive test.
---

# Verify run

Scopo: i test non li giudica chi li ha scritti, e il loro output non rientra intero nel contesto del chief.

## Sequenza
1. Prendi il comando di verifica dalla card. Se manca, restituisci `VERIFY: n/d` e fermati.
2. Delega l'esecuzione a `weeder`.
3. Raccogli solo: esito, e in caso di fallimento il primo errore.

## Output
```
VERIFY: PASS
```
oppure
```
VERIFY: FAIL
- file:riga
- messaggio (max 15 righe totali)
```

## Regole
- Non rilanciare la suite nel chief. Non incollare l'output intero.
- Non modificare codice né test: la correzione torna al `gardener`.
