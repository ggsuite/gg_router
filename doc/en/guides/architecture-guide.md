<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Architecture Guide

How a repo is cut into parts, and how those parts grow. The
[Code Guide](./code-guide.md) holds the rules for a single file and
function; this guide holds the rules above them. Shape the structure the
way a senior developer would: from where the project is going, not only
from what it does today.

## Start from where the project is going

- Find out what role the repo plays: it holds a domain, it is CLI or glue
  over a domain held elsewhere, it is a library with consumers, or it
  follows another repo (port, mirror, fork, generated code). A repo that
  follows another one is judged by how cheaply it keeps following it;
  structural changes to the mirrored API belong upstream first. In a
  follower, structure that matches upstream is no finding; a deviation
  from upstream is
- Read the goals before the code: the project management repo (goals,
  requirements, the architecture of the current quarter) if there is one,
  the concept in `CLAUDE.md`, the README, open tickets (the ticket folders
  of the workspace with their `ticket.json`, open only while their branch
  is not merged, and the issues on the repo host) and `git log`. Read the
  CHANGELOG as the direction past work took, not as a list of goals
- Infer where the system will vary only from evidence you can name: an
  interface with one implementation waiting for more, a README section on
  extending it, files the history shows changing with every feature, a
  consumer that works around what it gets, an open ticket, or what the
  user states. An axis without evidence carries no recommendation; at most
  it becomes a question to the user
- Name the quality attributes that decide trade-offs here, only those the
  sources or the code show: target platforms in the manifest or CI,
  benchmarks, stored outputs, the fixes of recent releases. Check that no
  platform specific API blocks a named target platform
- Keep what the sources state apart from what you infer; an inferred goal
  is a hypothesis until someone confirms it
- With no goal sources, say so; the target picture is then the current
  structure plus fixes for what already costs today

## Cut along concepts

- One concept per module, one top level concept per package; split a
  module when its concepts have different users or change at different
  rates, not because of its size
- Name a module after the concept it holds, never after its technique
  (`helpers`, `utils`, `misc`, `common`)
- Let dependencies point one way: from the edges (UI, CLI, IO, network,
  framework) towards the core that holds the domain
- Find out first which package holds the domain; keep that core free of
  IO, UI and framework types. A CLI or glue package over a domain held
  elsewhere has no core of its own
- Allow no cycles between modules or packages

## Hide the inside

- Keep the public API small; everything a caller does not need is
  private
- Give every piece of state exactly one owner; others ask the owner
  instead of reaching into its data
- Hand out immutable values, not references to internal collections
- Inject clocks, IO, randomness and the environment where code would
  otherwise branch on a test flag or an environment variable
- Hide a third party library behind an interface of your own only where
  the goals name replacing it or its API keeps changing and leaks into
  many modules; not for the organisation's own packages or stable basics
  such as path or args

## Treat the public API and stored outputs as promises

- For a published package the public API is the most important boundary;
  find its consumers (`interfaces.usedBy` in `index.jsonc`, imports across
  `.ocean`, re-exports) before you judge or change it
- Public API nobody uses, and public API that exists only for tests, are
  findings once all consumers are known; for a package published outside
  the workspace, assume outside consumers and ask
- Outputs that are stored or sent (hash values, file formats, CLI output
  that scripts parse) are contracts too; pin them with golden tests
  before you restructure
- What consumers use is a contract; what they need and rebuild
  themselves is a goal

## Say each concept once

- The same idea implemented in two modules is one concept that is
  missing; give it a home and let both use it
- Rebuilding what a dependency or a sibling repo already offers is
  duplication across repos; use theirs, or make one of them the single
  home. Two implementations of one concept that give different results
  are a defect
- Give a shared piece a module of its own at the second consumer. When a
  consumer in another repo needs it, move it into the existing repo whose
  scope fits; create a new package only when none fits, and name its
  cost: publish chain, versions, DNA rollout
- Two places that change together for every new feature are one concept
  split in two
- Not every likeness is duplication: two pieces that look alike but
  change for different reasons stay apart; neither is code specialised
  for speed when a benchmark or a stated reason in the code backs it

## Grow by adding, not by editing

- Where the goals predict variation, put the smallest seam that carries
  it: a function parameter or a data table before an interface, an
  interface before a registry
- Add a new kind of thing as a new type that fulfils the interface,
  instead of a new branch in every switch over the kinds
- This holds for kinds the goals expect to grow; a switch over a closed
  set (the types of a language, the value kinds of a format such as JSON,
  a fixed protocol) stays a switch
- Keep the seam where the variation is, not one level above or below
- Configure behaviour through data where the variants differ only in
  values

## Do not build for imagined futures

- A structural change earns its place through a goal from `@goals` or
  through a cost that exists today and that you can show: a file the
  history shows changing with every feature, copies that have already
  drifted, a bug the structure caused. Keeping a hotspot cheap to change
  counts as a goal when the history shows work continues there. Without
  either, leave the structure as it is
- A seam needs a goal behind it; an abstraction with a single
  implementation and no goal that asks for a second one is a finding
- Prefer the simplest structure that carries the goals over the most
  general one
- Generic frameworks inside an application, layers that only pass calls
  through and options nobody sets are cost without return

## Decide where new code goes before you write it

- Read the recorded target picture, if the project has one, and place the
  code where it says
- Before you add to an existing file or class, ask whether the feature
  belongs to the concept it holds; if not, give it a module or type of
  its own
- When you are about to extend a switch over kinds, add a mode flag or
  copy a block, name the missing concept and add it instead
- Look for the concept in this repo, its dependencies and the repos in
  `.ocean` before you write it (see `@dry`)
- When the right place needs a structural change first, or lies in
  another repo, propose it and ask before you write

## Watch for structure that grew by accretion

Code grown feature by feature, especially by an agent, tends to bolt new
behaviour onto what is already there. Look for:

- A class or file that grows with every feature and knows a little of
  everything
- A switch or `if` chain over a kind expected to grow, repeated in
  several places
- A boolean or mode parameter that turns a function into two functions
- A whole module copied and slightly changed instead of shared
- UI or CLI code that reads storage, network or files directly
- Shared mutable state that several modules write to, such as static
  flags and counters, instead of state owned by an explicit context
- Work done when a module is imported
- Test hooks in the public API, or branches on `isTest` or environment
  variables in library code
- A dumping ground module that everybody imports
- Files that change together in most feature commits, leaving out tests,
  manifests, changelogs and barrels; a hint to read closer, not yet a
  verdict

## Change the structure in small steps

- Draw the target picture first, then plan the way there
- Make every step shippable: the tests stay green and the release works
  after each one
- Pin behaviour the tests do not cover with characterisation or golden
  tests before a structural step; move tests with the code where you can,
  and name the rewrite cost where tests assert CLI output or log text
- Put the new structure next to the old one, move the callers over, then
  delete the old one
- Change the structure and the behaviour in separate steps, never in the
  same commit
- Classify each step as breaking or not; when consumers outside the
  workspace may exist, deprecate before you remove and batch removals
  into one major release; when all consumers are in the workspace, update
  them in the same workspace ticket
- Order steps that span repos by the release chain, the providing package
  first, as one workspace ticket
- Record the target picture where the project keeps it, so the next
  change follows it
