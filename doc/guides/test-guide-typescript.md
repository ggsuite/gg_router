<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Test Guide — TypeScript

What the [Test Guide](./test-guide.md) means in a TypeScript package.
Read that one first; this only fills in the specifics.

## Mirror the source tree

- `src/foo.ts` goes to `test/foo.spec.ts`
- `src/sub/bar.ts` goes to `test/sub/bar.spec.ts`
- Open the file with the license header

## Import through the public API

- Import `describe`, `it` and `expect` from `vitest`
- Import your own package through `src/index.ts`
- Reach into `src/…` directly only to test a helper that is deliberately
  not exported

## Nest with describe and it

- `describe(…)` by the member under test, `it(…)` per case
- Phrase the `it` so that name and description read as one sentence

## Set up with closures

- Reset shared state in `beforeEach`
- Release external resources in `afterEach`
- Put reusable setup into a local closure inside the spec file

## Start from the example

- `const user = User.example({ age: 17 });`

## Prefer real types over mocks

- Pass a function where a class would need a mock
- Reach for `vi.mock` only when nothing else works, and restore with
  `vi.restoreAllMocks`

## Assert on structure

- Compare whole objects with `toEqual`, not field by field
- Check errors with `await expect(fn()).rejects.toThrow(…)` — a rejected
  promise that nobody awaits passes silently
- Never `console.log` in a test

## Reach 100 percent coverage

- Run `vitest run --coverage`
- Mark a genuinely unreachable line with `/* v8 ignore next */`, a block
  with `/* v8 ignore start */` and `/* v8 ignore stop */`

## Validate before you commit

```bash
pnpm test
```

`vitest`, `eslint` and the Prettier check all have to be clean.
