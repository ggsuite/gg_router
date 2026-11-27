<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Install Flutter

Flutter ships with the Dart SDK. Installing Flutter therefore also gives you
`dart`, which is needed to install [gg](./install-gg-guide.md).

## Install on Mac

Make sure [brew is installed](./install-brew-on-mac-guide.md)

```bash
brew install --cask flutter
```

## Install on Windows

Download the installation bundle from
<https://docs.flutter.dev/get-started/install/windows>

Unzip it to a folder without spaces, e.g. `C:\src\flutter`

Add `C:\src\flutter\bin` to your `Path` environment variable:

Press `Windows`, type `environment variables`, open
`Edit the system environment variables`, click `Environment Variables`,
select `Path`, click `Edit` and add the folder.

Restart your terminal.

## Install on Linux / WSL

On Windows, make sure WSL and Ubuntu are installed

```bash
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
```

Add Flutter to your shell configuration:

```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Verify installation

```bash
flutter --version
dart --version
```

## Check the setup

```bash
flutter doctor
```

Follow the instructions printed by `flutter doctor` until all entries you need
are marked with a checkmark. Entries for platforms you do not develop for
(e.g. Android Studio or Xcode) can be ignored.
