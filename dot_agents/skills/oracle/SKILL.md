---
name: oracle
description: Invoke the OpenAI Responses API as an "oracle" for a stronger second opinion; use when you need a one-shot prompt with a configurable model (for example gpt-5.2-pro) and an API key. Also triggered by `$openai-responses-oracle`.
---

# Oracle (Responses API)

## Overview
Use `scripts/oracle_response.py` to send a single prompt to the OpenAI Responses API and print the model's text output. The script reads the API key from `OPENAI_API_KEY` and accepts a `--model` argument so model versions can change over time.
Requires Python 3.12+ (or `uv`).
The API key is read from the environment; there is no CLI flag for it.

## Quick start
1. Set the API key in your environment.
2. Run a prompt.

```bash
export OPENAI_API_KEY="..."
uv run scripts/oracle_response.py --model gpt-5.2-pro --input "Summarize the risks in this design doc."
```
If you do not use `uv`, `python scripts/oracle_response.py ...` also works.

## Inputs
- Provide the prompt with `--input "..."`, `--input-file path.txt`, or trailing args.
- Precedence: `--input-file` -> `--input` -> trailing args -> piped stdin.
- Trailing args are joined with spaces (shell quoting/newlines are not preserved).
- Add higher-priority guidance with `--instructions "..."` or `--instructions-file path.txt` (sent as the `instructions` field).
- Override the model with `--model <model-id>`.
- Override the API URL with `--api-url <url>` or set `OPENAI_BASE_URL` / `OPENAI_API_BASE`.

## Output control
- Use `--max-output-tokens <n>` to cap response length.

## Model discovery
List available model IDs for your API key:

```bash
python - <<'PY'
import json, os, urllib.request
req = urllib.request.Request(
    "https://api.openai.com/v1/models",
    headers={"Authorization": f"Bearer {os.environ['OPENAI_API_KEY']}"}
)
with urllib.request.urlopen(req, timeout=30) as resp:
    data = json.loads(resp.read().decode("utf-8"))
print("\n".join(sorted(m["id"] for m in data.get("data", []))))
PY
```

## Output
- Prints aggregated output text to stdout.
- If no output text is present, prints the full JSON response.
- Use `--json` to always print the full JSON response.
- Refusal text is printed like normal output if returned.

## Output contract
- Default mode: best-effort aggregated model text on stdout.
- `--json`: raw Responses API JSON on stdout.
- Errors and retry notices are written to stderr; failures return non-zero exit code.

## When not to use
- Don't use for multi-step workflows that require tools/actions.
- Don't use when OpenAI credentials or external API calls are not permitted/available.

## Reliability options
- `--timeout <seconds>` sets the request timeout. For the oracle pro model, start at 900 seconds (15 minutes) and adjust from there.
- Timeout applies per attempt, not across all retries.
- `--retries <count>` retries on 429/5xx and network timeouts.
- `--backoff <seconds>` sets exponential backoff base.
- `--max-backoff <seconds>` caps retry delay (jitter is applied).
- Retries include an idempotency key per run to avoid duplicate processing when retrying.

## Limitations
- Sends plain-text `input` with optional `instructions`; structured input items, tools, and multimodal content are not supported in this script.
