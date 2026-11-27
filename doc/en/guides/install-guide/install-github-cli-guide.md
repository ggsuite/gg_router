<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Install the GitHub CLI

The GitHub CLI (`gh`) is used by our workflow scripts to create, merge and
watch pull requests.

## Install on Mac

Make sure [brew is installed](./install-brew-on-mac-guide.md)

```bash
brew install gh
```

## Install on Windows

Visit <https://cli.github.com>

Download and run the installer.

Alternatively install it with winget:

```bash
winget install --id GitHub.cli
```

## Install on Linux / WSL

```bash
sudo apt install gh
```

## Verify installation

Restart your terminal when it was open during the installation, then run:

```bash
gh --version
```

Log in afterwards with `gh auth login`.
