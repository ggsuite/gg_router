---
name: readme
description: Checks the README against the README guide and template and fixes what is missing. Use when the user says "/readme" or asks to write or review the README.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Readme

## 1. Pick the guide

A DNA repo is a layer other repos list in their `dna/_dna.json`: it is
named `dna_*` or `dna-*`, or its `dna/_dna.json` declares `mustOverride`.
In a DNA repo read `doc/guides/readme-dna-guide.md` and
`doc/templates/readme-dna-template.md`.

Every other repo: read `doc/guides/readme-guide.md` and
`doc/templates/readme-template.md`.

Both follow the style, language and check rules of
`doc/guides/readme-guide.md`.

## 2. Run the check

Run `node scripts/check-readme.js`. It reports what a script can find:
missing or misplaced sections, leftover placeholders, broken links and
badges, a sentence that differs from the `description`, a German README
that drifted — and in a DNA repo every `dna/` file, variable and parent
layer the README does not mention.

## 3. Check what the script cannot

- The motivation says why the repo exists, not what it does. Ask the user
  when the repo does not tell — never invent it
- In a package repo every code example runs unchanged and matches
  `example/`, and its output is the one shown
- In a DNA repo the usage says where the files land and how to use what
  the layer ships
- Headings are in sentence case
- The documentation section links instead of duplicating
- `README.de.md` says the same as `README.md`, not only in structure

## 4. Fix

Write the corrections in both languages, run the check again until it
passes, then show the diff before committing.
