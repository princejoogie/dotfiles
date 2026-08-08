---
name: worklog
description: "Keep a per-PR worklog — a durable record of the notable decisions behind a change (why this path and not another, and the alternatives set aside) that the diff, PR description, and review thread don't preserve, reconstructed from the session's own record rather than written from memory. Opt-in per project: use only when a repo's AGENTS.md/CLAUDE.md asks for worklogs to be kept. Reach for it when producing the worklog for a change or PR, or regenerating one after the work has diverged."
---

# Worklog

A worklog is a per-PR markdown file that records the **notable decisions** behind a change and the reasoning for them — the *why this and not that*, and the alternatives set aside, that the diff, the PR description, and the review thread don't keep. It is **extracted from this session's record on disk, not written from memory**: memory, especially after a compaction, loses exactly the decisions worth keeping. Produce it by extracting from the record, and commit it with the change; when it needs to keep pace with the work, **regenerate it rather than hand-editing it** (see *Updating a worklog*).
## When to use this skill — opt-in per project

Worklogs are **off by default**. Keep one only when the project asks for it — the repo's `AGENTS.md` / `CLAUDE.md` says worklogs are kept here, or the user asks. **In a project that doesn't opt in, don't invoke this skill at all.** Each repo keeps its own worklogs under its own `.worklogs/` store, so the record travels with the code.

## Generating a worklog is expensive — spend it deliberately

Extracting a worklog is **slow and token-heavy**: a sub-agent reads the whole session transcript to produce it. So generation — and regeneration — is reserved for a few key moments in a change's life, never a reflex or a background loop. Which moments those are is dictated by the specific repo, project, or user.

When such a moment comes, (re)generate only when it would change what the worklog says:

- **no worklog yet** → generate one;
- **the work has drifted** since the current worklog was extracted → regenerate it (see *Updating a worklog*) — an out-of-date worklog going into a landing change is worse than an honest gap;
- **the work is unchanged** since it was extracted → leave it; regenerating would spend tokens to reproduce what's already there.

The cost is a reason to *decide* at these moments, not a reason to skip them: where the moment calls for a worklog and the work has moved, regenerating is worth it.

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

## Method

Run this to produce a worklog. The bundled scripts (in `${CLAUDE_SKILL_DIR}/scripts/`) hide the harness-specific mechanics, so the steps are the same on any harness — "this session", "a sub-agent". If `${CLAUDE_SKILL_DIR}` comes through unexpanded you're not on Claude Code: treat it as an indicator that the scripts live in *this skill's* directory and run them from the skill base directory your harness provides.

1. **Scaffold the worklog file:**

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/new-worklog.ts" --title "<short title>" \
     --related <pr-url> --related <ticket-url>
   ```

   It writes the three-section template into `.worklogs/<slug>.md` and prints the path. Note it — you'll pass it to the sub-agent in step 4.

2. **Identify this session** — run:

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/find-current-session.ts"
   ```

   On Claude Code this prints `session: <id>` straight away (the session id is in the environment). On a harness that doesn't expose one (OpenCode, Pi) it instead **marks this session** and prints the exact command to run next — `find-current-session.ts --marker <token>` — so run that as a second call to get `session: <id>`. Just follow what the script tells you. (If the lookup prints **CANDIDATES**, the marker didn't match yet — retry per its guidance, or pick by hand.)

3. **Get this session's transcript:**

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/get-session-transcript.ts" <id>
   ```

   It prints the path to a readable transcript file.

4. **Extract via a sub-agent.** Take the brief template at `${CLAUDE_SKILL_DIR}/assets/extraction-brief.md`, fill `{{CHANGE}}` (a one-line description, e.g. the PR title), `{{TRANSCRIPT_PATH}}` (from step 3) and `{{WORKLOG_PATH}}` (from step 1), and dispatch a **fresh sub-agent** with it. The sub-agent reads the transcript and writes the decisions into the worklog file. Use a sub-agent deliberately: a fresh one has no memory of the work to fill gaps with, so extraction stays honest, and the large transcript stays out of your own context.

5. **Triangulate and commit.** Skim the result against the diff and the PR; fix any anchor a reader couldn't open. Commit the worklog with the change.

## Updating a worklog

Updating a worklog means **regenerating it, never hand-patching it.** A worklog is an extraction from the session record; editing it by hand readmits memory and invention — the very failure modes the extraction exists to prevent — so patching is a violation of the process, not a shortcut within it. To update one, re-run the Method above: it rebuilds the file wholesale from the current record.

## Naming and location

Worklogs live in `.worklogs/` at the repo root, one file per PR, named with a random human-readable slug (the same collision-avoidance Changesets uses) so concurrent PRs in a monorepo never clash. **Always scaffold via `new-worklog.ts`** — it guarantees a free name and writes the correct template. The store is per-repo: the scaffolder locates it via `git rev-parse --show-toplevel`.

## Worklog vs the PR description

The PR description is the curated, after-the-fact framing written for a reviewer: what shipped and a broad why. The worklog is its complement — the decisions and the reasoning behind them, at a resolution the description isn't meant to carry, plus the alternatives it never mentions. Write both; they serve different readers and deliberately don't overlap. This skill produces the worklog, not the PR description.
