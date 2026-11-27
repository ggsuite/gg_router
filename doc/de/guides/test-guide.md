<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Test-Guide

Tests sind Pflicht, keine Empfehlung: Die Commit-Prüfung lehnt jeden Commit
ab, der nicht bei 100 Prozent Coverage liegt oder einen roten Test hat. Die
Regeln, die nur in einer Sprache Sinn ergeben, stehen nebenan:
[Dart](./test-guide-dart.md), [TypeScript](./test-guide-typescript.md).
Zur Struktur des getesteten Codes siehe den [Code-Guide](./code-guide.md).

## Den Quellbaum spiegeln <a id="mirror-the-source-tree"></a>

- Jede Quelldatei bekommt ihre eigene, nach ihr benannte Testdatei — die
  Coverage zählt pro Dateiname
- Eine Datei in einem Unterordner behält diesen Unterordner im Testbaum
- Die Testdatei mit dem Lizenz-Header beginnen

## Über die öffentliche API importieren <a id="import-through-the-public-api"></a>

- Das eigene Paket über seinen Einstiegspunkt importieren, so wie es ein
  Konsument tut
- Nur dann in die Interna greifen, wenn ein bewusst nicht exportierter
  Helfer getestet wird

## Nach dem Getesteten verschachteln <a id="nest-by-what-is-under-test"></a>

- Nach dem getesteten Member gruppieren, dann nach dem Fall
- Eine Gruppe nach der Signatur benennen, die sie abdeckt, z. B.
  `subList(start, end)`
- Ein Test deckt ein Verhalten ab; mehrere Assertions sind in Ordnung,
  wenn sie gemeinsam dieses eine Verhalten belegen

## Mit Closures aufsetzen, nicht mit einem Helfer-Modul <a id="set-up-with-closures-not-with-a-helper-module"></a>

- Geteilten Zustand vor jedem Test zurücksetzen
- Externe Ressourcen danach freigeben
- Wiederverwendbares Setup in eine lokale Closure innerhalb der Testdatei
  legen
- Kein Helfer-Modul bauen und nicht von einer Basis-Testklasse erben

## Schleife statt Parametrisierung <a id="loop-instead-of-parametrizing"></a>

- Den Testaufruf in eine Schleife packen, um mehrere Eingaben abzudecken
- Den variierenden Wert in den Testnamen aufnehmen

## Vom Beispiel ausgehen <a id="start-from-the-example"></a>

- Objekte über ihren `example`-Konstruktor bauen und nur die Werte
  übergeben, um die es im Test geht
- Hat eine Klasse noch kein Beispiel, eines hinzufügen, statt das Objekt im
  Test von Hand zu bauen

## Echte Typen statt Mocks bevorzugen <a id="prefer-real-types-over-mocks"></a>

- Konstruktoren ihre Abhängigkeiten als optionale Parameter nehmen lassen,
  dann ohne Mocks testen
- Eine Funktion übergeben, wo eine Klasse einen Mock bräuchte
- Ein Test-Singleton vor jedem Test zurücksetzen und danach leeren
- Nur dann zu einer Mocking-Bibliothek greifen, wenn nichts anderes
  funktioniert

## Auf Struktur prüfen <a id="assert-on-structure"></a>

- Ganze Collections auf einmal vergleichen, statt Element für Element zu
  prüfen
- Bei einem erwarteten Fehler Typ und Meldung prüfen, nicht nur, dass
  etwas geworfen wurde
- Nie in einem Test ausgeben — stattdessen die Ausgabe abfangen

## 100 Prozent Coverage erreichen <a id="reach-100-percent-coverage"></a>

- Eine wirklich unerreichbare Zeile mit dem Ignore-Kommentar des
  Coverage-Tools markieren
- Nur ignorieren, was nicht erreichbar ist, nicht, was unbequem ist
- Stattdessen den Pfad testen, wenn Dependency Injection ihn erreichen kann

## Vor dem Commit validieren <a id="validate-before-you-commit"></a>

Die Prüfungen vor dem Push selbst ausführen — Analyse, Formatierung und der
vollständige Testlauf müssen alle sauber sein.
