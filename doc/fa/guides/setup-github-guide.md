# راهنمای راه‌اندازی GitHub

این راهنما یک مخزن GitHub را با pull requestهای فقط squash، یک شاخه‌ی
پیش‌فرض محافظت‌شده و یک بررسی سریع (quick check) الزامی راه‌اندازی می‌کند.

## ۱. افزودن dna_github <a id="1-add-dna_github"></a>

```bash
gg dna add dna_github
gg dna build
```

این کار `scripts/setup-github-repo.js` و `.github/workflows/quick_check.yaml`
را به مخزن شما اضافه می‌کند.

## ۲. ادغام تغییرات در main <a id="2-merge-the-changes-into-main"></a>

تغییرات را commit کنید، یک pull request باز کنید و آن را در `main` ادغام
(merge) کنید. workflow بررسی سریع باید پیش از آنکه قواعد شاخه بتوانند آن را
الزامی کنند، روی `main` وجود داشته باشد.

## ۳. پیش‌نمایش تنظیمات <a id="3-preview-the-settings"></a>

```bash
node scripts/setup-github-repo.js
```

مخزن و تنظیماتی را که اعمال خواهند شد چاپ می‌کند، بدون اینکه چیزی را تغییر
دهد.

به [GitHub CLI](https://cli.github.com) (`gh auth login`) نیاز دارد.

## ۴. اعمال تنظیمات <a id="4-apply-the-settings"></a>

```bash
node scripts/setup-github-repo.js --apply
```

این فرمان:

- فقط ادغام‌های squash را مجاز می‌کند، ادغام خودکار (auto merge) را فعال
  می‌کند و شاخه‌ها را پس از ادغام حذف می‌کند
- مجموعه‌قواعد (ruleset) `Default` را روی شاخه‌ی پیش‌فرض می‌سازد یا به‌روز
  می‌کند: بدون حذف، بدون force push، تاریخچه‌ی خطی، pull request الزامی و
  بررسی سریع باید موفق شود

`--require-review` را اضافه کنید تا یک بازبینیِ تأییدکننده و حل‌شدنِ
رشته‌های بازبینی نیز الزامی شوند.
