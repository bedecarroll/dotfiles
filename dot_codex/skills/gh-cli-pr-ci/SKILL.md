---
name: gh-cli-pr-ci
description: Use the GitHub gh CLI to inspect pull requests, status checks, and CI failures. Trigger when triaging PRs/CI, fetching workflow logs, or summarizing check results. Prefer explicit --json field lists; avoid deprecated GraphQL fields like projectCards and invalid fields like checks by using statusCheckRollup.
---

# GH CLI PR/CI Triage

## Overview

Use this skill to triage PRs and CI failures with the gh CLI while avoiding GraphQL deprecations and invalid JSON fields. The key pattern: always request explicit JSON fields and use statusCheckRollup for checks.

## Quick Start Workflow

1) Fetch PR summary + checks (explicit fields only):

```bash
gh pr view <pr-number> --repo <owner>/<repo> \
  --json title,number,state,headRefName,baseRefName,author,mergeable,commits,files,additions,deletions,labels,statusCheckRollup
```

2) List failing checks with URLs:

```bash
gh pr view <pr-number> --repo <owner>/<repo> \
  --json statusCheckRollup \
  --jq '.statusCheckRollup[] | {name,conclusion,detailsUrl,startedAt,completedAt}'
```

3) Pull job logs from the details URL:

- details URL format: `https://github.com/<owner>/<repo>/actions/runs/<run-id>/job/<job-id>`
- fetch logs:

```bash
gh run view <run-id> --repo <owner>/<repo> --job <job-id> --log
```

## Pitfalls and Avoidance

- **Do not run `gh pr view` without `--json`.** The default GraphQL selection can request deprecated `projectCards` and trigger a deprecation error.
- **Do not use `--json checks`.** The field is not supported; use `statusCheckRollup` instead.
- **Keep JSON field lists minimal.** If a field causes errors, remove it and retry with a smaller list.
- **PR body newlines:** `gh pr create/edit --body` does **not** interpret `\n` escapes. Use `--body-file` (including `--body-file -` with a heredoc) or `gh api ... --input -` with JSON to preserve newlines.

## Useful Variations

- PR metadata without checks:

```bash
gh pr view <pr-number> --repo <owner>/<repo> \
  --json title,number,state,headRefName,baseRefName,author,mergeable,commits,files,additions,deletions,labels
```

- Filter only failed checks:

```bash
gh pr view <pr-number> --repo <owner>/<repo> \
  --json statusCheckRollup \
  --jq '.statusCheckRollup[] | select(.conclusion=="FAILURE") | {name,detailsUrl}'
```

## Decision Notes

- If you need project info, avoid classic projects fields; only add project-related fields if required and be prepared for permission or deprecation errors.
- For cross-repo PRs, always pass `--repo` to avoid querying the wrong default repository.
