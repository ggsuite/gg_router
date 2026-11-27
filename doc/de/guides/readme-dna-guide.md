<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# README-DNA-Guide

Folge diesem Guide für die README eines DNA-Repos — einer Schicht, die
andere Repos in ihrer `dna/_dna.json` aufführen. Es heißt `dna_*` oder
`dna-*`, oder seine `dna/_dna.json` deklariert `mustOverride`. Sein Leser
ruft keine API auf: Er will wissen, was sein Repo durch die Schicht erhält.

Aus dem [README-Guide](./readme-guide.md) gelten der erste Bildschirm, die
Motivation, das Verlinken, die Badges, Markdown, beide Sprachen und die
Prüfung. Beispiel, Einschränkungen und Status entfallen: Die Verwendung
zeigt die Einrichtung, der Umfang nennt die Grenzen.

## Vorlage kopieren <a id="copy-the-template"></a>

- `doc/en/templates/readme-dna-template.md` nach `README.md` kopieren oder
  eine vorhandene README daran ausrichten
- Jeden Abschnitt weglassen, zu dem diese Schicht nichts hat

## Sagen, was die Schicht tut <a id="say-what-the-layer-does"></a>

- Mit einem Satz beginnen: was ein Repo durch diese Schicht erhält
- Diesen Satz als `description` in `pubspec.yaml` und `package.json`
  verwenden
- Das Thema nennen, das sie verantwortet, nicht die Mechanik dahinter
- Die Motivation schreiben: welches Problem in den nutzenden Repos die
  Schicht löst

## Verwendung zeigen <a id="show-how-to-use-it"></a>

- Die Einrichtung direkt nach der Motivation zeigen, ein Leser will es
  ausprobieren
- Sagen, wo die Dateien im nutzenden Repo landen, z. B. `dna/doc/` in
  `doc/`, `dna/dot-claude/` in `.claude/`, `dna/scripts/` in `scripts/`
- Zeigen, wie das Mitgelieferte verwendet wird, z. B. den Befehl eines
  Skills oder Skripts und was er ausgibt
- Harte Voraussetzungen nennen, z. B. Node.js für ein Skript

## Auflisten, was die Schicht mitliefert <a id="list-what-the-layer-ships"></a>

- Guides, Vorlagen, Skills, Skripte und Konfiguration jeweils in einen
  eigenen Abschnitt setzen
- Jede Datei mit ihrem Pfad unterhalb von `dna/` und einer Zeile zu ihrem
  Zweck nennen; einen Ordner mit Hilfsdateien als Ganzes nennen, z. B.
  `dna/scripts/functions/`
- Einen Skill über den Befehl nennen, den ein Benutzer eintippt, z. B.
  `/translate`
- Sagen, welcher Guide ein Skript aufruft

## Umfang nennen <a id="name-its-scope"></a>

- Nennen, was sie bewusst anderen Schichten oder dem Repo überlässt

## Die Schichten nennen, auf denen sie aufbaut <a id="name-the-layers-it-builds-on"></a>

- Die Eltern-Schichten aus `dna/_dna.json` auflisten, jede mit ihrem Repo
  verlinkt
- Sagen, was jede Eltern-Schicht beiträgt, nicht nur ihren Namen
- Angeben, dass die Schicht orthogonal ist, wenn sie keine Eltern hat;
  helix, die Basis jeder Schicht, ist kein Elternteil
- Die Abschnitte nennen, die sie in einer Eltern-Schicht erweitert, und
  das Tag, das sie verwendet

## Variablen dokumentieren <a id="document-the-variables"></a>

- Jede Variable aus `dna/_vars.json` auflisten
- Die Bedeutung angeben; einen Wert nur nennen, wo er erklärt, warum die
  Variable existiert
- Sagen, welche ein nutzendes Repo selbst setzen muss, nämlich die, die
  `mustOverride` in `dna/_dna.json` markiert

## Aktuell halten <a id="keep-it-current"></a>

- Im Entwicklungsabschnitt sagen, dass nur `dna/` bearbeitet wird, nie die
  Kopien, die der Test schreibt
- Die README in derselben Änderung aktualisieren, die eine DNA-Datei
  hinzufügt oder entfernt
- `node scripts/check-readme.js` ausführen; in einem DNA-Repo meldet es
  zusätzlich jede `dna/`-Datei, Variable und Eltern-Schicht, die die README
  nicht erwähnt
