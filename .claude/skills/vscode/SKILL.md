---
name: vscode
description: Checks that installed VS Code extensions match the recommended list and that settings.json is valid JSONC. Use when the user says "/vscode" or asks whether the editor setup is complete.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Vscode

Read `doc/en/guides/vscode-guide.md` and follow it.

## 1. Check the extensions

List `.vscode/extensions.json` and compare against the extensions
actually installed.

Report every recommended extension that is missing.

## 2. Check the settings

Verify `.vscode/settings.json` parses as JSONC and that every
`editor.defaultFormatter` it sets points at an installed extension.

## 3. Report before fixing

List the findings first. Install or fix only what the user confirms.
