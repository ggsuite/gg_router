<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Übersetzungsleitfaden

## Die Sprachen kennen <a id="know-the-languages"></a>

- Dieses Repo führt seine Dokumentation in diesen Sprachen, die Leitsprache
  zuerst: `en`. Ändere sie in den `vars` von `dna/_dna.json`,
  unter dem Schlüssel `dna` + `Languages` in einem Wort, als
  Zwei-Buchstaben-Codes durch Kommas getrennt, z. B. `"en,de,fa"`
- Jede Sprache hat eigene Ordner: `doc/<lang>` für die Dokumentation, die
  zu keinem Quartal gehört, `pm/<lang>/<yyyy>-Q<n>` für das, was in einem
  Quartal geplant und geschrieben wird, z. B. den Blog
- `README.md` ist Englisch, jede andere Sprache hat `README.<lang>.md`
- Bei nur einer Sprache gibt es nichts zu übersetzen

## Die Sprachen synchron halten <a id="keep-the-languages-in-sync"></a>

- Lege zu jeder Datei einer Sprache die entsprechende Datei in jeder
  anderen Sprache an, mit gleichem Pfad unter `doc/<lang>` oder
  `pm/<lang>` und gleichem Dateinamen
- Stelle sicher, dass eine Änderung in einer Sprache in alle anderen
  übersetzt wird
- Nutze vorhandene übersetzte Dateien
- Beginne Dokumentation in der Leitsprache; auch wenn der Nutzer eine
  andere Sprache spricht, schreibe zuerst die Leitsprache
- Übersetze kurz vor dem Veröffentlichen
- Übersetze inhaltlich und strukturell gleich
- Übersetze keine Befehle, keinen Code, keine Pfade, APIs, IDs oder
  Dateinamen
- Übersetze nicht wörtlich
- Übersetze nie die Leitfäden und Vorlagen unter `doc/<lang>/guides` und
  `doc/<lang>/templates`: Die DNA-Schichten liefern sie in jeder Sprache
  aus

## Blogbeiträge <a id="blog-posts"></a>

- Beginne einen Beitrag in der Leitsprache, siehe den
  [Blog-Leitfaden](./blog-guide.md)
- Lege jede Übersetzung in `pm/<lang>/<yyyy>-Q<n>/blog` ihrer Sprache ab,
  im gleichen Quartal und mit dem gleichen Dateinamen wie das Original
- Kopiere für einen neuen Beitrag `doc/<lang>/templates/blog-template.md`
  der jeweiligen Sprache
- Folge für alles andere dem [Blog-Leitfaden](./blog-guide.md)
