<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# pnpm installieren

pnpm ist der Paketmanager der TypeScript-Repos. Sicherstellen, dass Node
installiert ist, auf dem [Mac](./install-node-mac-guide.md) oder unter
[Windows](./install-node-win-guide.md).

## Installieren <a id="install"></a>

Folgenden Befehl im Terminal ausführen (unter Windows in `Cmd` oder
PowerShell):

```bash
npm install --global pnpm@latest
```

pnpm wechselt selbstständig auf die Version, die ein Repo im Feld
`packageManager` seiner `package.json` angibt. Eine globale Installation
deckt daher alle Repos ab.

## Corepack abschalten <a id="turn-off-corepack"></a>

Falls pnpm zuvor über corepack aktiviert wurde, dies abschalten, damit die
globale Installation verwendet wird:

```bash
corepack disable pnpm
```

## Installation prüfen <a id="verify-installation"></a>

```bash
pnpm --version
```

Der Befehl gibt die installierte Version aus.

## pnpm aktuell halten <a id="keep-pnpm-up-to-date"></a>

```bash
pnpm self-update
```
