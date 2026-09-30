# T3 Orchestrator v2 feature inventory

Source: `pingdotgg/t3code` PR #2829 at `6134998b5a404f6be7a57363deb0eab274e8ffd7`. This lists both working behavior and target behavior. T3's own `TODO.md` still calls out unfinished work. A feature in the design docs is not proof that the PR implements it.

## Agent-facing orchestration

T3's app-owned MCP server documents the following tools (`docs/orchestration-v2/orchestrator-mcp-server.md`, `apps/server/src/mcp/toolkits/orchestrator/`). The document calls this "eleven" tools but names twelve, so the named operations are the checklist here:

| Feature | T3 behavior |
| --- | --- |
| Capability discovery | `orchestrator_capabilities` reports inherited provider/model, modes, available provider instances/models, and supported task operations. |
| Delegation | `delegate_task` makes an app-owned child thread/run from a prompt and optional role; async or bounded wait; provider/model/mode selection; request-key deduplication. The child does not inherit the parent transcript. |
| Task reads and cancellation | `task_status` reports durable status, work state, pending children, original result, latest follow-up result. `task_cancel` interrupts active work. |
| Batch independent threads | `create_threads` creates 1 to 20 top-level threads, with optional first prompts and independent target settings. |
| Workspace-aware launch | `t3_thread_launch` binds a root, existing checkout, or new worktree before the prompt. |
| Thread discovery/history | `t3_thread_list` filters and pages project threads. `t3_thread_read` reads bounded, incremental visible history in message or activity mode. |
| Thread metadata | `t3_thread_update` renames, regenerates title, links/unlinks a PR, with idempotent command receipts. |
| Thread interaction | `t3_thread_send` chooses auto, queue, steer, or restart. `t3_thread_wait` waits for a pinned run with a non-cancelling timeout. `t3_thread_interrupt` interrupts a chosen/current run. |
| MCP access policy | Session-scoped expiring credentials, project-scoped reads/writes, provider availability checks, privilege ceilings, typed denials. |

## Execution model and user-visible controls

Source: `docs/orchestration-v2/README.md`, `feature-lifecycles.md`, `thread-lineage-and-context-transfer.md`, `provider-switching-and-context.md`, `provider-capability-system.md`, `apps/server/src/orchestration-v2/Orchestrator.ts`.

- App-owned thread, run, attempt, execution-node, provider-session, provider-thread, and provider-turn IDs. Provider references remain separate. Native subagents, tools, approvals, plans, questions, and checkpoints appear in the execution graph. A child terminal event must not finish its parent root run.
- Thread create/archive/unarchive/delete, settle/unsettle, snooze/unsnooze, pin/unpin/reorder, visit/unread, metadata updates, linked PR state, runtime/interaction modes, and model selection.
- Prompt dispatch, active steering, restart steering, queuing, queued-run reorder/edit/cancel, queue resume, queued-message promotion, interrupt, and provider switching. Policy adapts to provider capabilities. Attachments are admitted as part of the prompt.
- Provider-native continuation and session reuse across turns. Provider change or return to a prior provider records a context handoff instead of rewriting earlier history.
- Forks from stable run/node/provider-thread points, app-level lineage, lazy native fork when supported, portable context fallback. Merge-back records a fork-delta summary for the next source-thread run. T3's own TODO says portable cross-provider fork and switch handoffs are unfinished.
- Checkpoint capture/diff and full rollback, including filesystem restore and provider conversation rollback, with later runs marked rolled back. T3's TODO notes rollback and projection edge cases remain.
- Provider-initiated approvals and structured user questions, answer/dismiss handling, plan/todo artifacts, token accounting, tool/assistant streaming, and terminal completion barrier after root work and nested child work.
- App-owned delegated work and observed provider-native subagents. Nested child work can keep a task pending after the first child turn; later follow-ups do not overwrite the published result. Completion delivery has acknowledgement/disposal and wake policy.
- Durable event log, command receipts, projections, transactionally enqueued side effects, worker leases/retries, restart reconciliation, snapshot-plus-cursor streams, and replay-backed adapter tests. Relevant code: `EventSink.ts`, `EffectOutbox.ts`, `EffectWorker.ts`, `ProjectionStore.ts`, `RunExecutionService.ts`, `ProviderRuntimeRecoveryService.ts`.
- Provider adapters for Codex, Claude, Cursor, Grok/ACP, generic ACP Registry, OpenCode, Pi, and Antigravity; provider-specific capabilities and transport. These are T3 integrations, not separate OpenCode plugin features.

## Important distinction

The T3 MCP toolkit, the T3 orchestration engine, and T3's target design are three different scopes. This plugin targets the agent-facing delegation and thread-management experience. OpenCode already owns model turns, tools, approvals, session events, and native provider connections. Reimplementing T3's provider adapters or event engine inside an OpenCode plugin would duplicate OpenCode and still lack a shared transaction with Core. See `PARITY.md` for exact results and `PLAN.md` for the next steps.
