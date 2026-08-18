<!-- Sub-agent brief template for the worklog skill. The skill replaces {{CHANGE}}, {{SLICE_PATH}},
     {{WORKLOG_PATH}} and {{ENTRY_PATH}}, then hands the filled text to a fresh sub-agent. Keep the
     wording otherwise verbatim — it encodes the grain the worklog depends on. -->

Write the next worklog entry for this change.

You are writing one entry in the worklog for {{CHANGE}}. A worklog is a journal of the **notable decisions** behind a change and the reasoning for them — extracted from the session record, not written from memory. It is built up in entries, one per stretch of the session; you are writing the entry for the stretch given to you below, not the whole worklog.

A worklog tracks **one branch of work** ({{CHANGE}}). Record only decisions that belong to it — if the session also covered other branches or PRs (including closely-related or stacked ones on the same issue), leave those for their own worklogs.

Record a decision only when it **both**:

- **shaped what shipped** — it led directly to something in this change's diff. Not a choice about *how the work was run* (which agent or model did it, how it was tested, when a ticket or PR was opened, where notes were posted); those stay out however deliberate they were; and
- **could have gone another way** — it was surprising, or not the obvious approach, or contested or reversed, or a genuine pick among several workable options. The forced and obvious calls — the only sensible implementation, the default — do not earn a line.

Also leave out the cosmetic, copy-level iteration (exact wording, spacing, colour shades) that polishes something already decided.

**A change to the brief itself is a decision, and it belongs to the stretch it arrived in.** If the ask was amended, expanded, narrowed, or redirected during this stretch, record that as an entry — what changed, and any stated reason. Do not treat it as background that was always true: the worklog's Starting point holds only where the work *began*, so an amendment recorded nowhere is lost, and one folded into the setup loses both when it arrived and that it was a change at all.

For each decision capture: what was decided; the alternatives that were weighed and why they were set aside; and any reason that was **actually stated** — write "no reason given" where none was, and never invent one. A decision reached through back-and-forth within this stretch is **one** entry with where it landed; distinct decisions each get their own. Ground every rationale in something any developer can open (this repo, the PR, team services); where the only anchor is out of reach (an unmerged PR, a local note), put its substance in the entry itself.

## Source — extract from this slice of the session record

    {{SLICE_PATH}}

This is the stretch of the session since the last entry was written — not the whole session. Work only from it. Use the shell to pull it into a workable form (the human turns, the decision points) and read selectively rather than loading it whole. You may consult the repo and its diff to ground and triangulate the reasoning.

## Check what is already recorded

    {{WORKLOG_PATH}}

Read **only its headings** (`grep '^#' {{WORKLOG_PATH}}`) — the existing entries and the decision titles under them. That tells you what is already captured, so you don't record the same decision twice.

If this stretch **revisited or reversed** a decision already recorded, that is exactly what to write down: a new decision entry that says what changed and points back at the earlier one (by its heading). **Do not edit the existing entry** — the worklog is append-only, and a reversal recorded as a reversal is the most valuable thing in it. You are not writing into this file at all.

## Output — write the entry to a new file

    {{ENTRY_PATH}}

Write **only the decisions for this stretch**, as `###` sections — one per decision, each with a short title and the reasoning beneath it:

```markdown
### <what was decided>

<what was decided, the alternatives weighed and why they were set aside, and any stated reason.>

### <the next decision>

…
```

Nothing else — no heading above the decisions (the skill adds the entry heading), and no scene-setting or narrative preamble. **Write to the shape above; don't read other worklogs in the store to see how it's done** — they include worklogs written to older shapes, and copying one reproduces a format that has since been deliberately changed.

Work only from what is actually in the record; do not pad. If this stretch contains no decisions at the grain above, write nothing and say so — an empty stretch is a correct outcome, and a padded entry is not.
