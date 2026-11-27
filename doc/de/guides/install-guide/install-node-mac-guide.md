<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Node auf dem Mac installieren

Sicherstellen, dass [brew installiert ist](./install-brew-on-mac-guide.md)

## nvm mit Homebrew installieren <a id="install-nvm-with-homebrew"></a>

```bash
brew install nvm
```

## nvm-Verzeichnis anlegen (falls nicht automatisch angelegt) <a id="create-nvm-directory-if-not-created-automatically"></a>

```bash
mkdir ~/.nvm
```

## nvm zur Shell-Konfiguration hinzufügen <a id="add-nvm-to-your-shell-configuration"></a>

Folgende Zeilen zur `~/.zshrc` hinzufügen:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion"
```

## Änderungen übernehmen <a id="apply-changes"></a>

```bash
source ~/.zshrc
```

## Installation prüfen <a id="verify-installation"></a>

```bash
command -v nvm
```

## Node installieren <a id="install-node"></a>

```bash
nvm install lts
nvm use lts
```
