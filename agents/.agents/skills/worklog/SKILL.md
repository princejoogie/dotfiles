---
name: worklog
description: "Keep a per-PR worklog — a durable record of the notable decisions behind a change (why this path and not another, and the alternatives set aside) that the diff, PR description, and review thread don't preserve, reconstructed from the session's own record rather than written from memory. Built up as a journal: started once, then extended by appending an entry covering the work since the last one. Opt-in per project: use only when a repo's AGENTS.md/CLAUDE.md asks for worklogs to be kept. Reach for it when starting the worklog for a change or PR, or bringing an existing one up to date."
---

# Worklog

A worklog is a per-PR markdown file that records the **notable decisions** behind a change and the reasoning for them — the *why this and not that*, and the alternatives set aside, that the diff, the PR description, and the review thread don't keep. It is **extracted from this session's record on disk, not written from memory**: memory, especially after a compaction, loses exactly the decisions worth keeping. Produce it by extracting from the record, and commit it with the change; when it needs to keep pace with the work, **append to it rather than rewriting or hand-editing it** (see *Updating a worklog*).

It is a **journal, not a document**: started once, then extended an entry at a time.

## When to use this skill — opt-in per project

Worklogs are **off by default**. Keep one only when the project asks for it — the repo's `AGENTS.md` / `CLAUDE.md` says worklogs are kept here, or the user asks. **In a project that doesn't opt in, don't invoke this skill at all.** Each repo keeps its own worklogs under its own `.worklogs/` store, so the record travels with the code.

## When to write — the project's call, not the skill's

Worklogs are written at a few key moments in a change's life, never as a reflex or a background loop. **Which moments those are is dictated by the specific repo, project, or user** — not by this skill.

When such a moment comes, act only when there is something new to record:

- **no worklog yet** → start one, then append its first entry;
- **work has happened** since the last entry → append an entry covering it (see *Updating a worklog*) — a worklog that stops short of a landing change is worse than one kept current;
- **nothing has happened** since the last entry → leave it. The slicer tells you outright when a stretch is empty.

Each entry costs a sub-agent run, but only over the stretch of the session since the last one — not the whole transcript. That is what makes keeping a worklog current affordable, and why appending often is better than saving it all up: an entry written close to the work it covers is drawn from the record at full detail.

## One worklog per branch of work

A worklog tracks a single **branch of work** — in practice, one per PR. Distinct streams of work each get their own worklog, **even when they are related**; the unit is the branch, not the feature or the ticket:

- **Two unrelated PRs** → two worklogs.
- **Two PRs on the same issue** → two worklogs — the issue isn't the unit.
- **Two closely-related _stacked_ PRs on one issue** → still two worklogs, one per PR.

The test is not "is this the same feature or ticket?" but "**is this a distinct branch of work, with its own diff and its own decisions?**" If it has its own PR/branch, it gets its own worklog. Link sibling worklogs to each other through the `related:` frontmatter rather than merging them into one file.

When a single session produced work for more than one branch, scope each worklog to **its** branch's decisions — extract only what belongs to that change, and leave the rest for their own worklogs.

## What goes in — the grain

This is the whole game. Record a decision when it **both**:

- **shaped what shipped** — it led directly to something in this PR's diff. *How the work was run* — which agent or model did it, how it was tested, when the ticket or PR was opened, where notes were posted — did not change the artifact and stays out, however deliberate it was; and
- **could have gone another way** — it was surprising, not the obvious approach, contested or reversed, or a real pick among workable options. The forced and obvious calls — the only sensible implementation, the default any competent build would reach — don't earn a line; recording them is the noise that buries the signal.

Leave out the cosmetic, copy-level churn (exact wording, spacing, colour shades). **One decision is one entry**: the back-and-forth and the rejected alternatives fold into that entry with where it landed; distinct decisions are each recorded separately. Big, codebase-shaping calls belong in a deliberate ADR — the worklog captures the everyday decisions no one opens an ADR for.

Keep it honest:

- **Extractive.** Record what was decided and what was said. Attach a reason only when one was **actually stated** — "no reason given" is a correct, valuable output; inventing a plausible why is the single biggest failure mode.
- **Indicative, not authoritative.** The worklog is one datapoint, to be triangulated against the diff, the PR, and the review thread.
- **Reachable anchors.** Ground each rationale in something any developer can open — this repo, the PR, team services. Where the only anchor is out of reach (an unmerged PR, a local note), put its substance in the worklog itself.

## The shape of the file

Frontmatter, a starting point, then entries:

```markdown
---
worklog: 2
related:
  - https://github.com/owner/repo/pull/935
date: 2026-06-29
sources:
  - harness: claude-code
    session: 75168430-de92-4f65-908f-4d413eff4609
    through: 2026-06-29T06:41:22.918Z    # how far the record has been read
---

# Worklog: Storybook prototyping scaffolding

## Starting point

Where the work started: what was asked for at the outset. Written once; never rewritten.

## 2026-06-29T04:12Z — initial build

### Place stories under `components/prototypes/` to reuse the existing glob
…

## 2026-06-29T06:41Z — review round 1

### Prototypes move to a dedicated `prototype/` area
Reverses the placement decision in the entry above. Review restructured it so …
```

Three rules hold the format together:

- **Entries are never edited.** When a later epoch reverses an earlier decision, the new entry **says so and points back**. The reversal is the highest-signal thing a worklog holds; rewriting the old entry destroys it and leaves a record that reads as though the final answer was always the answer.
- **An entry heading is a locator, not a summary** — a timestamp and a few factual words about which thread of work this epoch covered. **No prose stands between an entry heading and its first decision.** An entry contains decisions and nothing else; a narrative gloss at the top of an entry is how a decision journal decays back into a story of the work.
- **The template is the shape.** Follow the scaffolded file and this section; **don't read other worklogs to see how it's done.** The store holds worklogs written to older shapes, and copying one reproduces a format that has since been deliberately changed.

## Method

Run this to produce a worklog. The bundled scripts (in `${CLAUDE_SKILL_DIR}/scripts/`) hide the harness-specific mechanics, so the steps are the same on any harness — "this session", "a sub-agent". If `${CLAUDE_SKILL_DIR}` comes through unexpanded you're not on Claude Code: treat it as an indicator that the scripts live in *this skill's* directory and run them from the skill base directory your harness provides.

### Once per PR — start the worklog

1. **Identify this session:**

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/find-current-session.ts"
   ```

   On Claude Code this prints `session: <id>` from the environment. On OpenCode V2 it uses `opencode2 api` to query the authenticated background service and normally resolves the active session for this directory immediately. If multiple OpenCode sessions are active, or when running on Pi, it instead **marks this session** and prints the exact command to run next — `find-current-session.ts --marker <token>` — so run that as a second call. Just follow what the script tells you. (If the lookup prints **CANDIDATES**, the marker didn't match yet — retry per its guidance, or pick by hand.)

2. **Scaffold the file:**

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/new-worklog.ts" --session <id> --title "<short title>" \
     --related <pr-url> --related <ticket-url>
   ```

   It writes the template into `.worklogs/<slug>.md`, seeds the `sources` bookmark, and prints the path. Note it — every later step takes it.

3. **Write the `## Starting point`** yourself, in a few lines: **where the work started** — what was asked for at the outset, and anything already true that shaped it.

   It is a snapshot of one moment, not a summary of the brief as it finally stood. **Anything that arrived later belongs to the entry for the stretch it arrived in** — an amended or expanded brief, a new requirement, a change of direction. Those are among the most valuable things a worklog holds, and folding them up into the Starting point loses both when they arrived and that they were a change at all.

   The tell: if you're writing about something that happened *after* the work began, it isn't the starting point.

### Append an entry

Everything below is the repeatable part: run it to add the first entry, and again at each later moment the project calls for (see *When to write*).

4. **Slice the record since the bookmark.** Take `through` from the worklog's `sources` for this session, then:

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/get-session-transcript.ts" <id> --since <through>
   ```

   It prints the slice path, the record count, and the new `through` instant. If it reports **NOTHING NEW**, stop — there is nothing to record yet.

   OpenCode V2 reads the supported session export through `opencode2 api`, not the service database. Its slice records preserve timestamps from individual assistant content items, so a bookmark at an earlier item cannot skip later tool activity in the same assistant message.

5. **Extract via a sub-agent.** Take the brief template at `${CLAUDE_SKILL_DIR}/assets/extraction-brief.md`, fill `{{CHANGE}}`, `{{SLICE_PATH}}` (step 4), `{{WORKLOG_PATH}}` and `{{ENTRY_PATH}}` (a scratch file to write to), and dispatch a **fresh sub-agent** with it. It reads the slice and writes the entry's decisions to `{{ENTRY_PATH}}`.

   Use a sub-agent deliberately: a fresh one has no memory of the work to fill gaps with, so extraction stays honest, and the transcript stays out of your own context. It writes to a scratch file, not the worklog, so it cannot touch entries already there.

6. **Append it:**

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/append-entry.ts" --worklog <worklog> --entry <entry-file> \
     --session <id> --through <through-from-step-4> --label "<short locator>"
   ```

   This adds the entry and advances the bookmark as one operation — so an epoch can never be skipped by a bookmark that moved without its entry landing.

7. **Check and commit:**

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/validate-worklog.ts" <worklog>
   ```

   Then skim the entry against the diff and the PR, fix any anchor a reader couldn't open, and commit the worklog with the change.

### No record, no worklog

A worklog is **not possible without the raw session transcript**. If the session can't be located or its transcript can't be read — a harness that keeps sessions server-side, a cloud agent, a store that isn't there — **stop and say so**. Do not write one from context: an entry written from memory isn't a degraded worklog, it's a different and untrustworthy artifact wearing the name, and it is the exact failure this skill exists to prevent. The scripts exit non-zero rather than fall back, and `validate-worklog.ts` fails any entry that isn't covered by a bookmark.

Slicing is implemented for **Claude Code** and **OpenCode**. On Pi, `find-current-session.ts` and `get-session-transcript.ts` still locate a session and its transcript, but `--since` fails rather than silently handing back the whole thing.

## Updating a worklog

Updating a worklog means **appending an entry — never hand-patching it, and never regenerating it.** Both alternatives fail, for different reasons.

**Hand-patching** readmits memory and invention — the very failure modes extraction exists to prevent — so it is a violation of the process, not a shortcut within it. To add to a worklog, re-run *Append an entry* above: the sub-agent extracts from the record, and it writes to a scratch file that `append-entry.ts` appends, so nothing is ever edited by hand.

**Regenerating** — rebuilding the file wholesale — destroys the record it is meant to keep. When a decision is superseded, a regenerated worklog overwrites the original with its replacement, and the reasoning behind the first is gone; the file then reads as though the final answer was always the answer. Appending keeps the reversal *as* a reversal, which is the highest-signal thing a worklog holds. It is also why entries already in the file are never touched.

## Naming and location

Worklogs live in `.worklogs/` at the repo root, one file per PR, named with a random human-readable slug (the same collision-avoidance Changesets uses) so concurrent PRs in a monorepo never clash. **Always scaffold via `new-worklog.ts`** — it guarantees a free name and writes the correct template. The store is per-repo: the scaffolder locates it via `git rev-parse --show-toplevel`.

`worklog: 2` in the frontmatter marks this format. A worklog with no `worklog` field is v1 — the older whole-document format, written before the field existed; those are left as they are and are not appended to.

## Worklog vs the PR description

The PR description is the curated, after-the-fact framing written for a reviewer: what shipped and a broad why. The worklog is its complement — the decisions and the reasoning behind them, at a resolution the description isn't meant to carry, plus the alternatives it never mentions. Write both; they serve different readers and deliberately don't overlap. This skill produces the worklog, not the PR description.

A worklog is a record, not a document anyone sits down to read. It exists to be accurate and to be referenced later. Where accuracy and readability pull apart, accuracy wins.
