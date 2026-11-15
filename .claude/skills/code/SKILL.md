---
name: code
description: Checks the code of this repo against the code guide and reports what breaks the conventions. Use when the user says "/code" or asks for a structure review.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Code

Read `doc/guides/code-guide.md` and follow it. Read the guide for the
language of this repo as well — `code-guide-dart.md` or
`code-guide-typescript.md` next to it — and apply whichever one matches
what the repo is written in.

## 1. Check the layout

Report a barrel file that holds implementation, a file whose name does
not match its main type, and a source file without its test file.

## 2. Check the members

Report public members without a doc comment, mutable public fields,
classes without an `example` constructor, and types whose members are
out of the documented order.

## 3. Check the lints

Compare the lint configuration against the mandatory rule set of the
language guide and report what is missing or switched off without a
reason.

## 4. Report before fixing

List the findings first. Fix only what the user confirms.
