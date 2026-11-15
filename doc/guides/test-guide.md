<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Test Guide

Tests are mandatory, not a recommendation: the commit check refuses every
commit that is not at 100 percent coverage or has a red test. The rules
that only make sense in one language live next door:
[Dart](./test-guide-dart.md), [TypeScript](./test-guide-typescript.md).
For the structure of the code under test see the
[Code Guide](./code-guide.md).

## Mirror the source tree

- Every source file gets its own test file, named after it — coverage
  counts per file name
- A file in a subfolder keeps that subfolder in the test tree
- Open the test file with the license header

## Import through the public API

- Import your own package through its entry point, the way a consumer
  does
- Reach into the internals only to test a helper that is deliberately
  not exported

## Nest by what is under test

- Group by the member under test, then by the case
- Name a group after the signature it covers, e.g. `subList(start, end)`
- Let one test cover one behaviour; several assertions are fine when
  they establish that one behaviour together

## Set up with closures, not with a helper module

- Reset shared state before each test
- Release external resources afterwards
- Put reusable setup into a local closure inside the test file
- Do not build a helper module and do not inherit from a base test class

## Loop instead of parametrizing

- Wrap the test call in a loop to cover several inputs
- Put the varying value into the test name

## Start from the example

- Build objects through their `example` constructor and pass only the
  values the test is about
- When a class has no example yet, add one instead of building the
  object by hand in the test

## Prefer real types over mocks

- Let constructors take their dependencies as optional parameters, then
  test without mocks
- Pass a function where a class would need a mock
- Reset a test singleton before each test and clear it afterwards
- Reach for a mocking library only when nothing else works

## Assert on structure

- Compare whole collections at once instead of asserting element by
  element
- Assert on the type and the message of an expected error, not just that
  something was thrown
- Never print in a test — capture the output instead

## Reach 100 percent coverage

- Mark a genuinely unreachable line with the ignore comment of the
  coverage tool
- Ignore only what cannot be reached, not what is inconvenient
- Test the path instead when dependency injection can reach it

## Validate before you commit

Run the checks yourself before pushing — analysis, formatting and the
full test run all have to be clean.
