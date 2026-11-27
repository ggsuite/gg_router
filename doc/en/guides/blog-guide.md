<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Blog Guide

## Know which repos get a post

- Every repo of a ticket that has this guide gets its own post
- Write the post before publishing
- Follow the [Publish Guide](./publish-guide.md) if it exists

## Keep the post to this repo

- Write from the view of this repo alone
- Describe only what changed in this repo
- When dependencies were updated, name only the changes in them that
  matter for the work in this repo
- Never mention the repos that use this repo: a repo can be used by many
  parents and knows none of them
- Reference tickets and plans only if they belong to the organization of
  this repo

## Copy the template

- File the post in the quarter folder of the day the ticket is finished:
  `pm/<lang>/<yyyy>-Q<n>/blog`, `<lang>` being the leading language of the
  repo; create the folder if it is not present
- Come up with a summarizing title for the ticket
- Derive a file name title from it, in english kebab case
- Copy `doc/<lang>/templates/blog-template.md` to
  `pm/<lang>/<yyyy>-Q<n>/blog/<yyyy>-<mm>-<dd>-<title-in-english-kebab-case>.md`

## Content

- Follow the structure of the copied template
- Summarize the why, the how as well as the result
- Write simple and understandable
- Summarize the content in 60-100 lines
- Write longer for complex tickets
- Wrap lines at 80 characters
- Embed mermaid diagrams when needed
- Use mermaid ``` markdown blocks

## Other languages

- Write the post in the leading language of the repo first; the
  languages of the repo, leading one first, are `en`
- Translate it into the other languages with the
  [Translate Guide](./translate-guide.md): same file name, under
  `pm/<lang>/<yyyy>-Q<n>/blog` of each language
