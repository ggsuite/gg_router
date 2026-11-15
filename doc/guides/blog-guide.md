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

- Create a year folder `doc/blog/<yyyy>`, if not present
- Come up with a summarizing title for the ticket
- Derive a file name title from it, in english kebab case
- Copy `doc/templates/blog-template.md` to
  `doc/blog/<yyyy>/<yyyy>-<mm>-<dd>-<title-in-english-kebab-case>.md`

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

- This guide writes english posts only
- Posts in other languages are the job of the
  [Translate Guide](./translate-guide.md)
- Write english only, if that guide does not exist
