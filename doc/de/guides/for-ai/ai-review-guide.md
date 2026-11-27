<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Review

- Bemängele fehlende Übersetzungen.
- Bemängele im Review, wenn eine öffentliche API geändert und nicht in die
  README.md aufgenommen wurde.

## Architektur-Review (pro Änderung) <a id="architecture-review-per-change"></a>

Architektur-Befunde liegen zwischen Dateien, daher die Änderung als Ganzes
prüfen:

- Zuerst das festgehaltene Zielbild und die Ziele lesen (Projektmanagement-
  Repo oder `doc/architecture`) und die Änderung daran messen; über die
  geänderten Dateien hinaus nach einem bestehenden Ort für das Konzept
  suchen.
- Ein Feature, das einer Klasse oder Funktion hinzugefügt wurde, zu deren
  Konzept es nicht gehört; stattdessen das Konzept nennen, zu dem es gehört.
  Eine neue Methode, die zum Konzept passt, ist kein Befund.
- Ein neuer Zweig in einem `switch` oder einer `if`-Kette über Arten, die
  laut den Zielen wachsen werden und über die schon anderswo verzweigt wird.
- Ein neuer Boolean- oder Modus-Parameter, durch den eine Funktion zwei
  verschiedene Aufgaben erledigt; ein Flag, das nur eine Aufgabe feinjustiert,
  ist in Ordnung.
- Eine neue Abhängigkeit, die vom Kern in Richtung UI, IO oder eines
  Frameworks zeigt oder einen Zyklus schließt.
- Logik, die ein anderes Modul, eine Abhängigkeit (`interfaces.uses` in
  `index.jsonc`) oder ein Repo in `.ocean`, dessen Scope sie abdeckt, schon
  anbietet; den Ort nennen, an dem sie gefunden wurde.
- Eine neue Abstraktion mit nur einer Implementierung, die weder das Ticket
  noch das festgehaltene Zielbild verlangt.
- Diese Punkte gegen `doc/en/guides/architecture-guide.md` prüfen; zeigt die
  Änderung, dass die Struktur selbst nicht stimmt, `/gg-review-architecture`
  vorschlagen.

## Review-Checkliste (pro geänderter Datei) <a id="review-checklist-per-changed-file"></a>

### Guides

- Die Guides in `doc/en/guides` durchgehen und prüfen, was im Code angepasst
  werden muss, damit alle Guides erfüllt sind

### Redundanz / DRY <a id="redundancy--dry"></a>

- Identische oder nahezu identische Blöcke im Diff oder in seiner direkten
  Umgebung.
- Kleine Helfer, die im Repo schon existieren, aber nicht wiederverwendet
  werden.
- Doppelte Imports, doppelte Test-Setups, kopierte Konstanten.

### Verständlichkeit <a id="clarity"></a>

- Funktionen länger als ~10 Zeilen — Extraktion vorschlagen, aber nur, wenn
  es klar lesbarer wird.
- Verschachtelung tiefer als 3 Ebenen (`if`/`for`/`try`) — Early Returns
  vorschlagen.
- Namen, die nicht zu den Konventionen oder zum Zweck passen.
- Magische Zahlen / Strings, die als benannte Konstanten klarer wären.

### Platzhalter-Bezeichner <a id="placeholder-identifiers"></a>

- Bundle-IDs, Application-IDs, Paketnamen, Domains, URLs, Mail- und
  IP-Adressen der Organisation in Beispielen, Tests oder Doku — durch
  `com.example.<app>`, `example.com` und die Dokumentations-IP-Bereiche
  ersetzen.

### Performance

- `await` in einer Schleife, die parallel laufen könnte.
- Wiederholte Filter-und-Sammel-Ketten in Hot Paths.
- Eine Collection Element für Element in einer engen Schleife wachsen lassen,
  obwohl die Größe vorab bekannt ist.
- Subscriptions, Timer und Streams, die geöffnet und nie geschlossen werden.
- Synchrones IO auf einem asynchronen Pfad.
- Wiederholtes Parsen oder Berechnen, das außerhalb der Schleife gehört.

### Sicherheit <a id="security"></a>

- Secrets im Diff: nach `API_KEY`, `SECRET`, `PASSWORD`, `TOKEN` sowie
  JWT-/Base64-artigen langen Strings in neuen Zeilen suchen.
- Einen Prozess mit interpolierter Benutzereingabe starten → Risiko einer
  Shell-Injection.
- Eingabevalidierung an Systemgrenzen (HTTP-Handler, CLI-Argumente).
- Dateipfade aus externen Quellen ohne Normalisierung → Risiko eines
  Path Traversal.
- Neue Abhängigkeiten im Manifest: aktiv gepflegt? Bekannte Maintainer?
  Plausibler Score? Falls nicht beurteilbar, als Vorschlag melden.

## Interaktive Fix-Schleife <a id="interactive-fix-loop"></a>

Alle Blocker durchgehen: pro Befund den Patch zeigen,
anwenden / überspringen / bearbeiten (bearbeiten = der Nutzer beschreibt eine
Alternative, ein neuer Patch wird vorgeschlagen).
