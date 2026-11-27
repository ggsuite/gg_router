<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Node unter Windows installieren

- [Node deinstallieren](#uninstall-node)
  - [Cache leeren](#clean-cache)
  - [Deinstallationsprogramm ausführen](#run-uninstaller)
  - [Verbliebene Node-Ordner entfernen](#remove-remaining-node-folders)
  - [Node-Pfad aus der PATH-Variablen entfernen](#remove-node-path-from-path-variable)
- [NVM installieren](#install-nvm)
- [Node über NVM installieren](#install-node-via-nvm)

## Node deinstallieren <a id="uninstall-node"></a>

Wir verwenden `nvm`, um Node-Versionen zu installieren und auszuwählen.
Ist `nvm` bereits installiert, diesen und den nächsten Schritt überspringen.

### Cache leeren <a id="clean-cache"></a>

[Microsoft](https://learn.microsoft.com/en-us/windows/dev-environment/javascript/nodejs-on-windows#install-nvm-windows-nodejs-and-npm)

```bash
npm cache clean --force
```

### Deinstallationsprogramm ausführen <a id="run-uninstaller"></a>

`Windows` drücken

`uninstall Node.js` eingeben

Auf `Uninstall Node.js` klicken

Den Anweisungen folgen

### Verbliebene Node-Ordner entfernen <a id="remove-remaining-node-folders"></a>

[Verbliebene Node-Ordner entfernen](https://stackoverflow.com/questions/20711240/how-to-completely-remove-node-js-from-windows)

### Node-Pfad aus der PATH-Variablen entfernen <a id="remove-node-path-from-path-variable"></a>

Node aus der PATH-Variablen entfernen:

`Windows` drücken

`environment` eingeben

Auf `Edit the system environment variables` klicken

Auf `Environment Variables` klicken

Im `upper box` den Eintrag `PATH` auswählen

Auf `Edit` klicken

Nach dem Node-Pfad suchen

Falls vorhanden, den Eintrag entfernen

Den Dialog schließen

## NVM installieren <a id="install-nvm"></a>

[Quelle](https://github.com/coreybutler/nvm-windows#installation--upgrades)

<https://github.com/coreybutler/nvm-windows/releases> öffnen

`nvm-setup.exe` herunterladen

`nvm-setup.exe` ausführen

Den Anweisungen folgen

## Node über NVM installieren <a id="install-node-via-nvm"></a>

`Windows` drücken

`cmd` eingeben und `Enter` drücken

```bash
nvm install lts
nvm use lts
```
