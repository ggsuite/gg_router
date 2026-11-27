<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Test-Guide — TypeScript

Was der [Test-Guide](./test-guide.md) in einem TypeScript-Paket bedeutet.
Zuerst jenen lesen; dieser ergänzt nur die Besonderheiten.

## Den Quellbaum spiegeln <a id="mirror-the-source-tree"></a>

- `src/foo.ts` kommt nach `test/foo.spec.ts`
- `src/sub/bar.ts` kommt nach `test/sub/bar.spec.ts`
- Die Datei mit dem Lizenz-Header beginnen

## Über die öffentliche API importieren <a id="import-through-the-public-api"></a>

- `describe`, `it` und `expect` aus `vitest` importieren
- Das eigene Paket über `src/index.ts` importieren
- Nur dann direkt in `src/…` greifen, wenn ein bewusst nicht exportierter
  Helfer getestet wird

## Mit describe und it verschachteln <a id="nest-with-describe-and-it"></a>

- `describe(…)` nach dem getesteten Member, `it(…)` pro Fall
- Das `it` so formulieren, dass Name und Beschreibung sich als ein Satz
  lesen

## Mit Closures aufsetzen <a id="set-up-with-closures"></a>

- Geteilten Zustand in `beforeEach` zurücksetzen
- Externe Ressourcen in `afterEach` freigeben
- Wiederverwendbares Setup in eine lokale Closure innerhalb der Spec-Datei
  legen

## Vom Beispiel ausgehen <a id="start-from-the-example"></a>

- `const user = User.example({ age: 17 });`

## Echte Typen statt Mocks bevorzugen <a id="prefer-real-types-over-mocks"></a>

- Eine Funktion übergeben, wo eine Klasse einen Mock bräuchte
- Nur dann zu `vi.mock` greifen, wenn nichts anderes funktioniert, und mit
  `vi.restoreAllMocks` zurücksetzen

## Auf Struktur prüfen <a id="assert-on-structure"></a>

- Ganze Objekte mit `toEqual` vergleichen, nicht Feld für Feld
- Fehler mit `await expect(fn()).rejects.toThrow(…)` prüfen — ein
  abgelehntes Promise, auf das niemand wartet, besteht stillschweigend
- Nie `console.log` in einem Test

## 100 Prozent Coverage erreichen <a id="reach-100-percent-coverage"></a>

- `vitest run --coverage` ausführen
- Eine wirklich unerreichbare Zeile mit `/* v8 ignore next */` markieren,
  einen Block mit `/* v8 ignore start */` und `/* v8 ignore stop */`

## Vor dem Commit validieren <a id="validate-before-you-commit"></a>

```bash
pnpm test
```

`vitest`, `eslint` und der Prettier-Check müssen alle sauber sein.
