#!/usr/bin/env node

/**
 * @license
 * Copyright (c) ggsuite
 *
 * Use of this source code is governed by terms that can be
 * found in the LICENSE file in the root of this package.
 */

// Checks README.md and README.de.md against the README guides and prints
// every finding. Usage: node scripts/check-readme.js [repo directory]

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// .............................................................................
// The sections of the templates, in their order

const packageSections = [
  { name: 'Motivation', required: true },
  { name: 'Installation', required: true },
  { name: 'Usage', required: true },
  { name: 'Limitations' },
  { name: 'Documentation' },
  { name: 'How it works' },
  { name: 'Status' },
  { name: 'Contributing' },
  { name: 'License', required: true },
];

const dnaSections = [
  { name: 'Motivation', required: true },
  { name: 'Usage', required: true },
  { name: 'Guides' },
  { name: 'Templates' },
  { name: 'Skills' },
  { name: 'Scripts' },
  { name: 'Configuration' },
  { name: 'Scope' },
  { name: 'Layers', required: true },
  { name: 'Variables' },
  { name: 'Development', required: true },
  { name: 'License', required: true },
];

const maxBadges = 5;

// .............................................................................
// Reading files

const readText = (file) =>
  fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null;

// Reads a JSONC file of the repo; a broken one becomes a finding.
const readJsonc = (repoDir, file, findings) => {
  const text = readText(path.join(repoDir, file));
  if (text === null) return null;
  try {
    return parseJsonc(text);
  } catch {
    findings?.push(`${file} is not valid JSON`);
    return null;
  }
};

// Strips comments and trailing commas, so JSONC parses as JSON.
export const parseJsonc = (text) => {
  let out = '';
  let inString = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (inString) {
      out += c;
      if (c === '\\') out += text[++i] ?? '';
      else if (c === '"') inString = false;
    } else if (c === '"') {
      inString = true;
      out += c;
    } else if (c === '/' && text[i + 1] === '/') {
      while (i < text.length && text[i] !== '\n') i++;
      out += '\n';
    } else if (c === '/' && text[i + 1] === '*') {
      i = text.indexOf('*/', i + 2);
      if (i < 0) break;
      i++;
    } else {
      out += c;
    }
  }
  return JSON.parse(out.replace(/,(\s*[}\]])/g, '$1'));
};

// Reads a top-level scalar of pubspec.yaml, also when it spans lines.
export const yamlScalar = (text, key) => {
  const lines = text.split(/\r?\n/);
  const start = lines.findIndex((l) => l.startsWith(`${key}:`));
  if (start < 0) return null;

  const parts = [lines[start].slice(key.length + 1).trim()];
  for (const line of lines.slice(start + 1)) {
    if (!/^\s+\S/.test(line)) break;
    parts.push(line.trim());
  }

  let value = parts.join(' ').trim();
  if (/^[>|][+-]?/.test(value)) value = value.replace(/^[>|][+-]?\s*/, '');
  const quote = value[0];
  if ((quote === '"' || quote === "'") && value.endsWith(quote)) {
    value = value.slice(1, -1);
    if (quote === '"') value = value.replace(/\\"/g, '"');
  }
  return value;
};

// The GitHub organization and repo a repository URL points at
const githubRepo = (url) => {
  const m = (url ?? '').match(
    /github\.com[/:]([^/]+)\/([^/#?]+?)(?:\.git)?\/?$/,
  );
  return m ? { org: m[1], repo: m[2] } : null;
};

// Name, descriptions and repository of pubspec.yaml and package.json
const readPackage = (repoDir) => {
  const result = { name: null, descriptions: [], repository: null };

  const pubspec = readText(path.join(repoDir, 'pubspec.yaml'));
  if (pubspec) {
    result.name = yamlScalar(pubspec, 'name');
    const description = yamlScalar(pubspec, 'description');
    if (description) result.descriptions.push(['pubspec.yaml', description]);
    result.repository = githubRepo(yamlScalar(pubspec, 'repository'));
  }

  const packageJson = readText(path.join(repoDir, 'package.json'));
  if (packageJson) {
    const json = JSON.parse(packageJson);
    result.name ??= (json.name ?? '').replace(/^@[^/]+\//, '');
    if (json.description) {
      result.descriptions.push(['package.json', json.description]);
    }
    const url =
      typeof json.repository === 'string'
        ? json.repository
        : json.repository?.url;
    result.repository ??= githubRepo(url);
  }

  result.name ??= path.basename(repoDir);
  return result;
};

const listFiles = (dir, base = dir) =>
  fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) return listFiles(full, base);
    return [path.relative(base, full).split(path.sep).join('/')];
  });

// .............................................................................
// Parsing Markdown

// Splits Markdown into prose and code. `text` is the Markdown without code
// blocks and HTML comments; `prose` also lacks the inline code.
export const parseMarkdown = (markdown) => {
  const codeBlocks = [];
  const inlineCode = [];
  const textLines = [];
  let fence = null;
  let block = null;

  for (const line of markdown.split(/\r?\n/)) {
    const match = line.match(/^ {0,3}(`{3,}|~{3,})\s*([\w-]*)/);
    const closes =
      match &&
      fence &&
      match[1][0] === fence[0] &&
      match[1].length >= fence.length;
    if (fence && closes) {
      codeBlocks.push({ ...block, code: block.code.join('\n') });
      fence = null;
    } else if (fence) {
      block.code.push(line);
    } else if (match) {
      fence = match[1];
      block = { language: match[2], code: [] };
    }
    textLines.push(fence || match ? '' : line);
  }

  const text = textLines
    .join('\n')
    .replace(/<!--[\s\S]*?-->/g, (c) => c.replace(/[^\n]/g, ''));
  const prose = text.replace(/(`+)([\s\S]*?)\1/g, (_, _ticks, code) => {
    inlineCode.push(code);
    return '';
  });

  const headings = (level) =>
    prose
      .split('\n')
      .map((l) => l.match(new RegExp(`^#{${level}}\\s+(.+?)\\s*#*\\s*$`)))
      .filter(Boolean)
      .map((m) => m[1]);

  return {
    text,
    prose,
    inlineCode,
    codeBlocks,
    h1: headings(1),
    h2: headings(2),
  };
};

const normalize = (text) =>
  text
    .replace(/!?\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/[`*_]/g, '')
    .replace(/\s+/g, ' ')
    .trim()
    .replace(/\.$/, '')
    .toLowerCase();

// The first paragraph below the title that is neither a badge nor the
// language switcher.
const introOf = (prose) => {
  const paragraphs = prose.split(/\n\s*\n/).map((p) => p.trim());
  const title = paragraphs.findIndex((p) => /^#\s/.test(p));
  return (
    paragraphs
      .slice(title + 1)
      .find(
        (p) =>
          p &&
          !p.startsWith('#') &&
          !/^(\[!\[|!\[|<)/.test(p) &&
          !/\[(Deutsch|English)\]\(README/.test(p),
      ) ?? null
  );
};

// Whether text names a path or name on its own, not as part of a longer one
const mentions = (text, name) => {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return new RegExp(`(?<![\\w./-])${escaped}(?![\\w-]|\\.\\w|/\\w)`).test(
    text,
  );
};

// .............................................................................
// The checks of README.md and README.de.md

const checkSections = (md, sections, findings) => {
  const known = sections.map((s) => s.name.toLowerCase());
  const present = md.h2.map((h) => h.toLowerCase());

  for (const section of sections) {
    if (section.required && !present.includes(section.name.toLowerCase())) {
      findings.push(`Section "## ${section.name}" is missing`);
    }
  }

  const order = present.filter((h) => known.includes(h));
  for (let i = 1; i < order.length; i++) {
    if (known.indexOf(order[i]) < known.indexOf(order[i - 1])) {
      const name = sections[known.indexOf(order[i])].name;
      const before = sections[known.indexOf(order[i - 1])].name;
      findings.push(`Section "## ${name}" belongs before "## ${before}"`);
    }
  }
};

// A placeholder is a sentence in angle brackets, a token of the template
// such as <package>, a template line copied unchanged, or dnaXxx.
const checkPlaceholders = (md, markdown, template, prefix, findings) => {
  const found = new Set();
  const add = (p) => found.add(p.replace(/\s+/g, ' '));

  const sentences = [
    /<(?!https?:|!--)[A-Z][^<>]*>/g,
    /<[a-z][^<>=]*\s[^<>=/]*>/g,
  ];
  for (const pattern of sentences) {
    for (const m of md.prose.matchAll(pattern)) add(m[0]);
  }

  const tokens = new Set((template ?? '').match(/<[\w-]+>/g) ?? []);
  const code = [...md.inlineCode, ...md.codeBlocks.map((b) => b.code)];
  for (const text of [md.prose, ...code]) {
    for (const token of tokens) if (text.includes(token)) add(token);
    for (const m of text.matchAll(/\b\w*Xxx\b/g)) add(m[0]);
  }

  const templateLines = new Set(
    (template ?? '')
      .split(/\r?\n/)
      .map((l) => l.trim())
      .filter((l) => /<[\w-]+>/.test(l) && !l.startsWith('<!--')),
  );
  for (const line of markdown.split(/\r?\n/).map((l) => l.trim())) {
    const known = [...found].some((p) => line.includes(p));
    if (templateLines.has(line) && !known) add(line);
  }

  for (const block of md.codeBlocks) {
    if (block.language !== 'text') continue;
    for (const m of block.code.matchAll(/<[A-Z][^<>]*\s[^<>]*>/g)) add(m[0]);
  }

  for (const placeholder of found) {
    const short =
      placeholder.length > 60 ? `${placeholder.slice(0, 57)}...` : placeholder;
    findings.push(`${prefix}Placeholder ${short} is left`);
  }
};

const linkPattern = /\[([^\]]*)\]\(\s*<?([^)\s>]+)>?(?:\s+"[^"]*")?\s*\)/g;
const workflowPattern =
  /github\.com\/([^/]+)\/([^/]+)\/actions\/workflows\/([^/?#]+)/;

// A badge of the repo's own workflow points at its organization and at a
// workflow file that exists. Image and link of a badge report once.
const checkBadge = (badge, repoDir, pkg, prefix, findings) => {
  const [, org, repo, workflow] = badge;
  const own = pkg.repository
    ? repo === pkg.repository.repo
    : repo === pkg.name || repo === path.basename(repoDir);
  if (!own) return;

  if (pkg.repository && org !== pkg.repository.org) {
    findings.add(
      `${prefix}Badge points to the organization ${org}, ` +
        `the repository is in ${pkg.repository.org}`,
    );
  }
  if (!fs.existsSync(path.join(repoDir, '.github/workflows', workflow))) {
    findings.add(
      `${prefix}Badge points to .github/workflows/${workflow}, ` +
        'which does not exist',
    );
  }
};

// A relative link points at a file of the repo.
const checkLinkTarget = (target, repoDir, prefix, findings) => {
  if (/^([a-z][a-z0-9+.-]*:|#|\/\/)/i.test(target)) return;
  let file;
  try {
    file = decodeURI(target.replace(/[#?].*$/, ''));
  } catch {
    findings.push(`${prefix}Link ${target} is not a valid URI`);
    return;
  }
  if (file && !fs.existsSync(path.resolve(repoDir, file))) {
    findings.push(
      `${prefix}Link ${target} points to a file that does not exist`,
    );
  }
};

const checkLinks = (md, repoDir, pkg, prefix, findings) => {
  const links = [...md.prose.matchAll(linkPattern)].map((m) => ({
    label: m[1],
    target: m[2],
  }));
  const references = md.prose.matchAll(/^\s*\[[^\]]+\]:\s*(\S+)/gm);
  const attributes = md.prose.matchAll(/\b(?:src|href|srcset)="([^"\s]+)/g);
  const targets = new Set([
    ...links.map((l) => l.target),
    ...[...references, ...attributes].map((m) => m[1]),
  ]);

  for (const { label } of links) {
    if (/^\s*(here|hier|this|link|click here)\s*$/i.test(label)) {
      findings.push(
        `${prefix}Link text "${label}" does not say where it leads`,
      );
    }
  }

  const badgeFindings = new Set();
  for (const target of targets) {
    const badge = target.match(workflowPattern);
    if (target.startsWith('http://')) {
      findings.push(`${prefix}Link ${target} uses http, use https`);
    } else if (badge) {
      checkBadge(badge, repoDir, pkg, prefix, badgeFindings);
    } else {
      checkLinkTarget(target, repoDir, prefix, findings);
    }
  }
  findings.push(...badgeFindings);
};

const checkMarkdown = (md, prefix, findings) => {
  const badges = md.prose.match(/\[!\[[^\]]*\]\([^)]*\)\]\([^)]*\)/g) ?? [];
  if (badges.length > maxBadges) {
    findings.push(
      `${prefix}${badges.length} badges, keep at most ${maxBadges}`,
    );
  }
  const untagged = md.codeBlocks.filter((b) => !b.language).length;
  if (untagged > 0) {
    findings.push(`${prefix}${untagged} code block(s) without a language`);
  }
};

const checkTitleAndIntro = (md, pkg, findings) => {
  if (md.h1.length !== 1) {
    findings.push(`README.md has ${md.h1.length} titles, it needs one`);
  } else if (
    normalize(md.h1[0].replace(/^`?@[^/]+\//, '')).replace(/-/g, '') !==
    normalize(pkg.name).replace(/-/g, '')
  ) {
    findings.push(
      `The title "${md.h1[0]}" is not the package name ${pkg.name}`,
    );
  }

  const [first, second] = pkg.descriptions;
  if (second && normalize(first[1]) !== normalize(second[1])) {
    findings.push(
      `The description in ${first[0]} differs from the one in ${second[0]}`,
    );
  }

  const intro = introOf(md.prose);
  if (!intro) {
    findings.push(
      'The sentence below the title saying what it does is missing',
    );
  } else if (first && !normalize(intro).includes(normalize(first[1]))) {
    findings.push(
      `The sentence below the title differs from the description "${first[1]}"`,
    );
  }
};

const checkGerman = (repoDir, md, pkg, template, findings) => {
  if (!/\[Deutsch\]\(\.?\/?README\.de\.md\)/.test(md.prose)) {
    findings.push(
      'README.md: the language switcher to README.de.md is missing',
    );
  }
  const markdown = readText(path.join(repoDir, 'README.de.md'));
  if (markdown === null) {
    findings.push('README.de.md is missing');
    return;
  }

  const prefix = 'README.de.md: ';
  const de = parseMarkdown(markdown);
  if (!/\[English\]\(\.?\/?README\.md\)/.test(de.prose)) {
    findings.push(`${prefix}the language switcher to README.md is missing`);
  }
  if (de.h2.length !== md.h2.length) {
    findings.push(
      `${prefix}${de.h2.length} sections, README.md has ${md.h2.length}`,
    );
  }

  const en = md.codeBlocks.map((b) => b.code.trim());
  const ge = de.codeBlocks.map((b) => b.code.trim());
  if (en.length !== ge.length) {
    findings.push(
      `${prefix}${ge.length} code blocks, README.md has ${en.length}`,
    );
  } else {
    const index = en.findIndex((code, i) => code !== ge[i]);
    if (index >= 0) {
      findings.push(`${prefix}code block ${index + 1} differs from README.md`);
    }
  }

  checkPlaceholders(de, markdown, template, prefix, findings);
  checkLinks(de, repoDir, pkg, prefix, findings);
};

// .............................................................................
// The checks of a DNA repo

// Every file the layer ships is mentioned, by itself or by its folder; a
// skill by its command.
const checkShippedFiles = (repoDir, text, findings) => {
  const files = listFiles(path.join(repoDir, 'dna')).filter(
    (f) => !/^_[^/]*\.json$/.test(f),
  );
  const skills = new Set();
  for (const file of files) {
    const skill = file.match(/^dot-claude\/skills\/([^/]+)\//);
    if (skill) {
      skills.add(skill[1]);
      continue;
    }
    const folder = path.posix.dirname(`dna/${file}`);
    if (!mentions(text, `dna/${file}`) && !mentions(text, `${folder}/`)) {
      findings.push(`dna/${file} is not mentioned`);
    }
  }
  for (const skill of skills) {
    if (!mentions(text, `/${skill}`)) {
      findings.push(`Skill /${skill} is not mentioned`);
    }
  }
};

const checkMentionedFiles = (repoDir, text, findings) => {
  const paths = text.match(/(?<![\w./-])dna\/[\w./-]*[\w/]/g) ?? [];
  for (const file of new Set(paths)) {
    if (!fs.existsSync(path.join(repoDir, file))) {
      findings.push(`${file} is mentioned but does not exist`);
    }
  }
};

const checkVariables = (repoDir, text, findings) => {
  const vars = readJsonc(repoDir, 'dna/_vars.json', findings) ?? {};
  for (const key of Object.keys(vars)) {
    if (!text.includes(`\`${key}\``)) {
      findings.push(`Variable ${key} is not documented`);
    }
  }
};

// Every parent layer is named, or the layer says it is orthogonal
const checkParentLayers = (repoDir, text, findings) => {
  const config = readJsonc(repoDir, 'dna/_dna.json', findings);
  const layers = config?.layers ?? [];
  for (const layer of layers) {
    const name =
      typeof layer === 'string' ? layer : (layer.package ?? layer.name);
    const bare = (name ?? '').replace(/^@[^/]+\//, '');
    const variants = [bare, bare.replace(/-/g, '_'), bare.replace(/_/g, '-')];
    if (name && !variants.some((v) => mentions(text, v))) {
      findings.push(`Parent layer ${name} is not named`);
    }
  }
  const orthogonal =
    /\borthogonal\b/i.test(text) && !/\bnot orthogonal\b/i.test(text);
  if (layers.length === 0 && !orthogonal) {
    findings.push('The README does not say that the layer is orthogonal');
  }
};

const checkDna = (repoDir, md, findings) => {
  checkShippedFiles(repoDir, md.text, findings);
  checkMentionedFiles(repoDir, md.text, findings);
  checkVariables(repoDir, md.text, findings);
  checkParentLayers(repoDir, md.text, findings);
};

// .............................................................................

// A DNA layer is named dna_* or dna-*, or declares variables its consumers
// must set. A project that only uses layers has neither.
export const isDnaRepo = (repoDir, packageName) => {
  if (/^dna[_-]/.test(packageName ?? '')) return true;
  const config = readJsonc(repoDir, 'dna/_dna.json');
  return config?.mustOverride !== undefined;
};

export const checkReadme = (repoDir) => {
  const markdown = readText(path.join(repoDir, 'README.md'));
  if (markdown === null) return ['README.md is missing'];

  const findings = [];
  const pkg = readPackage(repoDir);
  const isDna = isDnaRepo(repoDir, pkg.name);
  const md = parseMarkdown(markdown);
  const template = readText(
    path.join(
      repoDir,
      'doc/templates',
      isDna ? 'readme-dna-template.md' : 'readme-template.md',
    ),
  );

  checkTitleAndIntro(md, pkg, findings);
  checkSections(md, isDna ? dnaSections : packageSections, findings);
  checkPlaceholders(md, markdown, template, '', findings);
  checkLinks(md, repoDir, pkg, '', findings);
  checkMarkdown(md, '', findings);
  checkGerman(repoDir, md, pkg, template, findings);
  if (isDna) checkDna(repoDir, md, findings);

  return findings;
};

// .............................................................................

const isMain =
  process.argv[1] &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isMain) {
  const repoDir = path.resolve(process.argv[2] ?? '.');
  const findings = checkReadme(repoDir);
  if (findings.length === 0) {
    console.log('✓ README matches the guide');
  } else {
    for (const finding of findings) console.log(`✗ ${finding}`);
    process.exit(1);
  }
}
