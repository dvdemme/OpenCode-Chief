# OpenCode Chief

Un "team" di agenti AI per [opencode](https://opencode.ai): un orchestratore (`chief`) che pianifica, decompone e delega a un equipaggio di subagent specializzati, con revisione incrociata multi-vendor e controllo costo/beneficio.

Due vendor indipendenti (DeepSeek e xAI/Grok), ognuno usato dove rende di più.

## Requisiti

- [opencode](https://opencode.ai) installato (consigliata l'ultima versione).
- Una o più chiavi API: DeepSeek, xAI (vedi FAQ se ne hai una sola).

## Installazione (guidata)

```bash
git clone https://github.com/dvdemme/OpenCode-Chief.git
cd OpenCode-Chief
./install.sh          # oppure: ./install.sh --copy
```

`install.sh` ti guida passo-passo:

1. verifica che opencode sia installato;
2. configura i provider (le chiavi vengono chieste da `opencode auth login`, non da questo script);
3. collega agenti + skill nel tuo `~/.config/opencode/`;
4. (opzionale) imposta `chief` come modello di default;
5. verifica l'installazione.

Poi **riavvia opencode** e lancia:

```bash
opencode --agent chief
```

## Il team

| Agente | Modello | Ruolo |
|---|---|---|
| `chief` | DeepSeek V4 Pro | orchestra, delega, integra |
| `gardener` | DeepSeek V4 Pro | implementa codice e test |
| `weeder` | DeepSeek Flash | task meccanici/ripetitivi |
| `scout` | DeepSeek Flash | interpreta immagini/diagrammi |
| `inspector` | Grok 4.7 | review incrociata del codice |
| `plan-check` | Grok 4.7 | micro-revisione del piano |

## Skill automatiche

- `task-card` — card di delega prima di ogni Task.
- `review-package` — pacchetto per la review dell'`inspector`.
- `close-task` — handoff a fine task.

Le skill si caricano da sole quando servono (l'utente non le invoca): il `chief` le attiva con giudizio.

## Aggiornamento

```bash
cd OpenCode-Chief && git pull
```

Con l'installazione via symlink (default) l'aggiornamento è automatico: `git pull` aggiorna i file collegati.

## FAQ

**Ho una sola chiave (es. solo DeepSeek).** Puoi installare lo stesso: `inspector` e `plan-check` (xAI) non risponderanno finché non configuri quel provider. Configuralo dopo con `opencode auth login -p xai`.

**Posso saltare un provider?** Sì, l'installer te lo chiede per ciascuno. Se salti, gli agenti collegati restano inattivi (ma il resto funziona).

**Windows?** Non ancora supportato (v2).

**Dove finiscono i file?** In `~/.config/opencode/` (agenti in `agent/`, skill in `skill/`).

## Licenza

MIT
