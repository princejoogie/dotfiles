---
name: opencode-sdk
description: |
  [WHAT] TypeScript SDK for programmatic control of OpenCode AI coding agent.
  [HOW] Client/server architecture: start embedded server or connect to existing instance.
  [WHEN] Use when automating OpenCode, building integrations, or controlling sessions programmatically.
  [WHY] Enables headless coding agent workflows, CI/CD integration, and custom tooling.

  Triggers: "opencode", "opencode sdk", "opencode api", "opencode programmatic",
            "control opencode", "opencode automation", "opencode typescript",
            "opencode client", "opencode server", "coding agent sdk"

  Category: EXECUTE (run agents) + GET (session data)
version: 1.0.0
npm: "@opencode-ai/sdk"
npm_version: "1.1.36"
docs: "https://opencode.ai/docs/sdk"
---

# OpenCode SDK

TypeScript SDK for the OpenCode AI coding agent. Control sessions, send prompts, and subscribe to events programmatically.

## Quick Start

```bash
npm install @opencode-ai/sdk
```

### Full Instance (Server + Client)

```typescript
import { createOpencode } from "@opencode-ai/sdk"

const { client, server } = await createOpencode({
  hostname: "127.0.0.1",
  port: 4096,
  timeout: 5000,
  config: {
    model: "anthropic/claude-sonnet-4-20250514"
  }
})

// Use client...
server.close()
```

### Client Only (Connect to Running Instance)

```typescript
import { createOpencodeClient } from "@opencode-ai/sdk"

const client = createOpencodeClient({
  baseUrl: "http://localhost:4096"
})
```

## Core APIs

### Sessions

```typescript
// Create session
const session = await client.session.create({
  body: { title: "My Task" }
})

// Send prompt
const result = await client.session.prompt({
  path: { id: session.id },
  body: {
    model: { providerID: "anthropic", modelID: "claude-sonnet-4-20250514" },
    parts: [{ type: "text", text: "Implement a function to..." }]
  }
})

// Inject context without AI response
await client.session.prompt({
  path: { id: session.id },
  body: {
    noReply: true,
    parts: [{ type: "text", text: "Context: This project uses..." }]
  }
})

// List sessions
const sessions = await client.session.list()

// Get session messages
const messages = await client.session.messages({ path: { id: session.id } })
```

### Files & Search

```typescript
// Search text in files
const textResults = await client.find.text({
  query: { pattern: "function.*handler" }
})

// Find files by name
const files = await client.find.files({
  query: { query: "*.ts", type: "file", limit: 50 }
})

// Find symbols
const symbols = await client.find.symbols({
  query: { query: "handleRequest" }
})

// Read file content
const content = await client.file.read({
  query: { path: "src/index.ts" }
})
```

### Events (SSE Stream)

```typescript
const events = await client.event.subscribe()

for await (const event of events.stream) {
  switch (event.type) {
    case "message.updated":
      console.log("Message:", event.properties.info)
      break
    case "session.status":
      console.log("Status:", event.properties.status)
      break
    case "permission.updated":
      // Handle permission requests
      break
  }
}
```

### TUI Control

```typescript
// Append to prompt
await client.tui.appendPrompt({ body: { text: "Add this text" } })

// Submit prompt
await client.tui.submitPrompt()

// Show toast
await client.tui.showToast({
  body: { message: "Task complete", variant: "success" }
})

// Execute command
await client.tui.executeCommand({ body: { name: "agent_cycle" } })
```

## Key Types

```typescript
import type {
  Session,
  Message,
  UserMessage,
  AssistantMessage,
  Part,
  TextPart,
  ToolPart,
  Permission,
  SessionStatus
} from "@opencode-ai/sdk"
```

## Decision Tree

```
What do you need?
│
├─→ Start OpenCode + control it?
│   └─→ createOpencode() - starts server + returns client
│
├─→ Connect to running OpenCode?
│   └─→ createOpencodeClient({ baseUrl }) - client only
│
├─→ Send prompts programmatically?
│   └─→ client.session.prompt()
│
├─→ Inject context without response?
│   └─→ client.session.prompt({ body: { noReply: true, ... } })
│
├─→ Stream events in real-time?
│   └─→ client.event.subscribe()
│
└─→ Control TUI remotely?
    └─→ client.tui.* methods
```

## Integration Patterns

### Headless Agent Loop

```typescript
import { createOpencode } from "@opencode-ai/sdk"

const { client, server } = await createOpencode()
const session = await client.session.create({ body: { title: "Automated" } })

// Subscribe to events for progress
const events = await client.event.subscribe()

// Send task
await client.session.prompt({
  path: { id: session.id },
  body: {
    model: { providerID: "anthropic", modelID: "claude-sonnet-4-20250514" },
    parts: [{ type: "text", text: "Fix all TypeScript errors in src/" }]
  }
})

// Wait for completion via events
for await (const event of events.stream) {
  if (event.type === "session.idle" && event.properties.sessionID === session.id) {
    break
  }
}

server.close()
```

### Permission Handling

```typescript
for await (const event of events.stream) {
  if (event.type === "permission.updated") {
    const perm = event.properties
    // Auto-approve file reads, prompt for writes
    if (perm.type === "file_read") {
      await client.postSessionIdPermissionsPermissionId({
        path: { id: perm.sessionID, permissionId: perm.id },
        body: { response: "allow" }
      })
    }
  }
}
```

## References

- `references/api-reference.md` - Complete API documentation
- `references/types.md` - Full TypeScript type definitions
- `references/events.md` - All event types and properties

## See Also

- Official docs: https://opencode.ai/docs/sdk
- OpenCode CLI: `opencode` (TUI)
- GitHub: https://github.com/anomalyco/opencode
