---
name: translate
description: Checks whether documentation is out of sync between English and German and translates what is missing. Use when the user says "/translate" or asks whether anything needs translating.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Translate

Read `doc/guides/translate-guide.md` and follow it.

## 1. Find what is out of sync

List the English documentation (`doc`, `README.md`) and the German one
(`doc/de`, `README.de.md`).

Report three groups:

- English files without a German counterpart
- German files without an English counterpart
- pairs whose newer side changed after the older one, from `git log -1`

Cover the blog the same way: `doc/blog/<yyyy>` against
`doc/de/blog/<yyyy>`.

Stop here and report when every pair is complete and current — there is
nothing to translate.

## 2. Translate what is missing

Translate content- and structure-equal, never literally.

Do not translate commands, code, paths or API names.

## 3. Show the result

List every file you wrote, then let the user review before committing.
