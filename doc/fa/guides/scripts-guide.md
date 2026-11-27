<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# راهنمای اسکریپت‌ها

اسکریپت‌های node که یک مخزن گردش کار خود را با آن‌ها خودکار می‌کند، و
توابعی که میان آن‌ها مشترک است — از خواندن وضعیت محلی git تا فراخوانی
GitHub API.

## به جای تکرار یک فرمان از یک تابع استفاده کنید <a id="use-a-function-instead-of-repeating-a-command"></a>

- از `dna/scripts/functions/` وارد (import) کنید؛ هرگز یک فراخوانی `git`،
  `gh` یا سیستم فایل را در چند اسکریپت تکرار نکنید
- تا جای ممکن تابع را خالص (pure) نگه دارید: ورودی یکسان، خروجی یکسان،
  بدون چاپ کردن

## افزودن یک اسکریپت <a id="add-a-script"></a>

- آن را در `dna/scripts/` قرار دهید و بخش‌های مشترکش را در
  `dna/scripts/functions/`
- سرآیند مجوز (license header) را که همه‌ی فایل‌های این‌جا دارند به آن بدهید
- آن را از راهنمای لایه‌ای که به آن نیاز دارد فراخوانی کنید
