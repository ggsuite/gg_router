---
name: translate
description: Checks whether documentation is out of sync between the languages of the repo and translates what is missing. Use when the user says "/translate" or asks whether anything needs translating.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Translate

Read `doc/en/guides/translate-guide.md` and follow it.

## 1. Find what is out of sync

Take the languages of the repo from the guide, the leading one first. List
the documentation of each language: `doc/<lang>`, `pm/<lang>` and
`README.md` or `README.<lang>.md`. Leave out `doc/<lang>/guides` and
`doc/<lang>/templates`, they come from the DNA.

Report three groups:

- files of one language without a counterpart in another language
- counterparts that exist only in a language that is not one of the repo
- pairs whose newer side changed after the older one, from `git log -1`

Stop here and report when every language is complete and current — there
is nothing to translate.

## 2. Translate what is missing

Translate content- and structure-equal, never literally.

Do not translate commands, code, paths, IDs or API names.

## 3. Show the result

List every file you wrote, then let the user review before committing.
