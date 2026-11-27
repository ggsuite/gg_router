---
name: scripts
description: Checks that every script in dna/scripts is syntactically valid, imports resolve and logic is not duplicated. Use when the user says "/scripts" or asks whether the scripts still work.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Scripts

Read `doc/en/guides/scripts-guide.md` and follow it.

## 1. Check every script parses

Run `node --check` on each file in `scripts/` and `scripts/functions/`.

Report any file that fails.

## 2. Check the imports resolve

For each `import … from './functions/…'`, verify the target file exists
and exports the named symbol.

Report an import that resolves to nothing.

## 3. Check for duplication

Report a `git`, `fs` or `child_process` call that is copied across two
scripts instead of living in one shared function.

## 4. Fix

Write the corrections, then show the diff before committing.
