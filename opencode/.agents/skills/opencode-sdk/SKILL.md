---
name: opencode-sdk
description: Use when automating OpenCode with the TypeScript SDK, building integrations that start or connect to an OpenCode server, create/control sessions, stream events, handle permissions, inspect files, or drive the TUI programmatically. Not for configuring OpenCode agent settings or authoring skills; skill-creator for those.
---

# OpenCode SDK

Use `@opencode-ai/sdk` for programmatic control of OpenCode. The current checked source at `/Users/pjuguilon/Documents/codes/vervio/vendio/opencode` exposes SDK version `1.17.7`.

Exports to choose from:

1. `@opencode-ai/sdk`: legacy generated client shape using `{ path, query, body }` arguments.
2. `@opencode-ai/sdk/server`: server/TUI process helpers for the legacy export.
3. `@opencode-ai/sdk/v2`: latest generated client shape using direct parameter objects.
4. `@opencode-ai/sdk/v2/server`: server/TUI process helpers for the v2 export.

Prefer `@opencode-ai/sdk/v2` for new integrations against the latest server. Keep `@opencode-ai/sdk` for existing code that already uses the legacy `{ path, query, body }` call shape.

Important response rule: generated clients default to field responses. Either set `responseStyle: "data"` with `throwOnError: true` for direct data returns, or unwrap `response.data` explicitly.

## Workflow

1. Decide whether the integration owns an OpenCode server or connects to an existing one.
2. For new code, import from `@opencode-ai/sdk/v2` and use direct parameters such as `client.session.prompt({ sessionID, parts })`.
3. Use the legacy root export only when maintaining code that already calls methods like `client.session.prompt({ path, body })`.
4. For read-only historical audits such as daily work logs, prefer `scripts/export-sessions.mjs` instead of starting an SDK-managed server.
5. Create or select a session before sending prompts, commands, shell commands, or file-oriented requests.
6. Use `client.v2.session.wait({ sessionID })` when you only need to wait until native v2 session work is idle.
7. Subscribe to events before long-running prompts when you need streaming progress, permission handling, question handling, or file-change notifications.
8. Pass `directory`, `workspace`, or v2 `location` values explicitly when automating a project other than the server's default directory.
9. Use `throwOnError: true` or explicit response checks when callers need fail-fast behavior.

## Install

```bash
npm install @opencode-ai/sdk
```

Use the host repository's package manager when adding the dependency.

Bundled helper scripts have their own dependency manifest:

```bash
cd /Users/pjuguilon/.agents/skills/opencode-sdk/scripts
npm install
```

Install those script dependencies once before using SDK-backed script modes.

## Read-Only Session Export

Use `scripts/export-sessions.mjs` when auditing previous sessions/messages, building daily work logs, extracting preference corrections, or collecting usage metrics. Do not start an SDK-managed server just to read local history; it can contend with the local store and fail around SQLite WAL checkpointing such as `PRAGMA wal_checkpoint(PASSIVE)`.

Preferred modes:

1. If an OpenCode server is already running, use the SDK client path with `--base-url`.
2. If no server is running, or SDK-managed server startup fails, use the read-only SQLite store path.
3. Report which source mode was used in the consuming analysis, but do not treat the SQLite path as an error when the task is read-only.

Examples:

```bash
node /Users/pjuguilon/.agents/skills/opencode-sdk/scripts/export-sessions.mjs \
  --date 2026-06-09 \
  --timezone Asia/Manila \
  --output /tmp/opencode-sessions-2026-06-09.json

node /Users/pjuguilon/.agents/skills/opencode-sdk/scripts/export-sessions.mjs \
  --base-url http://localhost:4096 \
  --date 2026-06-09 \
  --timezone Asia/Manila
```

The default SQLite database is `/Users/pjuguilon/.local/share/opencode/opencode.db`. The exporter groups sessions by project/workspace label so downstream worklogs can keep unrelated projects separate.

## Start Server And V2 Client

```typescript
import { createOpencodeClient, createOpencodeServer } from "@opencode-ai/sdk/v2"

const server = await createOpencodeServer({
  hostname: "127.0.0.1",
  port: 4096,
  timeout: 5000,
  config: {
    logLevel: "INFO",
  },
})

const client = createOpencodeClient({
  baseUrl: server.url,
  throwOnError: true,
  responseStyle: "data",
})

try {
  const session = await client.session.create({
    title: "Automated task",
    agent: "build",
  })

  await client.session.prompt({
    sessionID: session.id,
    parts: [{ type: "text", text: "Implement the requested change." }],
  })
} finally {
  server.close()
}
```

`createOpencodeServer()` starts the server process. Common options are `hostname`, `port`, `signal`, `timeout`, and `config`. If using `createOpencode()` directly, remember its client uses default field responses unless you unwrap `.data`.

## Connect To Existing Server

```typescript
import { createOpencodeClient } from "@opencode-ai/sdk/v2"

const client = createOpencodeClient({
  baseUrl: "http://localhost:4096",
  directory: process.cwd(),
  throwOnError: true,
  responseStyle: "data",
})
```

Client options include `baseUrl`, `fetch`, `parseAs`, `responseStyle`, `throwOnError`, `headers`, and `directory`. The v2 client also supports `experimental_workspaceID`, which becomes the `x-opencode-workspace` header and query `workspace` value for GET/HEAD requests.

## V2 Session Calls

The v2 export uses direct parameter objects, not `{ path, body, query }` wrappers.

```typescript
const session = await client.session.create({
  title: "My session",
  agent: "build",
})

const sessions = await client.session.list({ limit: 20 })
const current = await client.session.get({ sessionID: session.id })
const messages = await client.session.messages({ sessionID: session.id, limit: 50 })

await client.session.prompt({
  sessionID: session.id,
  model: { providerID: "anthropic", modelID: "claude-sonnet-4-5" },
  parts: [{ type: "text", text: "Hello!" }],
})

await client.session.prompt({
  sessionID: session.id,
  noReply: true,
  parts: [{ type: "text", text: "Context only. Do not respond." }],
})
```

Use `noReply: true` to inject context without triggering an assistant response. Use `session.promptAsync()` when you need to enqueue work and return immediately.

Other current top-level v2 session APIs include `status`, `children`, `todo`, `diff`, `messages`, `message`, `deleteMessage`, `fork`, `abort`, `init`, `share`, `unshare`, `summarize`, `command`, `shell`, `revert`, and `unrevert`.

## Native V2 API Namespace

`client.v2.*` maps to newer `/api/*` endpoints. Use it when you need the native location model, durable prompt admission, session wait, integration credentials, native filesystem browsing, or native permission/question lists.

```typescript
const nativeSession = await client.v2.session.create({
  location: { directory: process.cwd() },
  agent: "build",
})

await client.v2.session.prompt({
  sessionID: nativeSession.data.id,
  prompt: { text: "Fix all TypeScript errors." },
  delivery: "queue",
  resume: true,
})

await client.v2.session.wait({ sessionID: nativeSession.data.id })
```

Native v2 groups include `health`, `location`, `agent`, `session`, `model`, `provider`, `integration`, `credential`, `permission`, `fs`, `command`, `skill`, `event`, `pty`, `question`, `reference`, and `projectCopy`.

## Legacy Root Client Calls

The root `@opencode-ai/sdk` export still uses the old generated request shape.

```typescript
import { createOpencodeClient } from "@opencode-ai/sdk"

const legacy = createOpencodeClient({
  baseUrl: "http://localhost:4096",
  throwOnError: true,
  responseStyle: "data",
})

const session = await legacy.session.create({
  body: { title: "Legacy session" },
})

await legacy.session.prompt({
  path: { id: session.id },
  body: {
    parts: [{ type: "text", text: "Hello from the legacy client." }],
  },
})
```

Do not mix legacy examples with the v2 export: `path/body/query` wrappers belong to `@opencode-ai/sdk`, while direct parameters belong to `@opencode-ai/sdk/v2`.

## Structured Output

Request structured JSON from v2 `session.prompt()` with `format`.

```typescript
const result = await client.session.prompt({
  sessionID: session.id,
  parts: [{ type: "text", text: "Research Anthropic and return company info." }],
  format: {
    type: "json_schema",
    schema: {
      type: "object",
      properties: {
        company: { type: "string", description: "Company name" },
        founded: { type: "number", description: "Year founded" },
      },
      required: ["company", "founded"],
    },
    retryCount: 2,
  },
})

console.log(result.info.structured)
```

If structured output fails, check `result.info.error?.name === "StructuredOutputError"` or the thrown error when using `throwOnError: true`.

## Files And Search

```typescript
const textResults = await client.find.text({ pattern: "function.*opencode" })

const files = await client.find.files({
  query: "*.ts",
  type: "file",
  limit: 50,
})

const directories = await client.find.files({
  query: "packages",
  type: "directory",
  limit: 20,
})

const symbols = await client.find.symbols({ query: "handleRequest" })

const content = await client.file.read({ path: "src/index.ts" })

const status = await client.file.status()

const nativeMatches = await client.v2.fs.find({
  location: { directory: process.cwd() },
  query: "Button",
  type: "file",
  limit: "20",
})
```

The legacy root export still wraps these in `query: { ... }`.

## Events And Completion

Subscribe to `event.subscribe()` before sending work if you need streaming progress, permission handling, question handling, or completion.

```typescript
const events = await client.event.subscribe()

await client.session.prompt({
  sessionID: session.id,
  parts: [{ type: "text", text: "Fix all TypeScript errors." }],
})

for await (const event of events.stream) {
  if (event.type === "session.idle" && event.properties.sessionID === session.id) {
    break
  }
}
```

Useful current v2 event groups include `session.*`, `session.next.*`, `message.*`, `permission.asked`, `permission.replied`, `permission.v2.asked`, `permission.v2.replied`, `question.*`, `question.v2.*`, `todo.updated`, `file.edited`, `file.watcher.updated`, `pty.*`, `vcs.branch.updated`, `workspace.*`, and `worktree.*`.

For native v2 session prompts, prefer `client.v2.session.wait({ sessionID })` when event details are not needed.

## Permission Handling

The latest v2 direct permission APIs reply with `"once"`, `"always"`, or `"reject"`.

```typescript
for await (const event of events.stream) {
  if (event.type !== "permission.asked") continue

  const permission = event.properties
  if (permission.permission === "read") {
    await client.permission.reply({
      requestID: permission.id,
      reply: "once",
    })
  }
}
```

Native v2 session-owned permissions use `client.v2.session.permission.reply()`:

```typescript
for await (const event of events.stream) {
  if (event.type !== "permission.v2.asked") continue

  await client.v2.session.permission.reply({
    sessionID: event.properties.sessionID,
    requestID: event.properties.id,
    reply: "once",
  })
}
```

Legacy root clients still use `permission.updated` plus `postSessionIdPermissionsPermissionId()`:

```typescript
await legacy.postSessionIdPermissionsPermissionId({
  path: { id: permission.sessionID, permissionID: permission.id },
  body: { response: "once" },
})
```

Do not auto-approve write, shell, network, or destructive permissions unless the integration has an explicit policy for that trust boundary.

## TUI Control

Use TUI APIs only when controlling an interactive OpenCode TUI remotely.

```typescript
await client.tui.appendPrompt({ text: "Add this to the prompt" })
await client.tui.submitPrompt()
await client.tui.clearPrompt()

await client.tui.openHelp()
await client.tui.openSessions()
await client.tui.openThemes()
await client.tui.openModels()

await client.tui.executeCommand({ command: "agent_cycle" })
await client.tui.selectSession({ sessionID: session.id })
await client.tui.showToast({
  message: "Task complete",
  variant: "success",
})
```

The current generated client also exposes `tui.publish()` and `tui.control` for lower-level TUI integrations.

## Other API Groups

Use `global.health()`, `global.event()`, `global.dispose()`, and `global.upgrade()` for global server operations.

Use `project.list()`, `project.current()`, `project.initGit()`, `project.update()`, and `project.directories()` for project context.

Use `path.get()` for current path info.

Use `config.get()`, `config.update()`, and `config.providers()` for configuration and provider defaults.

Use `app.log()`, `app.agents()`, and `app.skills()` for app-level integration hooks.

Use `provider.*`, `auth.*`, `mcp.*`, `lsp.status()`, and `formatter.status()` only when the integration specifically needs those subsystems.

Use `worktree.*`, `sync.*`, `part.*`, `question.*`, and `permission.*` for newer automation surfaces.

## Types

```typescript
import type { Message, Part, PermissionV2Reply, Session, SessionStatus } from "@opencode-ai/sdk/v2"
```

Supplemental references in this skill:

1. `references/api-reference.md`: method groups and call-shape differences.
2. `references/events.md`: current event families and permission/question patterns.
3. `references/types.md`: notable type shapes and 1.17.7 changes.
