# GitHub-Einrichtungsleitfaden

Dieser Leitfaden richtet ein GitHub-Repository mit reinen Squash-Pull-Requests,
einem geschützten Standard-Branch und einem verpflichtenden Quick Check ein.

## 1. dna_github hinzufügen <a id="1-add-dna_github"></a>

```bash
gg dna add dna_github
gg dna build
```

Das fügt dem Repository `scripts/setup-github-repo.js` und
`.github/workflows/quick_check.yaml` hinzu.

## 2. Die Änderungen in main mergen <a id="2-merge-the-changes-into-main"></a>

Committe die Änderungen, öffne einen Pull-Request und merge ihn in `main`.
Der Quick-Check-Workflow muss auf `main` existieren, bevor die Branch-Regeln
ihn verlangen können.

## 3. Die Einstellungen in der Vorschau prüfen <a id="3-preview-the-settings"></a>

```bash
node scripts/setup-github-repo.js
```

Gibt das Repository und die Einstellungen aus, die angewendet würden, ohne
etwas zu ändern.

Erfordert die [GitHub CLI](https://cli.github.com) (`gh auth login`).

## 4. Die Einstellungen anwenden <a id="4-apply-the-settings"></a>

```bash
node scripts/setup-github-repo.js --apply
```

Das:

- erlaubt nur Squash-Merges, aktiviert Auto-Merge und löscht Branches nach
  dem Merge
- legt das Ruleset `Default` auf dem Standard-Branch an oder aktualisiert
  es: kein Löschen, kein Force-Push, lineare Historie, Pull-Requests
  erforderlich und der Quick Check muss bestehen

Ergänze `--require-review`, um zusätzlich ein zustimmendes Review und
aufgelöste Review-Threads zu verlangen.
