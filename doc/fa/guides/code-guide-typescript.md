<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# راهنمای کد — TypeScript

آنچه [راهنمای کد](./code-guide.md) در یک بستهٔ TypeScript معنا می‌دهد.
ابتدا آن را بخوان؛ این راهنما فقط جزئیات را تکمیل می‌کند.

## چیدمان بسته <a id="lay-out-the-package"></a>

- `src/index.ts` را فایل barrel کن: سرآیند مجوز، سپس فقط خطوط `export …`،
  بدون پیاده‌سازی
- پیاده‌سازی را در `src/<file>.ts` بگذار
- فایل‌ها را به سبک kebab-case و به نام نوع اصلی‌ای که در خود دارند نام‌گذاری کن
- `src/` را یک‌به‌یک در `test/` آینه کن، هر فایل به شکل `<name>.spec.ts`

## ترتیب importها <a id="order-the-imports"></a>

- ابتدا ماژول‌های داخلی Node، سپس وابستگی‌ها، سپس آنچه به همین مخزن تعلق دارد
- درون بسته importهای نسبی را ترجیح بده

## شکل‌دهی API <a id="shape-the-api"></a>

- به‌جای فهرست بلندی از پارامترهای موقعیتی، یک شیء options بگیر
- آنچه تغییر نمی‌کند را `readonly` علامت بزن، و برای شکلی که مصرف‌کننده
  پیاده‌سازی می‌کند `interface` را ترجیح بده
- از کد ناهمگام `Promise<T>` برگردان و خطاها را با
  `try` / `catch` / `throw` مدیریت کن
- هر promise را await کن یا به چیزی بسپار که این کار را می‌کند — promise
  رهاشده (floating) خطای rejection خود را گم می‌کند

## برای هر کلاس یک مثال بده <a id="give-every-class-an-example"></a>

یک `static example(…)` ارائه کن که یک شیء options ناقص می‌گیرد و برای هر
چیزی که جا افتاده یک مقدار کارا می‌گذارد:

```ts
/** Creates an example user for tests and docs. */
static example(options: Partial<UserOptions> = {}): User {
  return new User({ name: 'Jane Doe', age: 42, ...options });
}
```

## کامنت‌های نشانه (landmark) <a id="comment-landmarks"></a>

- `// #####…` پیش از یک کلاس، interface، type یا enum
- `// ....…` پیش از هر متد، getter یا بلوک فیلدِ مستندشده

## مستندسازی با TSDoc <a id="document-with-tsdoc"></a>

- هر عضو export‌شده یک کامنت `/** … */` همراه با توضیح دارد
- پارامترها را به شکل `@param name - <description>` مستند کن
- نوع‌ها در امضا (signature) آمده‌اند — آن‌ها را در کامنت تکرار نکن
- فقط وقتی فراخوانی بدیهی نیست، یک مثال اضافه کن

## lintها را سخت‌گیرانه نگه دار <a id="keep-the-lints-strict"></a>

- `eslint` را با `typescript-eslint` به‌همراه افزونه‌های `tsdoc` و `jsdoc`
  اجرا کن
- `tsdoc/syntax` و `jsdoc/require-description` را روی `error` نگه دار
- `strict` را در `tsconfig.json` فعال کن
- قالب‌بندی را به Prettier بسپار: گیومهٔ تکی، نقطه‌ویرگول، دو فاصله،
  ویرگول انتهایی (trailing comma)، ۸۰ ستون

## نام‌گذاری یکدست <a id="name-things-consistently"></a>

| ساختار                | سبک                  | مثال                   |
| --------------------- | -------------------- | ---------------------- |
| کلاس، interface، type | PascalCase           | `BlobStorage`          |
| فایل                  | kebab-case           | `blob-storage.ts`      |
| فایل تست              | `<filename>.spec.ts` | `blob-storage.spec.ts` |
| تابع، متغیر           | lowerCamelCase       | `readItem`             |
| ثابت                  | lowerCamelCase       | `carriageReturn`       |
| مقدار enum            | lowerCamelCase       | `Status.success`       |

## از این‌ها پرهیز کن <a id="avoid-these"></a>

- `any` جایی که یک نوع واقعی جور است — سراغ `unknown` برو و آن را محدود کن
- assertion غیرتهی (`!`) برای ساکت کردن کامپایلر
- `export default` — exportهای نام‌دار، barrel را صادق نگه می‌دارند
- گیومهٔ دوتایی (double quotes)
- promise رهاشده (floating)
