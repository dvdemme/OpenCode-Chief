---
description: Passa Chief in postura build ed esegue il piano approvato.
agent: chief-build
subagent: false
---

Siamo in postura BUILD. Se esiste un piano in `~/.opencode/plan`, esegui quello senza ripianificare da zero; altrimenti esegui il lavoro richiesto. Commit, push e deploy restano da confermare.

$ARGUMENTS
