---
name: opencode-sdk
description: Use when automating OpenCode with the TypeScript SDK, building integrations that start or connect to an OpenCode server, create/control sessions, stream events, handle permissions, inspect files, or drive the TUI programmatically. Not for configuring OpenCode agent settings or authoring skills; skill-creator for those.
---

# OpenCode SDK

Use `@opencode-ai/sdk` for programmatic control of OpenCode. The current checked source at `/Users/pjuguilon/Documents/codes/vervio/vendio/opencode` exposes SDK version `1.15.13` and exports the main SDK from `@opencode-ai/sdk`, plus versioned exports under `@opencode-ai/sdk/v2`.

## Workflow

1. Decide whether the integration owns an OpenCode server or connects to an existing one.
2. For read-only historical audits such as daily work logs, prefer `scripts/export-sessions.mjs` instead of starting an SDK-managed server.
3. Use `createOpencode()` when your code should start the server and close it later.
4. Use `createOpencodeClient({ baseUrl })` when the server is already running.
5. Create or select a session before sending prompts, commands, shell commands, or file-oriented requests.
6. Subscribe to events before long-running prompts when you need progress, completion, or permission handling.
7. Use `throwOnError: true` or explicit response checks when callers need fail-fast behavior.

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

## Start Server And Client

```typescript
import { createOpencode } from "@opencode-ai/sdk"

const opencode = await createOpencode({
  hostname: "127.0.0.1",
  port: 4096,
  timeout: 5000,
  config: {
    model: "anthropic/claude-3-5-sonnet-20241022",
  },
})

try {
  const session = await opencode.client.session.create({
    body: { title: "Automated task" },
  })

  await opencode.client.session.prompt({
    path: { id: session.id },
    body: {
      model: { providerID: "anthropic", modelID: "claude-3-5-sonnet-20241022" },
      parts: [{ type: "text", text: "Implement the requested change." }],
    },
  })
} finally {
  opencode.server.close()
}
```

`createOpencode()` starts both a server and a client. Common options are `hostname`, `port`, `signal`, `timeout`, and `config`.

## Connect To Existing Server

```typescript
import { createOpencodeClient } from "@opencode-ai/sdk"

const client = createOpencodeClient({
  baseUrl: "http://localhost:4096",
})
```

Client options include `baseUrl`, `fetch`, `parseAs`, `responseStyle`, `throwOnError`, and `directory`. The v2 client also supports `experimental_workspaceID`.

## Core Session Calls

```typescript
const session = await client.session.create({
  body: { title: "My session" },
})

const sessions = await client.session.list()
const current = await client.session.get({ path: { id: session.id } })
const messages = await client.session.messages({ path: { id: session.id } })

await client.session.prompt({
  path: { id: session.id },
  body: {
    model: { providerID: "anthropic", modelID: "claude-3-5-sonnet-20241022" },
    parts: [{ type: "text", text: "Hello!" }],
  },
})

await client.session.prompt({
  path: { id: session.id },
  body: {
    noReply: true,
    parts: [{ type: "text", text: "Context only. Do not respond." }],
  },
})
```

Use `noReply: true` to inject context without triggering an assistant response. Use `session.promptAsync()` when you need to enqueue work and return immediately.

Other current session APIs include `status`, `children`, `todo`, `init`, `fork`, `abort`, `share`, `unshare`, `diff`, `summarize`, `message`, `command`, `shell`, `revert`, and `unrevert`.

## Structured Output

Request structured JSON from `session.prompt()` with `outputFormat`.

```typescript
const result = await client.session.prompt({
  path: { id: session.id },
  body: {
    parts: [{ type: "text", text: "Research Anthropic and return company info." }],
    outputFormat: {
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
  },
})

console.log(result.data.info.structured_output)
```

If structured output fails, check `result.data.info.error?.name === "StructuredOutputError"`.

## Files And Search

```typescript
const textResults = await client.find.text({
  query: { pattern: "function.*opencode" },
})

const files = await client.find.files({
  query: { query: "*.ts", type: "file", limit: 50 },
})

const directories = await client.find.files({
  query: { query: "packages", type: "directory", limit: 20 },
})

const symbols = await client.find.symbols({
  query: { query: "handleRequest" },
})

const content = await client.file.read({
  query: { path: "src/index.ts" },
})

const status = await client.file.status()
```

## Events And Completion

Subscribe to `event.subscribe()` before sending work if you need to wait for completion.

```typescript
const events = await client.event.subscribe()

await client.session.prompt({
  path: { id: session.id },
  body: {
    parts: [{ type: "text", text: "Fix all TypeScript errors." }],
  },
})

for await (const event of events.stream) {
  if (event.type === "session.idle" && event.properties.sessionID === session.id) {
    break
  }
}
```

Useful event types include `message.updated`, `session.status`, `session.idle`, `permission.updated`, `permission.replied`, `session.compacted`, and `file.edited`.

## Permission Handling

Respond to permission requests with `postSessionIdPermissionsPermissionId()`.

```typescript
for await (const event of events.stream) {
  if (event.type !== "permission.updated") continue

  const permission = event.properties
  if (permission.type === "file_read") {
    await client.postSessionIdPermissionsPermissionId({
      path: { id: permission.sessionID, permissionID: permission.id },
      body: { response: "allow" },
    })
  }
}
```

Do not auto-approve write, shell, network, or destructive permissions unless the integration has an explicit policy for that trust boundary.

## TUI Control

Use TUI APIs only when controlling an interactive OpenCode TUI remotely.

```typescript
await client.tui.appendPrompt({ body: { text: "Add this to the prompt" } })
await client.tui.submitPrompt()
await client.tui.clearPrompt()

await client.tui.openHelp()
await client.tui.openSessions()
await client.tui.openThemes()
await client.tui.openModels()

await client.tui.executeCommand({ body: { name: "agent_cycle" } })
await client.tui.showToast({
  body: { message: "Task complete", variant: "success" },
})
```

The current generated client also exposes `tui.publish()` and `tui.control` for lower-level TUI integrations.

## Other API Groups

Use `global.event()` for global server events and `event.subscribe()` for the main event stream.

Use `project.list()` and `project.current()` for project context.

Use `path.get()` for current path info.

Use `config.get()` and `config.providers()` for configuration and provider defaults.

Use `app.log()` and `app.agents()` for app-level integration hooks.

Use `mcp.*`, `lsp.status()`, and `formatter.status()` only when the integration specifically needs those subsystems.

Use `auth.set()` to set provider credentials through the server API.

## Types

```typescript
import type { Message, Part, Permission, Session } from "@opencode-ai/sdk"
```
