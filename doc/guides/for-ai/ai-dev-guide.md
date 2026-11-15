<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Development guide for AIs

## Ask the developer for the ticket infos

Ask for these one after the other and give the developer a single input
field per answer — one question per field, never all of them in one
question and never as a plain prose question:

- Ask for the ticket ID
- Ask for the ticket title
- Ask for the ticket description

## Replace in this document

- Replace `~/dev/` by the workspace directory from the memory
- Ask for the workspace directory if none is known
- Replace `GGS-145` by the ticket ID you asked for
- Replace `Fix issue abc` by the ticket title you asked for

## Create a ticket

```bash
cd ~/dev/ # workspace
gg do create ticket GGS-145 -m"Fix issue abc"
cd tickets/GGS-145
```

## Choose the project management repo — or work without one

A ticket may belong to a project management repo. It holds the plans,
decisions and blog posts of a project, but no code. It is optional: ask the
user whether this ticket uses one. Write "project management repo" whenever
you write to the user, never "PM repo".

With a project management repo: look at the `index.jsonc` of each repo in
.ocean and find the one the ticket belongs to — its summary or domain talks
about project management or planning, not about code. If one fits, propose
it to the user. If none fits, ask the user which repo to use, or whether to
create a new one.

After the user's confirmation, add it to the ticket **before** any other
repo:

```bash
gg do add pm_repo
```

If it has `doc/guides/pm-repo-guide.md`, read it: it describes how the repo
is structured and how planning works there. If the file does not exist,
follow the guides that repo has.

Without a project management repo: skip this step and continue with the git
repositories. The ticket then carries no plan of its own.

## Add git repositories

Ask the user how the repos are chosen, as a single question with two
options: automatically or manually.

Manually: ask in a second single input field which repos the ticket needs,
e.g. `repo1 repo2`. Check each name against the repos in .ocean and ask
again for names that do not exist there. The entered list is the
confirmation; add the repos as shown below.

Automatically: look at the `index.jsonc` of each repo in .ocean and decide
which repos need to be added to the ticket.
Make a plan for how you roughly want to implement the ticket.
Check the plan against the scope of each repo (see
[Keep every repo in its scope](#keep-every-repo-in-its-scope)) and propose
a split, a new repo or a move wherever a part does not fit.
Also explain to the user what you roughly want to change in which repo to
implement the ticket and let them confirm that the corresponding repos are
added to the ticket.

If the ticket is only planned (see below), the project management repo may
be the only repo of the ticket.

After the user's confirmation, add the repos to the ticket:

```bash
gg do add repo1 repo2
```

## Keep every repo in its scope

Every repo covers one fixed scope: the `summary` and `domain` of its
`index.jsonc`. If a repo has none, take the scope from its README.md and
create the `index.jsonc` with the first change of the ticket in that repo
(see [Keep the index.jsonc up to date](#keep-the-indexjsonc-up-to-date)).
Code outside that scope blurs the repo. Check the scope whenever you decide
where code goes — while choosing the repos, while implementing and before
the review — and propose a change on your own, without being asked, as soon
as code does not fit the repo it is in or is about to land in:

- **Split a repo** — the repo has grown a second scope: propose splitting
  it into two repos, each with a scope of its own
- **Add a new repo** — the code belongs to a domain no repo in .ocean
  covers: propose creating one with `gg do create repo`, which adds it to
  the ticket
- **Add an existing repo** — the code belongs to a repo in .ocean that is
  not part of the ticket yet: propose adding it with `gg do add`
- **Move code** — existing code, or code you just wrote, belongs to another
  repo: propose moving it there

For each proposal, name the code concerned, the repo it is in, the repo it
should go to, and why it fits the scope of that repo better. Then let the
user decide:

- **Now** — change it within this ticket: add or create the repo, move the
  code, and adjust the dependencies and imports of both sides
- **Later** — keep it as a follow-up ticket: in the project management repo
  if the ticket has one, otherwise in the ticket. Continue with the code
  where it is.

Whenever the scope of a repo changes, update the `index.jsonc` of each repo
concerned (see
[Keep the index.jsonc up to date](#keep-the-indexjsonc-up-to-date)): a new
or split-off repo gets its own `summary` and `domain`, the repo that gives
code away is narrowed accordingly, and `interfaces.uses` and
`interfaces.usedBy` follow the new dependencies.

Never split a repo, add or create one, or move code without the user's
confirmation.

## Open the workspace in Vscode — only on request

Do not open VS Code on your own — many tickets need no editor. Tell the
user they can open the workspace from the ticket folder with the following
command, and run it only when the user asks for it:

```bash
gg do code
```

## Plan (optional)

Requirements come before the plan. If the project management repo keeps
requirements (`doc/requirements`) and none of its accepted requirements
covers the ticket, engineer them with the user first — with
`/gg-plan-requirements` if the repo has it — and plan the ticket only after
that. Bug tickets are the exception, they name their bug file.

Ask the user whether the ticket is planned before it is implemented.

If yes, write the plan into the project management repo, following its
`doc/guides/pm-repo-guide.md` if present, otherwise its other guides: the
goal, the requirements it fulfils, the affected repos, the rough steps and
open questions. Without a project management repo, put the plan into the
ticket itself. Let the user review the plan and revise it until they confirm
it.

## Implement (optional)

Ask the user whether the ticket is implemented now, or whether it is only
planned. Some tickets are only planned; the implementation follows in a later
ticket.

- Implement: implement your features based on the guides. Write the code
  comments and documentation of a dependency in its own terms, without its
  parents (see
  [Describe every repo in its own terms](#describe-every-repo-in-its-own-terms)).
  Keep every repo in its scope while you code: stop and propose a split,
  a new repo or a move as soon as code does not fit (see
  [Keep every repo in its scope](#keep-every-repo-in-its-scope))
- Plan only: skip this step. The following steps then apply to the project
  management repo only.

## Keep the index.jsonc up to date

The `index.jsonc` of a repo describes what the repo is: its `summary`, its
`domain` and its `interfaces`. Other agents choose the repos of a ticket by
it, so it must match the code at all times, not only at the review.

Whenever you change code in a repo, check whether its `index.jsonc` still
matches and update it in the same step:

- `summary` and `domain` — when the repo can do something new, no longer
  does something, or its scope changed
- `interfaces.uses` — when the repo starts or stops using another repo, or
  uses a different API of it
- `interfaces.usedBy` — when another repo starts or stops using this one;
  update the `uses` of that repo too, so both sides agree

A repo without `index.jsonc` gets one with the first change of the ticket,
whatever the change: copy `doc/templates/index-template.jsonc` to
`index.jsonc` and fill it from the README.md and the code. Never leave a
repo of the ticket without one.

Follow `doc/guides/index-guide.md`: keywords instead of sentences, the
fields of the template only. Once the file exists, a change that leaves all
three fields true — a bug fix, a refactoring inside the repo — needs no
update.

## Describe every repo in its own terms

A ticket often changes a repo together with one of its dependencies: the
parent repo uses the dependency. The dependency does not know its parents,
so what you write into it describes its own change only — never why a
parent needs it. This holds for everything you write into the dependency:

- commit messages, `nextCommitMessage` and `mergeMessage` — and with them
  the `CHANGELOG.md` entry and the pull request title
- blog posts
- code comments and documentation
- its `index.jsonc`, except `interfaces.usedBy`, which names the parents
  on purpose

Never name a parent repo there, nor the goal of the ticket or the use case
of the parent. The parent, in turn, may name the dependency and what it
uses of it.

- Wrong in `gg_git`: `Add remote creation for gg do create repo`
- Right in `gg_git`: `Add a function that creates a remote repository`
- Right in `gg`: `Create the remote repository with gg_git`

Which repo depends on which is in `interfaces.uses` of the `index.jsonc`,
and in `pubspec.yaml` or `package.json`.

## Keep the publish config up to date

Each repo of the ticket has a file `.gg/publish_config.json`. gg offers its
values as defaults: `gg do commit` pre-fills the commit message editor with
`nextCommitMessage`, `gg do publish` pre-selects `versionIncrement` and
pre-fills the merge message with `mergeMessage`. git ignores the file.

Whenever you change code in a repo, update `nextCommitMessage` of that repo
so it describes everything that is not committed yet, not only your last
step. Create the file if it does not exist. Change only the keys you mean
to change and keep the rest — `commits` is written by gg, never by hand.

```json
{
  "publishConfig": {
    "nextCommitMessage": {
      "firstLine": "Let the user pick the ticket repos",
      "details": ["Ask whether repos are chosen automatically or manually"]
    },
    "mergeMessage": "Let the user pick the ticket repos manually",
    "versionIncrement": "minor"
  }
}
```

- `firstLine`: imperative, at most 60 characters, in the terms of the
  repo itself (see [Describe every repo in its own terms](#describe-every-repo-in-its-own-terms))
- `details`: optional, one entry per line
- `mergeMessage`: the pull request title and the merge commit message of
  the repo
- `versionIncrement`: `patch`, `minor` or `major`, matching what the
  ticket changes in the repo

Set `mergeMessage` and `versionIncrement` as soon as the change of the repo
is clear, and adjust them when it changes. Only `gg do commit` in the
ticket folder reads `nextCommitMessage`; `gg one do commit` does not.

## Commit

```bash
gg do commit
```

Every repo gets its own message. When repos of the ticket depend on each
other, never commit them with one `-m` for all. Commit each repo on its own
with its `nextCommitMessage` (see
[Describe every repo in its own terms](#describe-every-repo-in-its-own-terms)):

```bash
cd repo1
gg one do commit -m"<nextCommitMessage of repo1>"
```

`gg do commit` without `-m` offers the same messages, but in an editor the
user has to confirm — leave that way to the user.

`gg do commit` and `gg can commit` act on all repos of the ticket. When you
are inside a single repo instead of the ticket folder, use the standalone
form on that repo:

```bash
gg one can commit
gg one do commit
```

## Push

```bash
gg do push
```

## Review

Check the diff of every repo of the ticket against its scope first (see
[Keep every repo in its scope](#keep-every-repo-in-its-scope)) and propose
a split, a new repo or a move for everything that does not fit.

Then document the change in every repo, so the documentation lands in the
pull requests and is reviewed with the code:

- Run `/blog` in every repo of the ticket that has
  `doc/guides/blog-guide.md`, the project management repo included. A
  dependency's post describes its own change, without its parents (see
  [Describe every repo in its own terms](#describe-every-repo-in-its-own-terms))
- Update the README.md, and check once more that every repo has an
  `index.jsonc` and that it matches the code of the ticket
- Commit and push again

Let the user confirm that the review phase is started.

```bash
gg do review
```

gg creates pull requests for each repo and prints the URLs to the
terminal.

Afterwards load the review-light skill and execute it.

## Publish

- Check `mergeMessage` and `versionIncrement` in `.gg/publish_config.json`
  of each repo — `gg do publish` offers them as defaults
- If the ticket was only planned, publish the project management repo only

Ask the user to run the following command **manually**:

```bash
gg do publish
```

gg triggers the pull request merge and publishes the changes to the
registry. Finally the version tag is created and pushed.
