---
name: write-tweet
description: >-
  Write high-engagement tweets about technical content, especially open source
  projects. Applies research-backed patterns from developer Twitter practitioners
  (swyx, kelseyhightower, rauchg, simonw, Supabase, Tailwind CSS, Vercel).
---

# Write a Technical Tweet

Use this skill to write one or more tweets about a technical feature, release,
bug fix, refactor, milestone, or concept — optimized for developer audience
engagement on Twitter/X.

## Usage

```
/write-tweet [topic, PR number, path/to/post.md, or "thread about X"]
```

### Input types

**PR number** — fetch context first. Auto-detect the repo from the working
directory (`gh repo view --json nameWithOwner -q .nameWithOwner`), or use
`--repo owner/repo` if provided:

```bash
gh pr view <number> --repo OWNER/REPO
```

**Markdown file (blog post)** — read the file, then extract:
1. The thesis / core insight (usually in the opening or conclusion)
2. The single most compelling metric or before/after in the post
3. The primary CTA link (docs, repo, or demo linked in the post)
4. Any code snippet that could serve as the "proof" tweet

A blog post tweet thread is not a summary — it's a hook that makes someone
want to read the full post. Lead with the most surprising finding, not the
topic. The thread's job is to give away enough value that clicking feels
necessary, not optional.

---

## Step 1: Classify the Announcement Type

Determine which type of content this is. The type dictates the hook and structure:

| Type | Hook element | Format |
|------|-------------|--------|
| **New project / launch** | Problem being solved | 5-7 tweet thread |
| **Performance improvement** | The ratio (e.g. 12x faster) | 3-5 tweet thread or single tweet |
| **New feature** | Visual proof (GIF/screenshot) or before/after | 3-4 tweets |
| **v2.0 / major release** | Honest critique of v1 | 6-8 tweet thread |
| **Bug fix (critical)** | "If you've seen X, here's why" | 2-3 tweets |
| **Refactor / cleanup** | Lines deleted, not lines changed | 3-4 tweets |
| **Deprecation** | Time-to-migrate, migration path up front | 3-4 tweets |
| **Milestone (stars, users)** | Journey / unexpected path, not just the number | 4-6 tweet thread |
| **Concept / TIL** | Discovery frame: "I just figured out..." | Single tweet or 2-3 tweets |

---

## Step 2: Write the Opening Tweet

The opener is the only tweet most people read. It must work completely standalone.

### Opening formulas that stop the scroll

Pick the formula that fits the content:

**Number + Outcome** (most reliable for performance/scale claims):
> "We rewrote our query engine in Rust. 12x faster. Here's what actually changed:"

**Before/After Teaser** (withholds the punchline):
> "Our CI pipeline used to take 22 minutes. It now takes 3. We changed one thing."

**TIL / Discovery frame** (removes expectation of expertise, invites curiosity):
> "TIL Python's dict.setdefault() exists. I've been writing 5-line patterns that are one line."

**Problem erasure** ("you can now stop doing X"):
> "You no longer have to configure X manually. Here's what we shipped instead:"

**Earned milestone** (journey framing):
> "After 2 years building in public, here's what I got wrong about open source distribution."

**Contrarian claim** (drives replies):
> "Most async errors in Python aren't async errors. Here's the pattern I keep seeing:"

### What kills openers — never do these
- "We're excited to announce…"
- "Today we're shipping…"
- "Check out our new…"
- Leading with a version number ("v2.3.1 is out")
- Starting with your project's name before establishing why it matters

### The 8-word rule
The first 8-10 words appear before "see more" on mobile. If the value isn't in those words, the tweet won't be expanded. Test your opener by reading just the first 8 words aloud.

---

## Step 3: Structure the Thread (if applicable)

Use this sequence for multi-tweet threads. Each tweet should be able to stand
alone as a screenshot.

**Tweet 1 — Hook**: The result, not the mechanism. One sentence max. Must work standalone.

**Tweet 2 — The Problem**: Name the pain in concrete terms. "Our checkout flow had a 3.2s LCP on mobile" beats "our site was slow." This earns audience empathy.

**Tweet 3 — The Failed Attempts** (optional, high-trust signal): What you tried that didn't work. Eliminates "why didn't you just…" replies preemptively.

**Tweet 4 — The Solution Mechanism**: What specifically changed. Be precise. "Switched to streaming responses" not "made it faster."

**Tweet 5 — The Proof**: The most shareable tweet. Screenshot, benchmark table, GIF, or before/after code. Numbers here, not in prose.

**Tweet 6 — The Broader Lesson**: Generalize the finding. "This works because..." Transforms an announcement into something worth bookmarking.

**Tweet 7 — CTA**: One link. See Step 5.

**Rules for threads:**
- Never end a mid-thread tweet with a complete thought — leave a gap the next tweet fills
- The most shareable tweet is usually #4 or #5, not the opener — write it to stand alone
- 4-7 tweets is the sweet spot; anything longer requires proportionate significance
- Number threads only when sequence matters (avoid "1/" when it's just for show)

---

## Step 4: Content Rules by Type

### Before/After (highest-engagement format for code changes)

The before code must be recognizably painful to the audience — not obscure-bad,
but bad in a way developers have written themselves.

```
Before: [painful, familiar code — keep it short]
After: [clean version]

What made this possible: [one-sentence mechanism]
```

For code tweets, recommend a Carbon/Ray.so screenshot over inline code for
anything 5+ lines. Note this to the user.

### Performance / Benchmark tweets

Always include:
- The ratio, not just the absolute number ("3x faster" > "300ms faster")
- Comparison baseline ("vs. the previous version" or "vs. [known alternative]")
- A methodology note or link (even a brief one — defuses credibility challenges)

Avoid:
- "Significantly faster" with no number
- Overly precise numbers that suggest cherry-picking ("47.3% faster")

### Bug fix tweets (critical severity)

Frame around user pain, not the fix:
> "We just fixed a bug that silently dropped writes under high memory pressure.
> If you've had mysterious data loss with [tool], this was probably why.
> Upgrading to 1.4.2 is strongly recommended."

The "this was probably why" retroactively resolves past user frustration — this
is the emotional hook.

### Dry technical content (refactors, config changes, infra)

Frame as a mystery, lesson, or near-miss rather than an event:

- **The debugging story**: "A memory leak that only appeared in production, only on Tuesdays, only when two flags were enabled."
- **The dumbest-possible-cause contrast**: "3 days of debugging. Root cause: a trailing space in a YAML key."
- **Lines deleted > lines added**: "Deleted 1,600 lines this week. Best PR review I've done."

### Milestone tweets

Never just the number. The milestone is the hook, the journey is the content:

> "50k GitHub stars. We started it in a weekend because we were frustrated with X.
> Here's what building in public actually looks like: [thread]"

---

## Step 5: Calls to Action

**What works:**
- The "try in 30 seconds" CTA: `npx create-[project] my-app`
- Stars as utility: "If this solves a problem you've had, a GitHub star helps others find it."
- Opinion solicitation: "The hardest part was X — curious if others solved it differently."
- Specific follow pitch: "We ship every 2 weeks. Following is the easiest way to see what we break next."

**What doesn't work:**
- "Check it out!" (no specific action)
- "Please star our repo to help us grow!" (charity framing)
- "RT if you found this useful" (begging, also algorithmically penalized)
- Multiple competing links

**One primary link maximum.** If there are multiple things to link, pick the one
that represents the next natural action for someone who just read the thread.

---

## Step 6: Tone and Voice Rules

- **"You can now do X"** beats **"We shipped X"** — lead with the user, not the product
- **"I"** outperforms **"we"** for individual maintainers; "we" is fine for team accounts
- **Specific > vague** always: "reduced cold start from 400ms to 40ms" beats "blazing fast"
- **One honest caveat** builds more trust than the rest of the thread combined
- **Authenticity markers**: acknowledge what this doesn't solve, mention migration complexity, name the thing you got wrong first
- Avoid buzzwords with no substance: "AI-native," "enterprise-ready," "developer-first" without evidence
- Never use exclamation points more than once per tweet

---

## Step 7: Format, Delivery, and Output File

For each tweet or thread, produce:

1. **The tweet(s)** — clearly separated, character counts noted
2. **Media recommendation** — what screenshot, GIF, or visual would make this land
3. **Timing note** — if relevant (release announcements on release day, Tue-Thu 9-11am for best reach)
4. **One alternative version** — a different hook formula if the first is risky or opinionated

Then write everything to a markdown file in the current working directory:

- **Filename convention**: `tweet-<slug>.md` where `<slug>` is a short kebab-case
  summary of the topic (e.g. `tweet-pr-676-m-decompose.md`, `tweet-constraint-validation.md`).
- If the argument was a PR number, use `tweet-pr-<number>-<short-title>.md`.
- If the argument was a markdown file, derive the slug from the filename.
- Use the Write tool to create the file. Do not ask — just write it.
- Tell the user the filename after writing.

### Output file format

```markdown
# Tweet: <topic>

> Source: <PR url, file path, or description>
> Date: <today's date>

---

## Primary thread

**Tweet 1** (~NNN chars)
[tweet text]

**Tweet 2** (~NNN chars)
[tweet text]

...

**Media:** [recommendation]
**Timing:** [recommendation]

---

## Alternative opener

[single tweet alternative]
```

Character counts:
- Single tweet: target 200-280 characters
- Thread opener: must work at 280 characters standalone
- Thread tweets 2+: 150-280 characters each

---

## Step 8: Self-Review Checklist

| # | Check |
|---|-------|
| 1 | Does the opener work **completely standalone** in 8-10 words? |
| 2 | Does it lead with **user benefit**, not product name or version? |
| 3 | Are all claims backed by **specific numbers**, not adjectives? |
| 4 | Is there exactly **one primary CTA** with one link? |
| 5 | Does it read like an **engineer wrote it**, not a brand team? |
| 6 | Is there at least one **honest caveat or limitation**? |
| 7 | Does the most shareable tweet (**#4-5**) work as a standalone screenshot? |
| 8 | Is the thread **4-7 tweets** unless the topic genuinely justifies more? |
| 9 | Is the before/after code **recognizably familiar** to the audience? |
| 10 | Is the CTA framed as **utility** ("helps others find it"), not a request? |

---

## Common Mistakes to Avoid

- **Announcing without demonstrating**: a tweet that describes a feature with no code, GIF, or benchmark forces the reader to take the claim on faith
- **Burying the proof**: the benchmark or before/after goes in tweet 2-3, not tweet 6
- **The press release opener**: any tweet that starts with "We're excited…" signals that an engineer didn't write it
- **Overly long threads for minor features**: length should match significance — a bug fix that deserves 2 tweets shouldn't get 10
- **Generic "what do you think?" CTA**: ask a specific, genuine question tied to the content if you want replies
- **Marketing copy voice**: "best-in-class," "game-changing," "enterprise-grade" — these activate developer skepticism immediately
