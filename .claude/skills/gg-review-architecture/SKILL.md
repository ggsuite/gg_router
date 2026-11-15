---
name: gg-review-architecture
description: Reviews the architecture of this repo against its goals and the architecture guide, and proposes a target structure and the steps to get there. Use when the user says "/gg-review-architecture" or asks for an architecture review, a restructuring or how the structure should evolve.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# GG Review Architecture

Read `doc/guides/architecture-guide.md` and follow it. Read
`doc/guides/code-guide.md` as well; this review works one level above it.
If `doc/guides/architecture-guide.md` is missing, the DNA of this repo
is out of date: report that as the first finding and read the guide from
the `dna_clean_code` layer in `.ocean` instead. Do not stop.

Review the whole repo, not the current diff, and look beyond it where the
guide says so. Think like a senior developer who will still maintain
this code in two years.

## 1. Understand the goals and the role

Determine the role of the repo as `@goals` describes, with evidence. For
a repo that follows another, find the upstream (`interfaces.uses`, the
manifest description, a matching name in `.ocean`), the upstream version
it mirrors (tag, CHANGELOG, commit message) and the upstream releases
since; report that gap. Whether the repo keeps following is a goal;
without a source it is an inferred one.

If the DNA names a project management repo (see `pm-repo-guide.md`) or a
ticket does, read its goals, requirements and the architecture of the
current quarter (`doc/<yyyy>-Q<n>/architecture/architecture.md`); with
none, say so and go on.

Write a short list of where the project is going, each point marked as
stated (with its source) or inferred (I1, I2, ...). Carry inferred
points on as hypotheses and make every recommendation that rests on one
conditional ("only if I1 holds"). Collect the questions for the top of
the report. Stop and ask before step 2 only when one answer would turn
the whole review around, such as whether this repo may diverge from the
repo it follows, and no source answers it; otherwise name the assumption
and go on.

## 2. Measure and map the structure

Measure before you read in depth: lines per file, commits per file over
the last year or the whole history if shorter
(`git log --name-only --format=`, counted per file), files that change
together, and how many files import each one. Leave out the initial or
import commit, generated files, manifests, lockfiles, changelogs,
barrels and tests from every count. In a package of fewer than about ten
source files, read them all and skip the counts. When the files you look
at have only a handful of commits of their own (a port, a squashed
import), say so and use the upstream history.

Group the files into the concepts they hold; in a small package a
concept may be one file. List for each what it holds and what it depends
on. Take the public API at the package level. Draw the dependencies
between concepts as a mermaid diagram of at most fifteen nodes, only
when there are five concepts or more. In TypeScript, mark cycles that
exist only through `import type` apart from runtime cycles.

Check what `CLAUDE.md`, the README and existing architecture docs claim
about the structure against the code; a false claim is a finding.

## 3. Look at the neighbours

For each concept in the map, search the source files of the repos in
`.ocean` for its public symbol names and file names, skipping
`node_modules`, `.dart_tool`, `build` and `dist`; dependencies
(`pubspec.yaml`, `package.json`) and `index.jsonc` are shortcuts, not
the search. When a neighbour holds the same concept, run the same input
through both and set the `git log` of both copies side by side; a fix
that landed in only one copy is the evidence of cost. For a library,
find its consumers as `@contracts` describes; follow a re-export one
level further, and look one level further for target platforms and
stored outputs. Search only for the concepts of this repo; check each
concept you propose in step 5 the same way before you propose it.

A fix that belongs in another repo goes into the report as a proposal
for a workspace ticket; do not plan it in detail. Still name the release
order and the cost across repos.

## 4. Check and weigh

Check the structure against `@boundaries`, `@encapsulation`,
`@contracts`, `@dry`, `@extension`, `@yagni` and `@smells`, but report
by weight, not by section. Open with a verdict of two or three
sentences: is the structure the bottleneck for the goals at all, and if
so, the one decision that matters most, and the cheapest first step that
breaks nothing.

Report only what costs something against a goal from step 1 or today
(see `@yagni`). Back each cost with evidence: churn, the size of the
last comparable change, the number of places a new variant would touch.
Rank by cost and strength of evidence: a defect or a cost that exists
today comes before a cost that rests on an inferred goal. Show up to
three in detail and at most five more in one line each. Anchor each
finding where it can be checked: file and line or range with the symbol
named, a count of places for a spread finding, or the search you ran for
something missing. Cite only lines you opened in this session. List the
sections without a finding in one line ("checked, none: ..."); never
write a finding to fill a section.

List false claims about the structure (step 2) in one list of their own,
without a cost; they take no place among the top findings.

## 5. Design the target structure

Describe the structure that carries the goals: what moves where, which
seams to add or remove, and a new concept only where a goal asks for it.
The target may be the current structure. Draw it next to the current
diagram when it differs.

Weigh the change that costs the most against at least one alternative;
changing nothing always counts as one. Vary where the change lives
(here, in a dependency, upstream) as well as how far it goes. Give each
option its cost (packages, releases, breaking changes for consumers,
test rework), the quality attribute it trades against, and the point
from which it would win. For every other change, and for each rejected
option when the target is the current structure, one line is enough: the
goal or present cost it serves and the point from which it would win.
Drop a change that serves none.

## 6. Plan the steps

Order the changes into steps that are each shippable on their own, as
the guide describes under `@migration`. Name for each step what it
changes, which tests move, are added or pin behaviour, whether it breaks
a consumer, and which repo has to release first.

Keep defects and behaviour changes found on the way out of the
structural steps: mark each as read or tested, and plan it as a step of
its own (pin the behaviour, then fix) or as a ticket proposal. A missing
upstream feature is a ticket proposal, not a step.

## 7. Report before changing

Present the verdict, the questions, the findings, the target picture and
the steps. Change nothing yet.

Once the user confirms, record the target picture only if it takes more
than one step or spans repos, where the project already keeps it: this
repo's section in the project management repo's current
`architecture/architecture.md` (follow its `pm-repo-guide.md`, and only
if it is checked out locally; otherwise hand the section over in the
report), else an existing architecture doc
(`doc/architecture/architecture.md`, `README.architecture.md`); create
`doc/architecture/architecture.md` only if none exists, with the
diagrams as `.mmd` files in `img` next to it. Let `CLAUDE.md` link to it
instead of repeating it.

Record each confirmed decision, including tempting options you rejected,
even when the target is the current structure: in the project management
repo's `concepts/decisions`, else in a "Decisions" section of that file.
Correct, or replace with a link, every structural claim in `CLAUDE.md`
that is false or repeats the record; leave behaviour notes alone.

Implement the confirmed steps one at a time, each as its own commit with
the commit check of the repo; stop when a check fails or a step turns
out different from the plan.
