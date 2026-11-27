<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# نصب Azure CLI

اگر مخزن‌ها (repositories) در Azure DevOps قرار دارند، Azure CLI را نصب
کنید. در غیر این صورت از این راهنما بگذرید.

## نصب خط فرمان <a id="install-the-command-line"></a>

در Windows اجرا کنید:

```bash
winget install --exact --id Microsoft.AzureCLI
```

در Mac مطمئن شوید که [brew نصب شده است](./install-brew-on-mac-guide.md) و
اجرا کنید:

```bash
brew install azure-cli
```

ترمینال و Vscode را دوباره راه‌اندازی کنید تا `az` پیدا شود.

نصب را بررسی کنید:

```bash
az --version
```

## افزودن افزونهٔ Azure DevOps <a id="add-the-azure-devops-extension"></a>

```bash
az extension add --name azure-devops
```

## ورود <a id="log-in"></a>

```bash
az login
```

هنگام پرسش
`Select a subscription and tenant (Type a number or Enter for no changes)`
کلید `Enter` را بزنید.

خطایی گرفتید که اشتراکی (subscription) ندارید؟ با tenant خود وارد شوید:

```bash
az login --tenant [TENANT ID] --allow-no-subscription
```

خطا tenantهای شما را فهرست می‌کند — ترکیب طولانی عدد و حرف را بردارید، نه
نام کوتاه را. پیدا نمی‌کنید؟ این را دنبال کنید:
<https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id>

## تنظیم سازمان و پروژهٔ پیش‌فرض <a id="set-the-default-organization-and-project"></a>

```bash
az devops configure --defaults organization=https://dev.azure.com/<your-azure-devops-organization> project=<your-azure-devops-project>
```

همهٔ فرمان‌های بعدی `az devops` از این پیش‌فرض‌ها استفاده می‌کنند.

## دریافت دسترسی به فید بسته‌ها <a id="get-access-to-the-package-feed"></a>

بسته‌ها از یک فید Azure Artifacts می‌آیند، نه از رجیستری عمومی.
[راهنمای فید npm آژور](./install-azure-npm-feed-guide.md) را دنبال کنید.
