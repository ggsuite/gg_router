<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# راهنمای کد — Dart

آنچه [راهنمای کد](./code-guide.md) در یک بستهٔ Dart یا Flutter معنا
می‌دهد. ابتدا آن را بخوان؛ این راهنما فقط جزئیات را تکمیل می‌کند.

## چیدمان بسته <a id="lay-out-the-package"></a>

- `lib/<package>.dart` را یک فایل barrel کن: سرآیند مجوز، `library;`،
  سپس فقط خطوط `export 'src/…';`
- پیاده‌سازی را در `lib/src/<file>.dart` بگذار
- فایل‌ها را به سبک snake_case و به نام نوع اصلی‌ای که در خود دارند نام‌گذاری کن
- `lib/src/` را یک‌به‌یک در `test/` آینه کن

## ترتیب importها <a id="order-the-imports"></a>

- ابتدا `dart:`، سپس `package:`، سپس importهای نسبی را بنویس
- درون بسته importهای نسبی را ترجیح بده

## شکل‌دهی API <a id="shape-the-api"></a>

- پارامترهای نام‌دار را `required` علامت بزن، مگر مقدار پیش‌فرض داشته باشند
- برای راه جایگزینِ ساختن شیء از سازندهٔ factory استفاده کن
- از کد ناهمگام `Future<T>` برگردان و خطاها را با
  `try` / `catch` / `rethrow` مدیریت کن
- هر future را await کن یا با `unawaited(…)` علامت بزن

## برای هر کلاس یک مثال بده <a id="give-every-class-an-example"></a>

یک `factory X.example({…})` با پارامترهای صرفاً اختیاری ارائه کن که برای
هرکدام به یک مقدار کارا برمی‌گردد:

```dart
/// Creates an example user for tests and docs.
factory User.example({String? name, int? age}) =>
    User(name: name ?? 'Jane Doe', age: age ?? 42);
```

## کامنت‌های نشانه (landmark) <a id="comment-landmarks"></a>

- `// #####…` پیش از یک کلاس، enum یا هر ساختار سطح بالای دیگر
- `// ....…` پیش از هر متد، getter یا بلوک فیلدِ مستندشده

## مستندسازی با `///` <a id="document-with-"></a>

- هر عضو عمومی یک کامنت `///` دارد
- پارامترها را به شکل `- [name] <description>` مستند کن
- فقط وقتی فراخوانی بدیهی نیست، یک مثال `dart` در بلوک کد اضافه کن

## lintها را سخت‌گیرانه نگه دار <a id="keep-the-lints-strict"></a>

- `package:lints/recommended.yaml` را include کن
- `public_member_api_docs`، `prefer_single_quotes`،
  `require_trailing_commas`، `always_declare_return_types`،
  `unawaited_futures` و خانوادهٔ `prefer_const_*` را فعال کن
- `strict-casts`، `strict-inference` و `strict-raw-types` را فعال کن
- `lines_longer_than_80_chars` را فقط در بسته‌های Flutter غیرفعال کن، و تنها
  وقتی سد راه است

## نام‌گذاری یکدست <a id="name-things-consistently"></a>

| ساختار     | سبک                    | مثال                        |
| ---------- | ---------------------- | --------------------------- |
| کلاس       | PascalCase             | `RouterDelegate`            |
| فایل       | snake_case             | `router_delegate.dart`      |
| فایل تست   | `<filename>_test.dart` | `router_delegate_test.dart` |
| عضو خصوصی  | `_camelCase`           | `_updateState`              |
| ثابت       | `lowerCamelCase`       | `carriageReturn`            |
| مقدار enum | `lowerCamelCase`       | `Status.success`            |

## از این‌ها پرهیز کن <a id="avoid-these"></a>

- نوع بازگشتی `dynamic`
- گیومهٔ دوتایی (double quotes)
- futureهای await‌نشده بدون `unawaited(…)`
