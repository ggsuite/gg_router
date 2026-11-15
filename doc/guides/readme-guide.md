<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# README Guide

Follow this guide for the README of a package or an app. A DNA repo — a
layer other repos list in their `dna/_dna.json` — follows the
[README DNA Guide](./readme-dna-guide.md) for its sections; the rules on
style, languages and checks below apply to it as well.

## Copy the template

- Copy `doc/templates/readme-template.md` to `README.md`, or revise an
  existing README against it
- Keep the order of the sections, drop the optional ones the repo has
  nothing for
- Replace every `<placeholder>`

## Open with what it does

- Put the name, the badges and one or two sentences on the first screen —
  a reader decides there whether the package fits
- Use the `description` of `pubspec.yaml` or `package.json` as that
  sentence, so GitHub, pub.dev and npm say the same
- Name hard limits early, e.g. the supported platforms

## Say why it exists

- Write the motivation: the problem or friction that led to the repo, and
  what it aims for
- Write it for a newcomer — the why is what READMEs leave out most often
- Take it from the repo, its docs and its history; ask the user when they
  do not tell, never invent it

## Show it working

- Give one copyable install command per ecosystem
- Show the most important feature as a snippet that runs unchanged — no
  pseudo code, no TODOs
- Keep the snippet the same code as `example/`; pub.dev shows that file
  in its Example tab
- Show what the snippet prints

## Say where it ends

- Name what the package deliberately does not do, and its sharp edges
- State how mature it is, e.g. that the API may change before 1.0

## Link instead of repeating

- Link the guides, the architecture docs and the blog; do not copy them
- Link only files that exist in the repo
- Write link texts that say where they lead, never "here"

## Keep badges few and true

- Use at most five: CI, registry version, pub points, coverage, license
- Point the CI badge at a workflow file in `.github/workflows/`
- Drop a badge whose status nobody watches

## Write plain Markdown

- Use sentence case for headings and the imperative for tasks, e.g.
  "Install the package"
- Tag every code block with its language
- Use `https` links only — pub.dev deducts points for `http`
- Add no table of contents, GitHub generates one

## Write it in two languages

- Keep `README.md` in English and `README.de.md` in German
- Put a language switcher below the title: `English | [Deutsch](README.de.md)`
  in `README.md`, `[English](README.md) | Deutsch` in `README.de.md`
- Keep both content- and structure-equal: the same sections in the same
  order, the headings and the prose translated
- Keep the code blocks identical, their comments included
- Write the README in the language of the prompt first, then translate it
- Follow `doc/guides/translate-guide.md` when the repo has one
- pub.dev and npm show `README.md` only

## Check it

- Run `node scripts/check-readme.js`; it reports a title that is not the
  package name, missing or misplaced sections, leftover placeholders,
  broken links and badges, too many badges, untagged code blocks, a
  sentence that differs from the `description`, and a German README that
  drifted
- Update the README in the same change as the code it describes
