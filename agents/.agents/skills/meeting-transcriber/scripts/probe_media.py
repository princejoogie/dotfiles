#!/usr/bin/env python3
"""Probe local audio/video metadata with ffprobe and write audit artifacts."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
from pathlib import Path
from typing import Any


def run_ffprobe(path: Path) -> dict[str, Any]:
    if not shutil.which("ffprobe"):
        raise SystemExit("ffprobe is required but was not found on PATH.")
    cmd = [
        "ffprobe",
        "-v",
        "error",
        "-show_format",
        "-show_streams",
        "-of",
        "json",
        str(path),
    ]
    result = subprocess.run(cmd, check=True, capture_output=True, text=True)
    return json.loads(result.stdout)


def markdown_report(path: Path, probe: dict[str, Any]) -> str:
    fmt = probe.get("format", {})
    streams = probe.get("streams", [])
    lines = [
        "# Media Probe",
        "",
        f"Source: `{path}`",
        "",
        "## Format",
        "",
        f"- Duration: `{fmt.get('duration', '')}` seconds",
        f"- Format: `{fmt.get('format_name', '')}`",
        f"- Bit rate: `{fmt.get('bit_rate', '')}`",
        "",
        "## Streams",
        "",
    ]
    for stream in streams:
        index = stream.get("index", "")
        codec_type = stream.get("codec_type", "")
        codec_name = stream.get("codec_name", "")
        lines.append(f"### Stream {index}: {codec_type}")
        lines.append("")
        lines.append(f"- Codec: `{codec_name}`")
        if codec_type == "audio":
            lines.append(f"- Channels: `{stream.get('channels', '')}`")
            lines.append(f"- Channel layout: `{stream.get('channel_layout', '')}`")
            lines.append(f"- Sample rate: `{stream.get('sample_rate', '')}`")
        if codec_type == "video":
            lines.append(f"- Size: `{stream.get('width', '')}x{stream.get('height', '')}`")
            lines.append(f"- Frame rate: `{stream.get('r_frame_rate', '')}`")
        lines.append("")
    lines.extend(
        [
            "## Diarization Notes",
            "",
            "- Multiple channels do not prove separable speakers. Inspect or compare channels before promising channel-based diarization.",
            "- If audio is mixed, use best-effort speaker labels with confidence notes.",
        ]
    )
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Probe local media metadata.")
    parser.add_argument("media", help="Local audio/video path.")
    parser.add_argument("--output", default="media-probe.md", help="Markdown report path.")
    parser.add_argument("--json-output", help="Optional raw ffprobe JSON output path.")
    args = parser.parse_args()

    media = Path(args.media).expanduser()
    if not media.exists():
        raise SystemExit(f"Media not found: {media}")

    probe = run_ffprobe(media)
    output = Path(args.output).expanduser()
    output.write_text(markdown_report(media, probe), encoding="utf-8")
    if args.json_output:
        Path(args.json_output).expanduser().write_text(json.dumps(probe, indent=2) + "\n", encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
