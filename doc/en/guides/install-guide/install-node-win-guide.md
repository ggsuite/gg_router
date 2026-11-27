<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Install Node on Windows

- [Uninstall Node](#uninstall-node)
  - [Clean cache](#clean-cache)
  - [Run uninstaller](#run-uninstaller)
  - [Remove remaining Node folders](#remove-remaining-node-folders)
  - [Remove node path from PATH variable](#remove-node-path-from-path-variable)
- [Install NVM](#install-nvm)
- [Install Node via NVM](#install-node-via-nvm)

## Uninstall Node

We are using `nvm` to install and select Node versions.
If you have already installed `nvm`, you can skip this and the next step.

### Clean cache

[Microsoft](https://learn.microsoft.com/en-us/windows/dev-environment/javascript/nodejs-on-windows#install-nvm-windows-nodejs-and-npm)

```bash
npm cache clean --force
```

### Run uninstaller

Press `Windows`

Type `uninstall Node.js`

Click `Uninstall Node.js`

Follow the instructions

### Remove remaining Node folders

[Remove remaining Node folders](https://stackoverflow.com/questions/20711240/how-to-completely-remove-node-js-from-windows)

### Remove node path from PATH variable

Remove Node from the PATH variable:

Press `Windows`

Type `environment`

Click `Edit the system environment variables`

Click `Environment Variables`

In the `upper box`, select `PATH`

Click `Edit`

Search for the Node path

When existing, remove the entry

Close the dialog

## Install NVM

[Source](https://github.com/coreybutler/nvm-windows#installation--upgrades)

Open <https://github.com/coreybutler/nvm-windows/releases>

Download `nvm-setup.exe`

Execute `nvm-setup.exe`

Follow the instructions

## Install Node via NVM

Press `Windows`

Type `cmd` and press `Enter`

```bash
nvm install lts
nvm use lts
```
