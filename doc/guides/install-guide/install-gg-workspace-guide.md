<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Create a gg workspace

## Create a dev dir

```bash
mkdir -p ~/dev2
cd ~/dev2
```

## Init a gg workspace

```bash
gg do init workspace
```

This creates the `.ocean` folder and instantiates the latest `dna_gg` in
the workspace folder: the gg guides, the skills, the hooks that keep your
prompts in the project management repo and the managed block of
`CLAUDE.md`. It is the same as running `gg dna init`, `gg dna add dna_gg`
and `gg dna build` by hand. Every ticket gets a copy of the skills and
the hooks.

## Add your repositories

```bash
gg do add dnaOrgUrl
```
