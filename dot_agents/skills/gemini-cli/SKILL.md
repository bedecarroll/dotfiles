---
name: gemini-cli
description: Use the Google Gemini CLI to get a second opinion on code, architecture, and UI/UX work. Trigger when a user asks to consult Gemini, wants an external critique, or requests UI feedback, design alternatives, or code review via the Gemini CLI.
---

# Gemini CLI

## Overview

Use the Gemini CLI as a fast second-opinion engine for UI critique and code review. Keep prompts focused, include only the relevant context, and validate suggestions before applying.

## Quick start

1. Confirm the CLI binary and input mode:
   - Use `gemini` as the default command name.
   - Run `gemini --help` to identify supported flags and input modes.
   - Use `-p` / `--prompt` for one-shot non-interactive runs.
   - Use a positional prompt only when you want interactive mode.
   - If stdin is supported, prefer piping a structured prompt or a file.

2. Run with full context once the CLI invocation is working; avoid test prompts to save tokens.
   - Prefer `--output-format text` for readability or `--output-format json` for structured parsing.

## Non-interactive long prompt patterns

Use heredoc or file-based prompt construction to avoid shell quoting issues.

```bash
gemini --output-format text -p "$(cat <<'PROMPT'
You are a staff engineer.
Review this diff for correctness and edge cases.
Return: risks, fixes, quick refactors.

<insert code/diff context here>
PROMPT
)"
```

```bash
PROMPT_FILE=/tmp/gemini_prompt.txt
cat > "$PROMPT_FILE" <<'PROMPT'
You are a pragmatic architect.
Evaluate option A vs B and recommend one with tradeoffs.
PROMPT
gemini --output-format json -p "$(cat "$PROMPT_FILE")"
```

## Output contract

- `--output-format text`: human-readable plain text.
- `--output-format json`: machine-readable JSON; prefer this when downstream parsing is required.
- Non-zero exit code indicates CLI/runtime failure.

## When not to use

- Don't use for primary-source/citation-grade verification.
- Don't use unless the user requests a Gemini second opinion.

## Workflow

1. Classify the request:
   - **UI/UX critique**: layout, hierarchy, visual design, accessibility, interaction flow.
   - **UI alternative generation**: new layout concepts or copy variations.
   - **Code second opinion**: review logic, edge cases, performance, correctness.
   - **Architecture check**: tradeoffs, risks, suggested alternatives.

2. Gather context (keep it minimal):
   - Goal, constraints, target platform, and success criteria.
   - Relevant code, diffs, or snippets only (avoid entire repos).
   - Any non-negotiables (design system, performance limits, deadlines).

3. Run the CLI with a structured prompt.

4. Validate the response:
   - Check for incorrect assumptions or hallucinated APIs.
   - Cross-check suggestions against project constraints.
   - Apply only improvements that you can justify.

## Prompt patterns

### UI critique

Use when asking for layout and visual feedback.

```
You are a senior product designer.
Critique this UI for hierarchy, clarity, and accessibility.
Return: (1) top 3 issues, (2) quick wins, (3) risky changes.

Context:
- Platform: <web | iOS | Android | desktop>
- Audience: <persona>
- Constraints: <design system, brand, perf>

UI description or markup:
<brief description, screenshot notes, or key UI code>
```

### UI alternatives

Use when you want multiple layout or copy options.

```
You are a UX lead.
Propose 3 alternative layouts with pros/cons and when to use each.

Context:
- Goal: <what must improve>
- Constraints: <grid, components, tokens>

Current UI summary:
<short summary>
```

### Code second opinion

Use for review and risk spotting.

```
You are a staff engineer.
Review the code below for correctness, edge cases, and maintainability.
Return: (1) risks, (2) suggested fixes, (3) quick refactors.

Context:
- Language/stack: <...>
- Constraints: <perf, security, compatibility>

Code:
<snippet or diff>
```

### Architecture tradeoffs

Use for system design or refactor choices.

```
You are a pragmatic architect.
Evaluate these options and recommend one. Include tradeoffs and failure modes.

Context:
- Goal: <...>
- Constraints: <cost, latency, team skills>

Options:
1) <option A>
2) <option B>
```

## Notes

- Avoid sending secrets or proprietary data unless explicitly approved.
- Prefer short, specific prompts over broad requests.
- If the CLI supports file inputs, prefer file paths over large inline text.
