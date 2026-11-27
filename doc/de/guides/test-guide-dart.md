<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Test-Guide — Dart

Was der [Test-Guide](./test-guide.md) in einem Dart- oder Flutter-Paket
bedeutet. Zuerst jenen lesen; dieser ergänzt nur die Besonderheiten.

## Den Quellbaum spiegeln <a id="mirror-the-source-tree"></a>

- `lib/src/foo.dart` kommt nach `test/foo_test.dart`
- `lib/src/sub/bar.dart` kommt nach `test/sub/bar_test.dart`
- Die Datei mit dem Lizenz-Header und einem `main()` auf oberster Ebene
  beginnen

## Über die öffentliche API importieren <a id="import-through-the-public-api"></a>

- `package:test/test.dart` importieren, in einem Flutter-Paket
  `package:flutter_test/flutter_test.dart`
- Das eigene Paket über seine Barrel-Datei importieren
- Nur dann in `package:<pkg>/src/…` greifen, wenn ein bewusst nicht
  exportierter Helfer getestet wird

## Mit group und test verschachteln <a id="nest-with-group-and-test"></a>

- `group(…)` nach dem getesteten Member, `test(…)` pro Fall

## Mit Closures aufsetzen <a id="set-up-with-closures"></a>

- Geteilten Zustand in `setUp` zurücksetzen
- Externe Ressourcen in `tearDown` freigeben
- Wiederverwendbares Setup in eine lokale Closure innerhalb von `main()`
  legen

## Vom Beispiel ausgehen <a id="start-from-the-example"></a>

- `final user = User.example(age: 17);`

## Echte Typen statt Mocks bevorzugen <a id="prefer-real-types-over-mocks"></a>

- Nur dann zu `mockito` oder `mocktail` greifen, wenn nichts anderes
  funktioniert

## Auf Struktur prüfen <a id="assert-on-structure"></a>

- Ganze Listen mit `equals([…])` vergleichen
- Exceptions mit `throwsA(isA<X>().having(…))` prüfen
- Nie `print` in einem Test

## 100 Prozent Coverage erreichen <a id="reach-100-percent-coverage"></a>

- Eine wirklich unerreichbare Zeile mit `// coverage:ignore-line`
  markieren, einen Block mit `// coverage:ignore-start` und
  `// coverage:ignore-end`

## Vor dem Commit validieren <a id="validate-before-you-commit"></a>

```bash
gg can commit
```

`dart analyze`, `dart format` und `dart test` müssen alle sauber sein.
