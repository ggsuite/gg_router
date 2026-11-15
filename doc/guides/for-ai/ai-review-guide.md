<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Review

- Complain when translations are missing.
- Complain in the review when a public API was changed and it was not
  added to the README.md

## Architecture review (per change)

Architecture findings lie between files, so check the change as a whole:

- Read the recorded target picture and goals first (project management
  repo or `doc/architecture`) and judge the change against them; look
  beyond the changed files for an existing home of the concept.
- A feature added to a class or function whose concept it does not
  belong to; name the concept it belongs to instead. A new method that
  fits the concept is no finding.
- A new branch in a switch or `if` chain over kinds that the goals
  expect to grow and that is already switched on elsewhere.
- A new boolean or mode parameter that makes a function do two
  different jobs; a flag that only tunes one job is fine.
- A new dependency that points from the core towards UI, IO or a
  framework, or that closes a cycle.
- Logic that another module, a dependency (`interfaces.uses` in
  `index.jsonc`) or a repo in `.ocean` whose scope covers it already
  offers; name the place you found it in.
- A new abstraction with a single implementation that neither the
  ticket nor the recorded target picture asks for.
- Check these against `doc/guides/architecture-guide.md`; when the
  change shows the structure itself is off, suggest
  `/gg-review-architecture`.

## Review checklist (per changed file)

### Guides

- Walk through the guides in `doc/guides` and check what needs to be
  adjusted in the code so that all guides are fulfilled

### Redundancy / DRY

- Identical or nearly identical blocks in the diff or its direct
  neighborhood.
- Small helpers that already exist in the repo but are not reused.
- Duplicate imports, duplicate test setups, copied constants.

### Clarity

- Functions longer than ~10 lines — suggest extraction, but only if
  it is clearly more readable.
- Nesting deeper than 3 levels (`if`/`for`/`try`) — suggest
  early returns.
- Names that do not match the conventions or the purpose.
- Magic numbers / strings that would be clearer as named constants.

### Placeholder identifiers

- Bundle IDs, application IDs, package names, domains, URLs, mail and
  IP addresses of the organization in examples, tests or docs — replace
  them by `com.example.<app>`, `example.com` and the documentation IP
  ranges.

### Performance

- Awaiting inside a loop that could run in parallel.
- Repeated filter-and-collect chains in hot paths.
- Growing a collection element by element in a tight loop where the
  size is known up front.
- Subscriptions, timers and streams that are opened and never closed.
- Synchronous IO on an asynchronous path.
- Repeated parsing or computing that belongs outside the loop.

### Security

- Secrets in the diff: check for `API_KEY`, `SECRET`, `PASSWORD`,
  `TOKEN`, plus JWT-/Base64-like long strings in new lines.
- Starting a process with interpolated user input → shell injection
  risk.
- Input validation at system boundaries (HTTP handlers, CLI args).
- File paths from external sources without normalization →
  path traversal risk.
- New dependencies in the manifest: actively maintained? Known
  maintainers? Plausible score? If not assessable, report as a
  suggestion.

## Interactive fix loop

Walk through all blockers: show the patch per finding,
apply / skip / edit (edit = the user describes an
alternative, a new patch is proposed).
