---
name: gg-ticket
description: Creates a gg ticket and adds the repos it needs. Use when the user says "/gg-ticket", "new ticket", "fix bug X", or "implement feature Y".
---

# Create a ticket

All `gg do` commands run inside the workspace. Ask for the workspace
directory if none is known.

## 1. Ask for the ticket data

Ask for these three, one after the other, and give the user a single input
field per answer — one question per field, never all three in one question
and never as a plain prose question:

- Ticket ID, e.g. `GGS-145`
- Title, one imperative line, e.g. `Fix issue abc`
- Description, one or two sentences on what the ticket changes

## 2. Create the ticket

```bash
cd ~/dev/ # workspace
gg do create ticket GGS-145 -m"Fix issue abc"
cd tickets/GGS-145
```

## 3. Choose the project management repo — or work without one

A ticket may belong to a project management repo: plans, decisions and blog
posts of a project, no code. It is optional, so ask the user which way this
ticket runs:

- **with a project management repo** — read the `index.md` of the repos in
  `.ocean`, propose the one the ticket belongs to, and after the
  confirmation add it **before** any other repo:

  ```bash
  gg do add pm_repo
  ```

  Read `doc/guides/pm-repo-guide.md` of that repo if it exists: it says how
  the repo is structured and how planning works there. If none of the repos
  fits, ask whether to create one.

- **without a project management repo** — skip this step and go straight to
  the code repos. The ticket then carries no plan of its own.

Call it the "project management repo" whenever you write to the user, never
"PM repo".

## 4. Choose the code repos

Ask the user how the code repos are chosen, as a single question with two
options:

- **automatically** — Claude finds the repos. Read the `index.jsonc` of
  the candidate repos in `.ocean`. Tell the user which repos the ticket
  needs and what you roughly want to change in each one. Check each part
  against the scope of its repo and propose a split, a new repo or a move
  wherever a part does not fit (see
  [Keep every repo in its scope](#keep-every-repo-in-its-scope)).
- **manually** — the user names the repos. Ask in a second single input
  field which repos the ticket needs, e.g. `repo1 repo2`. Check each name
  against the repos in `.ocean` and ask again for names that do not exist
  there. The entered list is the confirmation.

A ticket that is only planned may need no code repo at all.

After the confirmation:

```bash
gg do add repo1 repo2
```

## 5. Open the workspace only on request

Do not open VS Code on your own — many tickets need no editor. Tell the
user they can open the workspace from the ticket folder with:

```bash
gg do code
```

Run it only when the user asks for it.

## 6. Plan or implement

If the project management repo keeps requirements (`doc/requirements`)
and no accepted requirement covers the ticket, engineer them with the user
first — with `/gg-plan-requirements` if the repo has it — before any plan or
code. Bug tickets are the exception, they name their bug file.

Ask the user whether the ticket is planned first. If yes, write the plan
into the project management repo as its `pm-repo-guide.md` describes (or as
its other guides do) and let the user confirm it. Without a project
management repo, put the plan into the ticket itself and let the user
confirm it there. Then ask whether the ticket is implemented now or only
planned — in the latter case the ticket ends with the project management
repo alone.

While implementing, write the code comments and documentation of a
dependency in its own terms: never name the repos of the ticket that use
it, nor their goal (section "Describe every repo in its own terms" of
`doc/guides/for-ai/ai-dev-guide.md`). Keep every repo in its scope: stop
and propose a split, a new repo or a move as soon as code does not fit (see
below). With every code change, check whether the `index.jsonc` of the repo
still matches and update it in the same step; a repo without one gets it
with its first change — section "Keep the index.jsonc up to date" of
`doc/guides/for-ai/ai-dev-guide.md` says when and how.

## Keep every repo in its scope

Every repo covers one fixed scope: the `summary` and `domain` of its
`index.jsonc`, or its README.md as long as it has none. From choosing the
repos until the review, propose a change on your own as soon as code does
not fit the repo it is in or is about to land in:

- **Split a repo** that has grown a second scope into two repos
- **Add a new repo** with `gg do create repo` for a domain no repo covers
- **Add an existing repo** with `gg do add` when the code belongs there
- **Move code**, existing or just written, into the repo whose scope it fits

Name the code, the repo it is in, the repo it should go to and why. Let the
user decide whether it changes now, within this ticket, or later, as a
follow-up ticket. After a change of scope, update the `index.jsonc` of each
repo concerned. Section "Keep every repo in its scope" of
`doc/guides/for-ai/ai-dev-guide.md` has the details.

## Important

- Never add repos without confirmation — a manually entered list counts as
  one. Rather too few than too many — more can be added later.
- Do not start the implementation unasked.
- Do not open VS Code unasked.
- Never split a repo, add or create one, or move code without the user's
  confirmation.
