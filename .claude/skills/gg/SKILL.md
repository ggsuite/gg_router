---
name: gg
description: Lists the skills of the gg workflow and says which one comes next. Use when the user says "/gg", asks which gg skills exist, or asks how the gg workflow continues.
---

# The gg workflow skills

Every skill of this workflow carries the `gg-` prefix. Print the list
below, in this order — it is the order of a ticket's life.

- `/gg-ticket` — creates a ticket and adds the repos it needs
- `/gg-commit` — proposes a message and commits through `gg do commit`,
  or `gg one do commit` inside a single repo
- `/gg-push` — pushes the ticket branches with `gg do push`
- `/gg-review` — writes the blog posts, opens the pull requests with
  `gg do review` and reviews the changes
- `/gg-publish` — prepares the release and hands `gg do publish` over to
  the user
- `/gg-cleanup` — removes what the published ticket left behind

A repo may carry more `gg-` skills than these. Look at
`.claude/skills/gg-*` and add what you find there, with the `description`
of its `SKILL.md` as the text.

## Say which skill comes next

Read the state of the current ticket and name the next step:

- No ticket folder yet → `/gg-ticket`
- Uncommitted work → `/gg-commit`
- Committed, not pushed → `/gg-push`
- Pushed, no pull requests yet → `/gg-review`
- Reviewed and the pull requests are green → `/gg-publish`
- Published → `/gg-cleanup`

## Important

- Only list the skills, never run one of them unasked.
