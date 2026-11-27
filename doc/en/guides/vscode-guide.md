<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# VS Code Guide

The shared editor settings and recommended extensions every repo opens
with.

## What is configured

- Format on save through Prettier, pinned to the workspace config so it
  never falls back to bundled defaults
- 80 character rulers, no trailing whitespace, a final newline
- Coverage gutters and the testing panel
- A license header template for every language this family writes,
  using `ggsuite` and `ggsuite`
- `dna/_dna.json` is associated with `jsonc`, so its comments do not show
  as errors

## Add a setting

- Put it in `dna/dot-vscode/settings.json`, under the section comment it
  belongs to — add a new `// ####… \n// Name \n// ####…` section if none
  fits
- State why in a comment when the setting is not self-explanatory

## Add a recommended extension

- Add its id to `dna/dot-vscode/extensions.json`
- Give it a matching setting in `settings.json` if it needs one, e.g. a
  `[language]`-scoped `editor.defaultFormatter`

## Override in a consuming repo

- A same-path `dna/dot-vscode/settings.json` in a later layer replaces
  this one whole
- A `dna/dot-vscode/settings.overrides.json` merges instead: objects
  deep-merge, `"key!"` replaces without merging, `"key+"` appends to an
  array — see the helix README for the full syntax
