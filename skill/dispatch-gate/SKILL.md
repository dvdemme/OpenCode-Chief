---
name: dispatch-gate
description: Usare subito prima di ogni delega a un subagent. Decide se delegare o fare inline, imposta il tetto di fan-out, il formato di ritorno e le regole di escalation. Non implementa e non revisiona.
---

# Dispatch gate

Prima di ogni chiamata a un subagent, applica queste regole.

## 1. Delegare o no
Non delegare se il dato è già nel contesto o bastano 1–2 letture su un file noto: fai inline.
Delega solo se compri isolamento, parallelismo o un vendor diverso. Un fan-out costa molto più di una risposta inline.

## 2. Chi
- Ricognizione → `mapper` (Flash). Mai `explore`: eredita il modello del padre.
- Meccanico, rename, esecuzione test → `weeder` (Flash).
- Design e implementazione non banale → `gardener` (Pro).
- Immagini e diagrammi → `scout` (Flash).
- Revisione cross-vendor → `inspector` (Grok), solo dopo `review-gate`.
- Piano a rischio → `plan-check` (Grok), solo traccia System o score ≥ 2.

## 3. Come
- Fan-out massimo 3, nello stesso turno, con scope di scrittura disgiunti. Se due scope si sovrappongono, uniscili.
- Una card per subagent (`task-card`). Il prompt è autonomo: path, done, vietato, formato di ritorno.
- Chiedi conclusioni, non dump. Ogni card dichiara il tetto di righe del report.

## 4. Readiness (traccia Feature/System)
Prima di delegare a `gardener`, verifica che ci siano: scope esplicito, comando di verifica, assunzioni dichiarate.
Se manca uno dei tre, non delegare: chiedi il dato o segna `BLOCKED`.

## 5. Escalation
Un solo gradino (Flash → Pro, oppure Pro → Grok su diagnosi), allegando il fallimento. Al secondo fail, fermati e chiedi all'utente. Non riprovare in loop.

## 6. Plan-delta
Se lo scope cambia dopo un piano esistente, non riscrivere il piano: aggiungi un delta concosa cambia, cosa resta valido, cosa si toglie, cosa si aggiunge, se la readiness cambia.

Output: una riga di decisione (`inline` / `delega: <agente>`) più la card.
