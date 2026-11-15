---
name: blog
description: Writes the blog post for the current ticket from the blog guide and template. Use when the user says "/blog" or asks for a post about the change.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Blog

Read `doc/guides/blog-guide.md` and follow it.

## 1. Check whether a post is missing

Look at the commits of this repo in the current ticket.

Report whether `doc/blog/<yyyy>` already holds a post for this change.

Stop here and report when it does.

## 2. Write the post

Copy `doc/templates/blog-template.md` and fill it in. Posts in other
languages follow the translate guide.

Describe only this repo: its own changes and what updated dependencies
changed for it. Never mention the repos that use it.

Summarize the why, the how and the result in 60-100 lines, wrapped at 80
characters.

## 3. Show the result

Name the file you wrote, then let the user review before committing.
