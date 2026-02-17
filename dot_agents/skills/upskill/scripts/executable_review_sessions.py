#!/usr/bin/env python3
"""Analyze Codex session logs and recommend skill improvements."""

from __future__ import annotations

import argparse
import difflib
import json
import re
import time
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


INVOCATION_RE = re.compile(r"\$([a-z0-9][a-z0-9-]{0,63})")
MISSING_SKILL_RE = re.compile(r"\$([a-z0-9][a-z0-9-]{0,63}).{0,40}isn.?t an installed skill", re.IGNORECASE)
BUILTIN_TOOLS_RE = re.compile(r"using the built-in ([a-z0-9 -]+) tools", re.IGNORECASE)
ERROR_PATTERNS = (
    re.compile(r"not found for API version", re.IGNORECASE),
    re.compile(r"no longer accepted", re.IGNORECASE),
    re.compile(r"not supported for generatecontent", re.IGNORECASE),
    re.compile(r"unsupported.{0,30}(model|api|endpoint|version)", re.IGNORECASE),
    re.compile(r"(model|api|endpoint|version).{0,30}unsupported", re.IGNORECASE),
    re.compile(r"no inline image data found", re.IGNORECASE),
)
TOKEN_RE = re.compile(r"[a-z0-9]+")
GENERIC_NON_SKILL_NAMES = {"cmd", "args", "arg", "tool", "tools"}
STOPWORDS = {
    "the",
    "a",
    "an",
    "and",
    "or",
    "for",
    "to",
    "of",
    "in",
    "on",
    "with",
    "via",
    "use",
    "using",
    "when",
    "where",
    "that",
}
TOKEN_ALIASES = {
    "github": {"gh"},
    "gh": {"github"},
    "jujutsu": {"jj"},
    "jj": {"jujutsu", "workflow"},
    "workflow": {"jj"},
    "openai": {"oracle", "responses"},
    "responses": {"oracle", "openai"},
    "oracle": {"responses", "openai"},
}


@dataclass
class Evidence:
    timestamp: str
    file_path: str
    snippet: str


@dataclass
class Report:
    files_scanned: int
    messages_scanned: int
    installed_skills_count: int
    known_invocations: Counter
    unknown_invocations: Counter
    unknown_evidence: dict[str, list[Evidence]]
    existing_skill_issues: Counter
    issue_evidence: dict[str, list[Evidence]]
    builtin_tool_fallbacks: Counter


@dataclass
class SkillMeta:
    name: str
    description: str
    tokens: set[str]
    is_builtin: bool


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Review ~/.codex/sessions and recommend skill improvements."
    )
    parser.add_argument(
        "--sessions-dir",
        default=str(Path("~/.codex/sessions").expanduser()),
        help="Directory containing Codex JSONL session logs.",
    )
    parser.add_argument(
        "--skills-dir",
        default=str(Path("~/.agents/skills").expanduser()),
        help="Directory containing installed skills.",
    )
    parser.add_argument(
        "--max-files",
        type=int,
        default=250,
        help="Maximum number of most-recent session files to scan.",
    )
    parser.add_argument(
        "--exclude-active-minutes",
        type=int,
        default=10,
        help="Skip files modified in the last N minutes to avoid partial active sessions.",
    )
    parser.add_argument(
        "--since-days",
        type=int,
        default=45,
        help="Only scan session files modified in the last N days.",
    )
    parser.add_argument(
        "--min-count",
        type=int,
        default=1,
        help="Minimum hit count required before recommending an item.",
    )
    parser.add_argument(
        "--max-evidence",
        type=int,
        default=3,
        help="Maximum evidence snippets per recommendation.",
    )
    parser.add_argument(
        "--output",
        choices=("markdown", "json"),
        default="markdown",
        help="Output format.",
    )
    parser.add_argument(
        "--include-rename-candidates",
        action="store_true",
        help="Include rename/alias mapping recommendations (off by default).",
    )
    parser.add_argument(
        "--include-builtins",
        action="store_true",
        help="Include built-in/system skills in improvement recommendations.",
    )
    return parser.parse_args()


def _extract_frontmatter_description(skill_file: Path) -> str:
    try:
        content = skill_file.read_text(encoding="utf-8")
    except OSError:
        return ""

    lines = content.splitlines()
    if not lines or lines[0].strip() != "---":
        return ""

    for line in lines[1:60]:
        if line.strip() == "---":
            break
        if line.lower().startswith("description:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    return ""


def _tokenize(text: str) -> set[str]:
    tokens = {t for t in TOKEN_RE.findall(text.lower()) if t and t not in STOPWORDS}
    expanded = set(tokens)
    for tok in tokens:
        expanded.update(TOKEN_ALIASES.get(tok, set()))
    return expanded


def discover_installed_skills(skills_dir: Path) -> dict[str, SkillMeta]:
    installed: dict[str, SkillMeta] = {}
    if not skills_dir.exists():
        return installed

    for skill_file in skills_dir.rglob("SKILL.md"):
        name = skill_file.parent.name
        description = _extract_frontmatter_description(skill_file)
        tokens = _tokenize(f"{name} {description}")
        is_builtin = ".system" in skill_file.parts
        installed[name] = SkillMeta(
            name=name,
            description=description,
            tokens=tokens,
            is_builtin=is_builtin,
        )
    return installed


def iter_session_files(
    sessions_dir: Path, max_files: int, exclude_active_minutes: int, since_days: int
) -> list[Path]:
    since_cutoff = time.time() - (since_days * 24 * 60 * 60)
    cutoff = time.time() - (exclude_active_minutes * 60)
    files = []
    for path in sessions_dir.rglob("*.jsonl"):
        try:
            mtime = path.stat().st_mtime
            if mtime < since_cutoff:
                continue
            if mtime >= cutoff:
                continue
        except OSError:
            continue
        files.append(path)
    files.sort(reverse=True)
    return files[:max_files]


def trim_snippet(text: str, limit: int = 140) -> str:
    cleaned = " ".join(text.split())
    if len(cleaned) <= limit:
        return cleaned
    return cleaned[: limit - 3] + "..."


def extract_text_events(event: dict) -> Iterable[tuple[str, str]]:
    event_type = event.get("type")
    payload = event.get("payload", {})

    if event_type == "response_item" and payload.get("type") == "message":
        role = payload.get("role", "")
        if role not in {"assistant"}:
            return
        for item in payload.get("content", []):
            item_type = item.get("type")
            if item_type in {"input_text", "output_text"}:
                text = item.get("text")
                if isinstance(text, str) and text.strip():
                    yield role, text
        return

    if event_type == "event_msg" and payload.get("type") == "user_message":
        message = payload.get("message")
        if isinstance(message, str) and message.strip():
            yield "user", message


def analyze_sessions(
    session_files: list[Path],
    installed_skills: set[str],
    max_evidence: int,
) -> Report:
    known_invocations: Counter = Counter()
    unknown_invocations: Counter = Counter()
    unknown_evidence: dict[str, list[Evidence]] = defaultdict(list)
    existing_skill_issues: Counter = Counter()
    issue_evidence: dict[str, list[Evidence]] = defaultdict(list)
    builtin_tool_fallbacks: Counter = Counter()

    messages_scanned = 0

    for session_file in session_files:
        active_skill: str | None = None
        seen_messages: set[tuple[str, str, str]] = set()
        try:
            lines = session_file.read_text(encoding="utf-8").splitlines()
        except OSError:
            continue

        for line in lines:
            if not line.strip():
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue

            timestamp = event.get("timestamp", "")
            for role, text in extract_text_events(event):
                dedupe_key = (timestamp, role, text)
                if dedupe_key in seen_messages:
                    continue
                seen_messages.add(dedupe_key)

                messages_scanned += 1

                if role == "user":
                    mentions = INVOCATION_RE.findall(text)
                    if mentions:
                        active_skill = mentions[-1]
                    for name in mentions:
                        if name in installed_skills:
                            known_invocations[name] += 1
                        else:
                            unknown_invocations[name] += 1
                            if len(unknown_evidence[name]) < max_evidence:
                                unknown_evidence[name].append(
                                    Evidence(
                                        timestamp=timestamp,
                                        file_path=str(session_file),
                                        snippet=trim_snippet(text),
                                    )
                                )

                if role == "assistant":
                    missing = MISSING_SKILL_RE.search(text)
                    if missing:
                        missing_name = missing.group(1)
                        unknown_invocations[missing_name] += 1
                        if len(unknown_evidence[missing_name]) < max_evidence:
                            unknown_evidence[missing_name].append(
                                Evidence(
                                    timestamp=timestamp,
                                    file_path=str(session_file),
                                    snippet=trim_snippet(text),
                                )
                            )

                    fallback = BUILTIN_TOOLS_RE.search(text)
                    if fallback:
                        builtin_tool_fallbacks[fallback.group(1).strip().lower()] += 1

                    if (
                        active_skill in installed_skills
                        and any(p.search(text) for p in ERROR_PATTERNS)
                    ):
                        existing_skill_issues[active_skill] += 1
                        if len(issue_evidence[active_skill]) < max_evidence:
                            issue_evidence[active_skill].append(
                                Evidence(
                                    timestamp=timestamp,
                                    file_path=str(session_file),
                                    snippet=trim_snippet(text),
                                )
                            )

    return Report(
        files_scanned=len(session_files),
        messages_scanned=messages_scanned,
        installed_skills_count=len(installed_skills),
        known_invocations=known_invocations,
        unknown_invocations=unknown_invocations,
        unknown_evidence=unknown_evidence,
        existing_skill_issues=existing_skill_issues,
        issue_evidence=issue_evidence,
        builtin_tool_fallbacks=builtin_tool_fallbacks,
    )


def closest_skill(name: str, installed: set[str]) -> str | None:
    match = difflib.get_close_matches(name, sorted(installed), n=1, cutoff=0.74)
    return match[0] if match else None


def semantic_skill_match(
    unknown_name: str, installed_skill_meta: dict[str, SkillMeta]
) -> tuple[str, float] | None:
    if unknown_name in installed_skill_meta:
        return unknown_name, 1.0

    unknown_tokens = _tokenize(unknown_name)
    if not unknown_tokens:
        return None

    best: tuple[str, float] | None = None
    for skill_name, meta in installed_skill_meta.items():
        name_tokens = _tokenize(skill_name)
        all_tokens = meta.tokens
        ratio = difflib.SequenceMatcher(None, unknown_name, skill_name).ratio()
        j_name = len(unknown_tokens & name_tokens) / max(len(unknown_tokens | name_tokens), 1)
        j_all = len(unknown_tokens & all_tokens) / max(len(unknown_tokens | all_tokens), 1)
        score = (0.55 * j_name) + (0.30 * j_all) + (0.15 * ratio)
        if best is None or score > best[1]:
            best = (skill_name, score)

    if best and best[1] >= 0.25:
        return best
    return None


def markdown_report(
    report: Report,
    installed_skill_meta: dict[str, SkillMeta],
    min_count: int,
    include_rename_candidates: bool,
    include_builtins: bool,
) -> str:
    installed_skills = set(installed_skill_meta.keys())
    lines: list[str] = []
    lines.append("# Upskill Report")
    lines.append("")
    lines.append(f"- Session files scanned: {report.files_scanned}")
    lines.append(f"- Messages scanned: {report.messages_scanned}")
    lines.append(f"- Installed skills detected: {report.installed_skills_count}")
    lines.append("")

    lines.append("## Existing Skill Improvement Candidates")
    existing_rows = [
        (name, count)
        for name, count in report.existing_skill_issues.most_common()
        if count >= min_count
        and (include_builtins or not installed_skill_meta.get(name, SkillMeta(name, "", set(), False)).is_builtin)
    ]
    if not existing_rows:
        lines.append("- No clear failure patterns detected in the scanned window.")
    else:
        for name, count in existing_rows:
            lines.append(f"- `{name}`: {count} issue signal(s) after activation.")
            for ev in report.issue_evidence.get(name, []):
                lines.append(
                    f"  Evidence: `{ev.timestamp}` in `{ev.file_path}` -> \"{ev.snippet}\""
                )
            if name not in installed_skills:
                close = closest_skill(name, installed_skills)
                if close:
                    lines.append(
                        f"  Suggestion: add alias guidance in `{close}` or create `{name}` as a dedicated skill."
                    )
                else:
                    lines.append(
                        f"  Suggestion: create `{name}` or map it to an existing skill in discovery instructions."
                    )
            else:
                lines.append(
                    "  Suggestion: add compatibility checks/fallback logic for known error patterns."
                )

    if include_rename_candidates:
        lines.append("")
        lines.append("## Rename/Alias Candidates")
        alias_rows: list[tuple[str, int, str, float]] = []
        for name, count in report.unknown_invocations.most_common():
            if count < min_count or name in GENERIC_NON_SKILL_NAMES:
                continue
            mapped = semantic_skill_match(name, installed_skill_meta)
            if mapped:
                alias_rows.append((name, count, mapped[0], mapped[1]))

        if not alias_rows:
            lines.append("- None")
        else:
            for name, count, mapped_name, score in alias_rows:
                lines.append(
                    f"- `{name}`: requested {count} time(s), likely maps to `{mapped_name}` (semantic score {score:.2f})."
                )
                lines.append(
                    f"  Suggestion: update trigger wording/aliases in `{mapped_name}` so `{name}` is recognized."
                )
                for ev in report.unknown_evidence.get(name, []):
                    lines.append(
                        f"  Evidence: `{ev.timestamp}` in `{ev.file_path}` -> \"{ev.snippet}\""
                    )

    lines.append("")
    lines.append("## New Skill Candidates")
    unknown_rows = [
        (name, count)
        for name, count in report.unknown_invocations.most_common()
        if count >= min_count and name not in GENERIC_NON_SKILL_NAMES
    ]
    if not unknown_rows:
        lines.append("- No unknown `$skill` invocations detected.")
    else:
        for name, count in unknown_rows:
            mapped = semantic_skill_match(name, installed_skill_meta)
            if mapped and not include_rename_candidates:
                continue
            if mapped and include_rename_candidates:
                continue
            lines.append(f"- `{name}`: requested {count} time(s), not installed.")
            close = closest_skill(name, installed_skills)
            if close:
                lines.append(
                    f"  Suggestion: either create `{name}` or clarify that `{close}` handles this task."
                )
            else:
                lines.append(
                    f"  Suggestion: create a new `{name}` skill with task workflow and reusable scripts."
                )
            for ev in report.unknown_evidence.get(name, []):
                lines.append(
                    f"  Evidence: `{ev.timestamp}` in `{ev.file_path}` -> \"{ev.snippet}\""
                )
        if lines[-1] == "## New Skill Candidates":
            lines.append("- None after semantic alias mapping.")

    lines.append("")
    lines.append("## Fallback Tool Signals")
    if not report.builtin_tool_fallbacks:
        lines.append("- None")
    else:
        for name, count in report.builtin_tool_fallbacks.most_common():
            lines.append(f"- `{name}` fallback used {count} time(s)")

    lines.append("")
    lines.append("## Known Skill Invocation Counts")
    if not report.known_invocations:
        lines.append("- None")
    else:
        for name, count in report.known_invocations.most_common():
            lines.append(f"- `{name}`: {count}")

    return "\n".join(lines)


def json_report(
    report: Report,
    installed_skill_meta: dict[str, SkillMeta],
    min_count: int,
    include_rename_candidates: bool,
    include_builtins: bool,
) -> str:
    installed_skills = set(installed_skill_meta.keys())
    existing = []
    for name, count in report.existing_skill_issues.most_common():
        if count < min_count:
            continue
        meta = installed_skill_meta.get(name)
        if meta and meta.is_builtin and not include_builtins:
            continue
        existing.append(
            {
                "skill": name,
                "count": count,
                "installed": name in installed_skills,
                "closest_installed_skill": closest_skill(name, installed_skills),
                "evidence": [ev.__dict__ for ev in report.issue_evidence.get(name, [])],
            }
        )

    alias_mappings = []
    new_skills = []
    for name, count in report.unknown_invocations.most_common():
        if count < min_count or name in GENERIC_NON_SKILL_NAMES:
            continue
        mapped = semantic_skill_match(name, installed_skill_meta)
        if mapped:
            alias_mappings.append(
                {
                    "requested_name": name,
                    "count": count,
                    "mapped_skill": mapped[0],
                    "semantic_score": round(mapped[1], 3),
                    "evidence": [ev.__dict__ for ev in report.unknown_evidence.get(name, [])],
                }
            )
            continue
        new_skills.append(
            {
                "skill": name,
                "count": count,
                "closest_installed_skill": closest_skill(name, installed_skills),
                "evidence": [ev.__dict__ for ev in report.unknown_evidence.get(name, [])],
            }
        )

    payload = {
        "summary": {
            "files_scanned": report.files_scanned,
            "messages_scanned": report.messages_scanned,
            "installed_skills_count": report.installed_skills_count,
        },
        "existing_skill_improvements": existing,
        "rename_alias_candidates": alias_mappings if include_rename_candidates else [],
        "new_skill_candidates": new_skills,
        "fallback_tool_signals": dict(report.builtin_tool_fallbacks),
        "known_skill_invocations": dict(report.known_invocations),
    }
    return json.dumps(payload, indent=2)


def main() -> int:
    args = parse_args()
    sessions_dir = Path(args.sessions_dir).expanduser()
    skills_dir = Path(args.skills_dir).expanduser()

    installed_skill_meta = discover_installed_skills(skills_dir)
    installed_skills = set(installed_skill_meta.keys())
    session_files = iter_session_files(
        sessions_dir, args.max_files, args.exclude_active_minutes, args.since_days
    )
    report = analyze_sessions(session_files, installed_skills, args.max_evidence)

    if args.output == "json":
        print(
            json_report(
                report,
                installed_skill_meta,
                args.min_count,
                args.include_rename_candidates,
                args.include_builtins,
            )
        )
    else:
        print(
            markdown_report(
                report,
                installed_skill_meta,
                args.min_count,
                args.include_rename_candidates,
                args.include_builtins,
            )
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
