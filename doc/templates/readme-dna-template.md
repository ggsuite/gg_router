<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# <dna_name>

English | [Deutsch](README.de.md)

<!-- Optional, only when the repo has the workflow. -->

[![CI](https://github.com/ggsuite/<dna_name>/actions/workflows/quick_check.yaml/badge.svg)](https://github.com/ggsuite/<dna_name>/actions/workflows/quick_check.yaml)

<One sentence: what a repo gets by adding this layer. The same text as the
`description` in `pubspec.yaml` or `package.json`.>

## Motivation

<Why this layer exists: which problem in the consuming repos it solves.>

## Usage

Declare it as a dev-dependency and initialize once:

```bash
pnpm add -D @<scope>/<npm-name>   # TypeScript projects
dart pub add dev:<dna_name>       # Dart projects
helix init
```

`helix init` places a test that instantiates and verifies the DNA on every
test run. It copies <which files land where, e.g. the guides to `doc/`>.

<How to use what the layer ships: the command of a skill or a script, and
what it prints.>

## Guides

- `dna/doc/guides/<topic>-guide.md` — <what it tells the reader to do>

## Templates

- `dna/doc/templates/<topic>-template.md` — <what it is a template for>

## Skills

- `/<command>` — <what it checks or produces, and which guide it follows>

## Scripts

- `dna/scripts/<name>.js` — <what it does, and which guide calls it>

## Configuration

- `dna/dot-github/workflows/<name>.yaml` — <which pipeline it defines>
- `dna/dot-vscode/<name>.json` — <which editor setting it contributes>

## Scope

<What this layer deliberately leaves to other layers.>

## Layers

<Which parents this layer builds on and what each contributes — or that
it is orthogonal and carries only its own topic.>

<Which section of a parent it extends, and under which tag.>

## Variables

- `dnaXxx` — <what it means, and whether a consuming repo must set it>

## Development

The `dna/` folder is hand-authored source and is never generated. The repo
instantiates its own DNA — run `dart test` after changes; commit first, a
file the DNA would overwrite must not carry uncommitted work.

Edit the files below `dna/`, never their copies outside it: the test
overwrites them.

## License

<SPDX identifier, e.g. MIT> — see [LICENSE](LICENSE).
