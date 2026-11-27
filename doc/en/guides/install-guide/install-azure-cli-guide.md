<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Install the Azure CLI

Install the Azure CLI when your repositories live in Azure DevOps. Skip
this guide otherwise.

## Install the command line

On Windows, run:

```bash
winget install --exact --id Microsoft.AzureCLI
```

On Mac, make sure [brew is installed](./install-brew-on-mac-guide.md) and
run:

```bash
brew install azure-cli
```

Restart your terminal and Vscode, so `az` is found.

Check the installation:

```bash
az --version
```

## Add the Azure DevOps extension

```bash
az extension add --name azure-devops
```

## Log in

```bash
az login
```

Press `Enter` when asked
`Select a subscription and tenant (Type a number or Enter for no changes)`.

Got an error saying you have no subscription? Log in with your tenant:

```bash
az login --tenant [TENANT ID] --allow-no-subscription
```

The error lists your tenants — take the long number and letter
combination, not the short name. Can't find it? Follow
<https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id>

## Set the default organization and project

```bash
az devops configure --defaults organization=https://dev.azure.com/<your-azure-devops-organization> project=<your-azure-devops-project>
```

Every later `az devops` command uses these defaults.

## Get access to the package feed

Packages come from an Azure Artifacts feed, not from the public registry.
Follow the [Azure npm feed guide](./install-azure-npm-feed-guide.md).
