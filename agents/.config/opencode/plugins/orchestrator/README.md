# Orchestrator for OpenCode V2

A standalone server plugin that delegates work to normal OpenCode sessions. It does not modify OpenCode Core. See `T3-FEATURES.md` for the T3 source inventory, `PLAN.md` for the implementation and recovery design, and `PARITY.md` for implemented and missing features.

## Install

The source is `~/dotfiles/agents/.config/opencode/plugins/orchestrator/`. The existing dotfiles installer installs this package's pinned dependencies and deploys the directory under `~/.config/opencode/plugins/`:

```sh
./agents/install.sh
```

Run that only when you want the installer to perform its other documented setup (Argent, Cua Driver, Stow, skill links, MCP fan-out). This work has **not** run the installer or restarted your OpenCode service. A new OpenCode server will discover the package directory after deployment.

## Agent tools

- `orchestrator_capabilities`: list OpenCode agents/models.
- `orchestrator_delegate`: create an async task. Supply `task`, optional `agent`, `model`, `worktree`, and `requestID`. The parent ID comes from the tool context; the input cannot redirect it.
- `orchestrator_send`: queue a follow-up; optional `requestID` prevents duplicate prompt admission.
- `orchestrator_wait`: wait for a child, optionally with `timeoutMs`. Timeout leaves it running.
- `orchestrator_status`: read one task or list the current session's tasks.
- `orchestrator_inspect`: read outcome and last assistant text from an uncertain child.
- `orchestrator_cancel`: interrupt child work and mark it cancelled.
- `orchestrator_retry`: create a **new** child for a failed, cancelled, or unknown task after inspection.
- `orchestrator_merge_back`: store a completed task's result as a context handoff and queue it to the parent. Optional `requestID` deduplicates its prompt.
- `orchestrator_complete`: child-only result handoff. A nested task must finish before its parent task is published as complete.
- `orchestrator_thread_launch` and `orchestrator_thread_create_many`: create independent sessions, with an optional first prompt and worktree.
- `orchestrator_thread_list`, `orchestrator_thread_read`, `orchestrator_thread_rename`: inspect plugin-launched sessions in the caller's project.
- `orchestrator_thread_send`, `orchestrator_thread_wait`, `orchestrator_thread_interrupt`: control those sessions.

Tools are visible through normal OpenCode tool discovery. A child should call `orchestrator_complete` with its assigned task ID; a successful idle session can also be summarized from its last assistant text.

The plugin also exports `./rpc` for trusted V2 clients. Its methods are `snapshot`, `launch`, `send`, and `cancel`, with a live `updated` event. Call `snapshot` again after reconnecting. The RPC does not receive an agent-tool session identity and should not be offered to untrusted clients.

The thread list contains sessions launched through this plugin, not every OpenCode session. OpenCode's normal session UI remains the source for all sessions.

## Limits

Task storage is durable, but a plugin cannot commit storage and an OpenCode session in the same transaction. After restart, ambiguous tasks are marked `unknown` and must be inspected. Notifications are queued synthetic messages; they do not automatically wake a parent model run. The plugin never deletes a worktree. OpenCode permissions and tools still govern child sessions; a worktree isolates a checkout, not filesystem access.

## Verify

```sh
cd ~/dotfiles/agents/.config/opencode/plugins/orchestrator
bun test orchestrator.test.mjs
../../node_modules/.bin/tsc -p tsconfig.json
```

The tests use a fake context. A real-service smoke test remains required before relying on background delegation.
