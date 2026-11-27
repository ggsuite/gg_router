<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Code-Guide

Was in jeder Sprache gilt, in der wir schreiben. Die Regeln, die nur in
einer davon Sinn ergeben, stehen nebenan: [Dart](./code-guide-dart.md),
[TypeScript](./code-guide-typescript.md). Für Tests siehe den
[Test-Guide](./test-guide.md), dafür, wie ein Repo in Teile geschnitten
wird, den [Architektur-Guide](./architecture-guide.md).

## Das Paket anlegen <a id="lay-out-the-package"></a>

- Das Paket nach dem Repo benennen
- Wie das Paket in Konzepte geschnitten wird, steht im
  [Architektur-Guide](./architecture-guide.md) unter `@boundaries`
- Das Paket über einen einzigen Einstiegspunkt bereitstellen, der
  re-exportiert und selbst keine Implementierung enthält
- Eine Datei nach dem Haupttyp benennen, den sie enthält
- Den Quellbaum eins zu eins im Testbaum spiegeln

## Jede Datei mit dem Lizenz-Header beginnen <a id="open-every-file-with-the-license-header"></a>

- Den Header aus einer benachbarten Datei kopieren
- Danach eine Leerzeile, dann die Imports

## Die Imports ordnen <a id="order-the-imports"></a>

- Zuerst Runtime und Standardbibliothek, dann Pakete von Drittanbietern,
  dann das, was zu diesem Repo gehört
- Jede Gruppe alphabetisch sortieren und die Gruppen durch eine Leerzeile
  trennen

## Die Member eines Typs ordnen <a id="order-the-members-of-a-type"></a>

- Zuerst Konstruktoren, jeder mit einem Doc-Kommentar
- Danach alternative Konstruktoren
- Öffentliche Methoden, gruppiert nach Zusammengehörigkeit, nicht
  alphabetisch
- Öffentliche Felder und Getter, standardmäßig unveränderlich
- Statische Konstanten und Methoden
- Private Member zuletzt

Veränderlichkeit vermeiden: Zustand über Copy-with-Methoden statt über
Setter ändern.

## Die API gestalten <a id="shape-the-api"></a>

- Standardmäßig benannte Parameter verwenden, positionale nur für ein
  triviales einzelnes Argument
- Parametern sinnvolle Defaults geben
- Aus asynchronem Code ein Promise oder Future zurückgeben und Fehler
  explizit behandeln — nie verschlucken
- Jeden asynchronen Aufruf awaiten oder bewusst kennzeichnen, dass es
  nicht geschieht

## Jeder Klasse ein Beispiel geben <a id="give-every-class-an-example"></a>

- Einen `example`-Konstruktor anbieten, der ohne ein einziges Argument
  eine gültige Instanz baut
- Jeden seiner Parameter optional machen, sodass ein Aufrufer nur die
  Werte überschreibt, die ihm wichtig sind
- Alles andere mit realistischen Werten füllen, nicht mit leeren Strings
  und Nullen
- Das Beispiel in Tests, Doku und anderen Beispielen verwenden, statt das
  Objekt von Hand zu bauen
- Nur dort weglassen, wo sich nichts instanziieren lässt: abstrakte Typen,
  Enums und rein statische Helfer

## Echte Bezeichner aus Beispielen heraushalten <a id="keep-real-identifiers-out-of-examples"></a>

- `com.example.<app>` schreiben, wo immer ein Beispiel, ein Test oder die
  Doku eine Bundle-ID, Application-ID oder einen Paketnamen braucht
- `example.com`, `example.org` oder `example.net` für Domains, URLs und
  Mail-Adressen wie `user@example.com` schreiben — sie sind für
  Dokumentation reserviert (RFC 2606, RFC 6761)
- `192.0.2.x`, `198.51.100.x`, `203.0.113.x` oder `2001:db8::` für
  IP-Adressen schreiben (RFC 5737, RFC 3849)
- Nie einen Bezeichner der Organisation nehmen, etwa
  `com.<organization>.<app>` oder die Domain der Organisation — ein
  Beispiel darf weder mit einer echten App kollidieren noch wie eine
  aussehen
- Echte Bezeichner nur in der Konfiguration der echten App halten

## Abschnitte mit Orientierungs-Kommentaren trennen <a id="separate-sections-with-comment-landmarks"></a>

- Eine `#####`-Linie vor einer Klasse, einem Enum oder einem anderen
  Konstrukt auf oberster Ebene
- Eine `.....`-Linie vor jeder dokumentierten Methode, jedem Getter oder
  Feldblock
- Ein benannter `#####`-Block innerhalb eines großen Typs, um einen
  Abschnitt zu markieren

Den Stil so lassen, wie er ist — keine Varianten erfinden.

## Jeden öffentlichen Member dokumentieren <a id="document-every-public-member"></a>

- Jedem öffentlichen Member einen Doc-Kommentar geben
- Mit einem vollständigen Satz in der dritten Person Indikativ beginnen
- Parameter in den folgenden Zeilen dokumentieren
- Ein Beispiel nur hinzufügen, wenn der Aufruf nicht offensichtlich ist

## Funktionen klein und flach halten <a id="keep-functions-small-and-flat"></a>

- Eine Funktion, die über etwa zehn Zeilen hinauswächst, will geteilt
  werden — aber nur, wenn die Aufteilung wirklich leichter zu lesen ist
- Früh zurückkehren statt verschachteln; mehr als drei Ebenen `if`,
  Schleife oder `try` sind ein Warnsignal
- Dem extrahierten Stück einen Namen geben, der sagt, was es tut, sodass
  sich der Aufrufer wie Prosa liest

## Es einmal sagen <a id="say-it-once"></a>

- Zwei nahezu identische Blöcke sind ein Block mit einem Parameter
- Den Helfer wiederverwenden, der im Repo schon existiert, statt einen
  zweiten zu schreiben
- Doppelte Imports, Test-Setups und kopierte Konstanten sind dasselbe
  Problem im Kleinen
- Dasselbe Konzept in zwei Modulen ist dasselbe Problem im Großen, siehe
  den [Architektur-Guide](./architecture-guide.md)

## Einheitlich benennen <a id="name-things-consistently"></a>

- Typen in PascalCase
- Private Member so markiert, wie die Sprache sie markiert
- Konstanten und Enum-Werte in lowerCamelCase
- Eine Testdatei nach der Datei benannt, die sie abdeckt

## Das vermeiden <a id="avoid-these"></a>

- Ein dynamisch typisierter Wert, wo ein echter Typ passt
- Öffentliche Felder verändern
- Ein TODO ohne Ticket-Verweis
- Auskommentierter Code, der „für später“ aufbewahrt wird — git ist die
  Historie
- Ein `Co-Authored-By`-Trailer in einem Commit
