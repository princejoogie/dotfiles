# OpenCode SDK API Reference

Complete API documentation for `@opencode-ai/sdk`.

## Client Creation

### createOpencode(options?)

Creates both a server and client instance.

```typescript
import { createOpencode } from "@opencode-ai/sdk"

const { client, server } = await createOpencode({
  hostname: "127.0.0.1",  // Server hostname
  port: 4096,             // Server port
  signal: AbortSignal,    // Abort signal for cancellation
  timeout: 5000,          // Timeout in ms for server start
  config: {               // Configuration overrides
    model: "anthropic/claude-sonnet-4-20250514"
  }
})

// When done
server.close()
```

### createOpencodeClient(config?)

Creates a client that connects to an existing server.

```typescript
import { createOpencodeClient } from "@opencode-ai/sdk"

const client = createOpencodeClient({
  baseUrl: "http://localhost:4096",  // Server URL
  fetch: globalThis.fetch,           // Custom fetch implementation
  parseAs: "auto",                   // Response parsing mode
  responseStyle: "fields",           // Return style: "data" or "fields"
  throwOnError: false                // Throw errors instead of return
})
```

### createOpencodeTui(options?)

Creates a TUI instance.

```typescript
import { createOpencodeTui } from "@opencode-ai/sdk/server"

const tui = createOpencodeTui({
  project: "/path/to/project",
  model: "anthropic/claude-sonnet-4-20250514",
  session: "session-id",
  agent: "build",
  signal: AbortSignal,
  config: {}
})

tui.close()
```

## API Namespaces

### client.global

| Method | Description | Response |
|--------|-------------|----------|
| `health()` | Check server health | `{ healthy: true, version: string }` |

### client.project

| Method | Description | Response |
|--------|-------------|----------|
| `list()` | List all projects | `Project[]` |
| `current()` | Get current project | `Project` |

### client.session

| Method | Description |
|--------|-------------|
| `list()` | List all sessions |
| `create({ body })` | Create new session |
| `get({ path: { id } })` | Get session by ID |
| `update({ path, body })` | Update session |
| `delete({ path: { id } })` | Delete session |
| `status({ path: { id } })` | Get session status |
| `children({ path: { id } })` | Get child sessions |
| `todo({ path: { id } })` | Get session todos |
| `init({ path: { id } })` | Initialize session |
| `fork({ path: { id } })` | Fork session |
| `abort({ path: { id } })` | Abort running session |
| `share({ path: { id } })` | Share session |
| `unshare({ path: { id } })` | Unshare session |
| `diff({ path: { id } })` | Get session diff |
| `summarize({ path: { id } })` | Summarize session |
| `messages({ path: { id } })` | List messages |
| `message({ path: { id, messageId } })` | Get single message |
| `prompt({ path, body })` | Send prompt |
| `promptAsync({ path, body })` | Send async prompt |
| `command({ path, body })` | Send command |
| `shell({ path, body })` | Run shell command |
| `revert({ path, body })` | Revert message |
| `unrevert({ path })` | Restore reverted |

### Session Prompt Body

```typescript
await client.session.prompt({
  path: { id: sessionId },
  body: {
    model: {
      providerID: "anthropic",
      modelID: "claude-sonnet-4-20250514"
    },
    parts: [
      { type: "text", text: "Your prompt here" }
    ],
    noReply: false,  // true = inject context only
    agent: "build"   // or "plan"
  }
})
```

### client.find

| Method | Description | Response |
|--------|-------------|----------|
| `text({ query: { pattern } })` | Search text in files | Match objects with path, lines, line_number |
| `files({ query })` | Find files/directories | `string[]` paths |
| `symbols({ query })` | Find workspace symbols | `Symbol[]` |

```typescript
// Find files
await client.find.files({
  query: {
    query: "*.ts",       // Pattern
    type: "file",        // "file" or "directory"
    directory: "/src",   // Override project root
    limit: 50            // Max results (1-200)
  }
})
```

### client.file

| Method | Description | Response |
|--------|-------------|----------|
| `read({ query: { path } })` | Read file content | `{ type: "raw" | "patch", content: string }` |
| `status({ query? })` | Get tracked file status | `File[]` |
| `list()` | List files | `File[]` |

### client.config

| Method | Description |
|--------|-------------|
| `get()` | Get config info |
| `update({ body })` | Update config |
| `providers()` | List providers and default models |

### client.provider

| Method | Description |
|--------|-------------|
| `list()` | List all providers |
| `auth({ path: { id } })` | Get auth status |
| `oauth.authorize({ path })` | Start OAuth flow |
| `oauth.callback({ path, query })` | Handle OAuth callback |

### client.tool

| Method | Description |
|--------|-------------|
| `ids({ path: { sessionId } })` | Get tool IDs for session |
| `list({ path: { sessionId } })` | List tools for session |

### client.mcp

| Method | Description |
|--------|-------------|
| `status()` | Get MCP server status |
| `add({ body })` | Add MCP server |
| `connect({ path: { id } })` | Connect to MCP server |
| `disconnect({ path: { id } })` | Disconnect MCP server |
| `auth.start({ path })` | Start MCP auth |
| `auth.callback({ path, query })` | MCP auth callback |
| `auth.authenticate({ path, body })` | Authenticate MCP |
| `auth.remove({ path })` | Remove MCP auth |

### client.tui

| Method | Description |
|--------|-------------|
| `appendPrompt({ body: { text } })` | Append text to prompt |
| `submitPrompt()` | Submit current prompt |
| `clearPrompt()` | Clear prompt |
| `openHelp()` | Open help dialog |
| `openSessions()` | Open session selector |
| `openThemes()` | Open theme selector |
| `openModels()` | Open model selector |
| `executeCommand({ body: { name } })` | Execute TUI command |
| `showToast({ body })` | Show toast notification |
| `publish({ body })` | Publish TUI event |
| `control.next()` | Get next TUI request |
| `control.response({ body })` | Submit TUI response |

### client.event

| Method | Description |
|--------|-------------|
| `subscribe()` | Subscribe to SSE stream |

### client.auth

| Method | Description |
|--------|-------------|
| `set({ path: { id }, body })` | Set authentication |

```typescript
await client.auth.set({
  path: { id: "anthropic" },
  body: { type: "api", key: "sk-..." }
})
```

### client.app

| Method | Description |
|--------|-------------|
| `log({ body })` | Write log entry |
| `agents()` | List available agents |

### client.path

| Method | Description |
|--------|-------------|
| `get()` | Get current path info |

### client.vcs

| Method | Description |
|--------|-------------|
| `get()` | Get VCS info |

### client.pty

| Method | Description |
|--------|-------------|
| `list()` | List PTY sessions |
| `create({ body })` | Create PTY |
| `get({ path: { id } })` | Get PTY |
| `update({ path, body })` | Update PTY |
| `remove({ path: { id } })` | Remove PTY |
| `connect({ path: { id } })` | Connect to PTY |

### client.lsp

| Method | Description |
|--------|-------------|
| `status()` | Get LSP server status |

### client.formatter

| Method | Description |
|--------|-------------|
| `status()` | Get formatter status |

### client.instance

| Method | Description |
|--------|-------------|
| `dispose()` | Dispose server instance |

### client.command

| Method | Description |
|--------|-------------|
| `list()` | List available commands |

### Permission Handling

```typescript
await client.postSessionIdPermissionsPermissionId({
  path: {
    id: sessionId,
    permissionId: permissionId
  },
  body: {
    response: "allow" | "deny" | "always" | "never"
  }
})
```
