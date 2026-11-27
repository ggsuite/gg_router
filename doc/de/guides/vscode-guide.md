<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# VS-Code-Leitfaden

Die gemeinsamen Editor-Einstellungen und empfohlenen Erweiterungen, mit
denen sich jedes Repo öffnet.

## Was konfiguriert ist <a id="what-is-configured"></a>

- Formatieren beim Speichern über Prettier, fest an die Workspace-Konfiguration
  gebunden, damit es nie auf mitgelieferte Standardwerte zurückfällt
- Lineale bei 80 Zeichen, keine Leerzeichen am Zeilenende, ein
  abschließender Zeilenumbruch
- Coverage Gutters und das Test-Panel
- Eine Vorlage für den Lizenz-Header für jede Sprache, die diese Familie
  schreibt, mit `ggsuite` und `ggsuite`
- `dna/_dna.json` ist mit `jsonc` verknüpft, damit seine Kommentare nicht
  als Fehler erscheinen

## Eine Einstellung hinzufügen <a id="add-a-setting"></a>

- Lege sie in `dna/dot-vscode/settings.json` unter dem Abschnittskommentar
  ab, zu dem sie gehört — füge einen neuen Abschnitt
  `// ####… \n// Name \n// ####…` hinzu, wenn keiner passt
- Begründe sie in einem Kommentar, wenn die Einstellung nicht
  selbsterklärend ist

## Eine empfohlene Erweiterung hinzufügen <a id="add-a-recommended-extension"></a>

- Füge ihre ID zu `dna/dot-vscode/extensions.json` hinzu
- Gib ihr bei Bedarf eine passende Einstellung in `settings.json`, z. B.
  ein auf `[language]` begrenztes `editor.defaultFormatter`

## In einem nutzenden Repo überschreiben <a id="override-in-a-consuming-repo"></a>

- Eine `dna/dot-vscode/settings.json` mit gleichem Pfad in einer späteren
  Schicht ersetzt diese vollständig
- Eine `dna/dot-vscode/settings.overrides.json` führt stattdessen zusammen:
  Objekte werden tief zusammengeführt, `"key!"` ersetzt ohne
  Zusammenführen, `"key+"` hängt an ein Array an — die vollständige Syntax
  steht in der README von helix
