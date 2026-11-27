<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Scripts Guide

The node scripts a repo automates its workflow with, and the functions they
share — from reading local git state to calling the GitHub API.

## Use a function instead of repeating a command

- Import from `dna/scripts/functions/`, never duplicate a `git`, `gh` or
  file system call across scripts
- Keep a function pure where possible: same input, same output, no
  printing

## Add a script

- Put it in `dna/scripts/`, its shared parts in `dna/scripts/functions/`
- Give it the license header every file here carries
- Call it from a guide of the layer that needs it
