#!/usr/bin/env python3
"""Convert exported GitHub annotation/comment JSON into Markdown."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def pick(data: dict[str, Any], *names: str) -> Any:
    for name in names:
        if name in data and data[name] not in (None, ""):
            return data[name]
    return ""


def flatten_items(data: Any) -> list[dict[str, Any]]:
    if isinstance(data, list):
        return [item for item in data if isinstance(item, dict)]
    if isinstance(data, dict):
        for key in ("annotations", "comments", "items", "reviewComments", "nodes"):
            value = data.get(key)
            if isinstance(value, list):
                return [item for item in value if isinstance(item, dict)]
    raise SystemExit("Could not find a list of annotation/comment objects in the JSON file.")


def comment_url(item: dict[str, Any]) -> str:
    meta = item.get("meta")
    if isinstance(meta, dict):
        url = pick(meta, "url", "html_url", "discussion_url")
        if url:
            return str(url)
    return str(pick(item, "url", "html_url", "discussion_url"))


def author_name(value: Any) -> str:
    if isinstance(value, dict):
        return str(pick(value, "login", "name", "email"))
    return str(value) if value else ""


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert GitHub annotations JSON to Markdown.")
    parser.add_argument("input", help="Input JSON file.")
    parser.add_argument("--output", default="github-comments.md", help="Output Markdown file.")
    parser.add_argument("--include-resolved", action="store_true", help="Include resolved comments.")
    args = parser.parse_args()

    source = Path(args.input).expanduser()
    data = json.loads(source.read_text(encoding="utf-8"))
    items = flatten_items(data)

    lines = ["# GitHub Comments", "", f"Source: `{source}`", ""]
    count = 0
    for index, item in enumerate(items, start=1):
        resolved = bool(item.get("resolved"))
        if resolved and not args.include_resolved:
            continue
        filename = pick(item, "filename", "path", "file", "filePath") or "(unknown file)"
        line = pick(item, "linenumber", "line", "position", "startLine")
        body = pick(item, "annotation", "body", "comment", "text") or "(no comment text)"
        author = author_name(pick(item, "author", "user", "login"))
        url = comment_url(item)
        status = "resolved" if resolved else "unresolved"
        count += 1
        lines.append(f"## {count}. `{filename}`")
        if line:
            lines.append(f"- Line: `{line}`")
        lines.append(f"- Status: {status}")
        if author:
            lines.append(f"- Author: {author}")
        if url:
            lines.append(f"- URL: {url}")
        lines.extend(["", str(body).strip(), ""])

    output = Path(args.output).expanduser()
    output.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
