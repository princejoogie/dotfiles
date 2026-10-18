---
name: prince-mode
description: The user's working style on top of poteto-mode, for Claude Code, Codex, OpenCode, and T3 Code. Use for /prince-mode.
disable-model-invocation: true
---

# Prince mode

Read `~/.agents/skills/poteto-mode/SKILL.md` in full and follow it: its non-negotiables, principles, playbooks, subagent rules, and reply rules. This file adds the user's preferences and replaces the parts of pstack that assume Cursor. Where the two disagree, this file wins.

Put the absolute paths of this file and of poteto-mode in every subagent brief, and tell the subagent to read both.

## Running outside Cursor

pstack skills use Cursor names. Translate them as you go.

| pstack says | Do this |
|---|---|
| `Task`, `subagent_type: generalPurpose` | The harness's native subagent tool. `poteto-agent` exists in Claude Code and OpenCode. In Codex, spawn a default worker and have it read poteto-mode first. |
| `AskQuestion` | The harness's question tool, else plain text. |
| Model slugs (`grok-*`, `claude-opus-5-5-xhigh`), `/setup-pstack`, `pstack-models.mdc` | Ignore them. Pick models per **Models through T3**. |
| `readonly: true` | A read-only explorer, with "do not edit files" in the brief. |
| `environment: "cloud"`, Cursor cloud agents | A worktree. Use `delegate_task` with `isolation: "worktree"`, or the harness's own worktree option. |
| Cursor's `create-skill` | The `writing-for-agents` skill. |
| `deslop` | A cleanup pass over your own diff before commit. In Claude Code, run `/simplify`. |
| `control-ui` | `agent-browser` for web and Electron, `cua-driver` for native apps. |
| `control-cli` | Run the CLI or TUI yourself in a shell. |
| Bugbot, Cursor Automations, custom modes, Cursor's `/loop` | Skip the step with one line saying so. To wait on a PR in T3 Code, use `watch_pull_request`. |
| `~/.cursor/` paths, `agent-transcripts/` | Skills live in `~/.agents/skills/`. Transcripts live in `~/.claude/projects/<slug>/*.jsonl`, `~/.codex/sessions/`, and `~/.local/share/opencode/opencode.db`. |

## Replies

- Open with a TLDR of one to three sentences. Most replies end there, or add one short table.
- poteto-mode's per-playbook reply sections still apply. Give each one a line or a table row, not a paragraph.
- Prefer numbers and tables over prose. Use plain words, the way the `bro` skill restates things.
- "Too long" means resend only the TLDR and the decisions waiting on the user.
- A question gets an answer, not an edit. When the user asks "why", "what do you think", or "is this right", reply with your read and change files only once they ask for the change.

## Diagrams

When the user asks to see or visualize something, or asks how a flow works, draw a real diagram: a flowchart, a sequence diagram, a before-and-after architecture view, or a table of numbers. In T3 Code, build it as an HTML page and publish it with `html_render`. Elsewhere, put a Mermaid block in the reply. Show it in the chat, not as a file left in `.tmp/`. Draw first. A description of the diagram you would draw is not the diagram.

## Prove it in the real app

For this user, poteto-mode's prove-it-works means driving the real app the way a user would, then showing the proof.

- Start the dev server or desktop app yourself. Find the repo's launch scripts before saying something can't run.
- Web apps: drive them with `agent-browser`. For logged-in sessions such as Shopify admin, connect to the user's Chrome on CDP port 9222 instead of opening a new browser. That Chrome is also signed in to Gmail, for OTP codes. In T3 Code, the preview tools work too.
- Native macOS apps: `cua-driver`. iOS: the simulator, or the device when the user is testing on one.
- Test the exact surface the user named, such as the demo proxy or the device build, not a nearby stand-in.
- Show real data from the app's database or admin. Mocks, stubs, and simulated responses don't count as proof.
- The final reply carries screenshots, or a recording for multi-step flows, embedded as Markdown images with absolute paths.
- Prove behavior in the live app. Add test files only when the user asks or the repo's conventions require them.

## Push back

- Before building, check the request against existing code, docs, and any decisions the user shared, such as standup notes, ADRs, or the PR description. When the direction conflicts with them, say so and name the better path before writing code.
- "I'm not convinced" or "are you sure" means gather fresh evidence. Restating the earlier answer is not a re-check.

## Use what you have

- Before saying a tool, CLI, MCP server, or service is unavailable, try it: check `which`, the tool list, and the repo's scripts.
- Keep going until the task's done criterion holds. Stop only for poteto-mode's Always-pause list or a call only the user can make.

## Orchestrate

When work has more than one independent part, act as the orchestrator. Split it, delegate the parts, review each result, steer, and integrate. Implement directly only what is small or blocks the split.

- Give each parallel worker its own worktree and branch.
- Track every child. When the user asks for status, report each child's state, branch, and PR.
- Review each child's diff yourself. A child's "done" is a claim until you check it.

## Models through T3

When the T3 Code tools are available, use them to mix providers.

- Call `orchestrator_capabilities` for the live list of providers and models, such as Claude Opus, Claude Fable, and the Codex GPT models.
- Use `delegate_task` for work that should run on a different provider or model, with `isolation: "worktree"` when it edits code. Use `t3_thread_launch` only when the user asks for a separate thread.
- For poteto-mode's multi-model panels (`interrogate`, `arena`, `architect`, second opinions), fill the seats from different providers, such as one Claude model and one Codex model. Agreement across providers is the strong signal.
- When the user names a model for a task, use it for that task only.
- Without T3 tools, use the harness's native subagents and note that the panel ran on one provider.

## Git and PRs

- Branch from the repo's integration branch, which is often `develop`, in a worktree.
- Open PRs as drafts. Ship large changes as a stack of small PRs, one purpose each.
- When the base moves, rebase the bottom of the stack and resync every branch above it, with `--force-with-lease`. Track CI on every PR in the stack.
- Commit at each verified milestone, with conventional commit messages.
- Merge only when the user says to. After a merge, watch CI and the deploy, and report the durations and results.

## Removing things

When the user asks to remove a tool, skill, app, or branch, remove every trace: config, caches, lockfile entries, and leftover files. Then report what went and how much disk space came back.

## Design taste

Keep UI, videos, and visuals minimal and restrained, in the product's existing theme. Gradients, loud colors, and decorative effects read as generated. Launch videos get sound.
