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
temperature: 0.2
permission:
  edit:
    "*": deny
    "~/.opencode/plan/*": allow
  bash:
    "*": deny
    "git status*": allow
    "git diff*": allow
    "git log*": allow
    "git rev-parse*": allow
    "node -e *CHIEF-LINK*": allow
    "node.exe -e *CHIEF-LINK*": allow
    "*ensure-links*": allow
  task:
    "*": deny
    mapper: allow
    scout: allow
    plan-check: allow
    explore: allow
    inspector: allow
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
temperature: 0.2
permission:
  edit: allow
  bash:
    "*": allow
    "git commit*": ask
    "git push*": ask
    "*deploy*": ask
  task: allow
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
