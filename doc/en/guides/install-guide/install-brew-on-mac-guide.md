<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Install Brew on Mac

[Homebrew](https://brew.sh) is the package manager used to install most of the
other tools on Mac, e.g. [Node](./install-node-mac-guide.md) and
[Flutter](./install-flutter-guide.md).

## Install Xcode command line tools

Homebrew needs the Apple command line tools:

```bash
xcode-select --install
```

## Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Add brew to your shell configuration

On Apple Silicon, Homebrew is installed to `/opt/homebrew` and is not in your
`PATH` yet:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

On Intel Macs, Homebrew is installed to `/usr/local` and is available right
away.

## Verify installation

```bash
brew --version
```

## Check the setup

```bash
brew doctor
```

`Your system is ready to brew.` means everything is fine. Warnings about
unrelated packages can be ignored.

## Keep brew up to date

```bash
brew update
brew upgrade
```
