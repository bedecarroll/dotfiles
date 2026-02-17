---
name: openai-image-api
description: Generate images via the OpenAI Images API from the CLI, save returned images to files, and control model/size/quality/format. Use when a user asks to create images with OpenAI's image generation API (for example /v1/images/generations), wants a script or CLI to call it, or needs local image files from gpt-image-1 or DALL-E models.
---

# OpenAI Image API

## Overview
Use `scripts/generate_image.py` to call the OpenAI Images API (`/v1/images/generations`) and write the returned images to disk. Read the API key from `OPENAI_API_KEY`.

## Quick start
1. Set the API key.
2. Run the script with a prompt.

```bash
export OPENAI_API_KEY="..."
python scripts/generate_image.py --prompt "Retro 90s space strategy UI, beveled panels, map view" --size 1024x1024 --quality high --output-format png --output-dir ./out --prefix space-ui
```

## Inputs
- Provide prompt via `--prompt`, `--prompt-file`, trailing args, or stdin (in that order).
- Set `--model` to `gpt-image-1` (default) or a DALL-E model.

## Output
- Save images to `--output-dir` with `--prefix` and a matching extension.
- Print saved file paths to stdout.
- Use `--json` to print the full API response (saved paths go to stderr).
- Use `--no-save` to skip writing files.

## Output contract
- Default mode: newline-delimited saved image paths on stdout.
- `--json`: full API response JSON on stdout; saved paths (if any) on stderr.
- Errors are printed to stderr and return a non-zero exit code.

## When not to use
- Don't use if the user explicitly requests Gemini or `nano-banana-pro`.
- Don't use for non-image-generation tasks or workflows that require other endpoints/providers.

## Common options
- Use `--size`, `--quality`, `--background`, `--output-format`, `--output-compression`, and `--moderation` with GPT image models.
- Use `--response-format` and `--style` with DALL-E models.
- Use `--n` to control the number of images to generate.

## Reliability
- Use `--timeout`, `--retries`, and `--backoff` to handle slow or rate-limited requests.
