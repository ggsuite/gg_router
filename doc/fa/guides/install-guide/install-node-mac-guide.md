<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# نصب Node روی Mac

مطمئن شوید که [brew نصب شده است](./install-brew-on-mac-guide.md)

## نصب nvm با Homebrew <a id="install-nvm-with-homebrew"></a>

```bash
brew install nvm
```

## ساخت پوشهٔ nvm (اگر خودکار ساخته نشده است) <a id="create-nvm-directory-if-not-created-automatically"></a>

```bash
mkdir ~/.nvm
```

## افزودن nvm به پیکربندی shell <a id="add-nvm-to-your-shell-configuration"></a>

خطوط زیر را به `~/.zshrc` اضافه کنید:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion"
```

## اعمال تغییرات <a id="apply-changes"></a>

```bash
source ~/.zshrc
```

## بررسی نصب <a id="verify-installation"></a>

```bash
command -v nvm
```

## نصب node <a id="install-node"></a>

```bash
nvm install lts
nvm use lts
```
