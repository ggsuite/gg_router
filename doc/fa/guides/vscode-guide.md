<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# راهنمای VS Code

تنظیمات مشترک ویرایشگر و افزونه‌های پیشنهادی که هر مخزن با آن‌ها باز می‌شود.

## چه چیزی پیکربندی شده است <a id="what-is-configured"></a>

- قالب‌بندی هنگام ذخیره با Prettier، وابسته به پیکربندی فضای کاری
  (workspace) تا هرگز به پیش‌فرض‌های همراه برنگردد
- خط‌کش در ۸۰ نویسه، بدون فاصله‌ی انتهای خط، یک خط جدید پایانی
- Coverage Gutters و پنل آزمون (testing panel)
- یک قالب سرآیند مجوز (license header) برای هر زبانی که این خانواده
  می‌نویسد، با استفاده از `ggsuite` و `ggsuite`
- `dna/_dna.json` به `jsonc` مرتبط شده است تا توضیحات آن به صورت خطا نمایش
  داده نشوند

## افزودن یک تنظیم <a id="add-a-setting"></a>

- آن را در `dna/dot-vscode/settings.json` زیر توضیحِ بخشی که به آن تعلق دارد
  قرار دهید — اگر هیچ بخشی مناسب نیست، یک بخش جدید
  `// ####… \n// Name \n// ####…` اضافه کنید
- وقتی تنظیم خودبه‌خود روشن نیست، دلیلش را در یک توضیح بنویسید

## افزودن یک افزونه‌ی پیشنهادی <a id="add-a-recommended-extension"></a>

- شناسه‌ی آن را به `dna/dot-vscode/extensions.json` اضافه کنید
- اگر لازم است، تنظیم متناسبی در `settings.json` به آن بدهید، مثلاً یک
  `editor.defaultFormatter` محدود به `[language]`

## بازنویسی در مخزنِ مصرف‌کننده <a id="override-in-a-consuming-repo"></a>

- یک `dna/dot-vscode/settings.json` با همان مسیر در لایه‌ای بعدی، این فایل را
  به‌طور کامل جایگزین می‌کند
- یک `dna/dot-vscode/settings.overrides.json` به جای آن ادغام می‌کند: اشیا
  به‌صورت عمیق ادغام می‌شوند، `"key!"` بدون ادغام جایگزین می‌کند، `"key+"`
  به یک آرایه اضافه می‌کند — برای نحو کامل README مربوط به helix را ببینید
