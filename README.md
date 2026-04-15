# dev-rel-skills

A collection of Claude Code agent skills for developer relations work. These skills automate the repetitive parts of dev-rel: finding what's worth writing about, drafting blog posts, and promoting content on social media.

## Skills

> **Target repo resolution.** Skills that hit GitHub use `--repo owner/repo` if passed, otherwise auto-detect from the current working directory's git remote (`gh repo view --json nameWithOwner`). Running any skill inside a cloned repo "just works" — no config needed.

### `/hn-scout`

Scans the Hacker News front page for AI-related posts and evaluates each for mellea integration or demo potential. Scores posts on fit (how naturally mellea applies) and buzz (how much visibility it could get) and generates concrete demo ideas for top-scoring opportunities. **This variant is hand-tuned for mellea.** For any other project, use `/hn-scout-generic`. Writes output to `hn-scout-YYYY-MM-DD.md`.

```
/hn-scout [--top N]
```

### `/hn-scout-generic`

Same as `/hn-scout`, but infers the target project's capabilities from its README at runtime so it works for any repo. Use this in any project that isn't mellea. Writes output to `hn-scout-YYYY-MM-DD.md`.

```
/hn-scout-generic [--repo owner/repo] [--top N]
```

### `/get-blog-candidates`

Fetches merged PRs from the current repo and ranks them by blog/demo potential. Detects whether the repo uses Conventional Commits, labels, or free-form PR titles and picks a scoring rubric to match. Outputs a ranked table with a "Top picks" callout so you can quickly decide what to write about next.

```
/get-blog-candidates [--repo owner/repo] [--since YYYY-MM-DD] [--until YYYY-MM-DD] [--limit N]
```

### `/release-blog`

Takes the latest GitHub release, scores all its PRs by blog-worthiness, identifies a narrative theme, and drafts a full release blog post. Highlight-tier PRs get their own sections with before/after code; lower-scoring PRs are grouped into an "Other Improvements" section. Auto-detects the repo's package ecosystem (pip, npm, cargo, go, gem, maven/gradle) to emit the right upgrade command. Writes the result to `blog-release-vX.Y.Z.md`.

```
/release-blog [--tag vX.Y.Z] [--repo owner/repo]
```

### `/write-technical-blog`

A structured guide for writing a deep-dive technical blog post about a single feature, capability, or PR. Covers post types (narrative, feature announcement, tutorial, retrospective), required structure (hook → motivation → walkthrough → trade-offs → CTA), code example rules, tone guidelines, and an SEO checklist. Writes the draft to a `blog-<slug>.md` file.

```
/write-technical-blog [topic or PR number or description]
```

### `/write-tweet`

Writes high-engagement tweets or threads about technical content. Classifies the announcement type (new feature, performance improvement, major release, etc.), applies opening formulas that stop the scroll, and structures multi-tweet threads so each tweet stands alone. Writes output to `tweet-<slug>.md` with character counts, media recommendations, and an alternative opener.

```
/write-tweet [topic, PR number, path/to/post.md, or "thread about X"]
```

### `/validate-snippets`

Extracts every fenced code block from a markdown file, executes each one, and reports which pass, fail, or were skipped. Supports Python, Go, JavaScript, TypeScript, and shell. Non-code blocks (JSON, YAML, output, etc.) are automatically skipped. Writes a detailed report and offers to fix failing snippets in place.

```
/validate-snippets <path/to/file.md>
```

### `/de-llmify`

Edits a piece of writing to remove patterns commonly associated with LLM-generated text — hollow openers, filler transitions, over-explained structure, hedge stacking, and corporate-speak. Based on Kobak et al. 2024 research and developer community observations. Pass a file path or inline text.

```
/de-llmify [path/to/file.md or inline text]
```

### `/link-preview`

Generates a link preview snippet for a post — markdown link card (with an eye-catching code snippet), Open Graph meta tags, and Twitter Card block. Takes a local markdown file or a URL, extracts the title, description, author, date, hero image, and the most compelling fenced code block from the post, and produces ready-to-paste snippets for embedding elsewhere. Writes output to `link-preview-<slug>.md`.

```
/link-preview [path/to/post.md or URL]
```

## Setup

Run the install script to symlink all skills into `~/.claude/skills/`:

```bash
./install-skills.sh
```

This creates a symlink in `~/.claude/skills/` for each skill directory in `skills/`. Existing symlinks are updated; non-symlink conflicts are skipped.

## Workflow

A typical dev-rel workflow using these skills:

1. **Scout trends** — run `/hn-scout` to find trending AI topics where your project has a natural angle
2. **Find candidates** — run `/get-blog-candidates` to see what merged recently and what's worth writing about
3. **Draft content** — use `/release-blog` for release summaries or `/write-technical-blog` for deep dives on a single feature
4. **Validate** — run `/validate-snippets` on the draft to make sure all code examples actually work
5. **Polish** — run `/de-llmify` on any generated content to remove AI writing tells before publishing
6. **Preview** — run `/link-preview` on the finished post to produce a link card and OG meta tags that make other posts want to link back
7. **Promote** — run `/write-tweet` on the resulting blog post file to generate a thread that drives readers to it