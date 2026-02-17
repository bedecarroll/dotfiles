---
name: nano-banana-pro
description: Generate and edit images with the Google Gemini Image Generation API (nano-banana style workflows, default model gemini-3-pro-image-preview). Use when a user asks for Gemini-based image generation, image editing from prompts plus input images, SDK or REST request examples, response parsing for inline image data, or troubleshooting Gemini image output behavior.
---

# Nano Banana Pro

## Overview
Use this skill to implement Gemini image generation or editing requests quickly and consistently. Prefer concrete API examples and deterministic response parsing, then tailor prompts to the user's visual goal.

## Workflow
1. Confirm task type: generate new image from text, or edit an existing image.
2. Select API path:
- Use the Google Gen AI SDK when writing project code.
- Use REST examples when the user asks for raw HTTP/cURL.
3. Build request with:
- `model: gemini-3-pro-image-preview` by default for Nano Banana Pro quality.
- Use `gemini-2.5-flash-image` when speed/latency is prioritized over highest quality.
- `response_modalities: ["TEXT", "IMAGE"]` for SDK flows when image output is required.
- `contents` containing prompt text and optional input image bytes for edits.
4. Parse response parts and save any `inline_data` image bytes to disk.
5. Return file paths and any model text output.

## Prompting Guidance
- State subject, composition, style, and lighting explicitly.
- For edits, describe exactly what should stay unchanged and what should change.
- For text rendering in images, request short text and high legibility.
- Iterate with small prompt deltas instead of rewriting the full prompt each attempt.

## Limitation
- Do not promise transparent backgrounds. This workflow should assume non-transparent (flattened) backgrounds in outputs.
- If the user needs alpha transparency, generate the image first and then run a separate background-removal/post-processing step.

## When not to use
- Don't use if the user explicitly requests the OpenAI Images API workflow.
- Don't use when an alpha-channel transparent output is required as direct model output.

## Resources
- Read `references/gemini-image-generation.md` for API patterns, response parsing, and request examples aligned to the official docs.
