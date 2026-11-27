<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# راهنمای تست — Dart

آنچه [راهنمای تست](./test-guide.md) در یک بستهٔ Dart یا Flutter معنا
می‌دهد. ابتدا آن را بخوان؛ این راهنما فقط جزئیات را تکمیل می‌کند.

## درخت سورس را آینه کن <a id="mirror-the-source-tree"></a>

- `lib/src/foo.dart` به `test/foo_test.dart` می‌رود
- `lib/src/sub/bar.dart` به `test/sub/bar_test.dart` می‌رود
- فایل را با سرآیند مجوز (license header) و یک `main()` در سطح بالا شروع کن

## از طریق API عمومی import کن <a id="import-through-the-public-api"></a>

- `package:test/test.dart` را import کن، یا در یک بستهٔ Flutter
  `package:flutter_test/flutter_test.dart` را
- بستهٔ خودت را از طریق فایل barrel آن import کن
- فقط وقتی به `package:<pkg>/src/…` دست ببر که تابع کمکی‌ای را تست می‌کنی که
  عمداً export نشده است

## با group و test تودرتو کن <a id="nest-with-group-and-test"></a>

- `group(…)` بر اساس عضو تحت تست، `test(…)` برای هر حالت

## با closureها آماده‌سازی کن <a id="set-up-with-closures"></a>

- وضعیت مشترک را در `setUp` بازنشانی کن
- منابع بیرونی را در `tearDown` آزاد کن
- آماده‌سازی قابل‌استفادهٔ مجدد را در یک closure محلی درون `main()` بگذار

## از مثال شروع کن <a id="start-from-the-example"></a>

- `final user = User.example(age: 17);`

## نوع‌های واقعی را بر mockها ترجیح بده <a id="prefer-real-types-over-mocks"></a>

- فقط وقتی سراغ `mockito` یا `mocktail` برو که هیچ راه دیگری جواب ندهد

## روی ساختار assert کن <a id="assert-on-structure"></a>

- فهرست‌های کامل را با `equals([…])` مقایسه کن
- استثناها را با `throwsA(isA<X>().having(…))` بررسی کن
- هرگز در تست `print` نکن

## به پوشش ۱۰۰ درصد برس <a id="reach-100-percent-coverage"></a>

- خطی را که واقعاً دسترس‌ناپذیر است با `// coverage:ignore-line` علامت بزن،
  و یک بلوک را با `// coverage:ignore-start` و `// coverage:ignore-end`

## پیش از commit اعتبارسنجی کن <a id="validate-before-you-commit"></a>

```bash
gg can commit
```

`dart analyze`، `dart format` و `dart test` همگی باید بدون خطا باشند.
