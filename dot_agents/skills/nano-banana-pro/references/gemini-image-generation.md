# Gemini Image Generation API Notes

Source: https://ai.google.dev/gemini-api/docs/image-generation

## Model and API shape
- Default to `gemini-3-pro-image-preview` for Nano Banana Pro quality workflows.
- Use `gemini-2.5-flash-image` as a faster alternative when latency matters more than top quality.
- SDK pattern: call `client.models.generate_content(...)` and request `response_modalities` that include `"IMAGE"` when image output is needed.
- REST pattern: call `models/{model}:generateContent` with `contents` parts for text and optional inline image bytes.

## Generate vs Edit
- Generate: send text-only prompt in `contents`.
- Edit: send prompt text plus one or more input images in `contents` parts.
- Multi-image edits are supported by providing multiple image parts and a clear instruction for each source image's role.

## Response handling
- Responses may contain both text and image parts.
- For SDK responses, iterate candidates/parts and:
- Print text parts for diagnostics or user-facing notes.
- Decode and save image `inline_data` bytes.
- For REST responses, decode base64 image data from inline image parts.

## Prompting tips
- Specify framing, subject, style, and lighting explicitly.
- When editing, name the change and the preservation constraints ("keep pose/background, only change jacket color").
- For reliable text in-image results, request short phrases and readable typography.

## Important limitation
- Treat transparent backgrounds as unsupported/unreliable for this workflow.
- Assume generated images come with non-transparent backgrounds.
- If transparency is required, chain a post-processing step (background removal/matting) after generation.
