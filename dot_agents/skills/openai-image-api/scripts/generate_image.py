#!/usr/bin/env python3
import argparse
import base64
import binascii
import json
import os
import socket
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

API_URL = "https://api.openai.com/v1/images/generations"
API_KEY_ENV = "OPENAI_API_KEY"
DEFAULT_MODEL = "gpt-image-1"
DEFAULT_TIMEOUT_SECONDS = 120
DEFAULT_RETRIES = 2
DEFAULT_BACKOFF_SECONDS = 1.5


def read_prompt(args):
    if args.prompt_file:
        try:
            with open(args.prompt_file, "r", encoding="utf-8") as handle:
                return handle.read()
        except OSError as exc:
            sys.stderr.write(f"Failed to read --prompt-file: {exc}\n")
            sys.exit(2)
    if args.prompt is not None:
        return args.prompt
    if args.prompt_parts:
        return " ".join(args.prompt_parts)
    if not sys.stdin.isatty():
        return sys.stdin.read()
    return None


def normalize_output_format(fmt):
    if not fmt:
        return None
    fmt = fmt.lower()
    if fmt == "jpg":
        return "jpeg"
    return fmt


def format_error_body(err_body):
    try:
        payload = json.loads(err_body)
    except json.JSONDecodeError:
        return err_body
    if isinstance(payload, dict) and isinstance(payload.get("error"), dict):
        err = payload["error"]
        parts = [err.get("message"), err.get("type"), err.get("param"), err.get("code")]
        parts = [part for part in parts if part]
        if parts:
            return " | ".join(parts)
    return err_body


def iter_images(response_json):
    data = response_json.get("data")
    if not isinstance(data, list):
        return []
    images = []
    for item in data:
        if not isinstance(item, dict):
            continue
        if "b64_json" in item and item["b64_json"]:
            images.append(("b64_json", item["b64_json"]))
        elif "url" in item and item["url"]:
            images.append(("url", item["url"]))
    return images


def guess_extension(url, fallback):
    path = urlparse(url).path
    ext = os.path.splitext(path)[1].lstrip(".").lower()
    return ext or fallback


def save_images(images, output_dir, prefix, output_format):
    output_dir.mkdir(parents=True, exist_ok=True)
    saved_paths = []
    total = len(images)
    for idx, (kind, payload) in enumerate(images, start=1):
        if output_format:
            ext = output_format
        elif kind == "url":
            ext = guess_extension(payload, "png")
        else:
            ext = "png"

        if total == 1:
            filename = f"{prefix}.{ext}"
        else:
            filename = f"{prefix}_{idx:02d}.{ext}"

        path = output_dir / filename
        if kind == "b64_json":
            try:
                image_bytes = base64.b64decode(payload)
            except (ValueError, binascii.Error) as exc:
                raise ValueError(f"Failed to decode base64 image {idx}: {exc}")
            path.write_bytes(image_bytes)
        else:
            with urllib.request.urlopen(payload, timeout=60) as response:
                path.write_bytes(response.read())
        saved_paths.append(str(path))
    return saved_paths


def main():
    parser = argparse.ArgumentParser(
        description="Call the OpenAI Images API and save generated images."
    )
    parser.add_argument("--model", default=DEFAULT_MODEL, help="Model id (default: %(default)s).")
    parser.add_argument("--prompt", help="Prompt text. If omitted, use remaining args or stdin.")
    parser.add_argument("--prompt-file", help="Read prompt text from a file.")
    parser.add_argument(
        "prompt_parts",
        nargs="*",
        help="Prompt text (fallback when --prompt is omitted).",
    )
    parser.add_argument("--n", type=int, help="Number of images to generate.")
    parser.add_argument("--size", help="Image size (model-specific).")
    parser.add_argument("--quality", help="Image quality (model-specific).")
    parser.add_argument("--background", help="Background setting (transparent/opaque/auto).")
    parser.add_argument(
        "--output-format",
        dest="output_format",
        help="Output format for GPT image models (png/jpeg/webp).",
    )
    parser.add_argument(
        "--output-compression",
        type=int,
        help="Compression level 0-100 for jpeg/webp (GPT image models only).",
    )
    parser.add_argument(
        "--response-format",
        choices=["url", "b64_json"],
        help="Response format for DALL-E models only.",
    )
    parser.add_argument(
        "--moderation",
        choices=["auto", "low"],
        help="Moderation level for GPT image models.",
    )
    parser.add_argument("--style", help="Style for DALL-E 3 (vivid or natural).")
    parser.add_argument("--user", help="Optional end-user identifier.")
    parser.add_argument(
        "--output-dir",
        default=".",
        help="Directory to save images (default: current directory).",
    )
    parser.add_argument(
        "--prefix",
        default="image",
        help="Filename prefix for saved images (default: image).",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print full JSON response to stdout.",
    )
    parser.add_argument(
        "--no-save",
        action="store_true",
        help="Skip writing image files.",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=DEFAULT_TIMEOUT_SECONDS,
        help="Request timeout in seconds (default: %(default)s).",
    )
    parser.add_argument(
        "--retries",
        type=int,
        default=DEFAULT_RETRIES,
        help="Retry count for transient errors (default: %(default)s).",
    )
    parser.add_argument(
        "--backoff",
        type=float,
        default=DEFAULT_BACKOFF_SECONDS,
        help="Base backoff seconds between retries (default: %(default)s).",
    )
    args = parser.parse_args()

    prompt = read_prompt(args)
    if not prompt:
        parser.error("Provide --prompt, prompt args, or pipe stdin.")

    api_key = os.environ.get(API_KEY_ENV)
    if not api_key:
        sys.stderr.write(f"Missing {API_KEY_ENV} environment variable.\n")
        sys.exit(2)

    output_format = normalize_output_format(args.output_format)

    payload = {"prompt": prompt, "model": args.model}
    if args.n is not None:
        payload["n"] = args.n
    if args.size:
        payload["size"] = args.size
    if args.quality:
        payload["quality"] = args.quality
    if args.background:
        payload["background"] = args.background
    if output_format:
        payload["output_format"] = output_format
    if args.output_compression is not None:
        payload["output_compression"] = args.output_compression
    if args.response_format:
        payload["response_format"] = args.response_format
    if args.moderation:
        payload["moderation"] = args.moderation
    if args.style:
        payload["style"] = args.style
    if args.user:
        payload["user"] = args.user

    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        API_URL,
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    retries = max(0, args.retries)
    attempt = 0
    while True:
        try:
            with urllib.request.urlopen(request, timeout=args.timeout) as response:
                body = response.read().decode("utf-8")
            break
        except urllib.error.HTTPError as exc:
            err_body = exc.read().decode("utf-8", errors="replace")
            retryable = exc.code == 429 or 500 <= exc.code < 600
            if retryable and attempt < retries:
                time.sleep(args.backoff * (2 ** attempt))
                attempt += 1
                continue
            sys.stderr.write(f"HTTP {exc.code} from Images API.\n")
            if err_body:
                sys.stderr.write(format_error_body(err_body) + "\n")
            sys.exit(1)
        except (TimeoutError, socket.timeout):
            if attempt < retries:
                time.sleep(args.backoff * (2 ** attempt))
                attempt += 1
                continue
            sys.stderr.write("Request timed out.\n")
            sys.exit(1)
        except urllib.error.URLError as exc:
            if attempt < retries:
                time.sleep(args.backoff * (2 ** attempt))
                attempt += 1
                continue
            reason = getattr(exc, "reason", exc)
            sys.stderr.write(f"Request failed: {reason}\n")
            sys.exit(1)

    try:
        response_json = json.loads(body)
    except json.JSONDecodeError:
        sys.stderr.write("Failed to parse JSON response.\n")
        sys.stderr.write(body + "\n")
        sys.exit(1)

    if args.json:
        sys.stdout.write(json.dumps(response_json, indent=2, sort_keys=True))
        sys.stdout.write("\n")

    images = iter_images(response_json)
    if not images:
        if not args.json:
            sys.stdout.write(json.dumps(response_json, indent=2, sort_keys=True))
            sys.stdout.write("\n")
        return

    if args.no_save:
        if not args.json:
            sys.stdout.write("\n".join(content for _, content in images) + "\n")
        return

    output_dir = Path(args.output_dir)
    try:
        saved_paths = save_images(images, output_dir, args.prefix, output_format)
    except Exception as exc:
        sys.stderr.write(f"Failed to save images: {exc}\n")
        sys.exit(1)

    if args.json:
        for path in saved_paths:
            sys.stderr.write(f"saved: {path}\n")
        return

    for path in saved_paths:
        sys.stdout.write(path + "\n")


if __name__ == "__main__":
    main()
