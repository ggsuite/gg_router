<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Code-Guide — Dart

Was der [Code-Guide](./code-guide.md) in einem Dart- oder Flutter-Paket
bedeutet. Zuerst jenen lesen; dieser ergänzt nur die Besonderheiten.

## Das Paket anlegen <a id="lay-out-the-package"></a>

- `lib/<package>.dart` als Barrel-Datei anlegen: Lizenz-Header,
  `library;`, danach nur Zeilen `export 'src/…';`
- Die Implementierung in `lib/src/<file>.dart` ablegen
- Dateien in snake_case nach dem Haupttyp benennen, den sie enthalten
- `lib/src/` eins zu eins in `test/` spiegeln

## Die Imports ordnen <a id="order-the-imports"></a>

- Zuerst `dart:`, dann `package:`, dann relative Imports schreiben
- Innerhalb des Pakets relative Imports bevorzugen

## Die API gestalten <a id="shape-the-api"></a>

- Benannte Parameter `required` markieren, sofern sie keinen Default haben
- Für einen alternativen Weg, das Objekt zu erzeugen, einen
  Factory-Konstruktor verwenden
- Aus asynchronem Code `Future<T>` zurückgeben und Fehler mit
  `try` / `catch` / `rethrow` behandeln
- Jedes Future awaiten oder mit `unawaited(…)` markieren

## Jeder Klasse ein Beispiel geben <a id="give-every-class-an-example"></a>

Eine `factory X.example({…})` mit ausschließlich optionalen Parametern
anbieten, die für jeden auf einen funktionierenden Wert zurückfällt:

```dart
/// Creates an example user for tests and docs.
factory User.example({String? name, int? age}) =>
    User(name: name ?? 'Jane Doe', age: age ?? 42);
```

## Orientierungs-Kommentare <a id="comment-landmarks"></a>

- `// #####…` vor einer Klasse, einem Enum oder einem anderen Konstrukt auf
  oberster Ebene
- `// ....…` vor jeder dokumentierten Methode, jedem Getter oder Feldblock

## Mit `///` dokumentieren <a id="document-with-"></a>

- Jeder öffentliche Member trägt einen `///`-Kommentar
- Parameter als `- [name] <description>` dokumentieren
- Ein `dart`-Codebeispiel nur hinzufügen, wenn der Aufruf nicht
  offensichtlich ist

## Die Lints streng halten <a id="keep-the-lints-strict"></a>

- `package:lints/recommended.yaml` einbinden
- `public_member_api_docs`, `prefer_single_quotes`,
  `require_trailing_commas`, `always_declare_return_types`,
  `unawaited_futures` und die `prefer_const_*`-Familie einschalten
- `strict-casts`, `strict-inference` und `strict-raw-types` einschalten
- `lines_longer_than_80_chars` nur in Flutter-Paketen abschalten, und nur,
  wenn es im Weg ist

## Einheitlich benennen <a id="name-things-consistently"></a>

| Konstrukt       | Stil                   | Beispiel                    |
| --------------- | ---------------------- | --------------------------- |
| Klasse          | PascalCase             | `RouterDelegate`            |
| Datei           | snake_case             | `router_delegate.dart`      |
| Testdatei       | `<filename>_test.dart` | `router_delegate_test.dart` |
| Privater Member | `_camelCase`           | `_updateState`              |
| Konstante       | `lowerCamelCase`       | `carriageReturn`            |
| Enum-Wert       | `lowerCamelCase`       | `Status.success`            |

## Das vermeiden <a id="avoid-these"></a>

- `dynamic` als Rückgabetyp
- Doppelte Anführungszeichen
- Nicht awaitete Futures ohne `unawaited(…)`
