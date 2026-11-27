<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Authenticate against the Azure npm feed

Do this before your first `pnpm install`, and again whenever the token
expires.

## Create a personal access token

Open <https://dev.azure.com/<your-azure-devops-organization>/_usersSettings/tokens>

Click `New Token`

Enter a name that identifies your machine, e.g. `Dell XPS`

Check the scopes you need:

- `Work Items`: `Read`
- `Code`: `Read, write`
- `Build`: `Read`
- `Release`: `Read`
- `Test Management`: `Read`
- `Packaging`: `Read, write`

Click `Create`

Copy the token. It is shown only once.

## Encode the token

Run:

```bash
node -e "require('readline').createInterface({input:process.stdin,output:process.stdout,historySize:0}).question('PAT> ',p => { b64=Buffer.from(p.trim()).toString('base64');console.log(b64);process.exit(); })"
```

Paste the token and press `Enter`

Copy the encoded token. Reading the token from a prompt keeps it out of
your shell history.

## Write the token into your .npmrc

Open the file:

```bash
code ~/.npmrc
```

Replace an existing block for the same feed by the following, and paste
the encoded token over `[BASE64_ENCODED_PERSONAL_ACCESS_TOKEN]`:

```npmrc
; begin auth token
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/registry/:username=<your-azure-devops-organization>
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/registry/:_password=[BASE64_ENCODED_PERSONAL_ACCESS_TOKEN]
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/registry/:email=npm requires email to be set but doesn't use the value
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/:username=<your-azure-devops-organization>
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/:_password=[BASE64_ENCODED_PERSONAL_ACCESS_TOKEN]
//pkgs.dev.azure.com/<your-azure-devops-organization>/<your-azure-devops-project>/_packaging/<your-npm-feed>/npm/:email=npm requires email to be set but doesn't use the value
; end auth token
```

Save the file.

Keep the token in `~/.npmrc` only. Never commit it to a repository.
