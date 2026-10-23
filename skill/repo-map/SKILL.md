---
name: repo-map
description: Usare all'inizio del lavoro su un repo quando manca .chief/repo-map.md o il rev non è HEAD. Produce una mappa corta (tetto 120 righe) da leggere al posto del codice. In plan mode è sola lettura.
---

# Repo map

Obiettivo: dare al chief una mappa corta invece di fargli rileggere il repo a ogni sessione.

## Quando
- Manca `.chief/repo-map.md`, oppure la riga `rev:` non corrisponde a `git rev-parse HEAD`.
- In PLAN: puoi leggerla, non riscriverla.

## Chi la scrive
`mapper` in sola lettura produce il contenuto; in BUILD `weeder` lo salva. Mai in PLAN.

## Formato (tetto 120 righe)
```
rev: <git rev-parse HEAD>
stack: linguaggi, framework, gestori di pacchetti
entrypoint: percorso:riga
comandi: test=..., build=..., lint=...
zone vietate: path o moduli da non toccare
convenzioni: max 5 righe, solo regole non ovvie
```

## Regole
- Niente segreti, niente `.env`, niente contenuto di file.
- Solo fatti verificati: un percorso che non esiste non entra.
- Se il file supera 120 righe, taglia le voci meno utili, non aggiungere.
