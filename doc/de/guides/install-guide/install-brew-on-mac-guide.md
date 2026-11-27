<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Brew auf dem Mac installieren

[Homebrew](https://brew.sh) ist der Paketmanager, mit dem auf dem Mac die
meisten anderen Werkzeuge installiert werden, z. B.
[Node](./install-node-mac-guide.md) und [Flutter](./install-flutter-guide.md).

## Xcode-Kommandozeilenwerkzeuge installieren <a id="install-xcode-command-line-tools"></a>

Homebrew braucht die Apple-Kommandozeilenwerkzeuge:

```bash
xcode-select --install
```

## Homebrew installieren <a id="install-homebrew"></a>

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Brew zur Shell-Konfiguration hinzufügen <a id="add-brew-to-your-shell-configuration"></a>

Auf Apple Silicon wird Homebrew nach `/opt/homebrew` installiert und ist
noch nicht im `PATH`:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

Auf Intel-Macs wird Homebrew nach `/usr/local` installiert und ist sofort
verfügbar.

## Installation prüfen <a id="verify-installation"></a>

```bash
brew --version
```

## Einrichtung prüfen <a id="check-the-setup"></a>

```bash
brew doctor
```

`Your system is ready to brew.` bedeutet, dass alles in Ordnung ist.
Warnungen zu nicht zugehörigen Paketen können ignoriert werden.

## Brew aktuell halten <a id="keep-brew-up-to-date"></a>

```bash
brew update
brew upgrade
```
