---
name: trim-static-video
description: Extract review frames and trim dull static sections from local video files with ffmpeg. Use when the user asks to remove boring, static, frozen, unchanged, idle, or dull parts of a recording, especially with a threshold like "same for more than 5 seconds"; default the dull/static threshold to 5 seconds when the user does not provide one.
---

# Trim Static Video

Use the bundled script first. It extracts review frames, detects frozen/still ranges with sampled `ffmpeg` `freezedetect`, seek-renders only the kept segments, concatenates them, and writes a JSON report. The default path is optimized for speed.

## Default Workflow

1. Identify the input video path from the user request.
2. Determine the dull/static threshold:
   - Use the user's requested value when they say things like "over 8 seconds", "more than 10s", or "static for 3 seconds".
   - Use `5` seconds when no value is provided.
3. Run:

```bash
python3 ~/.agents/skills/trim-static-video/scripts/trim_static_video.py "/absolute/path/to/video.mov" --dull-seconds 5
```

You may omit `--dull-seconds` when using the default, because the script defaults to `5.0`.

The default command is fast because it:

- Analyzes freezes at `2` fps and 426px width instead of full resolution.
- Extracts review frames in parallel with freeze detection.
- Renders only kept segments instead of decoding the skipped dull ranges.
- Uses macOS `h264_videotoolbox` automatically when ffmpeg exposes it; otherwise uses `libx264 -preset veryfast`.

## Outputs

The script never overwrites the input video. By default it writes:

- Trimmed video beside the input as `<stem>.trimmed-static.mp4`
- Frames under `.tmp/video-trim-<timestamp>/frames/` in the current working directory
- `trim-static-report.json` with detected freeze ranges, cut ranges, kept ranges, durations, and verification
- ffmpeg logs and filter scripts in the same work directory

Use `--output` or `--workdir` when the user asks for a specific destination.

## Tuning

- `--dull-seconds N`: threshold for what counts as dull/static. Default `5`.
- `--keep-static-seconds N`: amount of each static stretch to keep before cutting. Defaults to the dull threshold. Use a lower value when the final verification still reports long static spans.
- `--merge-gap-seconds N`: merge frozen ranges separated by short gaps before cutting. Defaults to `min(3, dull_seconds / 2)` so tiny changes do not recreate dull stretches after concatenation.
- `--analysis-fps N` and `--analysis-scale WIDTH:-2`: lower values are faster; raise them only when freeze detection misses meaningful movement.
- `--full-analysis`: use source frame rate/resolution for detection when precision matters more than speed.
- `--render-mode segments`: default; seek to kept ranges, encode those segments, then concat.
- `--render-mode copy`: fastest; stream-copy kept segments without re-encoding, but cuts are keyframe-bound and may retain extra static padding.
- `--render-mode filter`: slower; use one concat filter graph for tighter timestamp behavior.
- `--frames-fps N`: frame extraction rate. Default `1`.
- `--skip-frames`: render only the trimmed video and report.

For the fastest acceptable draft, run:

```bash
python3 ~/.agents/skills/trim-static-video/scripts/trim_static_video.py "/absolute/path/to/video.mov" --render-mode copy --skip-frames
```

For a fast final output with fewer retained dull frames, run:

```bash
python3 ~/.agents/skills/trim-static-video/scripts/trim_static_video.py "/absolute/path/to/video.mov" --keep-static-seconds 3
```

## Verification

After rendering, inspect the script's final summary. It reruns `freezedetect` on the trimmed output and warns if still spans remain longer than the dull threshold plus a small margin. If that happens, rerun with either:

```bash
python3 ~/.agents/skills/trim-static-video/scripts/trim_static_video.py "/absolute/path/to/video.mov" --dull-seconds 5 --keep-static-seconds 3
```

or increase `--merge-gap-seconds` when several short static ranges were separated by tiny motion gaps.

In the final response, report the output video path, frame directory, original duration, trimmed duration, removed duration, and whether verification found remaining over-threshold still spans.
