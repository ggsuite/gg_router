---
name: guide
description: Writes a new guide or reviews an existing one against the writing rules. Use when the user says "/guide" or asks to add or clean up documentation.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Guide

Read `doc/en/guides/dna-guides-guide.md` and `doc/en/guides/doc-guide.md` and
follow them.

## 1. Check the guides that are there

Report guides that duplicate content instead of referencing each other.

Report headings that do not read as a summary when listed together.

Report steps that span more than one line and prose where the imperative
belongs.

## 2. Write

Put a new guide in `dna/doc/en/guides` and ship it in every language:
the same file name in `dna/doc/de/guides` and `dna/doc/fa/guides`.

Keep it short, address the reader directly, one step per line.

## 3. Show the result

List every file you wrote, then let the user review before committing.
