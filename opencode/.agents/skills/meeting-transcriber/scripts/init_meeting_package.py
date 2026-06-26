#!/usr/bin/env python3
"""Create a deterministic meeting-transcriber output package scaffold."""

from __future__ import annotations

import argparse
import json
import re
import shutil
from datetime import date
from pathlib import Path


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", value.strip().lower()).strip("-")
    return slug or "meeting"


def write_if_missing(path: Path, content: str) -> None:
    if not path.exists():
        path.write_text(content, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Create a meeting transcript package scaffold.")
    parser.add_argument("--title", required=True, help="Meeting title.")
    parser.add_argument("--source", action="append", default=[], help="Source media/transcript path or URL. May be repeated.")
    parser.add_argument("--transcript", help="Existing transcript file to copy into raw-transcript.md.")
    parser.add_argument("--media", help="Primary audio/video file path.")
    parser.add_argument("--repo", help="Related local repo path.")
    parser.add_argument("--github-comments", help="GitHub comments or annotations file path.")
    parser.add_argument("--date", default=date.today().isoformat(), help="Package date, default: today.")
    parser.add_argument("--slug", help="Directory slug. Defaults to title slug.")
    parser.add_argument("--out-dir", help="Output directory. Defaults to .tmp/meeting-transcriber-<date>-<slug>.")
    parser.add_argument("--force", action="store_true", help="Allow overwriting copied raw transcript.")
    args = parser.parse_args()

    slug = args.slug or slugify(args.title)
    out_dir = Path(args.out_dir or f".tmp/meeting-transcriber-{args.date}-{slug}").expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)
    for child in ("screenshots", "ocr"):
        (out_dir / child).mkdir(exist_ok=True)

    raw_transcript = out_dir / "raw-transcript.md"
    if args.transcript:
        transcript_path = Path(args.transcript).expanduser()
        if transcript_path.exists():
            if args.force or not raw_transcript.exists():
                shutil.copyfile(transcript_path, raw_transcript)
        else:
            raise SystemExit(f"Transcript not found: {transcript_path}")
    else:
        write_if_missing(raw_transcript, "# Raw Transcript\n\n")

    write_if_missing(out_dir / "speaker-transcript.md", "# Speaker Transcript\n\n")
    write_if_missing(out_dir / "visual-context.md", "# Visual Context\n\n")
    write_if_missing(out_dir / "ocr-notes.md", "# OCR Notes\n\n")
    write_if_missing(out_dir / "github-comments.md", "# GitHub Comments\n\n")

    manifest = {
        "title": args.title,
        "date": args.date,
        "sources": args.source,
        "transcript": args.transcript,
        "media": args.media,
        "repo": args.repo,
        "github_comments": args.github_comments,
        "outputs": {
            "raw_transcript": "raw-transcript.md",
            "speaker_transcript": "speaker-transcript.md",
            "visual_context": "visual-context.md",
            "ocr_notes": "ocr-notes.md",
            "github_comments": "github-comments.md",
            "screenshots": "screenshots/",
            "ocr": "ocr/",
        },
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    readme = f"""# {args.title}

Date: {args.date}

## Sources

"""
    for source in args.source:
        readme += f"- {source}\n"
    if args.media:
        readme += f"- Media: `{args.media}`\n"
    if args.transcript:
        readme += f"- Transcript: `{args.transcript}`\n"
    if args.github_comments:
        readme += f"- GitHub comments: `{args.github_comments}`\n"
    if args.repo:
        readme += f"- Repo: `{args.repo}`\n"
    readme += """
## Summary

## Key Decisions

## Action Items

## Open Questions

## Evidence

- [Raw transcript](raw-transcript.md)
- [Speaker transcript](speaker-transcript.md)
- [Visual context](visual-context.md)
- [OCR notes](ocr-notes.md)
- [GitHub comments](github-comments.md)
- [Screenshot directory](screenshots/)
"""
    write_if_missing(out_dir / "README.md", readme)

    print(out_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
