import { readFileSync, writeFileSync } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const body = readFileSync(join(root, "prompts", "chief.md"), "utf8").replace(/\r\n/g, "\n");

const faces = [
  {
    file: "chief.md",
    postura: "PLAN",
    front: `---
description: Chief — postura plan. Orchestra e non implementa. Per eseguire il piano, /build.
mode: primary
model: deepseek/deepseek-v4-pro
request:
  body:
    temperature: 0.2
permissions:
  - action: edit
    resource: "*"
    effect: deny
  - action: edit
    resource: "~/.opencode/plan/*"
    effect: allow
  - action: shell
    resource: "*"
    effect: deny
  - action: shell
    resource: "git status*"
    effect: allow
  - action: shell
    resource: "git diff*"
    effect: allow
  - action: shell
    resource: "git log*"
    effect: allow
  - action: shell
    resource: "git rev-parse*"
    effect: allow
  - action: shell
    resource: "node -e *CHIEF-LINK*"
    effect: allow
  - action: shell
    resource: "node.exe -e *CHIEF-LINK*"
    effect: allow
  - action: shell
    resource: "*ensure-links*"
    effect: allow
  - action: subagent
    resource: "*"
    effect: deny
  - action: subagent
    resource: mapper
    effect: allow
  - action: subagent
    resource: scout
    effect: allow
  - action: subagent
    resource: plan-check
    effect: allow
  - action: subagent
    resource: explore
    effect: allow
  - action: subagent
    resource: inspector
    effect: allow
---
`,
  },
  {
    file: "chief-build.md",
    postura: "BUILD",
    front: `---
description: Chief — postura build. Stesso orchestratore; può delegare l'implementazione. Si entra con /build.
mode: primary
model: deepseek/deepseek-v4-pro
request:
  body:
    temperature: 0.2
permissions:
  - action: edit
    resource: "*"
    effect: allow
  - action: shell
    resource: "*"
    effect: allow
  - action: shell
    resource: "git commit*"
    effect: ask
  - action: shell
    resource: "git push*"
    effect: ask
  - action: shell
    resource: "*deploy*"
    effect: ask
  - action: subagent
    resource: "*"
    effect: allow
---
`,
  },
];

const banner = "<!-- Generato da prompts/chief.md — modifica quello, poi: node scripts/render-chief.mjs -->\n\n";

for (const face of faces) {
  const text = face.front + "\n" + banner + body.replaceAll("{{POSTURA}}", face.postura);
  writeFileSync(join(root, "agent", face.file), text, "utf8");
}

console.log("render-chief: OK");
