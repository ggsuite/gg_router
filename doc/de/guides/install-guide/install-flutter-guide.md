<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Flutter installieren

Flutter bringt das Dart-SDK mit. Mit Flutter ist daher auch `dart`
installiert, das für die Installation von [gg](./install-gg-guide.md)
nötig ist.

## Auf dem Mac installieren <a id="install-on-mac"></a>

Sicherstellen, dass [brew installiert ist](./install-brew-on-mac-guide.md)

```bash
brew install --cask flutter
```

## Unter Windows installieren <a id="install-on-windows"></a>

Das Installationspaket von
<https://docs.flutter.dev/get-started/install/windows> herunterladen

In einen Ordner ohne Leerzeichen entpacken, z. B. `C:\src\flutter`

`C:\src\flutter\bin` zur Umgebungsvariablen `Path` hinzufügen:

`Windows` drücken, `environment variables` eingeben,
`Edit the system environment variables` öffnen, auf `Environment Variables`
klicken, `Path` auswählen, auf `Edit` klicken und den Ordner hinzufügen.

Terminal neu starten.

## Unter Linux / WSL installieren <a id="install-on-linux--wsl"></a>

Unter Windows sicherstellen, dass WSL und Ubuntu installiert sind

```bash
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
```

Flutter zur Shell-Konfiguration hinzufügen:

```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Installation prüfen <a id="verify-installation"></a>

```bash
flutter --version
dart --version
```

## Einrichtung prüfen <a id="check-the-setup"></a>

```bash
flutter doctor
```

Den Anweisungen von `flutter doctor` folgen, bis alle benötigten Einträge
mit einem Häkchen markiert sind. Einträge für Plattformen, für die nicht
entwickelt wird (z. B. Android Studio oder Xcode), können ignoriert werden.
