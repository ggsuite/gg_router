<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Code Guide

What holds in every language we write. The rules that only make sense in
one of them live next door: [Dart](./code-guide-dart.md),
[TypeScript](./code-guide-typescript.md). For tests see the
[Test Guide](./test-guide.md), for how a repo is cut into parts the
[Architecture Guide](./architecture-guide.md).

## Lay out the package

- Name the package after the repo
- For how the package is cut into concepts, see the
  [Architecture Guide](./architecture-guide.md) under `@boundaries`
- Expose the package through a single entry point that re-exports and
  holds no implementation of its own
- Name a file after the main type it holds
- Mirror the source tree in the test tree one to one

## Open every file with the license header

- Copy the header from a neighbouring file
- Follow it with a blank line, then the imports

## Order the imports

- Runtime and standard library first, then third-party packages, then
  what belongs to this repo
- Sort each group alphabetically and separate the groups by a blank line

## Order the members of a type

- Constructors first, each with a doc comment
- Alternative constructors next
- Public methods, grouped by what belongs together, not alphabetically
- Public fields and getters, immutable by default
- Static constants and methods
- Private members last

Avoid mutability: change state through copy-with methods instead of
setters.

## Shape the API

- Use named parameters by default, positional only for a trivial single
  argument
- Give parameters sensible defaults
- Return a promise or future from async code and handle errors
  explicitly — never swallow them
- Await every asynchronous call, or mark deliberately that you do not

## Give every class an example

- Offer an `example` constructor that builds a valid instance without a
  single argument
- Make each of its parameters optional, so a caller overrides only the
  values that matter to them
- Fill everything else with realistic values, not with empty strings and
  zeros
- Use the example in tests, docs and other examples instead of building
  the object by hand
- Leave it out only where nothing can be instantiated: abstract types,
  enums and purely static helpers

## Keep real identifiers out of examples

- Write `com.example.<app>` wherever an example, test or doc needs a
  bundle ID, application ID or package name
- Write `example.com`, `example.org` or `example.net` for domains, URLs
  and mail addresses such as `user@example.com` — they are reserved for
  documentation (RFC 2606, RFC 6761)
- Write `192.0.2.x`, `198.51.100.x`, `203.0.113.x` or `2001:db8::` for IP
  addresses (RFC 5737, RFC 3849)
- Never take an identifier of the organization, such as
  `com.<organization>.<app>` or the domain of the organization — an
  example must neither collide with a real app nor look like one
- Keep real identifiers in the configuration of the real app only

## Separate sections with comment landmarks

- A `#####` rule before a class, enum or other top level construct
- A `.....` rule before every documented method, getter or field block
- A named `#####` block inside a large type to mark a section

Keep the style as it is — do not invent variants.

## Document every public member

- Give each public member a doc comment
- Start with one complete sentence in third person indicative
- Document parameters on the following lines
- Add an example only when the call is not obvious

## Keep functions small and flat

- A function that outgrows roughly ten lines wants to be split — but only
  when the split is genuinely easier to read
- Return early instead of nesting; more than three levels of `if`, loop
  or `try` is a smell
- Give the extracted piece a name that says what it does, so the caller
  reads as prose

## Say it once

- Two nearly identical blocks are one block with a parameter
- Reuse the helper that already exists in the repo instead of writing a
  second one
- Duplicated imports, test setups and copied constants are the same
  problem in small
- The same concept in two modules is the same problem in large, see the
  [Architecture Guide](./architecture-guide.md)

## Name things consistently

- Types in PascalCase
- Private members marked the way the language marks them
- Constants and enum values in lowerCamelCase
- A test file named after the file it covers

## Avoid these

- A dynamically typed value where a real type fits
- Mutating public fields
- A TODO without a ticket reference
- Commented out code kept "for later" — git is the history
- A `Co-Authored-By` trailer in a commit
