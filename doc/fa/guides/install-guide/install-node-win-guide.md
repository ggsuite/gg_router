<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# نصب Node روی Windows

- [حذف Node](#uninstall-node)
  - [پاک کردن کش](#clean-cache)
  - [اجرای حذف‌کننده](#run-uninstaller)
  - [حذف پوشه‌های باقی‌ماندهٔ Node](#remove-remaining-node-folders)
  - [حذف مسیر node از متغیر PATH](#remove-node-path-from-path-variable)
- [نصب NVM](#install-nvm)
- [نصب Node با NVM](#install-node-via-nvm)

## حذف Node <a id="uninstall-node"></a>

ما از `nvm` برای نصب و انتخاب نسخه‌های Node استفاده می‌کنیم.
اگر `nvm` را قبلاً نصب کرده‌اید، می‌توانید از این مرحله و مرحلهٔ بعد بگذرید.

### پاک کردن کش <a id="clean-cache"></a>

[Microsoft](https://learn.microsoft.com/en-us/windows/dev-environment/javascript/nodejs-on-windows#install-nvm-windows-nodejs-and-npm)

```bash
npm cache clean --force
```

### اجرای حذف‌کننده <a id="run-uninstaller"></a>

`Windows` را بزنید

`uninstall Node.js` را تایپ کنید

روی `Uninstall Node.js` کلیک کنید

دستورها را دنبال کنید

### حذف پوشه‌های باقی‌ماندهٔ Node <a id="remove-remaining-node-folders"></a>

[حذف پوشه‌های باقی‌ماندهٔ Node](https://stackoverflow.com/questions/20711240/how-to-completely-remove-node-js-from-windows)

### حذف مسیر node از متغیر PATH <a id="remove-node-path-from-path-variable"></a>

Node را از متغیر PATH حذف کنید:

`Windows` را بزنید

`environment` را تایپ کنید

روی `Edit the system environment variables` کلیک کنید

روی `Environment Variables` کلیک کنید

در `upper box`، `PATH` را انتخاب کنید

روی `Edit` کلیک کنید

مسیر Node را جستجو کنید

اگر وجود دارد، آن را حذف کنید

پنجره را ببندید

## نصب NVM <a id="install-nvm"></a>

[منبع](https://github.com/coreybutler/nvm-windows#installation--upgrades)

<https://github.com/coreybutler/nvm-windows/releases> را باز کنید

`nvm-setup.exe` را دانلود کنید

`nvm-setup.exe` را اجرا کنید

دستورها را دنبال کنید

## نصب Node با NVM <a id="install-node-via-nvm"></a>

`Windows` را بزنید

`cmd` را تایپ کنید و `Enter` را بزنید

```bash
nvm install lts
nvm use lts
```
