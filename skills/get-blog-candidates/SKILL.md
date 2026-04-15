---
name: get-blog-candidates
description: >-
  Fetch and rank merged PRs from the current repository by their likelihood of
  being good blog or demo candidates. Scores on: feat label/prefix, lines of
  code changed, and presence of docs/examples changes.
---

# Rank PRs for Blog/Demo Candidates

Fetch merged PRs from the target repository for a given time window and rank
them by blog/demo potential.

## Usage

```
/get-blog-candidates [--repo owner/repo] [--since YYYY-MM-DD] [--until YYYY-MM-DD] [--limit N]
```

Defaults:
- `--repo` = auto-detected from the current working directory's git remote
- `--since` = Monday of current week
- `--limit` = 30

---

## Steps

### 1. Determine the target repo

If `--repo` was passed, use it. Otherwise auto-detect from the working
directory:

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

If that fails (no `gh` auth, not inside a repo, or no `origin` remote),
ask the user for `owner/repo`.

### 2. Fetch merged PRs with file details

```bash
gh pr list \
  --repo OWNER/REPO \
  --state merged \
  --search "merged:>SINCE_DATE" \
  --limit LIMIT \
  --json number,title,mergedAt,author,labels,url,additions,deletions,files
```

### 3. Detect the repo's commit-message convention

Before scoring, sample the first 5-10 PR titles. Classify the repo:

- **Conventional Commits**: most titles start with `feat:`, `fix:`, `chore:`,
  `docs:`, `refactor:`, etc. Use the **prefix rubric** below.
- **Label-driven**: titles are free-form, but most PRs carry labels like
  `enhancement`, `bug`, `feature`, `documentation`. Use the **label rubric**.
- **Free-form**: neither prefixes nor consistent labels. Fall back to the
  **content rubric** (lines changed + file paths only).

Note which convention the repo uses in the output.

### 4. Score each PR

Apply the rubric that matches the repo's convention. Higher = better
blog/demo candidate.

#### Prefix rubric (Conventional Commits repos)

| Signal | Points |
|--------|--------|
| Title starts with `feat:` or `feat(` | **+40** |
| Label `enhancement` or `feature` | **+20** |
| Title starts with `fix:` | **+5** |
| Any changed file under `docs/examples/`, `examples/`, or `samples/` | **+25** |
| Any changed file under `docs/docs/` or `docs/` (non-example) | **+15** |
| Any changed `.md` file anywhere | **+10** |
| Net lines changed (additions + deletions) ≥ 500 | **+15** |
| Net lines changed ≥ 200 | **+10** |
| Net lines changed ≥ 50 | **+5** |
| Title starts with `chore:`, `ci:`, `build:`, or `fix: update github` | **-30** (infra noise) |
| Title starts with `docs:` (docs-only, no examples) | **-10** |

#### Label rubric (label-driven repos)

| Signal | Points |
|--------|--------|
| Label `enhancement`, `feature`, or `new-feature` | **+40** |
| Label `improvement` or `performance` | **+25** |
| Label `bug`, `bugfix`, or `fix` | **+5** |
| Label `breaking-change` or `breaking` | **+30** |
| Any changed file under `docs/examples/`, `examples/`, or `samples/` | **+25** |
| Any changed file under `docs/` | **+15** |
| Any changed `.md` file anywhere | **+10** |
| Net lines changed ≥ 500 | **+15** |
| Net lines changed ≥ 200 | **+10** |
| Net lines changed ≥ 50 | **+5** |
| Label `chore`, `ci`, `build`, `dependencies`, or `infra` | **-30** |
| Label `documentation` (docs-only, no examples) | **-10** |
| Author is `dependabot[bot]` or `renovate[bot]` | **-40** |

#### Content rubric (free-form repos)

| Signal | Points |
|--------|--------|
| Any changed file under `examples/`, `docs/examples/`, or `samples/` | **+35** |
| Any changed file under `docs/` | **+20** |
| Any changed `.md` file anywhere | **+10** |
| Net lines changed ≥ 500 | **+25** |
| Net lines changed ≥ 200 | **+15** |
| Net lines changed ≥ 50 | **+5** |
| Title contains keywords: `add`, `new`, `introduce`, `support` | **+15** |
| Title contains keywords: `fix`, `bump`, `update dep`, `typo` | **-20** |
| Author is `dependabot[bot]` or `renovate[bot]` | **-40** |

Compute `score` for each PR. Sort descending.

### 5. Output ranked table

Print a markdown table with columns:

| Rank | # | Title | Score | Signals |
|------|---|-------|-------|---------|

The **Signals** column should list which signals fired, e.g.:
`feat prefix, docs/examples touched, 1811 lines`

Above the table, note which repo and which rubric was used:

```
Repo: owner/repo — rubric: Conventional Commits (prefix-based)
```

Then add a short section **"Top picks"** calling out the #1 and #2 PRs with a
one-sentence explanation of why each is a good candidate.

---

## Scoring Notes

- PRs with example/sample changes are high-value because they already have
  runnable demo material.
- Large line counts (≥ 500) indicate substantial new functionality.
- Infra PRs (dep bumps, CI, chores) are penalized because they rarely make
  good blog content.
- If two PRs tie, prefer the one with example changes.
- Example directory paths vary by project (`examples/`, `docs/examples/`,
  `samples/`, `demo/`, etc.). The rubrics cover the common ones; if a repo
  uses something else, note it and adjust inline.
