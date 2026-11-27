---
name: index
description: Creates or updates the repository index.jsonc from the index guide and template. Use when the user says "/index" or asks for the repo overview.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Index

Read `doc/en/guides/index-guide.md` and `doc/en/templates/index-template.jsonc`
and follow them.

## 1. Check whether the index is current

Report a missing `index.jsonc`.

Compare the described domain, goal and interfaces against the code that
is actually there — public entry points, exported classes, commands.

Report every entry that no longer exists and every interface that is
missing.

## 2. Update

Write the index, then show the diff before committing.
