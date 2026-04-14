---
name: hn-scout-generic
description: >-
  Scan Hacker News front page for AI-related posts, then evaluate each for
  integration or demo potential with the current project (inferred from the
  repo's README). Outputs a ranked list of bandwagon opportunities with
  concrete demo ideas.
---

# HN Scout (Generic): Find Bandwagon Opportunities for Any Project

Scan the Hacker News front page for AI-related posts, then evaluate whether
the current project could be used with or alongside whatever is being
discussed. The goal is to find trending topics where the project has a
credible angle — via a demo, blog post, integration, or Show HN.

Unlike `/hn-scout`, this variant does **not** bake in any specific project's
capabilities. It infers what the project is about from the repo's README at
runtime, so it works for any repo.

## Usage

```
/hn-scout-generic [--repo owner/repo] [--top N]
```

Defaults:
- `--repo` = auto-detected from the current working directory's git remote
- `--top 30` (number of HN front page items to scan)

---

## Steps

### 1. Determine the target project and build a capabilities profile

Resolve the repo:

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

If that fails, ask the user for `owner/repo`.

Fetch the README and repo metadata:

```bash
gh repo view OWNER/REPO --json description,topics,primaryLanguage
gh api repos/OWNER/REPO/readme --jq .content | base64 -d
```

From those sources, extract a **capabilities profile** in this shape:

```
Project: <name>
One-liner: <repo description or first paragraph of README>
Primary language: <from repo metadata>
Topics: <github topics list>
Key capabilities: <3-8 bullets extracted from README features/highlights>
Integrations: <libraries, providers, tools, frameworks the project supports>
Primary use cases: <2-4 scenarios the README emphasizes>
```

Be faithful to the README — do not invent capabilities. If the README is
thin (< 200 words) or missing, ask the user for a one-paragraph project
description before continuing.

Keep this profile in memory for all subsequent scoring.

### 2. Fetch the Hacker News front page

Use the Hacker News API to get the current top story IDs, then fetch
details for each:

```bash
# Get top story IDs (returns up to 500, we take the first N)
curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" | python3 -c "
import json, sys
ids = json.load(sys.stdin)[:TOP_N]
print(json.dumps(ids))
"
```

Then for each story ID, fetch the item:

```bash
curl -s "https://hacker-news.firebaseio.com/v0/item/{id}.json"
```

Collect: `id`, `title`, `url`, `score`, `descendants` (comment count), `by`,
`time`.

To avoid excessive API calls, batch the fetches and run them in parallel
where possible.

### 3. Filter for AI relevance

Score each post for AI relevance using the title, URL domain, and (when
available) a quick fetch of the linked content.

**AI-relevance signals** (any match = relevant):

| Signal | Weight |
|--------|--------|
| Title contains: LLM, GPT, Claude, AI, ML, model, inference, transformer, embedding, RAG, agent, fine-tun, prompt, diffusion, neural, deep learning, GenAI, generative, multimodal, vision model, language model, copilot, assistant, chatbot, reasoning, chain-of-thought, MCP, tool use, function calling | High |
| Title contains any term from the project's topics/capabilities | High |
| URL domain is: openai.com, anthropic.com, huggingface.co, arxiv.org (cs.AI/cs.CL/cs.LG), ollama.com, together.ai, replicate.com, deepmind.google, ai.meta.com | High |
| HN score >= 100 AND title mentions any programming/tech concept alongside AI | Medium |

Discard posts with no AI relevance signals. Keep the rest for scoring.

### 4. Read linked content for relevant posts

For each AI-relevant post, use WebFetch to read the linked URL. Extract:

- **What it is**: the project, paper, tool, or announcement in one sentence
- **Core technology**: what stack/language/framework it uses
- **Key capability**: what it does that people care about
- **Why it's trending**: what makes this interesting right now (new release,
  benchmark result, controversy, etc.)

If the URL is inaccessible (paywall, PDF-only, etc.), work from the title
and HN comments thread at `https://news.ycombinator.com/item?id={id}`
instead.

### 5. Score each post for project-fit opportunity

For each AI-relevant post, evaluate how naturally the current project
applies, using the capabilities profile from Step 1.

Score each post on two axes:

#### Fit score (0-50): How naturally does the project apply?

Evaluate each post against the capabilities profile. A post scores high on
fit when **at least one of the project's key capabilities or integrations
directly addresses something the post is about**.

| Signal | Points |
|--------|--------|
| Post's subject matter is a direct use case the project's README emphasizes | **+50** |
| Post discusses a pain point that one of the project's capabilities explicitly solves | **+40** |
| Post is about a library/provider/tool that the project already integrates with | **+35** |
| Post overlaps with the project's primary language and a listed capability | **+30** |
| Post is adjacent to the project's domain but doesn't directly use any capability | **+15** |
| Post is about AI broadly, but in a domain far from the project's sweet spot | **+5** |

Take the highest applicable signal (don't stack). For each score, record
**which specific capability** drove it — this becomes the credibility
check.

#### Buzz score (0-50): How much visibility could we get?

| Signal | Points |
|--------|--------|
| HN score >= 300 | **+30** |
| HN score >= 150 | **+20** |
| HN score >= 50 | **+10** |
| Comment count >= 200 | **+20** |
| Comment count >= 100 | **+15** |
| Comment count >= 50 | **+10** |

**Total opportunity score** = Fit score + Buzz score (max 100).

### 6. Generate demo ideas

For each post scoring >= 40 total, generate a concrete demo concept:

- **Demo title**: a short, punchy name for the demo (e.g., "<Project> x
  Qwen2.5: Structured extraction in 10 lines")
- **What to build**: 2-3 sentences describing a small, buildable demo
- **Project capabilities used**: which specific capabilities from the
  profile this showcases
- **Effort estimate**: S (afternoon hack), M (1-2 days), L (3-5 days)
- **Content angle**: how to frame this for maximum developer interest
  (blog post title, tweet hook, Show HN title)
- **Timeliness**: how quickly we need to ship to ride the wave (hours,
  days, this week)

If no capability from the profile genuinely applies, **do not invent
one**. Drop the post from the demo ideas section and note it under
"Skipped" with a one-phrase reason.

### 7. Output ranked results

Write a markdown file `hn-scout-YYYY-MM-DD.md` in the current working
directory.

#### Output format

```markdown
# HN Scout Report — YYYY-MM-DD

> Project: <name> (OWNER/REPO)
> Scanned top {N} Hacker News stories. Found {X} AI-relevant posts.
> Generated {Y} demo opportunities.

## Capabilities profile used for fit-scoring

- <capability 1>
- <capability 2>
- ...

---

## Top Opportunities

### 1. [Post Title](HN link) — Score: XX/100

> {one-line summary of the post}

| | |
|---|---|
| **HN Score** | {score} ({comments} comments) |
| **Fit** | {fit_score}/50 — {which capability applies and why} |
| **Buzz** | {buzz_score}/50 |
| **Source** | [{domain}]({url}) |

**Demo idea: {demo title}**

{What to build — 2-3 sentences}

- **Capabilities used**: {list}
- **Effort**: {S/M/L}
- **Content angle**: "{blog/tweet/ShowHN title}"
- **Ship by**: {timeliness}

---

### 2. ...

(repeat for all posts scoring >= 40)

---

## Also Relevant (score 20-39)

| # | Title | Score | Fit | Buzz | Quick take |
|---|-------|-------|-----|------|------------|
| ... | ... | ... | ... | ... | one-line note |

---

## Skipped (AI-relevant but low opportunity)

{Bulleted list of titles that were AI-relevant but scored < 20, with a
one-phrase reason for skipping each — including any posts where no
capability from the profile genuinely applied.}
```

---

## Guidance

- **Credibility is paramount.** Only suggest demos where the project
  genuinely adds value. A forced integration will backfire — developers
  smell marketing from a mile away. If a post is trending but the project
  has no natural angle, say so and move on.
- **Ground every fit claim in the capabilities profile.** If you can't
  point to a specific bullet in the profile that justifies the fit score,
  the fit score is wrong.
- **Speed matters.** HN cycles are 24-48 hours. Flag anything where the
  window is closing. A mediocre demo shipped today beats a polished one
  shipped next week.
- **Concrete beats vague.** "Build a demo" is not an action item. A good
  demo idea names specific APIs, specific models or providers, and a
  specific outcome.
- **Think like a developer, not a marketer.** The content angle should be
  genuinely useful or interesting, not "look at our product." The best
  bandwagon content teaches something while naturally showcasing the tool.

---

## Related Skills

- `/hn-scout` — the mellea-specific variant with a hand-tuned fit rubric.
  Prefer this generic version for any other project.
