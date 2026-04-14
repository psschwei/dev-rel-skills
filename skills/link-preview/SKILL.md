---
name: link-preview
description: >-
  Generate a link preview snippet for a blog post or article. Produces a
  markdown link card with an eye-catching code snippet, Open Graph meta tags,
  and a Twitter Card block so the post is ready to be embedded in other posts
  or shared on social platforms that render rich previews.
---

# Generate a Link Preview Snippet

Use this skill to produce a link preview for a post — either one of your own
drafts or an external article you want to reference. The output includes a
markdown-ready link card with a hero code snippet, Open Graph meta tags, and
a Twitter Card block.

This is the step between finishing a post and promoting it: before the tweet
thread, generate a preview snippet that other posts (yours or other people's)
can embed to drive traffic back. The preview must include a code snippet —
developers scroll past prose, but they stop for code.

## Usage

```
/link-preview [path/to/post.md or URL]
```

### Input types

**Local markdown file** (your own post) — read the file and extract the title,
description, canonical URL (from frontmatter), publication date, author, and
hero image. If the frontmatter is missing fields, infer them from the content
and note what was inferred.

**URL** — fetch the page with WebFetch and extract title, description, OG
image, site name, and any visible author/date. Note clearly that the content
is external.

If the argument is ambiguous (e.g., a path that doesn't exist and isn't a
URL), ask the user which they meant before proceeding.

---

## Step 1: Extract the Core Fields

A preview snippet needs these fields. For each, get the best version available
and note which source you used.

| Field | Priority order |
|-------|---------------|
| **Title** | Frontmatter `title` → first H1 → `<title>` tag → OG `og:title` |
| **Description** | Frontmatter `description` → first paragraph → meta description → OG `og:description` |
| **Canonical URL** | Frontmatter `canonical_url` / `permalink` → user-supplied URL → `<link rel="canonical">` |
| **Author** | Frontmatter `author` → byline in content → OG `article:author` |
| **Date** | Frontmatter `date` / `published` → visible byline date → OG `article:published_time` |
| **Hero image** | Frontmatter `image` / `cover` → first image in post → OG `og:image` |
| **Site name** | Frontmatter `site` → domain from URL → OG `og:site_name` |
| **Hero code snippet** | Frontmatter `preview_snippet` → most compelling fenced code block in the post → synthesized from the post's central example |

### Description rules

The description is the most load-bearing field — it's what decides whether
someone clicks. Do not just copy the first paragraph if that paragraph is a
setup or context dump.

- **Target length:** 140–180 characters. Under 120 looks truncated; over 200
  gets cut off on most platforms.
- **Lead with the payoff**, not the premise. "We cut p99 latency from 3.2s to
  800ms by switching to streaming responses" beats "Latency is a common
  problem in web applications."
- **Concrete over abstract.** Name specific tools, numbers, or outcomes.
- **No marketing voice.** If the draft says "we are excited to announce," the
  preview should say what the thing is.

If the post has no usable description, write one by pulling the thesis from
the opening and the single strongest result from the body.

---

## Step 2: Pick the Hero Image

The image is the preview's biggest visual element. Pick in this order:

1. An explicit frontmatter `image` or `og:image` — use as-is
2. A screenshot, diagram, or benchmark chart from the post — these convert
   better than stock photography
3. The first content image in the post — only if it's meaningful, not a
   decorative header
4. None — fall back to a site-wide default OG image

**Image spec:** 1200×630 is the correct OG image size. If the candidate image
is a different aspect ratio, flag it to the user rather than silently using
a distorted version.

If no image is available, say so explicitly in the output rather than
generating a placeholder.

---

## Step 3: Pick the Hero Code Snippet

The code snippet is the part of the preview that makes a developer stop
scrolling. A preview without code looks like marketing; a preview with the
right three lines of code looks like signal. Every preview this skill
produces **must** include a code snippet.

### What to pick

Walk through the fenced code blocks in the post and score each on:

1. **Payoff density** — does this block show the result the post is about?
   A benchmark output, a new API call, a before/after diff, or the one-liner
   the post builds toward. Pick the block that would make someone say "oh,
   that's what this does" without reading the post.
2. **Standalone readability** — can a developer understand the block without
   surrounding context? If it references variables defined elsewhere, either
   trim to the self-contained part or add a one-line comment naming what
   they are.
3. **Brevity** — aim for **3–10 lines**. Under 3 lines looks like a tagline;
   over 12 lines stops being scannable and starts looking like documentation.
4. **Language signal** — syntax-highlighted, recognizable language. If the
   post's examples are pseudocode, flag it — pseudocode makes a weaker
   preview than a real snippet.

### Preferred snippet shapes, in order

- **Before/after** (two tight blocks or a diff) — the highest-converting
  shape for refactors, API changes, and migrations
- **The one call that shows what the thing does** — e.g., the new public
  function being announced, used the way a reader would use it
- **A result block** — benchmark output, error message, or CLI output that
  proves the claim in the title
- **A configuration example** — only when the post's central point is
  configuration (otherwise configs read as dry)

### What not to pick

- Imports-only blocks or boilerplate setup
- Anything over 15 lines
- Code that needs three paragraphs of context to understand
- Output that is just `Hello, world` or a placeholder

### When the post has no good snippet

If the post truly lacks a usable code block (e.g., it's a narrative post
with only conceptual examples), synthesize a minimal one from the post's
central example — but only if the synthesis is faithful to what the post
describes. Mark synthesized snippets clearly in the Notes section of the
output, and ask the user to confirm before publishing.

---

## Step 4: Produce the Snippet Outputs

Produce all three formats in the output file. The user can copy whichever one
they need.

### 4a. Markdown link card

A ready-to-paste block for embedding the post inside another markdown file
(e.g., "further reading" sections or cross-posts). The card **must** include
the hero code snippet — that's the part that earns the click.

```markdown
> **[<Title>](<canonical URL>)**
> <Description>

```<language>
<hero code snippet>
```

> <Author> · <Date> · <Site name> · [Read →](<canonical URL>)
```

If there is also a hero image, place it above the title block:

```markdown
[![<Title>](<image URL>)](<canonical URL>)

> **[<Title>](<canonical URL>)**
> <Description>

```<language>
<hero code snippet>
```

> <Author> · <Date> · <Site name> · [Read →](<canonical URL>)
```

For platforms that strip fenced code out of blockquotes (some static site
generators do this), also produce an **all-in-blockquote variant** where the
code is indented inside the quote:

```markdown
> **[<Title>](<canonical URL>)**
> <Description>
>
> ```<language>
> <hero code snippet>
> ```
>
> <Author> · <Date> · <Site name> · [Read →](<canonical URL>)
```

### 4b. Open Graph meta tags

HTML `<meta>` tags ready to drop into the `<head>` of the post's page or a
site template. Always include these five at minimum:

```html
<meta property="og:type" content="article">
<meta property="og:title" content="<Title>">
<meta property="og:description" content="<Description>">
<meta property="og:url" content="<canonical URL>">
<meta property="og:image" content="<image URL>">
```

Add these when the data is available:

```html
<meta property="og:site_name" content="<Site name>">
<meta property="article:author" content="<Author>">
<meta property="article:published_time" content="<ISO 8601 date>">
```

### 4c. Twitter Card

Twitter/X renders its own card format. Use `summary_large_image` when a hero
image is available, otherwise `summary`.

```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="<Title>">
<meta name="twitter:description" content="<Description>">
<meta name="twitter:image" content="<image URL>">
```

If the user has a known Twitter handle (frontmatter `twitter` or similar),
add:

```html
<meta name="twitter:site" content="@<handle>">
<meta name="twitter:creator" content="@<handle>">
```

**Rendering the code on Twitter:** Twitter doesn't render code inside cards.
For posts where the code is the draw, recommend that the user screenshot the
hero code snippet (Carbon or ray.so, dark theme, include the language label)
and use that screenshot as the `twitter:image`. Note this to the user in the
output.

---

## Step 5: Character Limits and Truncation

Different platforms truncate differently. Note any fields that will get cut
off on specific platforms.

| Platform | Title limit | Description limit |
|----------|------------|-------------------|
| Open Graph (general) | ~90 chars | ~200 chars |
| Twitter/X cards | 70 chars | 200 chars |
| LinkedIn | ~70 chars (title shown), full description on expand | ~250 chars |
| Slack / Discord unfurls | Full title | ~300 chars |

If the title exceeds 70 characters, offer a shorter version as an
alternative. Never silently truncate — show the user both.

---

## Step 6: Write the Output File

Write the snippet to a markdown file in the current working directory.

- **Filename convention:** `link-preview-<slug>.md` where `<slug>` is derived
  from the input:
  - For a local post, use the filename without extension
    (`blog-pr-676-m-decompose.md` → `link-preview-pr-676-m-decompose.md`)
  - For a URL, use a short kebab-case slug of the title
    (`link-preview-streaming-responses.md`)
- Use the Write tool. Don't ask — just write it.
- Tell the user the filename after writing.

### Output file format

```markdown
# Link preview: <Title>

> Source: <file path or URL>
> Canonical URL: <canonical URL>
> Generated: <today's date>

## Extracted fields

- **Title:** <title> (<source, e.g., "from frontmatter">)
- **Description:** <description> (<N chars>)
- **Author:** <author>
- **Date:** <date>
- **Hero image:** <image URL or "none available">
- **Site name:** <site>
- **Hero code snippet:** <language>, <N lines> (<source, e.g., "extracted
  from post" or "synthesized — please review">)

## Markdown link card

<paste the block from 4a, including the hero code snippet>

## All-in-blockquote variant

<paste the blockquote-wrapped variant>

## Open Graph meta tags

```html
<paste the tags from 4b>
```

## Twitter Card

```html
<paste the tags from 4c>
```

**Social image recommendation:** If using the Twitter/X card, screenshot
the hero code snippet (Carbon or ray.so) and use it as `twitter:image`.

## Notes

<any issues: missing fields, truncation warnings, image aspect ratio
problems, inferred data, alternative shorter titles>
```

---

## Step 7: Self-Review Checklist

| # | Check |
|---|-------|
| 1 | Does the title work as a **standalone hook** without the description? |
| 2 | Is the description **140–180 characters** and leads with the payoff? |
| 3 | Is the canonical URL **absolute** (includes `https://`)? |
| 4 | Is the hero image URL absolute, not a relative path? |
| 5 | Are all OG tags **property=** (not **name=**) and Twitter tags **name=**? |
| 6 | Is the **title under 70 chars** for Twitter, or is a shorter version offered? |
| 7 | Does the markdown card read naturally as a **"further reading" block**? |
| 8 | Does the card **include a code snippet**, 3–10 lines, with a language tag? |
| 9 | Does the code snippet **stand alone** — readable without the post's context? |
| 10 | Is the code snippet the **payoff**, not setup or imports? |
| 11 | Are any **inferred fields** (where frontmatter was missing) clearly flagged? |
| 12 | Does the description avoid LLM tells (run `/de-llmify` mentally)? |
| 13 | Does the preview actually make someone want to **click**? |

---

## Common Mistakes to Avoid

- **Copying the first paragraph as the description**: first paragraphs are
  usually setup, not payoff. Rewrite from the post's strongest finding.
- **Leaving placeholder images**: if there's no image, say so. A broken or
  distorted preview image is worse than no image.
- **Relative URLs**: OG and Twitter tags require absolute URLs. A preview
  with `/images/hero.png` will render blank everywhere.
- **Using the same description as the post's intro**: the preview is meta
  content about the post, not a duplicate of its opening.
- **Title duplication in the description**: if the title is "We cut p99
  latency by 4x," the description should add new information, not restate
  the same claim.
- **Over-long titles**: 70+ character titles get truncated mid-word on
  Twitter. A 50-character title that fully renders beats a clever 90-char
  one that gets cut.
- **Picking boilerplate as the code snippet**: imports, class scaffolding,
  or `main()` wrappers are not the payoff. Go find the call that makes the
  post's point.
- **Code snippets without a language tag**: unlabeled code loses syntax
  highlighting on most renderers. Always include the language in the fence
  opener.
- **Oversized code blocks**: a 30-line snippet in a link card is a wall of
  text. Trim to the 3–10 lines that carry the point.

---

## Related Skills

- `/write-technical-blog` — draft the post first, then generate its preview
- `/release-blog` — release posts also benefit from a preview snippet
- `/write-tweet` — the tweet thread and the preview snippet together form
  the full promotion bundle for a post
- `/de-llmify` — run over the generated description if it reads formulaic
