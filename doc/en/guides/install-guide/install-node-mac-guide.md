<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Install Node on Mac

Make sure [brew is installed](./install-brew-on-mac-guide.md)

## Install nvm with Homebrew

```bash
brew install nvm
```

## Create nvm directory (if not created automatically)

```bash
mkdir ~/.nvm
```

## Add nvm to your shell configuration

Add the following lines to your `~/.zshrc`:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion"
```

## Apply changes

```bash
source ~/.zshrc
```

## Verify installation

```bash
command -v nvm
```

## Install node

```bash
nvm install lts
nvm use lts
```
