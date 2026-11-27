<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# راهنمای تست — TypeScript

آنچه [راهنمای تست](./test-guide.md) در یک بستهٔ TypeScript معنا می‌دهد.
ابتدا آن را بخوان؛ این راهنما فقط جزئیات را تکمیل می‌کند.

## درخت سورس را آینه کن <a id="mirror-the-source-tree"></a>

- `src/foo.ts` به `test/foo.spec.ts` می‌رود
- `src/sub/bar.ts` به `test/sub/bar.spec.ts` می‌رود
- فایل را با سرآیند مجوز (license header) شروع کن

## از طریق API عمومی import کن <a id="import-through-the-public-api"></a>

- `describe`، `it` و `expect` را از `vitest` import کن
- بستهٔ خودت را از طریق `src/index.ts` import کن
- فقط وقتی مستقیم به `src/…` دست ببر که تابع کمکی‌ای را تست می‌کنی که
  عمداً export نشده است

## با describe و it تودرتو کن <a id="nest-with-describe-and-it"></a>

- `describe(…)` بر اساس عضو تحت تست، `it(…)` برای هر حالت
- `it` را طوری بنویس که نام و توضیح با هم یک جمله خوانده شوند

## با closureها آماده‌سازی کن <a id="set-up-with-closures"></a>

- وضعیت مشترک را در `beforeEach` بازنشانی کن
- منابع بیرونی را در `afterEach` آزاد کن
- آماده‌سازی قابل‌استفادهٔ مجدد را در یک closure محلی درون فایل spec بگذار

## از مثال شروع کن <a id="start-from-the-example"></a>

- `const user = User.example({ age: 17 });`

## نوع‌های واقعی را بر mockها ترجیح بده <a id="prefer-real-types-over-mocks"></a>

- جایی که یک کلاس به mock نیاز دارد، یک تابع پاس بده
- فقط وقتی سراغ `vi.mock` برو که هیچ راه دیگری جواب ندهد، و با
  `vi.restoreAllMocks` بازگردانی کن

## روی ساختار assert کن <a id="assert-on-structure"></a>

- اشیای کامل را با `toEqual` مقایسه کن، نه فیلد به فیلد
- خطاها را با `await expect(fn()).rejects.toThrow(…)` بررسی کن — promise
  ردشده‌ای که کسی منتظرش نمی‌ماند، بی‌صدا قبول می‌شود
- هرگز در تست `console.log` نکن

## به پوشش ۱۰۰ درصد برس <a id="reach-100-percent-coverage"></a>

- `vitest run --coverage` را اجرا کن
- خطی را که واقعاً دسترس‌ناپذیر است با `/* v8 ignore next */` علامت بزن،
  و یک بلوک را با `/* v8 ignore start */` و `/* v8 ignore stop */`

## پیش از commit اعتبارسنجی کن <a id="validate-before-you-commit"></a>

```bash
pnpm test
```

`vitest`، `eslint` و بررسی Prettier همگی باید بدون خطا باشند.
