<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# احراز هویت در فید npm آژور

این کار را پیش از نخستین `pnpm install` انجام دهید و هر بار که توکن منقضی
شد، دوباره تکرار کنید.

## ساخت توکن دسترسی شخصی (personal access token) <a id="create-a-personal-access-token"></a>

<https://dev.azure.com/<your-azure-devops-organization>/_usersSettings/tokens> را باز کنید

روی `New Token` کلیک کنید

نامی وارد کنید که دستگاه شما را مشخص کند، مثلاً `Dell XPS`

دامنه‌های (scopes) لازم را علامت بزنید:

- `Work Items`: `Read`
- `Code`: `Read, write`
- `Build`: `Read`
- `Release`: `Read`
- `Test Management`: `Read`
- `Packaging`: `Read, write`

روی `Create` کلیک کنید

توکن را کپی کنید. فقط یک بار نمایش داده می‌شود.

## رمزگذاری توکن <a id="encode-the-token"></a>

اجرا کنید:

```bash
node -e "require('readline').createInterface({input:process.stdin,output:process.stdout,historySize:0}).question('PAT> ',p => { b64=Buffer.from(p.trim()).toString('base64');console.log(b64);process.exit(); })"
```

توکن را جای‌گذاری کنید و `Enter` را بزنید

توکن رمزگذاری‌شده را کپی کنید. خواندن توکن از یک اعلان (prompt) باعث
می‌شود در تاریخچهٔ shell ثبت نشود.

## نوشتن توکن در .npmrc <a id="write-the-token-into-your-npmrc"></a>

فایل را باز کنید:

```bash
code ~/.npmrc
```

بلوک موجود برای همین فید را با بلوک زیر جایگزین کنید و توکن رمزگذاری‌شده
را به جای `[BASE64_ENCODED_PERSONAL_ACCESS_TOKEN]` قرار دهید:

```npmrc
; begin auth token
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/registry/:username=<your-azure-devops-organization>
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/registry/:_password=[BASE64_ENCODED_PERSONAL_ACCESS_TOKEN]
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/registry/:email=npm requires email to be set but doesn't use the value
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/:username=<your-azure-devops-organization>
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/:_password=[BASE64_ENCODED_PERSONAL_ACCESS_TOKEN]
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/:email=npm requires email to be set but doesn't use the value
; end auth token
```

فایل را ذخیره کنید.

توکن را فقط در `~/.npmrc` نگه دارید. هرگز آن را در یک مخزن commit نکنید.
