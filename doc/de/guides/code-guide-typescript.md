<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Code-Guide — TypeScript

Was der [Code-Guide](./code-guide.md) in einem TypeScript-Paket bedeutet.
Zuerst jenen lesen; dieser ergänzt nur die Besonderheiten.

## Das Paket anlegen <a id="lay-out-the-package"></a>

- `src/index.ts` als Barrel anlegen: Lizenz-Header, danach nur Zeilen
  `export …`, keine Implementierung
- Die Implementierung in `src/<file>.ts` ablegen
- Dateien in kebab-case nach dem Haupttyp benennen, den sie enthalten
- `src/` eins zu eins in `test/` spiegeln, jede Datei als `<name>.spec.ts`

## Die Imports ordnen <a id="order-the-imports"></a>

- Zuerst Node-Builtins, dann Abhängigkeiten, dann das, was zu diesem Repo
  gehört
- Innerhalb des Pakets relative Imports bevorzugen

## Die API gestalten <a id="shape-the-api"></a>

- Ein Options-Objekt statt einer langen Liste positionaler Parameter
  entgegennehmen
- Was sich nicht ändert, `readonly` markieren, und für eine Form, die ein
  Konsument implementiert, `interface` bevorzugen
- Aus asynchronem Code `Promise<T>` zurückgeben und Fehler mit
  `try` / `catch` / `throw` behandeln
- Jedes Promise awaiten oder an etwas übergeben, das es tut — ein
  schwebendes Promise verliert seine Rejection

## Jeder Klasse ein Beispiel geben <a id="give-every-class-an-example"></a>

Ein `static example(…)` anbieten, das ein partielles Options-Objekt nimmt
und für alles Weggelassene einen funktionierenden Wert einsetzt:

```ts
/** Creates an example user for tests and docs. */
static example(options: Partial<UserOptions> = {}): User {
  return new User({ name: 'Jane Doe', age: 42, ...options });
}
```

## Orientierungs-Kommentare <a id="comment-landmarks"></a>

- `// #####…` vor einer Klasse, einem Interface, einem Typ oder einem Enum
- `// ....…` vor jeder dokumentierten Methode, jedem Getter oder Feldblock

## Mit TSDoc dokumentieren <a id="document-with-tsdoc"></a>

- Jeder exportierte Member trägt einen `/** … */`-Kommentar mit einer
  Beschreibung
- Parameter als `@param name - <description>` dokumentieren
- Die Typen stehen in der Signatur — im Kommentar nicht wiederholen
- Ein Beispiel nur hinzufügen, wenn der Aufruf nicht offensichtlich ist

## Die Lints streng halten <a id="keep-the-lints-strict"></a>

- `eslint` mit `typescript-eslint` ausführen, dazu die Plugins `tsdoc` und
  `jsdoc`
- `tsdoc/syntax` und `jsdoc/require-description` auf `error` lassen
- `strict` in `tsconfig.json` einschalten
- Die Formatierung Prettier überlassen: einfache Anführungszeichen,
  Semikolons, zwei Leerzeichen, Trailing Commas, 80 Spalten

## Einheitlich benennen <a id="name-things-consistently"></a>

| Konstrukt              | Stil                 | Beispiel               |
| ---------------------- | -------------------- | ---------------------- |
| Klasse, Interface, Typ | PascalCase           | `BlobStorage`          |
| Datei                  | kebab-case           | `blob-storage.ts`      |
| Testdatei              | `<filename>.spec.ts` | `blob-storage.spec.ts` |
| Funktion, Variable     | lowerCamelCase       | `readItem`             |
| Konstante              | lowerCamelCase       | `carriageReturn`       |
| Enum-Wert              | lowerCamelCase       | `Status.success`       |

## Das vermeiden <a id="avoid-these"></a>

- `any`, wo ein echter Typ passt — zu `unknown` greifen und eingrenzen
- Eine Non-Null-Assertion (`!`), um den Compiler zum Schweigen zu bringen
- `export default` — benannte Exporte halten das Barrel ehrlich
- Doppelte Anführungszeichen
- Ein schwebendes Promise
