<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# GitHub CLI installieren

Die GitHub CLI (`gh`) wird von unseren Workflow-Skripten genutzt, um Pull
Requests zu erstellen, zu mergen und zu beobachten.

## Auf dem Mac installieren <a id="install-on-mac"></a>

Sicherstellen, dass [brew installiert ist](./install-brew-on-mac-guide.md)

```bash
brew install gh
```

## Unter Windows installieren <a id="install-on-windows"></a>

<https://cli.github.com> aufrufen

Den Installer herunterladen und ausführen.

Alternativ mit winget installieren:

```bash
winget install --id GitHub.cli
```

## Unter Linux / WSL installieren <a id="install-on-linux--wsl"></a>

```bash
sudo apt install gh
```

## Installation prüfen <a id="verify-installation"></a>

Das Terminal neu starten, falls es während der Installation geöffnet war,
dann ausführen:

```bash
gh --version
```

Danach mit `gh auth login` anmelden.
