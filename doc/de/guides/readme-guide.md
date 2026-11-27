<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# README-Guide

Folge diesem Guide für die README eines Pakets oder einer App. Ein DNA-Repo
— eine Schicht, die andere Repos in ihrer `dna/_dna.json` aufführen — folgt
für seine Abschnitte dem [README-DNA-Guide](./readme-dna-guide.md); die
Regeln zu Stil, Sprachen und Prüfung unten gelten auch dafür.

## Vorlage kopieren <a id="copy-the-template"></a>

- `doc/en/templates/readme-template.md` nach `README.md` kopieren oder eine
  vorhandene README daran ausrichten
- Die Reihenfolge der Abschnitte beibehalten, optionale Abschnitte
  weglassen, zu denen das Repo nichts hat
- Jeden `<placeholder>` ersetzen

## Mit dem Zweck beginnen <a id="open-with-what-it-does"></a>

- Name, Badges und ein bis zwei Sätze auf den ersten Bildschirm setzen —
  dort entscheidet ein Leser, ob das Paket passt
- Die `description` aus `pubspec.yaml` oder `package.json` als diesen Satz
  verwenden, damit GitHub, pub.dev und npm dasselbe sagen
- Harte Grenzen früh nennen, z. B. die unterstützten Plattformen

## Sagen, warum es existiert <a id="say-why-it-exists"></a>

- Die Motivation schreiben: das Problem oder die Reibung, die zum Repo
  geführt hat, und was es erreichen will
- Für Neueinsteiger schreiben — das Warum fehlt in READMEs am häufigsten
- Es aus dem Repo, seinen Dokumenten und seiner Historie entnehmen; den
  Benutzer fragen, wenn diese es nicht verraten, nie erfinden

## Es in Aktion zeigen <a id="show-it-working"></a>

- Einen kopierbaren Installationsbefehl pro Ökosystem angeben
- Die wichtigste Funktion als Snippet zeigen, das unverändert läuft — kein
  Pseudocode, keine TODOs
- Das Snippet identisch mit dem Code in `example/` halten; pub.dev zeigt
  diese Datei im Tab Example
- Zeigen, was das Snippet ausgibt

## Sagen, wo es endet <a id="say-where-it-ends"></a>

- Nennen, was das Paket bewusst nicht tut, und seine Tücken
- Den Reifegrad angeben, z. B. dass sich die API vor 1.0 ändern kann

## Verlinken statt wiederholen <a id="link-instead-of-repeating"></a>

- Guides, Architektur-Dokumente und Blog verlinken, nicht kopieren
- Nur Dateien verlinken, die im Repo existieren
- Linktexte schreiben, die sagen, wohin sie führen, nie „hier“

## Wenige und wahre Badges <a id="keep-badges-few-and-true"></a>

- Höchstens fünf verwenden: CI, Registry-Version, Pub-Punkte, Coverage,
  Lizenz
- Das CI-Badge auf eine Workflow-Datei in `.github/workflows/` zeigen
  lassen
- Ein Badge entfernen, dessen Status niemand beobachtet

## Schlichtes Markdown schreiben <a id="write-plain-markdown"></a>

- Überschriften in Satzschreibweise, Aufgaben im Imperativ, z. B.
  „Paket installieren“
- Jeden Codeblock mit seiner Sprache auszeichnen
- Nur `https`-Links verwenden — pub.dev zieht für `http` Punkte ab
- Kein Inhaltsverzeichnis anlegen, GitHub erzeugt eines

## In jeder Sprache des Repos schreiben <a id="write-it-in-every-language-of-the-repo"></a>

- Die Sprachen dieses Repos, die führende zuerst, sind `en`
- `README.md` auf Englisch halten und je eine `README.<lang>.md` pro
  weiterer Sprache, z. B. `README.de.md`, `README.fa.md`
- Unter den Titel einen Sprachumschalter setzen, der jede Sprache nennt und
  alle anderen verlinkt, z. B. `English | [Deutsch](README.de.md)` in
  `README.md`, `[English](README.md) | Deutsch` in `README.de.md`
- Alle inhaltlich und strukturell gleich halten: dieselben Abschnitte in
  derselben Reihenfolge, Überschriften und Fließtext übersetzt
- Codeblöcke identisch halten, ihre Kommentare eingeschlossen
- Die README zuerst in der führenden Sprache schreiben, dann übersetzen
- `doc/en/guides/translate-guide.md` folgen
- pub.dev und npm zeigen nur `README.md`

## Prüfen <a id="check-it"></a>

- `node scripts/check-readme.js` ausführen; es meldet einen Titel, der
  nicht der Paketname ist, fehlende oder falsch platzierte Abschnitte,
  übrig gebliebene Platzhalter, kaputte Links und Badges, zu viele Badges,
  Codeblöcke ohne Sprache, einen Satz, der von der `description` abweicht,
  und eine abgedriftete deutsche README
- Die README in derselben Änderung aktualisieren wie den Code, den sie
  beschreibt
