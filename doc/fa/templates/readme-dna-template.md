<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# <dna_name>

[English](README.md) | فارسی

<!-- اختیاری، فقط وقتی مخزن این workflow را دارد. -->

[![CI](https://github.com/ggsuite/<dna_name>/actions/workflows/quick_check.yaml/badge.svg)](https://github.com/ggsuite/<dna_name>/actions/workflows/quick_check.yaml)

<یک جمله: مخزن با افزودن این لایه چه به دست می‌آورد. همان متن `description`
در `pubspec.yaml` یا `package.json`.>

## انگیزه <a id="motivation"></a>

<چرا این لایه وجود دارد: کدام مشکل مخزن‌های مصرف‌کننده را حل می‌کند.>

## استفاده <a id="usage"></a>

آن را به عنوان dev-dependency تعریف کنید و یک بار مقداردهی اولیه کنید:

```bash
pnpm add -D @<scope>/<npm-name>   # TypeScript projects
dart pub add dev:<dna_name>       # Dart projects
helix init
```

`helix init` تستی قرار می‌دهد که DNA را در هر اجرای تست نمونه‌سازی و بررسی
می‌کند. این کار <کدام فایل‌ها کجا قرار می‌گیرند، مثلاً راهنماها در
`doc/en/guides/`> را کپی می‌کند.

<چگونه از آنچه لایه عرضه می‌کند استفاده شود: فرمان یک skill یا یک اسکریپت،
و آنچه چاپ می‌کند.>

## راهنماها <a id="guides"></a>

- `dna/doc/en/guides/<topic>-guide.md` — <به خواننده می‌گوید چه کند>

## قالب‌ها <a id="templates"></a>

- `dna/doc/en/templates/<topic>-template.md` — <قالبی برای چه چیزی است>

## Skillها <a id="skills"></a>

- `/<command>` — <چه چیزی را بررسی یا تولید می‌کند، و از کدام راهنما پیروی
  می‌کند>

## اسکریپت‌ها <a id="scripts"></a>

- `dna/scripts/<name>.js` — <چه می‌کند، و کدام راهنما آن را فراخوانی می‌کند>

## پیکربندی <a id="configuration"></a>

- `dna/dot-github/workflows/<name>.yaml` — <کدام pipeline را تعریف می‌کند>
- `dna/dot-vscode/<name>.json` — <کدام تنظیم ویرایشگر را اضافه می‌کند>

## دامنه <a id="scope"></a>

<آنچه این لایه عمداً به لایه‌های دیگر واگذار می‌کند.>

## لایه‌ها <a id="layers"></a>

<این لایه بر کدام والدها بنا شده و هر کدام چه سهمی دارد — یا اینکه مستقل
(orthogonal) است و فقط موضوع خودش را دارد.>

<کدام بخش از یک والد را گسترش می‌دهد، و زیر کدام تگ.>

## متغیرها <a id="variables"></a>

- `dnaXxx` — <چه معنایی دارد، و آیا مخزن مصرف‌کننده باید آن را تنظیم کند>

## توسعه <a id="development"></a>

پوشهٔ `dna/` کد منبعی است که با دست نوشته می‌شود و هرگز تولید نمی‌شود. مخزن
DNA خودش را نمونه‌سازی می‌کند — پس از تغییرات `dart test` را اجرا کنید؛
ابتدا commit کنید، چون فایلی که DNA بازنویسی می‌کند نباید کار commit‌نشده
داشته باشد.

فایل‌های زیر `dna/` را ویرایش کنید، هرگز کپی‌های بیرون از آن را: تست آن‌ها
را بازنویسی می‌کند.

## مجوز <a id="license"></a>

<شناسهٔ SPDX، مثلاً MIT> — نگاه کنید به [LICENSE](LICENSE).
