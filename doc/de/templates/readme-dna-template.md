<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# <dna_name>

[English](README.md) | Deutsch

<!-- Optional, nur wenn das Repo den Workflow hat. -->

[![CI](https://github.com/ggsuite/<dna_name>/actions/workflows/quick_check.yaml/badge.svg)](https://github.com/ggsuite/<dna_name>/actions/workflows/quick_check.yaml)

<Ein Satz: was ein Repo durch diese Schicht erhält. Derselbe Text wie die
`description` in `pubspec.yaml` oder `package.json`.>

## Motivation

<Warum es diese Schicht gibt: welches Problem in den nutzenden Repos sie
löst.>

## Verwendung <a id="usage"></a>

Als Dev-Dependency deklarieren und einmal initialisieren:

```bash
pnpm add -D @<scope>/<npm-name>   # TypeScript projects
dart pub add dev:<dna_name>       # Dart projects
helix init
```

`helix init` legt einen Test an, der die DNA bei jedem Testlauf
instanziiert und prüft. Er kopiert <welche Dateien wo landen, z. B. die
Guides nach `doc/en/guides/`>.

<Wie das verwendet wird, was die Schicht mitliefert: der Befehl eines
Skills oder Skripts und was er ausgibt.>

## Guides

- `dna/doc/en/guides/<topic>-guide.md` — <was er den Leser tun lässt>

## Vorlagen <a id="templates"></a>

- `dna/doc/en/templates/<topic>-template.md` — <wofür sie eine Vorlage ist>

## Skills

- `/<command>` — <was er prüft oder erzeugt, und welchem Guide er folgt>

## Skripte <a id="scripts"></a>

- `dna/scripts/<name>.js` — <was es tut, und welcher Guide es aufruft>

## Konfiguration <a id="configuration"></a>

- `dna/dot-github/workflows/<name>.yaml` — <welche Pipeline sie definiert>
- `dna/dot-vscode/<name>.json` — <welche Editor-Einstellung sie beisteuert>

## Umfang <a id="scope"></a>

<Was diese Schicht bewusst anderen Schichten überlässt.>

## Schichten <a id="layers"></a>

<Auf welchen Eltern diese Schicht aufbaut und was jede beiträgt — oder dass
sie orthogonal ist und nur ihr eigenes Thema trägt.>

<Welchen Abschnitt einer Eltern-Schicht sie erweitert, und unter welchem
Tag.>

## Variablen <a id="variables"></a>

- `dnaXxx` — <was sie bedeutet, und ob ein nutzendes Repo sie setzen muss>

## Entwicklung <a id="development"></a>

Der Ordner `dna/` ist von Hand geschriebener Quelltext und wird nie
generiert. Das Repo instanziiert seine eigene DNA — nach Änderungen
`dart test` ausführen; vorher committen, denn eine Datei, die die DNA
überschreiben würde, darf keine uncommittete Arbeit enthalten.

Die Dateien unterhalb von `dna/` bearbeiten, nie ihre Kopien außerhalb
davon: Der Test überschreibt sie.

## Lizenz <a id="license"></a>

<SPDX-Kennung, z. B. MIT> — siehe [LICENSE](LICENSE).
