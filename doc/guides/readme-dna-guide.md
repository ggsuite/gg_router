<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# README DNA Guide

Follow this guide for the README of a DNA repo — a layer other repos list
in their `dna/_dna.json`. It is named `dna_*` or `dna-*`, or its
`dna/_dna.json` declares `mustOverride`. Its reader does not call an API:
they want to know what their repo gets by adding the layer.

From the [README Guide](./readme-guide.md) apply the first screen, the
motivation, linking, badges, Markdown, both languages and the check. The
example, the limitations and the status do not apply: the usage shows the
setup, the scope names the limits.

## Copy the template

- Copy `doc/templates/readme-dna-template.md` to `README.md`, or revise
  an existing README against it
- Drop every section this layer has nothing for

## Say what the layer does

- Open with one sentence: what a repo gets by adding this layer
- Use that sentence as the `description` in `pubspec.yaml` and
  `package.json`
- Name the topic it owns, not the machinery behind it
- Write the motivation: which problem in the consuming repos the layer
  solves

## Show how to use it

- Show the setup right after the motivation, a reader wants to try it
- Say where the files land in a consuming repo, e.g. `dna/doc/` in
  `doc/`, `dna/dot-claude/` in `.claude/`, `dna/scripts/` in `scripts/`
- Show how to use what it ships, e.g. the command of a skill or a script
  and what it prints
- Name hard requirements, e.g. Node.js for a script

## List what the layer ships

- Give guides, templates, skills, scripts and configuration their own
  section
- Name each file with its path below `dna/` and one line on its purpose;
  name a folder of helper files as a whole, e.g. `dna/scripts/functions/`
- Name a skill by the command a user types, e.g. `/translate`
- Say which guide calls a script

## Name its scope

- Name what it deliberately leaves to other layers or to the repo

## Name the layers it builds on

- List the parent layers from `dna/_dna.json`, each linked to its repo
- Say what each parent contributes, not just its name
- State that the layer is orthogonal when it has no parents; helix, the
  base of every layer, is no parent
- Name the sections it extends in a parent, and the tag it uses

## Document the variables

- List every variable of `dna/_vars.json`
- Give the meaning; name a value only where it explains why the variable
  exists
- Say which ones a consuming repo must set itself, the ones
  `mustOverride` in `dna/_dna.json` marks

## Keep it current

- Say in the development section that only `dna/` is edited, never its
  copies the test writes
- Update the README in the same change that adds or removes a DNA file
- Run `node scripts/check-readme.js`; in a DNA repo it also reports every
  `dna/` file, variable and parent layer the README does not mention
