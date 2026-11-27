<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Skript-Leitfaden

Die Node-Skripte, mit denen ein Repo seinen Arbeitsablauf automatisiert, und
die Funktionen, die sie teilen — vom Lesen des lokalen git-Zustands bis zum
Aufruf der GitHub-API.

## Eine Funktion nutzen, statt einen Befehl zu wiederholen <a id="use-a-function-instead-of-repeating-a-command"></a>

- Importiere aus `dna/scripts/functions/`, dupliziere nie einen `git`-,
  `gh`- oder Dateisystem-Aufruf über mehrere Skripte hinweg
- Halte eine Funktion wo möglich rein: gleiche Eingabe, gleiche Ausgabe,
  keine Konsolenausgabe

## Ein Skript hinzufügen <a id="add-a-script"></a>

- Lege es in `dna/scripts/` ab, seine gemeinsam genutzten Teile in
  `dna/scripts/functions/`
- Gib ihm den Lizenz-Header, den jede Datei hier trägt
- Rufe es aus einem Leitfaden der Schicht auf, die es braucht
