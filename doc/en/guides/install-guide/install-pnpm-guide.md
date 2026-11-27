<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Install pnpm

pnpm is the package manager of the TypeScript repos. Make sure Node is
installed, on [Mac](./install-node-mac-guide.md) or on
[Windows](./install-node-win-guide.md).

## Install

Execute the following command in your terminal (on Windows in `Cmd` or
PowerShell):

```bash
npm install --global pnpm@latest
```

pnpm switches to the version a repo names in the `packageManager` field
of its `package.json` by itself, so one global install covers every
repo.

## Turn off corepack

If you enabled pnpm through corepack before, turn that off, so the
global install is the one that runs:

```bash
corepack disable pnpm
```

## Verify installation

```bash
pnpm --version
```

The command prints the installed version.

## Keep pnpm up to date

```bash
pnpm self-update
```
