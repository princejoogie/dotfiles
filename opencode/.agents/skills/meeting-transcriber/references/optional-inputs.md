# Optional Inputs

Use this reference when a meeting package includes more than plain transcript text.

## Transcript-Only

- Preserve the original transcript as `raw-transcript.md` or reference the supplied source file.
- Do not invent timestamps, visual evidence, or speaker identity if the transcript does not support it.
- Produce decisions, action items, open questions, and follow-up groupings from the text alone.

## Audio Or Video

- Probe media first with `ffprobe` or equivalent to capture duration, streams, channels, and codec.
- Use `scripts/probe_media.py` when you need a reusable Markdown/JSON probe artifact.
- Verify whether channels are actually separable before promising channel-based diarization.
- Prefer a known local Whisper environment or cached model before installing anything new.
- Keep the raw transcription and speaker-labeled transcript as separate files.
- When video exists, inspect frames around topic shifts and moments where people point at or discuss visible UI.

## Screenshot References And OCR

- Extract frames only where they add context: screen changes, pointed-at UI, exact file names, code snippets, issue IDs, or PR comments.
- Use `scripts/extract_screenshots.py` for timestamped frame extraction and `scripts/ocr_screenshots.py` for tesseract-backed OCR when available.
- Name screenshots with timestamps so they can be traced back to the transcript.
- Use OCR or manual inspection to correct names, file paths, branch names, APIs, and visible text.
- Link every visual note to the screenshot filename and timestamp.
- Do not over-capture static frames that add no context.

## GitHub PR Or Annotation JSON

- If a PR URL is supplied, inspect current comments only when the user asks to use PR context.
- If exported annotations JSON is supplied, convert it into `github-comments.md` before summarizing or grouping.
- Group related comments by behavior or ownership boundary, not just by filename.
- Keep comment URLs and file/line references when available.
- Do not resolve comments, push code, or change repo files unless the user separately asks for implementation.

## Local Repo Path

- Read repo guidance first, such as `AGENTS.md`, local skills, or docs that define workflow standards.
- Use codebase context to correct transcript spelling and to understand which comments/tasks belong together.
- Keep repo inspection scoped to the meeting follow-up; avoid unrelated refactors or broad audits.
- When turning discussion into implementation plans, cite the repo files and plan files that justify the grouping.
