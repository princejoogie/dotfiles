---
name: meeting-transcriber
description: Transcribe local meeting audio/video or turn existing transcripts into summary, action, visual-context, and implementation-planning packages. Use when the user asks to transcribe, summarize, package, OCR-check, diarize, or extract tasks from a meeting recording, transcript, PR discussion, or repo-related meeting follow-up.
---

# Meeting Transcriber

Use this skill only when there is either an existing transcript or a local audio/video file to transcribe. If the user provides only a transcript, work from that text. If video/audio is also available, use it for transcription quality, screenshots, OCR, timing, and visual context as requested.

## Default Workflow

1. Identify inputs:
   - Transcript file or pasted transcript.
   - Local audio/video path when transcription or visual context is needed.
   - Optional participant names, GitHub PR/comment links, issue links, and local repo path.
2. Create a dated output directory in the current working directory, for example `.tmp/meeting-transcriber-YYYY-MM-DD-<slug>/`. Use `scripts/init_meeting_package.py` when a scaffold is helpful.
   - Store every artifact created by this skill inside that package folder. This includes transcripts, probes, screenshots, OCR text, converted comments, plans, manifests, and temporary helper outputs.
   - Do not write generated artifacts beside the source media, in the skill directory, or in another workspace unless the user explicitly asks for a different output location.
3. Preserve source evidence: keep raw transcript separate from speaker transcript, store screenshots under `screenshots/`, keep OCR/visual notes separate, and include source paths/links in the final README.
4. Produce only the deliverables the user requested, then validate that they cite the evidence used.

For detailed add-on rules, read `references/optional-inputs.md` when the user provides video, GitHub PR/comments, annotation JSON, issue links, or a local repo path. Read `references/output-package.md` before producing a multi-file package.

## Modes

### Transcript-Only Mode

- Do not invent timestamps, visual context, or speaker certainty that is absent from the transcript.
- Produce summaries, decisions, open questions, follow-ups, and action items from the transcript text.
- If speaker names are unclear, keep original labels or use `Speaker A`, `Speaker B`, etc. with a short confidence note.

### Audio/Video Transcription Mode

- Inspect media metadata first with tools such as `ffprobe` to confirm duration, stream count, channels, and codec.
- Check whether audio channels are genuinely separable before promising channel-based diarization. Stereo channels can be identical or mixed.
- Transcribe with the best available local toolchain. Prefer an existing working Whisper environment or cached model before installing anything new.
- Save:
  - `raw-transcript.md` or `.txt` with minimally edited transcription output.
  - `speaker-transcript.md` with best-effort speaker labels and confidence notes.
- Keep diarization realistic. If participants are known but the audio is mixed, label as named speakers only when the speech evidence supports it; otherwise use `Speaker A/B` plus notes like "best-effort, mixed audio".

### Visual Context Mode

- Sample frames around topic changes, screen changes, or moments where the transcript references visible artifacts.
- Save screenshots with timestamps, for example `screenshots/00-12-34-settings-page.png`. Use `scripts/extract_screenshots.py` when timestamps are known.
- Run OCR or manual frame inspection on screenshots that contain names, file paths, UI labels, APIs, branches, ticket IDs, or product terms.
- Use visible text to correct spelling and terminology in summaries and action items.
- Keep `visual-context.md` or `ocr-notes.md` separate from transcript files, and link each note back to screenshot filenames or timestamps.

### PR/Repo Consolidation Mode

- Fetch or inspect PR comments only when requested or clearly relevant to the meeting follow-up.
- If the user supplies exported GitHub annotations JSON, use `scripts/annotations_to_markdown.py` to create a readable review-comments file before grouping work.
- Use repo files, branches, API names, paths, package scripts, and comments to correct exact spelling and group related action items.
- Create implementation plans, worktree plans, Jira-ticket copy, Notion copy, or handoff notes only when the user asks for those outputs.
- Do not implement code from this skill unless the user explicitly asks to start implementation after the transcription package is complete.

## Helper Scripts

Run helpers from the current working directory where the output package should live, and point every helper output into that package folder:

```bash
python /Users/pjuguilon/.agents/skills/meeting-transcriber/scripts/init_meeting_package.py --title "Meeting title" --source /path/to/input.mov --out-dir .tmp/meeting-transcriber-YYYY-MM-DD-slug
python /Users/pjuguilon/.agents/skills/meeting-transcriber/scripts/probe_media.py /path/to/input.mov --output .tmp/meeting-transcriber-YYYY-MM-DD-slug/media-probe.md
python /Users/pjuguilon/.agents/skills/meeting-transcriber/scripts/extract_screenshots.py /path/to/video.mov --out-dir .tmp/meeting-transcriber-YYYY-MM-DD-slug/screenshots --timestamp 00:12:34 --timestamp 00:45:10
python /Users/pjuguilon/.agents/skills/meeting-transcriber/scripts/ocr_screenshots.py .tmp/meeting-transcriber-YYYY-MM-DD-slug/screenshots --output-dir .tmp/meeting-transcriber-YYYY-MM-DD-slug/ocr --index .tmp/meeting-transcriber-YYYY-MM-DD-slug/ocr-notes.md
python /Users/pjuguilon/.agents/skills/meeting-transcriber/scripts/annotations_to_markdown.py annotations.json --output .tmp/meeting-transcriber-YYYY-MM-DD-slug/github-comments.md
```

## Deliverable Package

Prefer this shape when the user asks for a full package. The package root is always relative to the current working directory unless the user explicitly requests another location:

```text
.tmp/meeting-transcriber-YYYY-MM-DD-<slug>/
  README.md
  raw-transcript.md
  speaker-transcript.md
  visual-context.md
  ocr-notes.md
  github-comments.md
  worktree-plan.md
  jira-tickets.md
  notion-handoff.md
  screenshots/
```

Only create optional files that are actually supported by available inputs and requested outputs.

`README.md` should include:

- Meeting title/date/source, summary, decisions, action items, open questions, evidence links, and confidence notes.

## Validation and Closeout

- Confirm every requested deliverable exists and is non-empty.
- Spot-check transcript excerpts against audio/video when media is available.
- Spot-check OCR-sensitive names, paths, APIs, branches, and issue IDs against screenshots, PR comments, or repo files.
- Check that screenshot filenames and README references match actual files.
- Report final artifact paths, notable confidence limits, and any requested outputs that could not be produced.
