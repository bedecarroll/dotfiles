---
name: upskill
description: Review Codex session logs in ~/.codex/sessions and recommend improvements to existing skills or creation of new skills. Use when a user asks for skill-gap analysis, repeated workflow detection, missing `$skill` invocation analysis, or a prioritized backlog of skills to create/update.
---

# Upskill

## Overview
Use this skill to convert historical session activity into a concrete skill backlog. Run the analyzer script to detect unknown skill invocations, fallback patterns, and high-value candidates for new skills.

## Workflow
1. Run the analyzer on recent sessions:
```bash
python scripts/review_sessions.py --max-files 250 --skills-dir ~/.agents/skills
```
2. If you need machine-readable output:
```bash
python scripts/review_sessions.py --output json --max-files 250 --skills-dir ~/.agents/skills
```
3. If current active sessions should be included, disable the freshness filter:
```bash
python scripts/review_sessions.py --exclude-active-minutes 0 --skills-dir ~/.agents/skills
```
4. If you want rename/alias analysis explicitly:
```bash
python scripts/review_sessions.py --include-rename-candidates --skills-dir ~/.agents/skills
```
5. If you need built-in/system skills in recommendations:
```bash
python scripts/review_sessions.py --include-builtins --skills-dir ~/.agents/skills
```
6. Convert findings into actions:
- `Existing Skill Improvement Candidates`: update the skill's `SKILL.md` or bundled resources.
- `New Skill Candidates`: create a new skill when requests are repeated and no installed skill covers the workflow.
- `Fallback Tool Signals`: prioritize skills where users requested `$skill` aliases and execution fell back to built-in tools.

## Decision Rules
- Prefer updating an existing skill when the requested behavior is already in scope and only triggers/guidance are missing.
- Prefer creating a new skill when users repeatedly invoke a distinct `$name` that is not installed.
- Use evidence lines (timestamp, file, snippet) to justify each change request.
- Keep recommendations focused: top repeated candidates first, then single-occurrence items.
- Keep rename/alias recommendations opt-in (`--include-rename-candidates`) to avoid migration-noise by default.
- Keep built-in/system skills excluded by default; include them only with `--include-builtins`.

## Resource
- `scripts/review_sessions.py`: scans `~/.codex/sessions` and generates recommendation reports.

## Output contract
- Default mode: markdown report on stdout.
- `--output json`: JSON report on stdout.
- Script failures write errors to stderr and return non-zero exit code.

## When not to use
- Don't use for speculative live debugging without logs/repro.
- Don't make direct edits without evidence (logs, failing tests, or repro steps).
