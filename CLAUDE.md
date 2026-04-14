# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A collection of Claude Code agent skills for developer relations work. Skills are defined as SKILL.md files under `skills/` and are installed via `./install-skills.sh`, which symlinks them into `~/.claude/skills/`. There is no build system, test suite, or runtime — the "application" is the prompt instructions themselves.

## Skill Architecture

Each skill lives in `skills/<skill-name>/SKILL.md`. Skills are designed to work as a pipeline:

1. `/hn-scout` — Scans Hacker News front page for AI-related posts, scores each for mellea integration potential, and generates concrete demo ideas. **Project-specific to mellea.** For any other project, use `/hn-scout-generic`.
2. `/hn-scout-generic` — Same as `/hn-scout`, but infers the target project's capabilities from its README at runtime, so it works for any repo.
3. `/get-blog-candidates` — Fetches merged PRs from the current repo, scores each by blog potential, and outputs a ranked table.
4. `/release-blog` — Drafts a full release post from the latest GitHub release, scoring PRs into Highlight (≥50), Mention (10–49), and Skip (<10) tiers.
5. `/write-technical-blog` — Deep-dive post guide drawing on best practices from Stripe, GitHub, Cloudflare, HashiCorp, and Google engineering blogs.
6. `/write-tweet` — Generates tweet threads with proven opening formulas and per-announcement-type content rules.
7. `/de-llmify` — Edits writing to remove LLM-generated text patterns before publishing.
8. `/validate-snippets` — Extracts fenced code blocks from writing, executes each, and reports pass/fail/skip results.

Skills can be used independently but typically flow sequentially: scout → discover → draft → validate → promote.

## Target Repo Resolution

Skills that interact with GitHub resolve the target repo in this order:

1. An explicit `--repo owner/repo` flag on the invocation.
2. Auto-detection from the current working directory's git remote
   (`gh repo view --json nameWithOwner -q .nameWithOwner`).
3. If both fail, the skill asks the user.

This means running any of these skills inside a cloned repo "just works" —
no configuration needed.

## External Dependency

All skills that fetch GitHub data rely on the `gh` CLI being installed and authenticated. Skills use `gh pr list`, `gh pr view`, `gh release view`, and `gh api`. The `/hn-scout` and `/hn-scout-generic` skills use the public Hacker News Firebase API (`hacker-news.firebaseio.com`) and WebFetch for reading linked articles.

## Output Files

Skills write their output to the working directory:
- HN scout reports → `hn-scout-YYYY-MM-DD.md`
- Release blog posts → `blog-release-vX.Y.Z.md`
- Feature blog posts → `blog-<slug>.md`
- Tweet threads → `tweet-<slug>.md`
- Snippet validation reports → `snippet-report-<slug>.md`

See `demos/` for real examples of each output type.

## Adding or Modifying Skills

Most skills are repo-agnostic and auto-detect the target repo from the
working directory (see "Target Repo Resolution" above). The one exception is
`/hn-scout`, which bakes in mellea's capabilities for high-quality fit
scoring; the generic equivalent is `/hn-scout-generic`, which reads
capabilities from the target repo's README at runtime.

When adding new skills, prefer the auto-detect pattern over hardcoding a
repo. Keep project-specific scoring rubrics parameterized (or gated behind
a `-<project>` suffix in the skill name) so the skill can be reused across
repos.
