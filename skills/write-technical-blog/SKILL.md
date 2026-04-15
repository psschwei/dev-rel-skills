---
name: write-technical-blog
description: >-
  Guide for writing a good technical blog post about a new code feature,
  capability, or release. Synthesizes best practices from Stripe, GitHub,
  Cloudflare, HashiCorp, and Google engineering blogs.
---

# Write a Technical Blog Post

Use this skill when drafting or reviewing a technical blog post about a new
code feature, capability, or release. Apply the checklist and structure below
to produce a post that is credible, scannable, and genuinely useful to
developers.

## Usage

```
/write-technical-blog [topic or PR number or description]
```

If given a PR number, fetch its title, description, and changed files first.
Determine the target repo in this order:

1. Use `--repo owner/repo` if the user supplied one.
2. Otherwise auto-detect from the current working directory:
   `gh repo view --json nameWithOwner -q .nameWithOwner`.
3. If auto-detection fails, ask the user.

Then run:

```bash
gh pr view <number> --repo OWNER/REPO
```

and apply the framework below.

---

## Working from Source Material

If given a file path as input, extract text from it before proceeding:

- **PDF**: use the Read tool directly — Claude can read PDFs natively.
- **PowerPoint (.pptx)**: convert to markdown with pandoc, then read the result:
  ```bash
  pandoc path/to/file.pptx -o /tmp/slides.md
  ```
  Then use the Read tool on `/tmp/slides.md`. To work with a specific slide
  range, grep for the slide headings or read the relevant line range.
  If pandoc is not available, fall back to `python-pptx`:
  ```bash
  python3 - <<'EOF'
  from pptx import Presentation
  prs = Presentation("path/to/file.pptx")
  for i, slide in enumerate(prs.slides, start=1):
      texts = []
      for shape in slide.shapes:
          if shape.has_text_frame:
              for para in shape.text_frame.paragraphs:
                  line = " ".join(run.text for run in para.runs).strip()
                  if line:
                      texts.append(line)
      print(f"\n--- Slide {i} ---")
      print("\n".join(texts) if texts else "(no text)")
  EOF
  ```
- **Other formats**: ask the user to export to PDF or paste the text.

Once text is extracted, proceed with the steps below.

---

## Step 1: Identify the Post Type

Before writing anything, determine which type of post this is:

| Type | Use when | Key difference |
|------|----------|----------------|
| **Narrative / deep-dive** | New capability, architecture change, design decision | Story arc: problem → journey → solution |
| **Feature announcement** | New API, new option, meaningful improvement | Lead with outcome; include before/after |
| **Tutorial / how-to** | Walk a reader through using a feature end-to-end | Goal-oriented; every step is runnable |
| **Retrospective / postmortem** | Design history, trade-offs, lessons learned | Honest; show failures alongside wins |

> A changelog entry and a blog post are different documents. A changelog is a
> factual, scannable record of what changed (Added / Changed / Fixed). A blog
> post explains *why* it matters and *how* to use it. Never substitute one
> for the other.

---

## Step 2: Answer These Before Writing

These questions define the post. If any are unclear, ask the user.

1. **Who is the reader?** (existing users, practitioners new to the project,
   broad developer audience)
2. **What problem does the reader already have** that this feature solves?
3. **What should the reader be able to do after reading** that they couldn't
   before?
4. **What is the single most important insight or result?** (the thesis)
5. **Are there known limitations or trade-offs** to acknowledge?

---

## Step 3: Post Structure

Use this skeleton, in order:

### 1. Title

- Lead with the **problem solved** or **outcome achieved**, not the feature name.
- Include the technology/feature name for SEO.
- Target 50–60 characters.
- Proven patterns:
  - `How we [solved X] in [product]`
  - `[Feature]: [one-line benefit]`
  - `[Problem] at scale: how we solved it`
- **Avoid**: "We are excited to announce…", vague superlatives, clickbait.

### 2. Opening hook (1–3 paragraphs)

- State the **problem the reader already has** in concrete terms.
- Quantify the pain if possible: "40 lines of boilerplate," "re-implemented
  in every project," "blocked the event loop."
- Include one compelling metric if available ("100× faster", "saved 600
  hours/year").
- The reader should know within 2–3 sentences: what this is, who it helps,
  why it matters now.
- **Avoid**: "We are excited to announce…", starting with the solution.

### 3. Problem / motivation (1–2 sections)

- Show the world *before* the feature. Use real code that illustrates the
  friction.
- Explain why the old approach was hard, not just that it was hard.
- A before-snippet here sets up the before/after comparison later.

### 4. Solution walkthrough (2–4 H2 sections)

- **Progressive disclosure**: start with the minimal working example, then
  add complexity in labeled steps.
- Each step introduces exactly one new concept.
- Every major concept gets a code block with inline comments on non-obvious
  lines.
- Include at least one diagram for structural/relational concepts (a
  paragraph-sized prose explanation of relationships between components
  signals a diagram is needed).
- Use the **before/after pattern** explicitly:
  - Label clearly (`# Before` / `# After` or side-by-side)
  - Keep the "before" code representative, not a strawman
  - Quantify the improvement: "reduces setup from 40 lines to 8"

### 5. Results / demo

- Show that it works: terminal output, benchmark numbers, screenshot of
  working state.
- Real numbers beat adjectives. "p99 latency: 120ms → 18ms on a 10GB
  dataset" beats "dramatically faster."
- If a full demo exists (notebook, repo, live link), link it here.

### 6. Honest trade-offs (brief)

- Acknowledge what the feature does *not* solve, known limitations, or who
  should not use it yet.
- One short paragraph or bullet list is enough.
- This is counterintuitive but dramatically increases reader trust.

### 7. Conclusion + CTA

- Summarize in **one sentence** (restate the core insight).
- Return to the reader's perspective: "If you're hitting [problem from
  intro], [feature] is now available…"
- Exactly **one primary CTA**: link to docs, quickstart, GitHub repo, or
  release notes. Not the marketing homepage.
- Optional secondary CTA: feedback thread, Discord/Slack, hiring link.
- **Avoid**: "We hope you find this useful", vague summaries, multiple
  competing CTAs.
- Optional: one sentence on future directions if there's a natural next
  chapter.

---

## Step 4: Code Example Rules

- **Never use screenshots for code.** Use fenced code blocks with the
  language specified (` ```python `, ` ```bash `, etc.).
- **Introduce every code block** with a sentence ending in a colon.
- **Show output** alongside non-trivial code blocks. Don't make readers
  mentally simulate execution.
- **Full working examples** for tutorials; **focused snippets** for
  illustrating a single concept.
- For omitted boilerplate, say so explicitly: `# ... existing setup omitted`.
- **Link to a complete, runnable repo** after inline snippets when possible.
- Mark placeholders with angle brackets: `<your-api-key>` (not curly braces,
  which conflict with many languages).
- Wrap lines at ~85 characters to avoid horizontal scroll.
- **Test every example.** Broken code is the fastest way to lose reader
  trust permanently.

---

## Step 5: Tone and Prose

- **Active voice, present tense**: "The SDK sends a request" not "A request
  is sent."
- **One post, one idea.** If you find yourself writing "and also," consider
  a separate post.
- **Avoid the curse of knowledge**: every acronym gets spelled out on first
  use; every internal term gets a one-sentence introduction.
- **Bold and inline code sparingly** — no more than 10% of prose text.
  Overuse makes nothing feel important.
- **Let engineers own the voice.** First-person bylines ("I built this
  because…") build more trust than anonymous corporate "we."
- **Show failures.** Posts that include dead ends before the solution are
  more credible and more shareable than posts that show only the finished
  answer.

---

## Step 6: SEO and Discoverability

- **URL slug**: `/blog/feature-name-benefit` not `/blog/post-12345`.
- **Title**: primary keyword in the first 3–4 words.
- **H2s**: each is an opportunity for a secondary keyword — write them as
  questions or statements a developer would search ("How to handle rate
  limiting").
- **Meta description** (150–160 chars): what the reader will be able to *do*
  after reading + one mild CTA ("See the full example").
- **Internal links**: link to related posts and docs; go back and add links
  from older posts to new ones.
- **External links**: official docs, RFCs, GitHub issues that explain design
  decisions — signals rigor.
- **Publish release-announcement posts on the same day as the release.**
- **Cross-post to dev.to or Hashnode** with a canonical URL pointing back to
  the original.
- **Promote in context**: GitHub README, changelog, release notes, Hacker
  News "Show HN" (plain informative title, no marketing language), relevant
  subreddits/Discord channels with 1–2 sentences of context, not just a link.

---

## Step 7: Write the Draft to a File

After drafting the post, write it to a markdown file in the current working directory:

- **Filename convention**: `blog-<slug>.md` where `<slug>` is a short kebab-case
  summary of the topic (e.g. `blog-pr-676-m-decompose.md`, `blog-rate-limiting.md`).
- If the argument was a PR number, use `blog-pr-<number>-<short-title>.md`.
- Use the Write tool to create the file. Do not ask — just write it.
- Tell the user the filename after writing.

---

## Step 8: Self-Review Checklist

Before finalizing, verify each item:

| # | Check |
|---|-------|
| 1 | Does the first paragraph state the **problem the reader already has**? |
| 2 | Is the motivation explained **before** the API/solution? |
| 3 | Does the title name a **problem or outcome**, not just the feature? |
| 4 | Is there a **before/after** comparison with labeled snippets? |
| 5 | Does every code block have **tested, runnable examples** with output shown? |
| 6 | Are **limitations or trade-offs** acknowledged? |
| 7 | Is there exactly **one primary CTA** at the end? |
| 8 | Can a skimmer understand the post from **headings alone**? |
| 9 | Is advanced content in a **late section** so beginners can stop early? |
| 10 | Are all code blocks using **fenced syntax with language specified**? |
| 11 | Does the post have a **single clear thesis** (one idea, not a roundup)? |
| 12 | Does it read like an **engineer wrote it**, not a press release? |

---

## Common Mistakes to Avoid

- **Changelog-as-blog-post**: a bulleted list of what changed with no
  narrative earns neither trust nor attention.
- **Burying the lede**: the most important result goes in the first 3
  paragraphs, not the conclusion.
- **Overlong intro**: "Software is complex and APIs are hard" before getting
  to the point loses most readers.
- **Vague superlatives**: "dramatically faster" is marketing; a benchmark
  with methodology is engineering.
- **Missing visuals for structural concepts**: if you're explaining
  relationships between components in 2+ paragraphs, use a diagram.
- **Treating all readers as the same audience**: a post for existing advanced
  users looks different from one for new practitioners.
- **Multiple competing CTAs**: pick one.
