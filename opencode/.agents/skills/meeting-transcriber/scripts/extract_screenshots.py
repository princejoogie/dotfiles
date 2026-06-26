#!/usr/bin/env python3
"""Extract timestamped screenshot references from a local video with ffmpeg."""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
from pathlib import Path


def safe_timestamp(value: str) -> str:
    cleaned = value.strip()
    if re.fullmatch(r"\d+(\.\d+)?", cleaned):
        total = int(float(cleaned))
        h, rem = divmod(total, 3600)
        m, s = divmod(rem, 60)
        return f"{h:02d}-{m:02d}-{s:02d}"
    return re.sub(r"[^0-9A-Za-z]+", "-", cleaned).strip("-")


def read_timestamps(args: argparse.Namespace) -> list[str]:
    values = list(args.timestamp or [])
    if args.timestamps_file:
        for line in Path(args.timestamps_file).expanduser().read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                values.append(line.split()[0])
    if not values:
        raise SystemExit("Provide --timestamp or --timestamps-file.")
    return values


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract screenshot frames at given timestamps.")
    parser.add_argument("video", help="Local video path.")
    parser.add_argument("--out-dir", required=True, help="Directory for extracted screenshots.")
    parser.add_argument("--timestamp", action="append", help="Timestamp such as 00:12:34 or seconds. May be repeated.")
    parser.add_argument("--timestamps-file", help="File containing one timestamp per line.")
    parser.add_argument("--prefix", default="frame", help="Screenshot filename prefix.")
    parser.add_argument("--ext", default="png", choices=("png", "jpg", "jpeg"), help="Image extension.")
    parser.add_argument("--overwrite", action="store_true", help="Overwrite existing screenshots.")
    args = parser.parse_args()

    if not shutil.which("ffmpeg"):
        raise SystemExit("ffmpeg is required but was not found on PATH.")

    video = Path(args.video).expanduser()
    if not video.exists():
        raise SystemExit(f"Video not found: {video}")

    out_dir = Path(args.out_dir).expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)
    refs: list[tuple[str, Path]] = []

    for ts in read_timestamps(args):
        name = f"{args.prefix}-{safe_timestamp(ts)}.{args.ext}"
        out_file = out_dir / name
        if out_file.exists() and not args.overwrite:
            refs.append((ts, out_file))
            continue
        cmd = [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y" if args.overwrite else "-n",
            "-ss",
            ts,
            "-i",
            str(video),
            "-frames:v",
            "1",
            str(out_file),
        ]
        subprocess.run(cmd, check=True)
        refs.append((ts, out_file))

    index = out_dir / "screenshot-references.md"
    lines = ["# Screenshot References", "", "| Timestamp | File |", "|---|---|"]
    for ts, path in refs:
        lines.append(f"| `{ts}` | `{path.name}` |")
    index.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(index)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
