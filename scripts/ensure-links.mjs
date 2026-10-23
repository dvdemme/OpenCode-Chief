import { existsSync, lstatSync, mkdirSync, readdirSync, realpathSync, rmSync, copyFileSync, cpSync, statSync, symlinkSync } from "fs";
import { homedir } from "os";
import { dirname, join, resolve } from "path";
import { fileURLToPath } from "url";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "..");

function configDir() {
  return process.env.OPENCODE_CONFIG_DIR || join(homedir(), ".config", "opencode");
}

function isLink(p) {
  try {
    return lstatSync(p).isSymbolicLink();
  } catch {
    return false;
  }
}

function sameTarget(p, target) {
  try {
    return resolve(realpathSync(p)) === resolve(realpathSync(target));
  } catch {
    return false;
  }
}

function ensureDir(p) {
  mkdirSync(p, { recursive: true });
}

const linked = [];
const refreshed = [];
const skipped = [];
const failed = [];

function link(src, dst, isDir) {
  const parent = dirname(dst);
  ensureDir(parent);

  if (isLink(dst)) {
    if (sameTarget(dst, src)) {
      skipped.push(dst);
      return;
    }
    skipped.push(`${dst} (già symlink altrove)`);
    return;
  }

  if (existsSync(dst)) {
    const st = statSync(dst);
    const srcSt = statSync(src);
    const typeOk = isDir ? st.isDirectory() : st.isFile();
    if (!typeOk) {
      skipped.push(`${dst} (tipo inatteso)`);
      return;
    }
    // Copia: aggiorna solo se la sorgente è più recente. Le modifiche locali restano.
    if (srcSt.mtimeMs > st.mtimeMs) {
      try {
        rmSync(dst, { recursive: isDir, force: true });
        if (isDir) cpSync(src, dst);
        else copyFileSync(src, dst);
        refreshed.push(dst);
      } catch (e) {
        failed.push(`${dst}: ${e.message}`);
      }
    } else {
      skipped.push(`${dst} (copia, invariata)`);
    }
    return;
  }

  try {
    const type = isDir && process.platform === "win32" ? "junction" : isDir ? "dir" : "file";
    symlinkSync(src, dst, type);
    linked.push(dst);
  } catch (e) {
    try {
      if (isDir) cpSync(src, dst);
      else copyFileSync(src, dst);
      refreshed.push(`${dst} (copia)`);
    } catch (e2) {
      failed.push(`${dst}: ${e2.message}`);
    }
  }
}

function linkDir(srcDir, dstDir, kind) {
  for (const entry of readdirSync(srcDir)) {
    if (entry.startsWith(".")) continue;
    const src = join(srcDir, entry);
    if (kind === "skill") {
      if (!existsSync(join(src, "SKILL.md")) && !entry.endsWith(".md")) continue;
      link(src, join(dstDir, entry), true);
    } else {
      if (!entry.endsWith(".md")) continue;
      link(src, join(dstDir, entry), false);
    }
  }
}

function pick(base, names) {
  for (const n of names) {
    const p = join(base, n);
    if (existsSync(p)) return p;
  }
  return join(base, names[0]);
}

const cfg = configDir();
const agentsDir = pick(cfg, ["agents", "agent"]);
const skillsDir = pick(cfg, ["skills", "skill"]);
const commandsDir = pick(cfg, ["commands", "command"]);

linkDir(join(REPO, "agent"), agentsDir, "agent");
linkDir(join(REPO, "skill"), skillsDir, "skill");
linkDir(join(REPO, "command"), commandsDir, "command");

const lines = [];
if (linked.length) lines.push(`collegati: ${linked.length}`);
if (refreshed.length) lines.push(`aggiornati: ${refreshed.length}`);
if (skipped.length) lines.push(`invariati: ${skipped.length}`);
if (failed.length) lines.push(`errori: ${failed.length}`);
for (const f of failed) lines.push(`  ! ${f}`);
console.log(`CHIEF-LINK: OK — ${lines.join(", ") || "niente da fare"}`);
