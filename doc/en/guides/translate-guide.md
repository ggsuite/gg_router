<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Translate Guide

## Know the languages

- This repo keeps its documentation in these languages, the leading one
  first: `en`. Change them in the `vars` of `dna/_dna.json`,
  under the key `dna` + `Languages` written as one word, as two-letter
  codes separated by commas, e.g. `"en,de,fa"`
- Every language has its own folders: `doc/<lang>` for the documentation
  that belongs to no quarter, `pm/<lang>/<yyyy>-Q<n>` for what is planned
  and written in a quarter, e.g. the blog
- `README.md` is English, every other language has `README.<lang>.md`
- With one language only, there is nothing to translate

## Keep the languages in sync

- Create for each file of one language the corresponding file in every
  other language, same path below `doc/<lang>` or `pm/<lang>` and same
  file name
- Make sure a change in one language is translated into all others
- Use existing translated files
- Start documentation in the leading language; when the user talks another
  language, still write the leading language first
- Translate shortly before publishing
- Translate content- and structure-equal
- Do not translate commands, code, paths, APIs, IDs or file names
- Do not translate literally
- Never translate the guides and templates under `doc/<lang>/guides` and
  `doc/<lang>/templates`: the DNA layers ship them in every language

## Blog posts

- Start a post in the leading language, see the [Blog Guide](./blog-guide.md)
- Put each translation into `pm/<lang>/<yyyy>-Q<n>/blog` of its language,
  the same quarter and the same file name as the original
- Copy `doc/<lang>/templates/blog-template.md` of the language for a new
  post
- Follow the [Blog Guide](./blog-guide.md) for everything else
