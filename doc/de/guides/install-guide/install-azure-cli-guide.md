<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Azure CLI installieren

Installiere die Azure CLI, wenn die Repositories in Azure DevOps liegen.
Andernfalls überspringe diesen Guide.

## Kommandozeile installieren <a id="install-the-command-line"></a>

Unter Windows ausführen:

```bash
winget install --exact --id Microsoft.AzureCLI
```

Auf dem Mac sicherstellen, dass [brew installiert ist](./install-brew-on-mac-guide.md),
und ausführen:

```bash
brew install azure-cli
```

Terminal und Vscode neu starten, damit `az` gefunden wird.

Installation prüfen:

```bash
az --version
```

## Azure-DevOps-Erweiterung hinzufügen <a id="add-the-azure-devops-extension"></a>

```bash
az extension add --name azure-devops
```

## Anmelden <a id="log-in"></a>

```bash
az login
```

Bei der Frage
`Select a subscription and tenant (Type a number or Enter for no changes)`
`Enter` drücken.

Fehler, dass keine Subscription vorhanden ist? Mit dem Tenant anmelden:

```bash
az login --tenant [TENANT ID] --allow-no-subscription
```

Der Fehler listet die Tenants auf — nimm die lange Kombination aus Zahlen
und Buchstaben, nicht den kurzen Namen. Nicht zu finden? Folge
<https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id>

## Standard-Organisation und -Projekt festlegen <a id="set-the-default-organization-and-project"></a>

```bash
az devops configure --defaults organization=https://dev.azure.com/<your-azure-devops-organization> project=<your-azure-devops-project>
```

Alle späteren `az devops`-Befehle verwenden diese Standardwerte.

## Zugriff auf den Paket-Feed erhalten <a id="get-access-to-the-package-feed"></a>

Pakete kommen aus einem Azure-Artifacts-Feed, nicht aus der öffentlichen
Registry. Folge dem [Guide zum Azure-npm-Feed](./install-azure-npm-feed-guide.md).
