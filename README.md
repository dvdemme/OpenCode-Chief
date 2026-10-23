# OpenCode Chief

Un "team" di agenti AI per [opencode](https://opencode.ai): un orchestratore (`chief`) che pianifica, scompone e delega a un equipaggio di subagent specializzati, con revisione incrociata multi-vendor e controllo costo/beneficio.

Due vendor indipendenti (DeepSeek e xAI/Grok), ognuno usato dove rende di più. Funziona su macOS, Linux e Windows.

## Requisiti

- [opencode](https://opencode.ai) v2 installato e nel `PATH`.
- Una o più chiavi API: DeepSeek, xAI (vedi FAQ se ne hai una sola).
- `node` consigliato (per install e aggiornamento); senza `node` c'è un fallback nativo.

## Installazione

```bash
git clone https://github.com/dvdemme/OpenCode-Chief.git
cd OpenCode-Chief
./install.sh          # macOS / Linux
```

Windows (PowerShell):

```powershell
git clone https://github.com/dvdemme/OpenCode-Chief.git
cd OpenCode-Chief
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

L'installer collega agenti, skill e comandi nella config globale (`~/.config/opencode`), poi ti dice cosa verificare. Le chiavi restano da configurare con `opencode auth login`, non da questo script.

Riavvia opencode e lancia:

```bash
opencode
```

`default_agent` è `chief`, quindi una sessione nuova parte in postura **plan**.

## Plan e build, restando Chief

Chief ha una sola personalità, in due posture:

| | `chief` (plan) | `chief-build` |
|---|---|---|
| Come ci si entra | default | `/build` |
| Edit | negato, salvo `~/.opencode/plan` | consentito nel repo |
| Shell | solo `git status`, `diff`, `log`, `rev-parse` e il linker | consentita; `commit`, `push`, `deploy` da confermare |
| Subagent | `mapper`, `scout`, `plan-check`, `inspector` | tutto il team |

Si torna in plan con `/plan`. Un prompt che dice "siamo in pianificazione" non basta: il divieto sta nei permessi, quindi un subagent o la shell non possono aggirarlo.

## Aggiornamento

Con l'installazione via symlink (default), **`git pull` basta**:

```bash
cd OpenCode-Chief && git pull
```

I file esistenti sono symlink, quindi si aggiornano da soli. I file **nuovi** vengono agganciati dalla prima azione di Chief: esegue `scripts/ensure-links.mjs`, che è idempotente e non sovrascrive nulla. Nessun secondo install, su nessun OS.

Se installi in modalità copia, `git pull` non aggiorna: rilancia l'installer dopo il pull.

## Il team

| Agente | Modello | Ruolo |
|---|---|---|
| `chief` | DeepSeek V4 Pro | orchestra in plan mode e non implementa |
| `chief-build` | DeepSeek V4 Pro | orchestra in build mode e delega l'implementazione |
| `gardener` | DeepSeek V4 Pro | implementa codice e test |
| `weeder` | DeepSeek Flash | task meccanici, esecuzione test, repo-map |
| `mapper` | DeepSeek Flash | ricognizione: `file:riga`, niente dump |
| `scout` | DeepSeek Flash | interpreta immagini/diagrammi |
| `inspector` | Grok 4.7 | review incrociata del codice |
| `plan-check` | Grok 4.7 | micro-revisione del piano |

## Skill automatiche

Si caricano da sole quando servono; non le invochi a mano.

- `task-card` — card di delega, con comando di verifica e tetto del report.
- `dispatch-gate` — decide se delegare, fan-out e escalation.
- `review-gate` — salta, riduce o attiva la review costosa.
- `repo-map` — mappa corta del repo, letta al posto del codice.
- `verify-run` — i test li esegue `weeder`, non chi ha scritto il codice.
- `review-package` — pacchetto per l'`inspector` (solo build).
- `close-task` — handoff a fine task.

## Comandi

- `/plan` — postura plan.
- `/build` — postura build, ed esegue il piano approvato se c'è.

## Migrazione da OpenCode-Commander

I nomi degli agenti sono cambiati (`commander` → `chief`, `rocket` → `gardener`, `rover` → `weeder`, `hubble` → `scout`, `antenna` → `plan-check`, `quasar` → `inspector`) ed è stato rimosso il calcolo costi. Per aggiornare:

```bash
cd OpenCode-Commander && git pull && ./install.sh
```

Poi riavvia opencode. I riferimenti ai vecchi nomi (prompt, script) non vengono migrati automaticamente.

## FAQ

**Ho una sola chiave (es. solo DeepSeek).** Puoi installare lo stesso: `inspector` e `plan-check` (xAI) non risponderanno finché non configuri quel provider con `opencode auth login -p xai`.

**Posso saltare un provider?** Sì. Gli agenti collegati al provider mancante restano inattivi, il resto funziona.

**Windows?** Supportato con `install.ps1`. I symlink richiedono Developer Mode o permessi elevati; senza, l'installer copia i file e lo segnala.

**Dove finiscono i file?** In `~/.config/opencode/` (agenti, skill e comandi).

**Come si aggiorna su un'altra macchina?** `git pull`. La prima azione di Chief aggancia i file nuovi.

## Licenza

MIT
