# Output Package

Use this reference before creating a multi-file meeting package.

## Package Root Rule

Create the package folder in the current working directory, for example `.tmp/meeting-transcriber-YYYY-MM-DD-<slug>/`.

All artifacts created by this skill must stay inside that package folder. This includes transcripts, probes, screenshots, OCR text, converted comments, plans, manifests, and temporary helper outputs. Do not write generated files beside the source media, in the skill directory, or in another workspace unless the user explicitly asks for a different output location.

## Recommended Layout

```text
.tmp/meeting-transcriber-YYYY-MM-DD-<slug>/
  README.md
  raw-transcript.md
  speaker-transcript.md
  visual-context.md
  ocr-notes.md
  github-comments.md
  media-probe.md
  worktree-plan.md
  jira-tickets/
  notion-handoff.md
  screenshots/
  ocr/
  manifest.json
```

Create only the files justified by inputs and requested outputs, and keep all of them under the package root.

## README Contents

- Meeting title, date, source files, and participants when known.
- Short summary.
- Key decisions.
- Action items with owners when supported by evidence.
- Open questions and risks.
- Links to transcript, visual notes, screenshots, PR comments, repo files, and generated plans.
- Confidence notes for diarization, transcription quality, OCR, or missing context.

## Evidence Rules

- Keep raw transcript separate from edited/speaker-labeled transcript.
- Do not hide uncertainty. Mark best-effort speaker labels, uncertain OCR, and inferred action owners.
- Prefer exact source paths, PR URLs, screenshot filenames, and timestamps over vague references.
- When a transcript section refers to visible UI, include a screenshot reference if video is available.
- When repo or PR context changes spelling or interpretation, note the source that corrected it.
- Keep generated helper outputs such as `manifest.json`, `media-probe.md`, `screenshot-references.md`, and OCR `.txt` files in the package so later agents can audit the summary.

## Planning Outputs

- Create implementation plans, worktree plans, Jira copy, Notion pages, or thread handoffs only when requested.
- Keep high-level indexes short and place detailed branch/task context in separate files.
- For stacked work, identify base branch, dependencies, validation, out-of-scope items, and why the ticket exists.
- Do not start implementation as part of meeting packaging unless explicitly asked.
