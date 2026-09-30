# T3 v2 to OpenCode V2 parity tracker

Updated after the first implementation against OpenCode V2 `@opencode/plugin@2.0.18`. "OpenCode-owned" means OpenCode already provides the behavior, not that this plugin reproduces T3's internal records. `T3-FEATURES.md` has source paths and distinguishes T3's implemented code from its design targets.

| T3 feature | This plugin / OpenCode V2 | Status / next work |
| --- | --- | --- |
| Capability discovery | `orchestrator_capabilities` lists available agents/models and supported task actions. | Partial: no T3 provider-instance availability/credential/mode diagnostics. |
| App-owned child task, async delegation | `orchestrator_delegate` persists a task, creates a fresh OpenCode session, selects agent/model, admits one prompt. Child gets no parent transcript. | Ported for the session-based workflow. No T3 run/node graph. |
| Explicit task result | `orchestrator_complete` accepts only the assigned child session; idle successful sessions fall back to last assistant text. | Ported, with a nested-task barrier. Does not reconstruct tool/approval/plan graph. |
| Wait, polling, cancel | `orchestrator_wait` with optional non-cancelling timeout, `orchestrator_status`, `orchestrator_cancel`. | Ported at task/session level. No per-run interrupt or separate follow-up result slots. |
| Follow-up message | `orchestrator_send` queues an OpenCode prompt. Optional request ID gives a stable message ID. | Partial: no queue reorder/edit/cancel or steer/restart policy in this tool. Native OpenCode `session.prompt` supports queue/steer. |
| Nested delegated work | Parent task remains running while its child tasks are nonterminal. | Partial: only plugin-owned child tasks are counted. Native provider subagent/tool work is OpenCode-owned. |
| Model/agent routing | Creation accepts an optional OpenCode agent and model. | Ported for new child sessions; no T3 provider-instance driver adapter or runtime/interaction mode routing. |
| Worktree binding | Optional `worktree: true` uses `ctx.worktree.create` before creating the child session. | Partial: no existing-worktree/root/new-worktree strategy input, cleanup, or automatic merge. A worktree is not a sandbox. |
| Durable command deduplication | Optional `requestID` deduplicates launch by parent and follow-up prompts by task. Stable initial prompt ID and notification ID. | Partial: storage and OpenCode session writes are not one transaction; an uncertain launch remains `unknown`. |
| Task result delivery | Queued synthetic parent message (`resume: false`), durable `notified` flag, live RPC `updated` event. | Partial: no T3 acknowledged wake policy or automatic parent continuation. Snapshot after reconnect. |
| Crash/reload recovery | Owner-location startup scan marks ambiguous in-flight tasks `unknown`; `orchestrator_inspect` reads child state; `orchestrator_retry` creates a new child explicitly. | Partial: no automatic provider-runtime resumption or exactly-once effect worker. |
| RPC/client | `snapshot`, `launch`, `send`, `cancel`, `updated` event. | Ported as a trusted-client server API; no dashboard/TUI yet. RPC has no per-caller session credential. |
| Independent top-level threads/batch creation | `orchestrator_thread_launch` creates an independent session with optional first prompt/worktree. `orchestrator_thread_create_many` creates 1 to 20. | Partial: no existing-checkout strategy, base branch, request-key deduplication, or batch atomicity. |
| Project thread list, paged read, metadata | `orchestrator_thread_list` lists plugin-launched sessions in the project; `orchestrator_thread_read` pages bounded message text; `orchestrator_thread_rename` updates title. | Partial: not all OpenCode sessions; no title regeneration, PR linkage, pin/snooze/settle/unread. Plugin `ctx.session` has no `list`. |
| Ordinary thread send/wait/interrupt | `orchestrator_thread_send` queues or steers, `orchestrator_thread_wait` has a timeout, `orchestrator_thread_interrupt` requests interruption. | Partial: only plugin-launched sessions, no restart/auto mode, run selection, or privilege-ceiling checks. |
| Thread fork and merge-back | `orchestrator_merge_back` stores an auditable handoff and queues a completed child result to its parent. | Partial: no true fork or fork-point delta calculation. Plugin `ctx.session` does not expose `fork`. |
| Provider switching and context handoff | New child can use a different model. | Not ported for an existing thread; explicit handoff records and delta summaries remain to build. T3's own cross-provider handoff TODO is still open. |
| Checkpoint/diff/rollback | OpenCode owns its session history and workspace tools. | Not ported. Full filesystem plus provider conversation rollback cannot be implemented atomically through this plugin. |
| Approvals, questions, plans, token usage, tool stream | OpenCode owns its model loop and tool/permission UI. | OpenCode-owned, not copied into the plugin task record. |
| Provider-native subagents and adapters | OpenCode owns its providers and built-in subagents. | Intentionally skipped: T3 Codex/Claude/Cursor/Grok/ACP/Pi adapters are not OpenCode plugin features. |
| Durable event log, graph projections, command receipts, effect outbox, leased workers | OpenCode owns session events; this plugin stores one JSON value per task. | Cannot match T3's atomic cross-system writes through public plugin APIs. No claim of equivalent durability. |
| Snapshot-plus-cursor stream, replay, debugger UI | RPC snapshot and live update events; OpenCode session history remains separately readable. | Partial: no cursor replay or custom UI. |
| T3 legacy V1 importer | No OpenCode equivalent needed. | Intentionally skipped: T3-only migration. |

## Checks and gaps

- `bun test orchestrator.test.mjs` has ten tests covering delegation, child-only completion, nested barrier, authorization on tools, launch/follow-up IDs, ambiguous launch, explicit retry, timeout, restart notification, independent session controls, merge-back, and uncertain independent-thread launch with an in-memory V2 plugin-context stub.
- `tsc -p tsconfig.json` checks the installed V2 API declarations.
- No disposable OpenCode server end-to-end test has run. Do not treat this as production-verified until the plugin is deployed and a real child session completes.
- Next priorities: real-service test, per-location storage behavior, restart boundary tests, trusted RPC caller policy, capability validation, richer thread controls, and explicit handoff records. See `PLAN.md`.
