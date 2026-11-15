---
name: gg-review
description: Writes the blog posts of the ticket, opens the pull requests with `gg do review` and reviews the changes. Use when the user says "/gg-review" or asks to review the current ticket.
---

# Review

Each repo documents its change first, so the documentation lands in the
pull requests and is reviewed with the code. Every commit after
`gg do review` voids the review.

## 1. Check the scope of every repo

Every repo covers one fixed scope: the `summary` and `domain` of its
`index.jsonc`, or its README.md if it has none. Read the diff of every repo
of the ticket against that scope. For code that does not fit, propose on
your own a split of the repo, a new repo, an existing repo to add, or a
move of the code into the repo whose scope it fits — with the reason. Let
the user decide whether it changes now, within this ticket, or later, as a
follow-up ticket. Section "Keep every repo in its scope" of
`doc/guides/for-ai/ai-dev-guide.md` has the details.

## 2. Document the change in every repo

Look for `doc/guides/blog-guide.md` in every repo of the ticket, the
project management repo included. It comes from the `dna_blog` layer.

- Run `/blog` in each repo that has it; skip the others
- A dependency's post describes its own change only: it never names the
  repos of the ticket that use it, nor their goal — section "Describe
  every repo in its own terms" of `doc/guides/for-ai/ai-dev-guide.md`
- `/blog` stops by itself when the post already exists

Update `README.md` of each repo the ticket changed. Check once more that
each of them has an `index.jsonc` — create it from
`doc/templates/index-template.jsonc` if not — and that it matches the code
of the ticket.

Let the user review the changes, then run `/gg-commit` and `/gg-push`.

## 3. Open the pull requests

Let the user confirm that the review phase is started. From the ticket
folder:

```bash
gg do review
```

gg creates a pull request for each repo and prints the URLs to the
terminal.

## 4. Review the changes

Load the `/review-light` skill and execute it.

A fix goes through `/gg-commit` and `/gg-push`, then run `gg do review`
again. Update the blog post of the repo when the fix changes what it
describes.

## Important

- Never write a blog post in a repo without `doc/guides/blog-guide.md`.
- Never start `gg do review` without the user's confirmation.
