<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# نصب Brew روی Mac

[Homebrew](https://brew.sh) مدیر بسته‌ای است که بیشتر ابزارهای دیگر روی Mac
با آن نصب می‌شوند، مثلاً [Node](./install-node-mac-guide.md) و
[Flutter](./install-flutter-guide.md).

## نصب ابزارهای خط فرمان Xcode <a id="install-xcode-command-line-tools"></a>

Homebrew به ابزارهای خط فرمان Apple نیاز دارد:

```bash
xcode-select --install
```

## نصب Homebrew <a id="install-homebrew"></a>

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## افزودن brew به پیکربندی shell <a id="add-brew-to-your-shell-configuration"></a>

روی Apple Silicon، Homebrew در `/opt/homebrew` نصب می‌شود و هنوز در `PATH`
نیست:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

روی Macهای Intel، Homebrew در `/usr/local` نصب می‌شود و بلافاصله در دسترس
است.

## بررسی نصب <a id="verify-installation"></a>

```bash
brew --version
```

## بررسی پیکربندی <a id="check-the-setup"></a>

```bash
brew doctor
```

`Your system is ready to brew.` یعنی همه‌چیز درست است. هشدارهای مربوط به
بسته‌های نامرتبط را می‌توان نادیده گرفت.

## به‌روز نگه داشتن brew <a id="keep-brew-up-to-date"></a>

```bash
brew update
brew upgrade
```
