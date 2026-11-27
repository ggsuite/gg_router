<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# نصب pnpm

pnpm مدیر بستهٔ مخزن‌های TypeScript است. مطمئن شوید که Node نصب شده است،
روی [Mac](./install-node-mac-guide.md) یا روی
[Windows](./install-node-win-guide.md).

## نصب <a id="install"></a>

فرمان زیر را در ترمینال اجرا کنید (در Windows در `Cmd` یا PowerShell):

```bash
npm install --global pnpm@latest
```

pnpm خودش به نسخه‌ای که هر مخزن در فیلد `packageManager` فایل
`package.json` خود نام می‌برد تغییر می‌کند، پس یک نصب سراسری برای همهٔ
مخزن‌ها کافی است.

## خاموش کردن corepack <a id="turn-off-corepack"></a>

اگر قبلاً pnpm را از طریق corepack فعال کرده‌اید، آن را خاموش کنید تا نصب
سراسری اجرا شود:

```bash
corepack disable pnpm
```

## بررسی نصب <a id="verify-installation"></a>

```bash
pnpm --version
```

این فرمان نسخهٔ نصب‌شده را چاپ می‌کند.

## به‌روز نگه داشتن pnpm <a id="keep-pnpm-up-to-date"></a>

```bash
pnpm self-update
```
