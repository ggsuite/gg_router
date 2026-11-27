<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Blog-Leitfaden

## Wissen, welche Repos einen Beitrag bekommen <a id="know-which-repos-get-a-post"></a>

- Jedes Repo eines Tickets, das diesen Leitfaden hat, bekommt einen eigenen
  Beitrag
- Schreibe den Beitrag vor dem Veröffentlichen
- Folge dem [Publish-Leitfaden](./publish-guide.md), falls vorhanden

## Den Beitrag auf dieses Repo beschränken <a id="keep-the-post-to-this-repo"></a>

- Schreibe allein aus der Sicht dieses Repos
- Beschreibe nur, was sich in diesem Repo geändert hat
- Wurden Abhängigkeiten aktualisiert, nenne nur deren Änderungen, die für
  die Arbeit in diesem Repo zählen
- Erwähne nie die Repos, die dieses Repo nutzen: Ein Repo kann von vielen
  Parents genutzt werden und kennt keinen davon
- Verweise nur auf Tickets und Pläne, die zur Organisation dieses Repos
  gehören

## Die Vorlage kopieren <a id="copy-the-template"></a>

- Lege den Beitrag im Quartalsordner des Tages ab, an dem das Ticket fertig
  wird: `pm/<lang>/<yyyy>-Q<n>/blog`, wobei `<lang>` die Leitsprache des
  Repos ist; lege den Ordner an, falls er fehlt
- Finde einen zusammenfassenden Titel für das Ticket
- Leite daraus einen Dateinamen-Titel ab, in englischem Kebab-Case
- Kopiere `doc/<lang>/templates/blog-template.md` nach
  `pm/<lang>/<yyyy>-Q<n>/blog/<yyyy>-<mm>-<dd>-<title-in-english-kebab-case>.md`

## Inhalt <a id="content"></a>

- Folge der Struktur der kopierten Vorlage
- Fasse das Warum, das Wie und das Ergebnis zusammen
- Schreibe einfach und verständlich
- Fasse den Inhalt in 60–100 Zeilen zusammen
- Schreibe bei komplexen Tickets länger
- Brich Zeilen bei 80 Zeichen um
- Bette bei Bedarf Mermaid-Diagramme ein
- Verwende mermaid ``` Markdown-Blöcke

## Andere Sprachen <a id="other-languages"></a>

- Schreibe den Beitrag zuerst in der Leitsprache des Repos; die Sprachen
  des Repos, die Leitsprache zuerst, sind `en`
- Übersetze ihn mit dem [Übersetzungsleitfaden](./translate-guide.md) in
  die anderen Sprachen: gleicher Dateiname, unter
  `pm/<lang>/<yyyy>-Q<n>/blog` der jeweiligen Sprache
