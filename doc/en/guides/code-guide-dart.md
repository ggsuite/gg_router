<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Code Guide — Dart

What the [Code Guide](./code-guide.md) means in a Dart or Flutter
package. Read that one first; this only fills in the specifics.

## Lay out the package

- Make `lib/<package>.dart` a barrel file: license header, `library;`,
  then only `export 'src/…';` lines
- Put the implementation in `lib/src/<file>.dart`
- Name files in snake_case after the main type they hold
- Mirror `lib/src/` in `test/` one to one

## Order the imports

- Write `dart:` first, then `package:`, then relative imports
- Prefer relative imports inside the package

## Shape the API

- Mark named parameters `required` unless they have a default
- Use a factory constructor for an alternative way to create the object
- Return `Future<T>` from async code and handle errors with
  `try` / `catch` / `rethrow`
- Await every future or mark it with `unawaited(…)`

## Give every class an example

Offer a `factory X.example({…})` with only optional parameters, falling
back to a working value for each:

```dart
/// Creates an example user for tests and docs.
factory User.example({String? name, int? age}) =>
    User(name: name ?? 'Jane Doe', age: age ?? 42);
```

## Comment landmarks

- `// #####…` before a class, enum or other top level construct
- `// ....…` before every documented method, getter or field block

## Document with `///`

- Every public member carries a `///` comment
- Document parameters as `- [name] <description>`
- Add a `dart` fenced example only when the call is not obvious

## Keep the lints strict

- Include `package:lints/recommended.yaml`
- Turn on `public_member_api_docs`, `prefer_single_quotes`,
  `require_trailing_commas`, `always_declare_return_types`,
  `unawaited_futures` and the `prefer_const_*` family
- Turn on `strict-casts`, `strict-inference` and `strict-raw-types`
- Disable `lines_longer_than_80_chars` in Flutter packages only, and only
  when it is in the way

## Name things consistently

| Construct | Style | Example |
| --- | --- | --- |
| Class | PascalCase | `RouterDelegate` |
| File | snake_case | `router_delegate.dart` |
| Test file | `<filename>_test.dart` | `router_delegate_test.dart` |
| Private member | `_camelCase` | `_updateState` |
| Constant | `lowerCamelCase` | `carriageReturn` |
| Enum value | `lowerCamelCase` | `Status.success` |

## Avoid these

- `dynamic` return types
- Double quotes
- Unawaited futures without `unawaited(…)`
