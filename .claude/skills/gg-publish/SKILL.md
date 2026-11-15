---
name: gg-publish
description: Prepares the release of a reviewed ticket and hands `gg do publish` over to the user. Use when the user says "/gg-publish" or asks to release the ticket.
---

# Publish

`gg do publish` merges the pull requests, publishes to the registry and
creates and pushes the version tags. It is interactive — the user runs it.

## 1. Check the preconditions

- Every repo of the ticket is committed and pushed.
- The pull requests created by `gg do review` are green.
- Every repo with `doc/guides/blog-guide.md` holds the post of this ticket
  in `doc/blog/<yyyy>`. If one is missing, go back to `/gg-review`.

## 2. Configure the publish

Write per repo into `.gg/publish_config.json` (see the development guide):

- `mergeMessage` — the pull request title and merge commit message
- `versionIncrement` — `patch`, `minor` or `major`, matching what the
  ticket changed

`gg do publish` pre-fills the merge message and pre-selects the version
increment with these values. Never run `gg do configure-publish` yourself,
it is interactive. Check that `CHANGELOG.md` reads well.

## 3. Let the user publish

Ask the user to run this **manually** from the ticket folder:

```bash
gg do publish
```

It asks whether the ticket and the remote feature branches may be deleted.
If the user declines, run `/gg-cleanup` afterwards.

## Important

- Never run `gg do publish` yourself.
- Never write versions or tags by hand.
