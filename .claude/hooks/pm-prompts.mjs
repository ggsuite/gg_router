// Keeps the prompts written to Claude Code in the project management repo.
//
// Claude Code runs this script on the hooks of .claude/settings.json:
// `prompt` notes each prompt in a buffer below ~/.claude/pm-prompts,
// `start` and `end` hand the buffer to a detached `sync`. The sync commits
// the prompts to the branch `prompts` of the project management repo
// without touching any working tree. Only the prompts are kept, never the
// answers. Nothing here may stop a prompt: every failure ends up in the log.

import { spawn, spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

/** The branch of the project management repo holding the prompts. */
export const promptsBranch = 'prompts';

const promptsDir = 'doc/prompts';
const peopleFile = 'doc/team/people.md';
const configFile = path.join('.claude', 'hooks', 'pm-prompts.json');

// A session that ended without an end event counts as ended after a week.
const staleMs = 7 * 24 * 60 * 60 * 1000;

// Prompts a project management repo did not take within a month are dropped.
const giveUpMs = 30 * 24 * 60 * 60 * 1000;

// A sync that holds its lock longer than this is taken to have crashed.
const lockMs = 10 * 60 * 1000;

const gitEnv = {
  ...process.env,
  GIT_TERMINAL_PROMPT: '0',
  GCM_INTERACTIVE: 'never',
};

// .............................................................................
/** The folder holding buffer, caches and log. */
export function home() {
  return (
    process.env.PM_PROMPTS_HOME ||
    path.join(os.homedir(), '.claude', 'pm-prompts')
  );
}

const sessionsDir = () => path.join(home(), 'sessions');

function sessionFile(sessionId) {
  const safe = String(sessionId).replace(/[^A-Za-z0-9-]/g, '');
  return path.join(sessionsDir(), `${safe}.jsonl`);
}

function log(message) {
  try {
    const file = path.join(home(), 'sync.log');
    fs.mkdirSync(home(), { recursive: true });
    const old = fs.existsSync(file)
      ? fs.readFileSync(file, 'utf8').split('\n').slice(-200)
      : [];
    old.push(`${new Date().toISOString()} ${message}`);
    fs.writeFileSync(file, old.join('\n').trimStart() + '\n');
  } catch {
    // Logging must never fail a hook.
  }
}

// .............................................................................
// Secrets

const secretPatterns = [
  /-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----/g,
  /\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}/g,
  /\bgithub_pat_[A-Za-z0-9_]{20,}/g,
  /\bglpat-[A-Za-z0-9_-]{20,}/g,
  /\bnpm_[A-Za-z0-9]{20,}/g,
  /\bsk-[A-Za-z0-9_-]{20,}/g,
  /\bxox[abprs]-[A-Za-z0-9-]{10,}/g,
  /\bAKIA[0-9A-Z]{16}\b/g,
  /\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}/g,
];

const keyedSecret =
  /\b(bearer|basic|password|passwort|passwd|pwd|secret|token|pat|api[_-]?key)(\s*[:=]\s*|\s+)("[^"]+"|'[^']+'|\S+)/gi;

const longToken = /[A-Za-z0-9][A-Za-z0-9_+=-]{31,}/g;

// Whether a long run of characters looks like a generated secret rather than
// a word, a path or a commit hash.
function looksRandom(token) {
  const upper = /[A-Z]/.test(token);
  const lower = /[a-z]/.test(token);
  const digit = /[0-9]/.test(token);
  if (upper && lower && digit) return true;
  return /^[a-z0-9]{40,}$/.test(token) && digit && !/^[0-9a-f]+$/.test(token);
}

/** [text] with everything that looks like a secret replaced. */
export function redact(text) {
  let result = text;
  for (const pattern of secretPatterns) {
    result = result.replace(pattern, '[redacted]');
  }
  result = result.replace(keyedSecret, (match, key, separator, value) =>
    value.length >= 6 && !value.startsWith('[redacted')
      ? `${key}${separator}[redacted]`
      : match,
  );
  return result.replace(longToken, (token) =>
    looksRandom(token) ? '[redacted]' : token,
  );
}

// .............................................................................
// Where the prompts go

function git(args, options = {}) {
  const result = spawnSync('git', args, {
    encoding: 'utf8',
    env: options.env ?? gitEnv,
    input: options.input,
    windowsHide: true,
    timeout: options.timeout ?? 120000,
  });
  return {
    ok: result.status === 0,
    out: (result.stdout ?? '').trim(),
    err: (result.stderr ?? '').trim() || String(result.error ?? ''),
  };
}

// The project management repo [dir] reports to, as named by its DNA.
function readPmRepo(dir) {
  try {
    const config = JSON.parse(
      fs.readFileSync(path.join(dir, configFile), 'utf8'),
    );
    return typeof config.pmRepo === 'string' ? config.pmRepo.trim() : '';
  } catch {
    return '';
  }
}

// The remote of [dir]. A clone of a local working clone reports the remote
// of that one.
function originOf(dir, depth = 0) {
  const origin = git(['-C', dir, 'remote', 'get-url', 'origin']);
  if (!origin.ok || !origin.out) return '';
  const local = path.resolve(dir, origin.out);
  if (depth < 3 && fs.existsSync(path.join(local, '.git'))) {
    return originOf(local, depth + 1) || origin.out;
  }
  return origin.out;
}

/**
 * The URL of the project management repo [pmRepo] beside the repo cloned
 * from [origin]: same host, same organization. A full URL is taken as is.
 * The name may end in `.git`: the DNA writes it that way, because helix
 * would re-case a bare name like `my_pm` into `myPm`.
 */
export function pmRepoUrl(pmRepo, origin) {
  if (!pmRepo) return '';
  if (/^[a-z][a-z0-9+.-]*:\/\/|^[^/\\\s]+@[^/\\\s]+:/i.test(pmRepo)) {
    return pmRepo;
  }
  const name = pmRepo.replace(/\.git$/, '');
  const match = (origin ?? '').match(/^(.*[/:\\])[^/:\\]+?(\.git)?[/\\]?$/);
  return match ? `${match[1]}${name}${match[2] ?? ''}` : '';
}

/**
 * The project management repos a session in [projectDir] reports to. A repo
 * names its own; a folder holding several repos, like a gg ticket, reports
 * to the ones its repos name.
 */
export function findTargets(projectDir) {
  let folders = [projectDir];
  if (!readPmRepo(projectDir)) {
    let entries = [];
    try {
      entries = fs.readdirSync(projectDir, { withFileTypes: true });
    } catch {
      // An unreadable folder reports nowhere.
    }
    folders = entries
      .filter((e) => e.isDirectory() && !e.name.startsWith('.'))
      .map((e) => path.join(projectDir, e.name))
      .filter((dir) => readPmRepo(dir));
  }
  const targets = [];
  const repos = [];
  for (const dir of folders.sort()) {
    const url = pmRepoUrl(readPmRepo(dir), originOf(dir));
    if (!url) continue;
    repos.push(path.basename(dir));
    if (!targets.includes(url)) targets.push(url);
  }
  return { targets, repos };
}

// .............................................................................
// The buffer

function appendLine(file, entry) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.appendFileSync(file, JSON.stringify(entry) + '\n');
}

function readSession(file) {
  const session = { meta: undefined, prompts: [], ended: false };
  for (const line of fs.readFileSync(file, 'utf8').split('\n')) {
    if (!line.trim()) continue;
    try {
      const entry = JSON.parse(line);
      if (entry.type === 'meta') session.meta = entry;
      if (entry.type === 'prompt') session.prompts.push(entry);
      if (entry.type === 'end') session.ended = true;
    } catch {
      // A line cut short by a crash is skipped.
    }
  }
  return session;
}

/** Notes the prompt of a `UserPromptSubmit` [input] in the buffer. */
export function onPrompt(input) {
  if (!input.session_id || typeof input.prompt !== 'string') return;
  const file = sessionFile(input.session_id);
  if (!fs.existsSync(file)) {
    const projectDir = process.env.CLAUDE_PROJECT_DIR || input.cwd;
    const { targets, repos } = findTargets(projectDir);
    if (!targets.length) return;
    appendLine(file, {
      type: 'meta',
      session: input.session_id,
      started: new Date().toISOString(),
      folder: path.basename(projectDir),
      repos,
      email: git(['-C', projectDir, 'config', 'user.email']).out,
      targets,
    });
  }
  appendLine(file, {
    type: 'prompt',
    at: new Date().toISOString(),
    text: redact(input.prompt),
  });
}

/** Marks the session of a `SessionEnd` [input] as ended. */
export function onEnd(input) {
  const file = sessionFile(input.session_id ?? '');
  if (fs.existsSync(file)) {
    appendLine(file, { type: 'end', at: new Date().toISOString() });
  }
}

// Starts a sync that outlives Claude Code and keeps the session waiting for
// nothing.
function startSync() {
  if (!fs.existsSync(sessionsDir())) return;
  if (!fs.readdirSync(sessionsDir()).some((f) => f.endsWith('.jsonl'))) return;
  const child = spawn(
    process.execPath,
    [fileURLToPath(import.meta.url), 'sync'],
    { detached: true, stdio: 'ignore', windowsHide: true },
  );
  child.unref();
}

// .............................................................................
// Rendering

const pad = (n) => String(n).padStart(2, '0');

function localDate(iso) {
  const d = new Date(iso);
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

function localTime(iso) {
  const d = new Date(iso);
  return `${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

/** The folder name of a person: lower case, umlauts spelled out. */
export function slug(name) {
  return name
    .toLowerCase()
    .replace(/ä/g, 'ae')
    .replace(/ö/g, 'oe')
    .replace(/ü/g, 'ue')
    .replace(/ß/g, 'ss')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/** The first name in [peopleMd] whose `Git` line lists [email]. */
export function personOf(email, peopleMd) {
  if (!email) return '';
  let name = '';
  for (const line of peopleMd.split(/\r?\n/)) {
    const heading = line.match(/^##\s+(.+?)\s*$/);
    if (heading) {
      name = heading[1];
      continue;
    }
    const emails = line.match(/^\s*-\s*Git:\s*(.+)$/i);
    if (
      name &&
      emails &&
      emails[1]
        .split(/[,;\s]+/)
        .some((e) => e.toLowerCase() === email.toLowerCase())
    ) {
      return name;
    }
  }
  return '';
}

/** Where the prompts of a session go in the project management repo. */
export function promptsPath(meta, person) {
  const date = localDate(meta.started);
  const folder = person ? slug(person) : '_unknown';
  const id = String(meta.session).slice(0, 8);
  return `${promptsDir}/${folder}/${date.slice(0, 7)}/${date}_${slug(meta.folder) || 'session'}_${id}.md`;
}

/** The head of the file a session's prompts start. */
export function renderHead(meta, person) {
  const lines = [
    `# ${localDate(meta.started)} · ${meta.folder} · ${String(meta.session).slice(0, 8)}`,
    '',
    `- Person: ${person || meta.email || 'unknown'}`,
  ];
  const repos = meta.repos ?? [];
  if (repos.length === 1 && repos[0] === meta.folder) {
    lines.push(`- Repo: ${meta.folder}`);
  } else {
    lines.push(`- Folder: ${meta.folder}`, `- Repos: ${repos.join(', ')}`);
  }
  lines.push(`- Session: ${meta.session}`);
  return lines.join('\n') + '\n';
}

/** [prompts] as Markdown sections, a heading with the time each. */
export function renderPrompts(prompts) {
  return prompts
    .map((p) => {
      // A prompt's own headings must not break the structure of the file.
      const text = p.text.replace(/\r\n/g, '\n').replace(/^#/gm, '\\#');
      return `\n## ${localTime(p.at)}\n\n${text.trim()}\n`;
    })
    .join('');
}

// .............................................................................
// Sync

// A short folder per URL: Windows refuses long object paths.
function cacheDir(url) {
  const hash = createHash('sha1').update(url).digest('hex').slice(0, 10);
  const name = slug(url.replace(/\.git\/?$/, '').split(/[/:]/).at(-1) ?? '');
  return path.join(home(), 'repos', `${name.slice(0, 30)}-${hash}.git`);
}

function ensureCache(url) {
  const dir = cacheDir(url);
  if (!fs.existsSync(path.join(dir, 'HEAD'))) {
    fs.mkdirSync(dir, { recursive: true });
    const init = git(['init', '--bare', '-q', dir]);
    if (!init.ok) throw new Error(`git init ${dir}: ${init.err}`);
  }
  if (!git(['-C', dir, 'remote', 'set-url', 'origin', url]).ok) {
    git(['-C', dir, 'remote', 'add', 'origin', url]);
  }
  return dir;
}

function readPeople(dir) {
  const fetched = git(['-C', dir, 'fetch', '-q', '--depth=1', 'origin', 'HEAD']);
  if (!fetched.ok) throw new Error(`fetch HEAD: ${fetched.err}`);
  return git(['-C', dir, 'show', `FETCH_HEAD:${peopleFile}`]).out;
}

// The tip of the prompts branch, '' while it does not exist yet.
function fetchBranch(dir) {
  const heads = git(['-C', dir, 'ls-remote', '--heads', 'origin', promptsBranch]);
  if (!heads.ok) throw new Error(`ls-remote: ${heads.err}`);
  if (!heads.out) return '';
  const ref = `refs/heads/${promptsBranch}`;
  const fetched = git(['-C', dir, 'fetch', '-q', 'origin', `+${ref}:${ref}`]);
  if (!fetched.ok) throw new Error(`fetch ${promptsBranch}: ${fetched.err}`);
  return git(['-C', dir, 'rev-parse', ref]).out;
}

function identityEnv(dir) {
  const env = { ...gitEnv };
  if (!git(['-C', dir, 'config', 'user.name']).out) {
    env.GIT_AUTHOR_NAME = env.GIT_COMMITTER_NAME = 'pm-prompts';
  }
  if (!git(['-C', dir, 'config', 'user.email']).out) {
    env.GIT_AUTHOR_EMAIL = env.GIT_COMMITTER_EMAIL = 'pm-prompts@localhost';
  }
  return env;
}

// Commits the not yet pushed prompts of [sessions] to the prompts branch of
// [url]. Returns how many prompts of each session the branch now holds.
function pushTarget(url, sessions) {
  const dir = ensureCache(url);
  const people = readPeople(dir);
  for (let attempt = 0; attempt < 3; attempt++) {
    const base = fetchBranch(dir);
    const index = path.join(
      os.tmpdir(),
      `pm-prompts-${process.pid}-${Date.now()}.index`,
    );
    const env = { ...identityEnv(dir), GIT_INDEX_FILE: index };
    try {
      const read = base
        ? git(['-C', dir, 'read-tree', base], { env })
        : git(['-C', dir, 'read-tree', '--empty'], { env });
      if (!read.ok) throw new Error(`read-tree: ${read.err}`);
      const names = new Set();
      const done = new Map();
      for (const { file, session, pushed } of sessions) {
        const fresh = session.prompts.slice(pushed);
        done.set(file, session.prompts.length);
        if (!fresh.length) continue;
        const person = personOf(session.meta.email, people);
        names.add(person || session.meta.email || 'unknown');
        const target = promptsPath(session.meta, person);
        const existing = base
          ? git(['-C', dir, 'cat-file', '-p', `${base}:${target}`])
          : { ok: false, out: '' };
        const head = existing.ok
          ? existing.out + '\n'
          : renderHead(session.meta, person);
        const blob = git(['-C', dir, 'hash-object', '-w', '--stdin'], {
          env,
          input: head + renderPrompts(fresh),
        });
        if (!blob.ok) throw new Error(`hash-object: ${blob.err}`);
        const added = git(
          [
            '-C',
            dir,
            'update-index',
            '--add',
            '--cacheinfo',
            `100644,${blob.out},${target}`,
          ],
          { env },
        );
        if (!added.ok) throw new Error(`update-index: ${added.err}`);
      }
      if (!names.size) return done;
      const tree = git(['-C', dir, 'write-tree'], { env });
      if (!tree.ok) throw new Error(`write-tree: ${tree.err}`);
      const message = `Add prompts of ${[...names].sort().join(', ')}`;
      const commit = git(
        [
          '-C',
          dir,
          'commit-tree',
          tree.out,
          ...(base ? ['-p', base] : []),
          '-m',
          message,
        ],
        { env },
      );
      if (!commit.ok) throw new Error(`commit-tree: ${commit.err}`);
      const pushed = git([
        '-C',
        dir,
        'push',
        '-q',
        'origin',
        `${commit.out}:refs/heads/${promptsBranch}`,
      ]);
      if (pushed.ok) return done;
      log(`push to ${url} rejected, retrying: ${pushed.err}`);
    } finally {
      fs.rmSync(index, { force: true });
    }
  }
  throw new Error(`push to ${url} failed three times`);
}

function takeLock() {
  const lock = path.join(home(), 'sync.lock');
  fs.mkdirSync(home(), { recursive: true });
  try {
    fs.writeFileSync(lock, String(process.pid), { flag: 'wx' });
  } catch {
    if (Date.now() - fs.statSync(lock).mtimeMs < lockMs) return undefined;
    fs.writeFileSync(lock, String(process.pid));
  }
  return () => fs.rmSync(lock, { force: true });
}

/** Pushes every buffered prompt and drops the sessions that are through. */
export function sync() {
  const release = takeLock();
  if (!release) return;
  try {
    if (!fs.existsSync(sessionsDir())) return;
    const byTarget = new Map();
    const all = [];
    for (const name of fs.readdirSync(sessionsDir())) {
      if (!name.endsWith('.jsonl')) continue;
      const file = path.join(sessionsDir(), name);
      const session = readSession(file);
      if (!session.meta) {
        fs.rmSync(file, { force: true });
        continue;
      }
      const stateFile = file.replace(/\.jsonl$/, '.state.json');
      let state = {};
      try {
        state = JSON.parse(fs.readFileSync(stateFile, 'utf8'));
      } catch {
        // No state yet: nothing of the session was pushed.
      }
      const entry = { file, stateFile, session, state };
      all.push(entry);
      for (const url of session.meta.targets) {
        if (!byTarget.has(url)) byTarget.set(url, []);
        byTarget.get(url).push({ file, session, pushed: state[url] ?? 0 });
      }
    }
    for (const [url, sessions] of byTarget) {
      try {
        const done = pushTarget(url, sessions);
        for (const entry of all) {
          if (done.has(entry.file)) entry.state[url] = done.get(entry.file);
        }
      } catch (e) {
        log(`sync ${url}: ${e.message}`);
      }
    }
    for (const { file, stateFile, session, state } of all) {
      const through = session.meta.targets.every(
        (url) => (state[url] ?? 0) >= session.prompts.length,
      );
      const lastAt = session.prompts.at(-1)?.at ?? session.meta.started;
      const age = Date.now() - new Date(lastAt).getTime();
      const ended = session.ended || age > staleMs;
      if (!through && age > giveUpMs) {
        log(`dropped ${file}: not taken within a month`);
      }
      if ((through && ended) || age > giveUpMs) {
        fs.rmSync(file, { force: true });
        fs.rmSync(stateFile, { force: true });
      } else {
        fs.writeFileSync(stateFile, JSON.stringify(state));
      }
    }
  } finally {
    release();
  }
}

// .............................................................................

function readStdin() {
  try {
    return JSON.parse(fs.readFileSync(0, 'utf8') || '{}');
  } catch {
    return {};
  }
}

function main(event) {
  try {
    if (event === 'prompt') onPrompt(readStdin());
    if (event === 'end') {
      onEnd(readStdin());
      startSync();
    }
    if (event === 'start') startSync();
    if (event === 'sync') sync();
  } catch (e) {
    log(`${event}: ${e.stack ?? e}`);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main(process.argv[2]);
}
