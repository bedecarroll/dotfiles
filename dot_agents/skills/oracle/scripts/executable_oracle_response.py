#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///
"""One-shot Responses API oracle CLI."""
from __future__ import annotations

import argparse
import email.utils
import json
import os
import random
import socket
import sys
import time
import uuid
import urllib.error
import urllib.request

API_URL = "https://api.openai.com/v1/responses"
API_KEY_ENV = "OPENAI_API_KEY"
API_BASE_ENV = "OPENAI_API_BASE"
API_BASE_URL_ENV = "OPENAI_BASE_URL"
DEFAULT_MODEL = "gpt-5.2-pro"
DEFAULT_TIMEOUT_SECONDS = 900
DEFAULT_RETRIES = 2
DEFAULT_BACKOFF_SECONDS = 1.5
DEFAULT_MAX_BACKOFF_SECONDS = 60
USER_AGENT = "oracle-cli/1.0"


def read_text_file(path: str, label: str) -> str:
    """Return file contents or exit with a clear error."""
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return handle.read()
    except OSError as exc:
        sys.stderr.write(f"Failed to read {label}: {exc}\n")
        sys.exit(2)


def read_prompt(args: argparse.Namespace) -> str | None:
    """Resolve the prompt from file, flags, args, or stdin."""
    if args.input_file:
        return read_text_file(args.input_file, "--input-file")
    if args.input is not None:
        return args.input
    if args.prompt_parts:
        return " ".join(args.prompt_parts)
    if not sys.stdin.isatty():
        return sys.stdin.read()
    return None


def read_instructions(args: argparse.Namespace) -> str | None:
    """Resolve optional instructions from file or flags."""
    if args.instructions_file:
        return read_text_file(args.instructions_file, "--instructions-file")
    if args.instructions is not None:
        return args.instructions
    return None


def extract_output_text(response: object) -> str | None:
    """Extract printable text from a Responses API payload."""
    if not isinstance(response, dict):
        return None
    output_text = response.get("output_text")
    if isinstance(output_text, str) and output_text:
        return output_text
    texts = []
    for item in response.get("output", []) or []:
        if not isinstance(item, dict):
            continue
        for content in item.get("content", []) or []:
            if isinstance(content, str):
                texts.append(content)
                continue
            if not isinstance(content, dict):
                continue
            content_type = content.get("type")
            if content_type == "output_text" and "text" in content:
                texts.append(content["text"])
            elif content_type == "refusal" and "refusal" in content:
                texts.append(content["refusal"])
            elif content_type is None and "text" in content:
                texts.append(content["text"])
    if texts:
        return "\n".join(texts)
    return None


def format_error_body(err_body: str) -> str:
    """Format an API error body into a readable string."""
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


def resolve_api_url(args: argparse.Namespace) -> str:
    if args.api_url:
        return args.api_url
    api_base = os.environ.get(API_BASE_URL_ENV) or os.environ.get(API_BASE_ENV)
    if api_base:
        return f"{api_base.rstrip('/')}/v1/responses"
    return API_URL


def build_request(
    api_url: str,
    api_key: str,
    payload: dict[str, object],
    idempotency_key: str,
) -> urllib.request.Request:
    data = json.dumps(payload).encode("utf-8")
    return urllib.request.Request(
        api_url,
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": USER_AGENT,
            "Idempotency-Key": idempotency_key,
        },
        method="POST",
    )


def compute_delay(args: argparse.Namespace, attempt: int, retry_after: str | None) -> float:
    if retry_after:
        try:
            delay = float(retry_after)
        except ValueError:
            try:
                retry_dt = email.utils.parsedate_to_datetime(retry_after)
            except (TypeError, ValueError):
                retry_dt = None
            if retry_dt is not None:
                delay = max(0.0, retry_dt.timestamp() - time.time())
            else:
                delay = args.backoff * (2**attempt)
    else:
        delay = args.backoff * (2**attempt)
    if args.max_backoff is not None:
        delay = min(delay, args.max_backoff)
    jitter = random.uniform(0.8, 1.2)
    return delay * jitter


def main() -> None:
    """CLI entrypoint."""
    parser = argparse.ArgumentParser(
        description="Call the OpenAI Responses API and print output text."
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help="Model id (default: %(default)s).",
    )
    parser.add_argument(
        "--input",
        help="Prompt text. If omitted, use remaining args or stdin.",
    )
    parser.add_argument(
        "--input-file",
        help="Read prompt text from a file.",
    )
    parser.add_argument(
        "--api-url",
        help="Override the Responses API URL.",
    )
    parser.add_argument(
        "--instructions",
        help="System/developer instructions to prepend.",
    )
    parser.add_argument(
        "--instructions-file",
        help="Read instructions text from a file.",
    )
    parser.add_argument(
        "prompt_parts",
        nargs="*",
        help="Prompt text (fallback when --input is omitted).",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print full JSON response instead of extracted text.",
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
    parser.add_argument(
        "--max-backoff",
        type=float,
        default=DEFAULT_MAX_BACKOFF_SECONDS,
        help="Maximum backoff seconds between retries (default: %(default)s).",
    )
    parser.add_argument(
        "--max-output-tokens",
        type=int,
        help="Upper bound for output tokens.",
    )
    args = parser.parse_args()

    prompt = read_prompt(args)
    if prompt is None:
        parser.error("Provide --input, prompt args, or pipe stdin.")

    api_key = os.environ.get(API_KEY_ENV)
    if not api_key:
        sys.stderr.write(
            f"Missing {API_KEY_ENV} environment variable. "
            "Set it in your shell; this script does not accept API keys via flags.\n"
        )
        sys.exit(2)

    if args.timeout <= 0:
        parser.error("--timeout must be positive.")
    if args.backoff < 0:
        parser.error("--backoff must be non-negative.")
    if args.max_backoff is not None and args.max_backoff <= 0:
        parser.error("--max-backoff must be positive.")
    if args.max_output_tokens is not None and args.max_output_tokens <= 0:
        parser.error("--max-output-tokens must be a positive integer.")

    payload = {"model": args.model, "input": prompt}
    instructions = read_instructions(args)
    if instructions:
        payload["instructions"] = instructions
    if args.max_output_tokens is not None:
        payload["max_output_tokens"] = args.max_output_tokens
    api_url = resolve_api_url(args)
    idempotency_key = str(uuid.uuid4())

    retries = max(0, args.retries)
    attempt = 0
    while True:
        try:
            request = build_request(api_url, api_key, payload, idempotency_key)
            with urllib.request.urlopen(request, timeout=args.timeout) as response:
                body = response.read().decode("utf-8")
            break
        except urllib.error.HTTPError as exc:
            err_body = exc.read().decode("utf-8", errors="replace")
            retryable = exc.code == 429 or 500 <= exc.code < 600
            if retryable and attempt < retries:
                delay = compute_delay(args, attempt, exc.headers.get("Retry-After"))
                time.sleep(delay)
                attempt += 1
                continue
            sys.stderr.write(f"HTTP {exc.code} from Responses API.\n")
            request_id = exc.headers.get("x-request-id")
            if request_id:
                sys.stderr.write(f"Request ID: {request_id}\n")
            if err_body:
                sys.stderr.write(format_error_body(err_body) + "\n")
            sys.exit(1)
        except (TimeoutError, socket.timeout):
            if attempt < retries:
                time.sleep(args.backoff * (2**attempt))
                attempt += 1
                continue
            sys.stderr.write("Request timed out.\n")
            sys.exit(1)
        except urllib.error.URLError as exc:
            if attempt < retries:
                time.sleep(args.backoff * (2**attempt))
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
        return

    text = extract_output_text(response_json)
    if text:
        sys.stdout.write(text)
        if not text.endswith("\n"):
            sys.stdout.write("\n")
    else:
        sys.stdout.write(json.dumps(response_json, indent=2, sort_keys=True))
        sys.stdout.write("\n")


if __name__ == "__main__":
    main()
