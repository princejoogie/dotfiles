#!/usr/bin/env python3
"""Trim static/dull ranges from a video with ffmpeg freezedetect."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import platform
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any


FREEZE_START_RE = re.compile(r"freeze_start: ([0-9.]+)")
FREEZE_END_RE = re.compile(r"freeze_end: ([0-9.]+)")
FREEZE_DURATION_RE = re.compile(r"freeze_duration: ([0-9.]+)")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract review frames and trim static video ranges with ffmpeg."
    )
    parser.add_argument("input", type=Path, help="Input video path.")
    parser.add_argument(
        "--dull-seconds",
        type=float,
        default=5.0,
        help="Seconds a frame may stay unchanged before it is considered dull. Default: 5.",
    )
    parser.add_argument(
        "--keep-static-seconds",
        type=float,
        default=None,
        help="Seconds of each static stretch to preserve. Default: same as --dull-seconds.",
    )
    parser.add_argument(
        "--merge-gap-seconds",
        type=float,
        default=None,
        help="Merge detected static ranges separated by this gap. Default: min(3, dull_seconds / 2).",
    )
    parser.add_argument(
        "--noise",
        default="-60dB",
        help="ffmpeg freezedetect noise threshold. Default: -60dB.",
    )
    parser.add_argument(
        "--analysis-fps",
        type=float,
        default=2.0,
        help="FPS used for freeze detection. Lower is faster. Default: 2.",
    )
    parser.add_argument(
        "--analysis-scale",
        default="426:-2",
        help="Scale used for freeze detection. Smaller is faster. Default: 426:-2.",
    )
    parser.add_argument(
        "--full-analysis",
        action="store_true",
        help="Run freeze detection at source frame rate/resolution.",
    )
    parser.add_argument(
        "--frames-fps",
        type=float,
        default=1.0,
        help="FPS for review frame extraction. Default: 1.",
    )
    parser.add_argument(
        "--frame-scale",
        default="1280:-2",
        help="Scale for extracted frames. Default: 1280:-2.",
    )
    parser.add_argument(
        "--skip-frames",
        action="store_true",
        help="Skip review frame extraction.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="Output MP4 path. Default: input stem plus .trimmed-static.mp4 beside input.",
    )
    parser.add_argument(
        "--workdir",
        type=Path,
        default=None,
        help="Artifact directory. Default: .tmp/video-trim-<timestamp> in the current directory.",
    )
    parser.add_argument(
        "--crf",
        type=int,
        default=22,
        help="libx264 CRF for rendered output. Default: 22.",
    )
    parser.add_argument(
        "--preset",
        default="veryfast",
        help="libx264 preset for encoded segments. Default: veryfast.",
    )
    parser.add_argument(
        "--encoder",
        choices=["auto", "libx264", "h264_videotoolbox"],
        default="auto",
        help="Video encoder. Default: auto, using VideoToolbox on macOS when available.",
    )
    parser.add_argument(
        "--video-bitrate",
        default="4M",
        help="Bitrate for h264_videotoolbox. Default: 4M.",
    )
    parser.add_argument(
        "--render-mode",
        choices=["segments", "filter", "copy"],
        default="segments",
        help=(
            "segments seeks to kept ranges and encodes only them; filter is frame-accurate but slower; "
            "copy is fastest but keyframe-bound. Default: segments."
        ),
    )
    parser.add_argument(
        "--verify-margin-seconds",
        type=float,
        default=0.25,
        help="Verification warning margin above dull-seconds. Default: 0.25.",
    )
    return parser.parse_args()


def require_binary(name: str) -> None:
    if shutil.which(name) is None:
        raise SystemExit(f"Missing required binary: {name}")


def run(args: list[str], log_path: Path | None = None) -> subprocess.CompletedProcess[str]:
    if log_path is None:
        return subprocess.run(args, check=True, text=True)

    with log_path.open("w") as log_file:
        return subprocess.run(
            args,
            check=True,
            text=True,
            stdout=log_file,
            stderr=log_file,
        )


def start(args: list[str], log_path: Path) -> tuple[subprocess.Popen[str], Any, list[str]]:
    log_file = log_path.open("w")
    process = subprocess.Popen(args, text=True, stdout=log_file, stderr=log_file)
    return process, log_file, args


def wait(started: tuple[subprocess.Popen[str], Any, list[str]]) -> None:
    process, log_file, args = started
    return_code = process.wait()
    log_file.close()
    if return_code != 0:
        raise subprocess.CalledProcessError(return_code, args)


def capture(args: list[str]) -> str:
    result = subprocess.run(args, check=True, text=True, capture_output=True)
    return result.stdout.strip()


def ffprobe_duration(path: Path) -> float:
    value = capture(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=nokey=1:noprint_wrappers=1",
            str(path),
        ]
    )
    return float(value)


def ffprobe_has_audio(path: Path) -> bool:
    value = capture(
        [
            "ffprobe",
            "-v",
            "error",
            "-select_streams",
            "a",
            "-show_entries",
            "stream=index",
            "-of",
            "csv=p=0",
            str(path),
        ]
    )
    return bool(value)


def ffmpeg_has_encoder(encoder: str) -> bool:
    try:
        return encoder in capture(["ffmpeg", "-hide_banner", "-encoders"])
    except subprocess.CalledProcessError:
        return False


def choose_encoder(requested: str) -> str:
    if requested != "auto":
        return requested
    if platform.system() == "Darwin" and ffmpeg_has_encoder("h264_videotoolbox"):
        return "h264_videotoolbox"
    return "libx264"


def encode_args(args: argparse.Namespace, encoder: str, has_audio: bool) -> list[str]:
    if encoder == "h264_videotoolbox":
        result = ["-c:v", "h264_videotoolbox", "-b:v", args.video_bitrate, "-pix_fmt", "yuv420p"]
    else:
        result = [
            "-c:v",
            "libx264",
            "-preset",
            args.preset,
            "-crf",
            str(args.crf),
            "-pix_fmt",
            "yuv420p",
        ]
    if has_audio:
        result.extend(["-c:a", "aac", "-b:a", "192k"])
    return result


def freeze_filter(args: argparse.Namespace) -> str:
    detector = f"freezedetect=n={args.noise}:d={args.dull_seconds:g}"
    if args.full_analysis:
        return detector

    filters = []
    if args.analysis_fps > 0:
        filters.append(f"fps={args.analysis_fps:g}")
    if args.analysis_scale:
        filters.append(f"scale={args.analysis_scale}")
    filters.append(detector)
    return ",".join(filters)


def parse_freezes(log_path: Path, fallback_end: float | None = None) -> list[dict[str, float]]:
    ranges: list[dict[str, float]] = []
    current_start: float | None = None
    pending_duration: float | None = None

    for line in log_path.read_text(errors="replace").splitlines():
        if start_match := FREEZE_START_RE.search(line):
            current_start = float(start_match.group(1))
            pending_duration = None
        if duration_match := FREEZE_DURATION_RE.search(line):
            pending_duration = float(duration_match.group(1))
        if end_match := FREEZE_END_RE.search(line):
            end = float(end_match.group(1))
            if current_start is not None:
                duration = pending_duration if pending_duration is not None else end - current_start
                ranges.append(
                    {
                        "start": current_start,
                        "end": end,
                        "duration": duration,
                    }
                )
            current_start = None
            pending_duration = None

    if current_start is not None and fallback_end is not None and fallback_end > current_start:
        ranges.append(
            {
                "start": current_start,
                "end": fallback_end,
                "duration": fallback_end - current_start,
            }
        )

    return [item for item in ranges if item["end"] > item["start"]]


def merge_ranges(
    ranges: list[dict[str, float]],
    gap_seconds: float,
) -> list[dict[str, float]]:
    merged: list[dict[str, float]] = []
    for item in sorted(ranges, key=lambda row: row["start"]):
        start = item["start"]
        end = item["end"]
        if merged and start <= merged[-1]["end"] + gap_seconds:
            merged[-1]["end"] = max(merged[-1]["end"], end)
            merged[-1]["duration"] = merged[-1]["end"] - merged[-1]["start"]
        else:
            merged.append({"start": start, "end": end, "duration": end - start})
    return merged


def build_ranges(
    duration: float,
    freeze_ranges: list[dict[str, float]],
    keep_static_seconds: float,
) -> tuple[list[dict[str, float]], list[dict[str, float]]]:
    cuts: list[dict[str, float]] = []
    for item in freeze_ranges:
        cut_start = min(item["end"], item["start"] + keep_static_seconds)
        if item["end"] - cut_start > 0.05:
            cuts.append(
                {
                    "start": cut_start,
                    "end": item["end"],
                    "duration": item["end"] - cut_start,
                }
            )

    kept: list[dict[str, float]] = []
    cursor = 0.0
    for cut in cuts:
        if cut["start"] > cursor + 0.05:
            kept.append(
                {
                    "start": cursor,
                    "end": cut["start"],
                    "duration": cut["start"] - cursor,
                }
            )
        cursor = max(cursor, cut["end"])

    if cursor < duration - 0.05:
        kept.append({"start": cursor, "end": duration, "duration": duration - cursor})

    return cuts, kept


def write_filter_script(path: Path, kept: list[dict[str, float]], has_audio: bool) -> None:
    parts: list[str] = []
    concat_inputs: list[str] = []

    for index, item in enumerate(kept):
        start = item["start"]
        end = item["end"]
        parts.append(f"[0:v]trim=start={start:.6f}:end={end:.6f},setpts=PTS-STARTPTS[v{index}]")
        if has_audio:
            parts.append(
                f"[0:a]atrim=start={start:.6f}:end={end:.6f},asetpts=PTS-STARTPTS[a{index}]"
            )
            concat_inputs.append(f"[v{index}][a{index}]")
        else:
            concat_inputs.append(f"[v{index}]")

    if has_audio:
        parts.append("".join(concat_inputs) + f"concat=n={len(kept)}:v=1:a=1[outv][outa]")
    else:
        parts.append("".join(concat_inputs) + f"concat=n={len(kept)}:v=1:a=0[outv]")

    path.write_text(";\n".join(parts) + "\n")


def quote_concat_path(path: Path) -> str:
    return str(path).replace("'", r"'\''")


def write_concat_file(path: Path, segment_paths: list[Path]) -> None:
    path.write_text("".join(f"file '{quote_concat_path(item)}'\n" for item in segment_paths))


def render_segments(
    input_path: Path,
    output_path: Path,
    kept: list[dict[str, float]],
    has_audio: bool,
    args: argparse.Namespace,
    workdir: Path,
    encoder: str,
    copy: bool,
) -> None:
    segments_dir = workdir / ("copy-segments" if copy else "encoded-segments")
    segments_dir.mkdir(parents=True, exist_ok=True)
    segment_paths: list[Path] = []

    for index, item in enumerate(kept):
        segment_path = segments_dir / f"segment_{index:04d}.mp4"
        segment_paths.append(segment_path)
        command = [
            "ffmpeg",
            "-hide_banner",
            "-y",
            "-ss",
            f"{item['start']:.6f}",
            "-i",
            str(input_path),
            "-t",
            f"{item['duration']:.6f}",
            "-map",
            "0:v:0",
        ]
        if has_audio:
            command.extend(["-map", "0:a:0?"])
        if copy:
            command.extend(["-c", "copy"])
        else:
            command.extend(encode_args(args, encoder, has_audio))
        command.extend(["-avoid_negative_ts", "make_zero", "-movflags", "+faststart", str(segment_path)])
        run(command, workdir / f"segment-{index:04d}.log")

    concat_path = workdir / "segments.ffconcat"
    write_concat_file(concat_path, segment_paths)
    run(
        [
            "ffmpeg",
            "-hide_banner",
            "-y",
            "-f",
            "concat",
            "-safe",
            "0",
            "-i",
            str(concat_path),
            "-c",
            "copy",
            "-movflags",
            "+faststart",
            str(output_path),
        ],
        workdir / "concat.log",
    )


def render_filter(
    input_path: Path,
    output_path: Path,
    kept: list[dict[str, float]],
    has_audio: bool,
    args: argparse.Namespace,
    workdir: Path,
    encoder: str,
) -> None:
    filter_path = workdir / "trim-filter-complex.txt"
    write_filter_script(filter_path, kept, has_audio)
    command = [
        "ffmpeg",
        "-hide_banner",
        "-y",
        "-i",
        str(input_path),
        "-filter_complex_script",
        str(filter_path),
        "-map",
        "[outv]",
    ]
    if has_audio:
        command.extend(["-map", "[outa]"])
    command.extend(encode_args(args, encoder, has_audio))
    command.extend(["-movflags", "+faststart", str(output_path)])
    run(command, workdir / "render.log")


def seconds(value: float) -> str:
    return f"{value:.2f}s"


def main() -> int:
    args = parse_args()
    require_binary("ffmpeg")
    require_binary("ffprobe")

    input_path = args.input.expanduser().resolve()
    if not input_path.exists():
        raise SystemExit(f"Input video does not exist: {input_path}")
    if args.dull_seconds <= 0:
        raise SystemExit("--dull-seconds must be greater than 0")

    keep_static_seconds = (
        args.keep_static_seconds if args.keep_static_seconds is not None else args.dull_seconds
    )
    if keep_static_seconds < 0:
        raise SystemExit("--keep-static-seconds must be >= 0")

    merge_gap_seconds = (
        args.merge_gap_seconds
        if args.merge_gap_seconds is not None
        else min(3.0, args.dull_seconds / 2.0)
    )
    if merge_gap_seconds < 0:
        raise SystemExit("--merge-gap-seconds must be >= 0")

    timestamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    workdir = (
        args.workdir.expanduser().resolve()
        if args.workdir is not None
        else Path.cwd() / ".tmp" / f"video-trim-{timestamp}"
    )
    workdir.mkdir(parents=True, exist_ok=True)

    output_path = (
        args.output.expanduser().resolve()
        if args.output is not None
        else input_path.with_name(f"{input_path.stem}.trimmed-static.mp4")
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)

    duration = ffprobe_duration(input_path)
    has_audio = ffprobe_has_audio(input_path)
    encoder = choose_encoder(args.encoder)
    detector_filter = freeze_filter(args)

    frames_dir = workdir / "frames"
    frame_process: tuple[subprocess.Popen[str], Any, list[str]] | None = None
    if not args.skip_frames:
        frames_dir.mkdir(parents=True, exist_ok=True)
        frame_process = start(
            [
                "ffmpeg",
                "-hide_banner",
                "-y",
                "-i",
                str(input_path),
                "-vf",
                f"fps={args.frames_fps:g},scale={args.frame_scale}",
                "-q:v",
                "3",
                str(frames_dir / "frame_%05d.jpg"),
            ],
            workdir / "extract-frames.log",
        )

    freeze_log = workdir / "freezedetect.log"
    freeze_process = start(
        [
            "ffmpeg",
            "-hide_banner",
            "-i",
            str(input_path),
            "-vf",
            detector_filter,
            "-an",
            "-f",
            "null",
            "-",
        ],
        freeze_log,
    )
    wait(freeze_process)
    if frame_process is not None:
        wait(frame_process)

    freeze_ranges = parse_freezes(freeze_log, fallback_end=duration)
    merged_freeze_ranges = merge_ranges(freeze_ranges, merge_gap_seconds)
    cuts, kept = build_ranges(duration, merged_freeze_ranges, keep_static_seconds)

    if cuts:
        if args.render_mode == "filter":
            render_filter(input_path, output_path, kept, has_audio, args, workdir, encoder)
        elif args.render_mode == "copy":
            render_segments(input_path, output_path, kept, has_audio, args, workdir, encoder, copy=True)
        else:
            render_segments(input_path, output_path, kept, has_audio, args, workdir, encoder, copy=False)
    else:
        run(
            [
                "ffmpeg",
                "-hide_banner",
                "-y",
                "-i",
                str(input_path),
                "-c",
                "copy",
                "-movflags",
                "+faststart",
                str(output_path),
            ],
            workdir / "copy.log",
        )

    output_duration = ffprobe_duration(output_path)
    frame_count = len(list(frames_dir.glob("frame_*.jpg"))) if frames_dir.exists() else 0

    verify_log = workdir / "freezedetect-trimmed.log"
    run(
        [
            "ffmpeg",
            "-hide_banner",
            "-i",
            str(output_path),
            "-vf",
            detector_filter,
            "-an",
            "-f",
            "null",
            "-",
        ],
        verify_log,
    )
    verification_ranges = parse_freezes(verify_log, fallback_end=output_duration)
    over_threshold_ranges = [
        item
        for item in verification_ranges
        if item["duration"] > args.dull_seconds + args.verify_margin_seconds
    ]

    report: dict[str, Any] = {
        "source": str(input_path),
        "output": str(output_path),
        "workdir": str(workdir),
        "frames_dir": str(frames_dir) if frames_dir.exists() else None,
        "frame_count": frame_count,
        "dull_seconds": args.dull_seconds,
        "keep_static_seconds": keep_static_seconds,
        "merge_gap_seconds": merge_gap_seconds,
        "noise": args.noise,
        "analysis_filter": detector_filter,
        "analysis_fps": None if args.full_analysis else args.analysis_fps,
        "analysis_scale": None if args.full_analysis else args.analysis_scale,
        "render_mode": args.render_mode,
        "encoder": encoder if args.render_mode != "copy" else "copy",
        "original_duration_seconds": duration,
        "trimmed_duration_seconds": output_duration,
        "removed_seconds": max(0.0, duration - output_duration),
        "freeze_ranges_seconds": freeze_ranges,
        "merged_freeze_ranges_seconds": merged_freeze_ranges,
        "cuts_seconds": cuts,
        "kept_ranges_seconds": kept,
        "verification_freeze_ranges_seconds": verification_ranges,
        "verification_over_threshold_ranges_seconds": over_threshold_ranges,
    }
    report_path = workdir / "trim-static-report.json"
    report_path.write_text(json.dumps(report, indent=2) + "\n")

    print("Done")
    print(f"Output: {output_path}")
    print(f"Frames: {frames_dir} ({frame_count})" if frames_dir.exists() else "Frames: skipped")
    print(f"Report: {report_path}")
    print(f"Mode: {args.render_mode}")
    print(f"Encoder: {encoder if args.render_mode != 'copy' else 'copy'}")
    print(f"Original duration: {seconds(duration)}")
    print(f"Trimmed duration: {seconds(output_duration)}")
    print(f"Removed: {seconds(report['removed_seconds'])}")
    if over_threshold_ranges:
        print(
            "Verification: warning, remaining static spans exceed "
            f"{seconds(args.dull_seconds + args.verify_margin_seconds)}"
        )
    else:
        print(
            "Verification: no remaining static spans over "
            f"{seconds(args.dull_seconds + args.verify_margin_seconds)}"
        )

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        print(f"Command failed with exit code {error.returncode}: {' '.join(error.cmd)}", file=sys.stderr)
        raise SystemExit(error.returncode)
