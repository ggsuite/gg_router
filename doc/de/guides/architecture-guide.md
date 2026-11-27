<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Architektur-Guide

Wie ein Repo in Teile geschnitten wird und wie diese Teile wachsen. Der
[Code-Guide](./code-guide.md) enthält die Regeln für eine einzelne Datei
und Funktion; dieser Guide enthält die Regeln darüber. Die Struktur so
gestalten, wie es ein Senior-Entwickler tun würde: von dem aus, wohin das
Projekt geht, nicht nur von dem, was es heute tut.

## Davon ausgehen, wohin das Projekt geht <a id="start-from-where-the-project-is-going"></a>

- Herausfinden, welche Rolle das Repo spielt: Es hält eine Domäne, es ist
  CLI oder Glue über einer Domäne, die anderswo liegt, es ist eine
  Bibliothek mit Konsumenten, oder es folgt einem anderen Repo (Port,
  Spiegel, Fork, generierter Code). Ein Repo, das einem anderen folgt, wird
  danach beurteilt, wie günstig es ihm weiter folgen kann; strukturelle
  Änderungen an der gespiegelten API gehören zuerst upstream. In einem
  Folge-Repo ist Struktur, die upstream entspricht, kein Befund; eine
  Abweichung von upstream schon
- Die Ziele vor dem Code lesen: das Projektmanagement-Repo (Ziele,
  Anforderungen, die Architektur des aktuellen Quartals), falls es eines
  gibt, das Konzept in `CLAUDE.md`, die README, offene Tickets (die
  Ticket-Ordner des Workspace mit ihrer `ticket.json`, offen nur, solange
  ihr Branch nicht gemergt ist, und die Issues beim Repo-Host) und
  `git log`. Das CHANGELOG als Richtung lesen, die bisherige Arbeit
  genommen hat, nicht als Liste von Zielen
- Nur aus Belegen, die sich benennen lassen, ableiten, wo das System
  variieren wird: ein Interface mit einer Implementierung, das auf weitere
  wartet, ein README-Abschnitt zum Erweitern, Dateien, die sich laut
  Historie mit jedem Feature ändern, ein Konsument, der um das herum
  arbeitet, was er bekommt, ein offenes Ticket oder das, was der Nutzer
  sagt. Eine Achse ohne Beleg trägt keine Empfehlung; höchstens wird sie
  zu einer Frage an den Nutzer
- Die Qualitätsmerkmale benennen, die hier Abwägungen entscheiden, nur
  die, die Quellen oder Code zeigen: Zielplattformen im Manifest oder in
  der CI, Benchmarks, gespeicherte Ausgaben, die Fixes der letzten
  Releases. Prüfen, dass keine plattformspezifische API eine genannte
  Zielplattform blockiert
- Das, was die Quellen sagen, getrennt halten von dem, was abgeleitet
  ist; ein abgeleitetes Ziel ist eine Hypothese, bis jemand es bestätigt
- Gibt es keine Zielquellen, das sagen; das Zielbild ist dann die aktuelle
  Struktur plus Fixes für das, was schon heute kostet

## Entlang von Konzepten schneiden <a id="cut-along-concepts"></a>

- Ein Konzept pro Modul, ein Top-Level-Konzept pro Paket; ein Modul
  teilen, wenn seine Konzepte unterschiedliche Nutzer haben oder sich
  unterschiedlich schnell ändern, nicht wegen seiner Größe
- Ein Modul nach dem Konzept benennen, das es hält, nie nach seiner
  Technik (`helpers`, `utils`, `misc`, `common`)
- Abhängigkeiten in eine Richtung zeigen lassen: von den Rändern (UI, CLI,
  IO, Netzwerk, Framework) zum Kern, der die Domäne hält
- Zuerst herausfinden, welches Paket die Domäne hält; diesen Kern frei von
  IO-, UI- und Framework-Typen halten. Ein CLI- oder Glue-Paket über einer
  Domäne, die anderswo liegt, hat keinen eigenen Kern
- Keine Zyklen zwischen Modulen oder Paketen zulassen

## Das Innere verbergen <a id="hide-the-inside"></a>

- Die öffentliche API klein halten; alles, was ein Aufrufer nicht braucht,
  ist privat
- Jedem Stück Zustand genau einen Besitzer geben; andere fragen den
  Besitzer, statt in seine Daten zu greifen
- Unveränderliche Werte herausgeben, keine Referenzen auf interne
  Collections
- Uhren, IO, Zufall und die Umgebung injizieren, wo der Code sonst auf ein
  Test-Flag oder eine Umgebungsvariable verzweigen würde
- Eine Drittanbieter-Bibliothek nur dort hinter einem eigenen Interface
  verbergen, wo die Ziele ihren Austausch nennen oder ihre API sich
  ständig ändert und in viele Module durchsickert; nicht für die eigenen
  Pakete der Organisation oder stabile Grundlagen wie path oder args

## Öffentliche API und gespeicherte Ausgaben als Versprechen behandeln <a id="treat-the-public-api-and-stored-outputs-as-promises"></a>

- Für ein veröffentlichtes Paket ist die öffentliche API die wichtigste
  Grenze; ihre Konsumenten finden (`interfaces.usedBy` in `index.jsonc`,
  Imports über `.ocean` hinweg, Re-Exporte), bevor sie beurteilt oder
  geändert wird
- Öffentliche API, die niemand nutzt, und öffentliche API, die nur für
  Tests existiert, sind Befunde, sobald alle Konsumenten bekannt sind; bei
  einem außerhalb des Workspace veröffentlichten Paket externe Konsumenten
  annehmen und nachfragen
- Ausgaben, die gespeichert oder versendet werden (Hash-Werte,
  Dateiformate, CLI-Ausgaben, die Skripte parsen), sind ebenfalls
  Verträge; sie vor dem Umstrukturieren mit Golden-Tests festnageln
- Was Konsumenten nutzen, ist ein Vertrag; was sie brauchen und selbst
  nachbauen, ist ein Ziel

## Jedes Konzept einmal sagen <a id="say-each-concept-once"></a>

- Dieselbe Idee, in zwei Modulen implementiert, ist ein fehlendes
  Konzept; ihm ein Zuhause geben und beide es nutzen lassen
- Nachzubauen, was eine Abhängigkeit oder ein Geschwister-Repo schon
  anbietet, ist Duplizierung über Repos hinweg; deren Lösung nutzen oder
  eines davon zum einzigen Zuhause machen. Zwei Implementierungen eines
  Konzepts, die unterschiedliche Ergebnisse liefern, sind ein Defekt
- Einem geteilten Stück beim zweiten Konsumenten ein eigenes Modul geben.
  Braucht es ein Konsument in einem anderen Repo, es in das bestehende
  Repo verschieben, dessen Scope passt; ein neues Paket nur anlegen, wenn
  keines passt, und seine Kosten benennen: Publish-Kette, Versionen,
  DNA-Rollout
- Zwei Stellen, die sich für jedes neue Feature gemeinsam ändern, sind ein
  in zwei Teile gespaltenes Konzept
- Nicht jede Ähnlichkeit ist Duplizierung: Zwei Stücke, die gleich
  aussehen, sich aber aus verschiedenen Gründen ändern, bleiben getrennt;
  ebenso wenig Code, der auf Geschwindigkeit spezialisiert ist, wenn ein
  Benchmark oder eine im Code genannte Begründung ihn stützt

## Durch Hinzufügen wachsen, nicht durch Ändern <a id="grow-by-adding-not-by-editing"></a>

- Wo die Ziele Variation vorhersagen, die kleinste Nahtstelle setzen, die
  sie trägt: ein Funktionsparameter oder eine Datentabelle vor einem
  Interface, ein Interface vor einer Registry
- Eine neue Art von Ding als neuen Typ hinzufügen, der das Interface
  erfüllt, statt als neuen Zweig in jedem `switch` über die Arten
- Das gilt für Arten, von denen die Ziele erwarten, dass sie wachsen; ein
  `switch` über eine geschlossene Menge (die Typen einer Sprache, die
  Wertarten eines Formats wie JSON, ein festes Protokoll) bleibt ein
  `switch`
- Die Nahtstelle dort halten, wo die Variation ist, nicht eine Ebene
  darüber oder darunter
- Verhalten über Daten konfigurieren, wo sich die Varianten nur in Werten
  unterscheiden

## Nicht für erdachte Zukünfte bauen <a id="do-not-build-for-imagined-futures"></a>

- Eine strukturelle Änderung rechtfertigt sich durch ein Ziel aus `@goals`
  oder durch Kosten, die heute bestehen und sich zeigen lassen: eine
  Datei, die sich laut Historie mit jedem Feature ändert, Kopien, die schon
  auseinandergelaufen sind, ein Bug, den die Struktur verursacht hat. Einen
  Hotspot günstig änderbar zu halten, zählt als Ziel, wenn die Historie
  zeigt, dass dort weitergearbeitet wird. Ohne beides die Struktur so
  lassen, wie sie ist
- Eine Nahtstelle braucht ein Ziel dahinter; eine Abstraktion mit nur
  einer Implementierung und ohne Ziel, das eine zweite verlangt, ist ein
  Befund
- Die einfachste Struktur, die die Ziele trägt, der allgemeinsten
  vorziehen
- Generische Frameworks innerhalb einer Anwendung, Schichten, die Aufrufe
  nur durchreichen, und Optionen, die niemand setzt, sind Kosten ohne
  Ertrag

## Vor dem Schreiben entscheiden, wohin neuer Code gehört <a id="decide-where-new-code-goes-before-you-write-it"></a>

- Das festgehaltene Zielbild lesen, falls das Projekt eines hat, und den
  Code dort platzieren, wo es vorsieht
- Vor dem Erweitern einer bestehenden Datei oder Klasse fragen, ob das
  Feature zu dem Konzept gehört, das sie hält; falls nicht, ihm ein eigenes
  Modul oder einen eigenen Typ geben
- Ist man dabei, einen `switch` über Arten zu erweitern, ein Modus-Flag
  hinzuzufügen oder einen Block zu kopieren, das fehlende Konzept benennen
  und stattdessen dieses hinzufügen
- Vor dem Schreiben in diesem Repo, seinen Abhängigkeiten und den Repos in
  `.ocean` nach dem Konzept suchen (siehe `@dry`)
- Braucht der richtige Ort zuerst eine strukturelle Änderung oder liegt er
  in einem anderen Repo, das vorschlagen und vor dem Schreiben nachfragen

## Auf Struktur achten, die durch Anlagerung gewachsen ist <a id="watch-for-structure-that-grew-by-accretion"></a>

Code, der Feature für Feature gewachsen ist, besonders durch einen Agenten,
neigt dazu, neues Verhalten an das Bestehende anzuschrauben. Achten auf:

- Eine Klasse oder Datei, die mit jedem Feature wächst und von allem ein
  wenig weiß
- Ein `switch` oder eine `if`-Kette über eine Art, die wachsen soll,
  wiederholt an mehreren Stellen
- Ein Boolean- oder Modus-Parameter, der eine Funktion in zwei Funktionen
  verwandelt
- Ein ganzes Modul, kopiert und leicht verändert statt geteilt
- UI- oder CLI-Code, der Speicher, Netzwerk oder Dateien direkt liest
- Geteilter veränderlicher Zustand, in den mehrere Module schreiben, etwa
  statische Flags und Zähler, statt Zustand, der einem expliziten Kontext
  gehört
- Arbeit, die beim Importieren eines Moduls erledigt wird
- Test-Hooks in der öffentlichen API oder Verzweigungen auf `isTest` oder
  Umgebungsvariablen in Bibliothekscode
- Ein Sammelbecken-Modul, das alle importieren
- Dateien, die sich in den meisten Feature-Commits gemeinsam ändern, ohne
  Tests, Manifeste, Changelogs und Barrels; ein Hinweis, genauer
  hinzusehen, noch kein Urteil

## Die Struktur in kleinen Schritten ändern <a id="change-the-structure-in-small-steps"></a>

- Zuerst das Zielbild zeichnen, dann den Weg dorthin planen
- Jeden Schritt auslieferbar machen: Die Tests bleiben grün, und das
  Release funktioniert nach jedem Schritt
- Verhalten, das die Tests nicht abdecken, vor einem strukturellen Schritt
  mit Charakterisierungs- oder Golden-Tests festnageln; Tests nach
  Möglichkeit mit dem Code verschieben und die Kosten des Umschreibens
  benennen, wo Tests CLI-Ausgaben oder Log-Texte prüfen
- Die neue Struktur neben die alte stellen, die Aufrufer umziehen, dann
  die alte löschen
- Struktur und Verhalten in getrennten Schritten ändern, nie im selben
  Commit
- Jeden Schritt als breaking oder nicht einstufen; können Konsumenten
  außerhalb des Workspace existieren, vor dem Entfernen als deprecated
  markieren und Entfernungen in einem Major-Release bündeln; sind alle
  Konsumenten im Workspace, sie im selben Workspace-Ticket anpassen
- Schritte, die mehrere Repos umfassen, nach der Release-Kette ordnen, das
  bereitstellende Paket zuerst, als ein Workspace-Ticket
- Das Zielbild dort festhalten, wo das Projekt es aufbewahrt, sodass die
  nächste Änderung ihm folgt
