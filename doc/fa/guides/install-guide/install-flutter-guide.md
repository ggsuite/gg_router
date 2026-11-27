<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# نصب Flutter

Flutter همراه با Dart SDK عرضه می‌شود. بنابراین با نصب Flutter، `dart` هم
نصب می‌شود که برای نصب [gg](./install-gg-guide.md) لازم است.

## نصب روی Mac <a id="install-on-mac"></a>

مطمئن شوید که [brew نصب شده است](./install-brew-on-mac-guide.md)

```bash
brew install --cask flutter
```

## نصب روی Windows <a id="install-on-windows"></a>

بستهٔ نصب را از
<https://docs.flutter.dev/get-started/install/windows> دانلود کنید

آن را در پوشه‌ای بدون فاصله از حالت فشرده خارج کنید، مثلاً `C:\src\flutter`

`C:\src\flutter\bin` را به متغیر محیطی `Path` اضافه کنید:

`Windows` را بزنید، `environment variables` را تایپ کنید،
`Edit the system environment variables` را باز کنید، روی
`Environment Variables` کلیک کنید، `Path` را انتخاب کنید، روی `Edit` کلیک
کنید و پوشه را اضافه کنید.

ترمینال را دوباره راه‌اندازی کنید.

## نصب روی Linux / WSL <a id="install-on-linux--wsl"></a>

در Windows مطمئن شوید که WSL و Ubuntu نصب شده‌اند

```bash
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
```

Flutter را به پیکربندی shell اضافه کنید:

```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## بررسی نصب <a id="verify-installation"></a>

```bash
flutter --version
dart --version
```

## بررسی پیکربندی <a id="check-the-setup"></a>

```bash
flutter doctor
```

دستورهایی را که `flutter doctor` چاپ می‌کند دنبال کنید تا همهٔ موارد لازم
با تیک علامت بخورند. موارد مربوط به پلتفرم‌هایی که برایشان توسعه
نمی‌دهید (مثلاً Android Studio یا Xcode) را می‌توان نادیده گرفت.
