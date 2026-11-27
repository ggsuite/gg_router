# Setup GitHub Guide

This guide sets up a GitHub repository with squash-only pull requests, a
protected default branch and a required quick check.

## 1. Add dna_github

```bash
gg dna add dna_github
gg dna build
```

This adds `scripts/setup-github-repo.js` and
`.github/workflows/quick_check.yaml` to your repository.

## 2. Merge the changes into main

Commit the changes, open a pull request and merge it into `main`. The quick
check workflow must exist on `main` before the branch rules can require it.

## 3. Preview the settings

```bash
node scripts/setup-github-repo.js
```

Prints the repository and the settings that would be applied, without
changing anything.

Requires the [GitHub CLI](https://cli.github.com) (`gh auth login`).

## 4. Apply the settings

```bash
node scripts/setup-github-repo.js --apply
```

This:

- allows only squash merges, enables auto merge and deletes branches after
  merge
- creates or updates the `Default` ruleset on the default branch: no deletion,
  no force push, linear history, pull requests required and the quick check
  must pass

Add `--require-review` to also require one approving review and resolved
review threads.
