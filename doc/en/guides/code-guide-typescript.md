<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Code Guide — TypeScript

What the [Code Guide](./code-guide.md) means in a TypeScript package.
Read that one first; this only fills in the specifics.

## Lay out the package

- Make `src/index.ts` the barrel: license header, then only `export …`
  lines, no implementation
- Put the implementation in `src/<file>.ts`
- Name files in kebab-case after the main type they hold
- Mirror `src/` in `test/` one to one, each file as `<name>.spec.ts`

## Order the imports

- Node builtins first, then dependencies, then what belongs to this
  repo
- Prefer relative imports inside the package

## Shape the API

- Take an options object rather than a long positional list
- Mark what does not change `readonly`, and prefer `interface` for a
  shape a consumer implements
- Return `Promise<T>` from async code and handle errors with
  `try` / `catch` / `throw`
- Await every promise, or hand it to something that does — a floating
  promise loses its rejection

## Give every class an example

Offer a `static example(…)` that takes a partial options object and
fills in a working value for everything left out:

```ts
/** Creates an example user for tests and docs. */
static example(options: Partial<UserOptions> = {}): User {
  return new User({ name: 'Jane Doe', age: 42, ...options });
}
```

## Comment landmarks

- `// #####…` before a class, interface, type or enum
- `// ....…` before every documented method, getter or field block

## Document with TSDoc

- Every exported member carries a `/** … */` comment with a description
- Document parameters as `@param name - <description>`
- The types are in the signature — do not repeat them in the comment
- Add an example only when the call is not obvious

## Keep the lints strict

- Run `eslint` with `typescript-eslint`, plus the `tsdoc` and `jsdoc`
  plugins
- Keep `tsdoc/syntax` and `jsdoc/require-description` at `error`
- Turn on `strict` in `tsconfig.json`
- Let Prettier own the formatting: single quotes, semicolons, two
  spaces, trailing commas, 80 columns

## Name things consistently

| Construct | Style | Example |
| --- | --- | --- |
| Class, interface, type | PascalCase | `BlobStorage` |
| File | kebab-case | `blob-storage.ts` |
| Test file | `<filename>.spec.ts` | `blob-storage.spec.ts` |
| Function, variable | lowerCamelCase | `readItem` |
| Constant | lowerCamelCase | `carriageReturn` |
| Enum value | lowerCamelCase | `Status.success` |

## Avoid these

- `any` where a real type fits — reach for `unknown` and narrow it
- A non-null assertion (`!`) used to silence the compiler
- `export default` — named exports keep the barrel honest
- Double quotes
- A floating promise
