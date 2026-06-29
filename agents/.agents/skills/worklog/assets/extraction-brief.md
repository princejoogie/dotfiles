<!-- Sub-agent brief template for the worklog skill. The skill replaces {{CHANGE}}, {{TRANSCRIPT_PATH}}
     and {{WORKLOG_PATH}}, then hands the filled text to a fresh sub-agent. Keep the wording otherwise
     verbatim — it encodes the grain the worklog depends on. -->

Generate the worklog for this change.

You are writing the worklog for {{CHANGE}}. A worklog is a record of the **notable decisions** behind a change and the reasoning for them — extracted from the session record, not written from memory.

A worklog tracks **one branch of work** ({{CHANGE}}). Record only decisions that belong to it — if the session also covered other branches or PRs (including closely-related or stacked ones on the same issue), leave those for their own worklogs.

Record a decision only when it **both**:

- **shaped what shipped** — it led directly to something in this change's diff. Not a choice about *how the work was run* (which agent or model did it, how it was tested, when a ticket or PR was opened, where notes were posted); those stay out however deliberate they were; and
- **could have gone another way** — it was surprising, or not the obvious approach, or contested or reversed, or a genuine pick among several workable options. The forced and obvious calls — the only sensible implementation, the default — do not earn a line.

Also leave out the cosmetic, copy-level iteration (exact wording, spacing, colour shades) that polishes something already decided.

For each decision capture: what was decided; the alternatives that were weighed and why they were set aside; and any reason that was **actually stated** — write "no reason given" where none was, and never invent one. A decision reached through back-and-forth is **one** entry with where it landed; distinct decisions each get their own. Ground every rationale in something any developer can open (this repo, the PR, team services); where the only anchor is out of reach (an unmerged PR, a local note), put its substance in the worklog itself.

## Source — extract from the session record on disk

    {{TRANSCRIPT_PATH}}

It is large; use the shell to pull it into a workable form (the human turns, the decision points) and read selectively rather than loading it whole. It may contain a mid-session compaction summary — work from the real turns across the whole record, not that summary. You may consult the repo and its diff to ground and triangulate the reasoning.

## Output — fill the existing worklog file

    {{WORKLOG_PATH}}

It already has the frontmatter and three section headings. Fill exactly these three, and add no others:

- **Context** — what the change is, and the brief as it was actually given (what was asked for). Light scene-setting, not a story of the work.
- **Decisions** — the spine. One entry per notable decision, at the grain above.
- **Final state** — what shipped, and where it diverged from the brief (and why, if a reason was stated).

Do not add a narrative "what happened" / "the arc" section. Work only from what is actually in the record; do not pad to fill a section. When done, the worklog file is the deliverable.
