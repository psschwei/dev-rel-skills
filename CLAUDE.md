# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A collection of Claude Code agent skills for developer relations work. Skills are defined as SKILL.md files under `skills/` and are installed via `./install-skills.sh`, which symlinks them into `~/.claude/skills/`. There is no build system, test suite, or runtime — the "application" is the prompt instructions themselves.

## Skill Architecture

Each skill lives in `skills/<skill-name>/SKILL.md`. Skills are designed to work as a pipeline:

1. `/hn-scout` — Scans Hacker News front page for AI-related posts, scores each for mellea integration potential, and generates concrete demo ideas
2. `/get-blog-candidates` — Fetches merged PRs from `generative-computing/mellea`, scores each by blog potential, and outputs a ranked table
3. `/release-blog` — Drafts a full release post from the latest GitHub release, scoring PRs into Highlight (≥50), Mention (10–49), and Skip (<10) tiers
4. `/write-technical-blog` — Deep-dive post guide drawing on best practices from Stripe, GitHub, Cloudflare, HashiCorp, and Google engineering blogs
5. `/write-tweet` — Generates tweet threads with proven opening formulas and per-announcement-type content rules
6. `/de-llmify` — Edits writing to remove LLM-generated text patterns before publishing
7. `/validate-snippets` — Extracts fenced code blocks from writing, executes each, and reports pass/fail/skip results
8. `/link-preview` — Generates a link preview snippet (markdown card with code snippet, Open Graph tags, Twitter Card) for a finished post or external URL

Skills can be used independently but typically flow sequentially: scout → discover → draft → validate → preview → promote.

## External Dependency

All skills that fetch GitHub data rely on the `gh` CLI being installed and authenticated. Skills use `gh pr list`, `gh pr view`, `gh release view`, and `gh api`. The `/hn-scout` skill uses the public Hacker News Firebase API (`hacker-news.firebaseio.com`) and WebFetch for reading linked articles.

## Output Files

Skills write their output to the working directory:
- HN scout reports → `hn-scout-YYYY-MM-DD.md`
- Release blog posts → `blog-release-vX.Y.Z.md`
- Feature blog posts → `blog-<slug>.md`
- Tweet threads → `tweet-<slug>.md`
- Snippet validation reports → `snippet-report-<slug>.md`
- Link preview snippets → `link-preview-<slug>.md`

See `demos/` for real examples of each output type.

## Adding or Modifying Skills

When editing SKILL.md files, the default target repo is `generative-computing/mellea`. Update the repo reference in the relevant SKILL.md if repurposing a skill for a different project.
