<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# نصب GitHub CLI

GitHub CLI (`gh`) را اسکریپت‌های گردش کار (workflow) ما برای ساختن، ادغام
(merge) و پیگیری pull requestها به کار می‌برند.

## نصب روی Mac <a id="install-on-mac"></a>

مطمئن شوید که [brew نصب شده است](./install-brew-on-mac-guide.md)

```bash
brew install gh
```

## نصب روی Windows <a id="install-on-windows"></a>

به <https://cli.github.com> بروید

نصب‌کننده را دانلود و اجرا کنید.

یا آن را با winget نصب کنید:

```bash
winget install --id GitHub.cli
```

## نصب روی Linux / WSL <a id="install-on-linux--wsl"></a>

```bash
sudo apt install gh
```

## بررسی نصب <a id="verify-installation"></a>

اگر ترمینال هنگام نصب باز بود، آن را دوباره راه‌اندازی کنید، سپس اجرا کنید:

```bash
gh --version
```

پس از آن با `gh auth login` وارد شوید.
