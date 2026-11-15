---
name: test
description: Checks the tests of this repo against the test guide and reports gaps. Use when the user says "/test" or asks whether the tests are in shape.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Test

Read `doc/guides/test-guide.md` and follow it. Read the guide for the
language of this repo as well — `test-guide-dart.md` or
`test-guide-typescript.md` next to it — and apply whichever one matches
what the repo is written in.

## 1. Check the mirroring

List the source tree against the test tree and report every source file
without its own test file — coverage counts per file name.

## 2. Check the content

Report tests that assert element by element where a structural compare
belongs, printing in tests, objects built by hand where the class's
`example` would do, mocks that a constructor parameter could replace,
and coverage ignores on paths that dependency injection could
reach.

## 3. Run the checks

Run the repo's own commit check and report what fails. Stop before
changing anything.

## 4. Report before fixing

List the findings first. Fix only what the user confirms.
