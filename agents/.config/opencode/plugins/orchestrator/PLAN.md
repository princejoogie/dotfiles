# OpenCode V2 plugin plan

This is an OpenCode V2 **server plugin**, not a Core patch. Install as the discovered package directory `~/.config/opencode/plugins/orchestrator/` through the existing dotfiles deployment. Use only `@opencode/plugin/effect`, public client methods, transforms, plugin storage, and RPC. Version checked against `@opencode/plugin@2.0.18`, matching the installed `opencode v2.0.18`, and the [V2 plugin docs](https://opencode.ai/v2/docs/build/plugins).

## State and execution

Each task lives under one plugin-storage key `tasks/<uuid>`. Persist the generated OpenCode session ID and initial message ID *before* invoking either API. A process-local semaphore serializes updates within this plugin instance. The child receives only the task text and completion instructions. A tool call can start a task in the parent session's directory or in an OpenCode-managed worktree. The child runs a normal OpenCode agent and model. A completion tool or the child's terminal session state produces a result. A queued synthetic message informs the parent, but does not automatically trigger another model request.

The plugin does **not** own OpenCode's session, tool, approval, or model turn state. OpenCode owns those. Task records and RPC events supplement normal session history. An RPC snapshot handles reconnects because RPC events are live-only.

## Recovery and safety

Plugin storage and OpenCode sessions cannot share a transaction. Startup marks ambiguous `starting` and `running` tasks `unknown`; do not replay an uncertain prompt or worktree creation. Inspect its child session before manual continuation. Completed notifications use a stable synthetic message ID and are retried after startup if the task record says `notified: false`. The message may have been admitted before the flag write; OpenCode's ID-based admission prevents duplicate notification messages. Parent/child checks are enforced on agent-facing tools. RPC clients are trusted server clients; the RPC methods do not have a caller-session credential, so they must not be exposed to untrusted callers.

## Work sequence

1. Implement and verify delegation, send, wait, status, cancel, completion, optional worktree, result extraction, nested-task barrier, storage, RPC snapshot/events. These are the first plugin slice.
2. Add deterministic request keys, bounded waits, task reconciliation/explicit retry, capability/model validation, clearer typed failures, and tests for lost responses and concurrent updates.
3. Expand ordinary thread management. Batch creation, plugin-owned listing/paged text reads, rename, worktree creation, queue/steer, wait, and interruption are present. Still needed: all-session discovery, existing-checkout attach, richer metadata, restart/auto prompt policy, and mode/permission policy. Favor OpenCode's native APIs instead of shadow copies.
4. Expand context transfer. Completed-task merge-back has an explicit stored handoff. Fork-point delta generation, same-session model/provider handoff, and a context-based fork approximation remain. Do not call private Core methods. Add client UI only after the server API is stable.
5. Test with the installed V2 package and a disposable OpenCode service, including restart during every remote-call boundary. Update `PARITY.md` for each feature, with a test or limitation cited. Do not claim T3-grade durability without an atomic Core boundary.

## Source material

- T3 PR #2829 commit `6134998b5a404f6be7a57363deb0eab274e8ffd7`, especially `docs/orchestration-v2/` and `apps/server/src/orchestration-v2/TODO.md`.
- OpenCode V2 docs: [plugins](https://opencode.ai/v2/docs/build/plugins), [Effect plugins](https://opencode.ai/v2/docs/build/plugins/effect/), [RPC](https://opencode.ai/v2/docs/build/plugins/rpc/).
- Local installed API declarations under this package's `node_modules/@opencode/plugin/` and its `@opencode/client`. Prefer these over assumptions when coding against the pinned version.
