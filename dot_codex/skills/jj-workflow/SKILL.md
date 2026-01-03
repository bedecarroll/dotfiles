---
name: jj-workflow
description: Jujutsu (jj) workflow guidance for Git-style tasks (commit/push, stacked work, status/log, diff/show, rebase, split/squash, abandon/restore, conflict resolve, bookmarks). Use when users mention jj/Jujutsu or ask how to do Git workflows in jj. Prefer auto-generated bookmarks via jj git push --change; avoid pre-creating bookmarks.
---

# JJ Workflow (Canonical)

## Policy

- For new PRs, always let jj generate the bookmark on push with `jj git push --change <rev>`.
- Do not run `jj git push` without `--change` for new PRs.
- Do not pre-create bookmarks. Only move an existing bookmark when updating a previously pushed change.
- Avoid generating multiple new bookmarks for the same PR.
- Only use `jj abandon` after confirming with the user; it is rare and usually indicates recovery from a bad state.

## Notes

- `@` is the working-copy commit; `@-` is its parent.
- `jj git push --change` creates a bookmark name (default prefix `push-`) and pushes it.
- `trunk()` resolves to the repository's trunk bookmark and avoids guessing `main` vs `master`; wrap it in single quotes for shell safety.
- When a revset includes parentheses (like `trunk()`), single-quote it.

## Workflows

Initialize / clone:

- `jj git init [DESTINATION]`
- `jj git clone <SOURCE> [DESTINATION]`

Create a new change from trunk:

- `jj new 'trunk()'`

Check where I am:

- `jj status`

Check commit history:

- `jj log`

View diff for current change:

- `jj diff` (defaults to `-r @`)

Show full change details:

- `jj show <rev>`
- Use `jj log -p -r <rev>` for patch-view history.

New commit (new PR):

- `jj commit -m "type(scope): message"`
- `jj git push --change @-`
- If this PR was already pushed, do not use `--change`; move the existing bookmark instead.

Add a commit to an existing PR/stack (reuse existing bookmark):

- `jj commit -m "type(scope): message"`
- `jj status` (identify the existing `push-...` bookmark for the current change)
- If multiple `push-...` bookmarks are shown, ask which PR/bookmark to update.
- `jj bookmark move <bookmark-name> --to @-`
- `jj git push --bookmark <bookmark-name>`
- If no bookmark exists yet, do not create one manually; use `jj git push --change @-`.

Amend current change content:

- `jj squash` (move working-copy changes into parent)

Split a change:

- `jj split`

Squash/merge changes in a stack:

- `jj squash [--from <rev>] [--into <rev>]`

Abandon a change:

- `jj abandon [REVSET]`

Restore a file to parent state:

- `jj restore <path>`
- Restore a file from trunk:
  - `jj restore --from 'trunk()' -- <path>`

Resolve conflicts:

- `jj resolve [FILESETS]...`

Recover from a bad state (operation log):

- Use when repo state is messed up (bad merges/conflicts/accidental rebase).
- Prefer `jj op log` + `jj op restore` over manual rebases when unsure.
- `jj op log` (see recent operations; each op snapshots repo state)
- Optional preview: `jj --at-op=<op-id> log`
- `jj undo` (undo the most recent operation)
- `jj redo` (redo the most recently undone operation)
- `jj op restore <op-id>` (restore repo state to a specific operation)
- `jj op revert <op-id>` (revert a specific earlier operation)

Sync with trunk:

- `jj git fetch`
- `jj rebase -d 'trunk()'`

Rebase a stack onto trunk (move a change and all its descendants):

- `jj rebase -r <rev>:: -A 'trunk()' --ignore-immutable`
