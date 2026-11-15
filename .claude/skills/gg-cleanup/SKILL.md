---
name: gg-cleanup
description: Removes what a published ticket left behind — feature branches, the ticket folder, and a stale workspace. Use when the user says "/gg-cleanup" or asks to clean up after a release.
---

# Clean up after the publish

Run this only when the ticket is published. `gg do publish` already offers to
delete the ticket and its remote feature branches — if the user accepted
that, only step 4 is left.

## 1. Verify that everything landed

Per repo of the ticket:

```bash
git status --porcelain      # must be empty
git log origin/main --oneline -3
```

Stop and report if a repo still holds uncommitted or unmerged work.

## 2. Delete the feature branches

In every repo that still sits on its feature branch (never on `main`):

```bash
git rev-parse --abbrev-ref @{u} >/dev/null && git rev-list --count @{u}..HEAD
```

Stop and ask the user to push first if that count is not `0`.

```bash
git fetch
git checkout main
git pull origin main
```

A plain `git branch -d` refuses a squash-merged branch even though it is
fully in `main` — test it with a merge instead:

```bash
git merge --no-commit --no-ff <branch>
git status --porcelain
git merge --abort
```

- Empty status → the branch is fully in `main`: `git branch -d <branch>`.
- Non-empty status → not merged yet: `git checkout <branch>` and tell the
  user to (create and) merge a pull request first.

## 3. Remove the ticket folder

```bash
cd ~/dev/ # workspace
rm -rf tickets/GGS-145
```

## 4. Update the workspace

Pull `main` in the repos the ticket touched, so the workspace matches the
release.

## Important

- Never delete a ticket whose pull requests are still open.
- Ask before removing the ticket folder — it may still hold notes.
