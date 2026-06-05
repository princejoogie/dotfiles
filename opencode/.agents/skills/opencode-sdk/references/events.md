# OpenCode SDK Events Reference

All SSE (Server-Sent Events) types emitted by the OpenCode server.

## Subscribing to Events

```typescript
const events = await client.event.subscribe()

for await (const event of events.stream) {
  console.log(event.type, event.properties)
}
```

## Event Types

### Server Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `server.instance.disposed` | `{ directory: string }` | Server instance disposed |

### Installation Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `installation.updated` | `{ version: string }` | OpenCode was updated |
| `installation.update-available` | `{ version: string }` | New version available |

### Session Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `session.created` | `{ info: Session }` | Session was created |
| `session.updated` | `{ info: Session }` | Session was updated |
| `session.status` | `{ sessionID, status: SessionStatus }` | Session status changed |
| `session.idle` | `{ sessionID: string }` | Session became idle |
| `session.compacted` | `{ sessionID: string }` | Session was compacted |

### Message Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `message.updated` | `{ info: Message }` | Message was updated |
| `message.removed` | `{ sessionID, messageID }` | Message was removed |
| `message.part.updated` | `{ part: Part, delta?: string }` | Message part updated |
| `message.part.removed` | `{ sessionID, messageID, partID }` | Message part removed |

### Permission Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `permission.updated` | `Permission` | Permission request created |
| `permission.replied` | `{ sessionID, permissionID, response }` | Permission was answered |

### File Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `file.edited` | `{ file: string }` | File was edited |

### Todo Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `todo.updated` | `{ sessionID, todos: Todo[] }` | Todos were updated |

### Command Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `command.executed` | `{ name, sessionID, arguments, messageID }` | Command was executed |

### LSP Events

| Event Type | Properties | Description |
|------------|------------|-------------|
| `lsp.updated` | `{ [key: string]: unknown }` | LSP state changed |
| `lsp.client.diagnostics` | `{ serverID, path }` | Diagnostics received |

## Key Types

### SessionStatus

```typescript
type SessionStatus =
  | { type: "idle" }
  | { type: "retry"; attempt: number; message: string; next: number }
  | { type: "busy" }
```

### Message

```typescript
type Message = UserMessage | AssistantMessage

type UserMessage = {
  id: string
  sessionID: string
  role: "user"
  time: { created: number }
  summary?: { title?: string; body?: string; diffs: FileDiff[] }
  agent: string
  model: { providerID: string; modelID: string }
  system?: string
  tools?: { [key: string]: boolean }
}

type AssistantMessage = {
  id: string
  sessionID: string
  role: "assistant"
  time: { created: number; completed?: number }
  error?: MessageError
  parentID: string
  modelID: string
  providerID: string
  mode: string
  path: { cwd: string; root: string }
  summary?: boolean
  cost: number
  tokens: {
    input: number
    output: number
    reasoning: number
    cache: { read: number; write: number }
  }
  finish?: string
}
```

### Part Types

```typescript
type Part =
  | TextPart
  | ReasoningPart
  | FilePart
  | ToolPart
  | StepStartPart
  | StepFinishPart
  | SnapshotPart
  | PatchPart
  | AgentPart
  | RetryPart
  | CompactionPart
  | SubtaskPart

type TextPart = {
  id: string
  sessionID: string
  messageID: string
  type: "text"
  text: string
  synthetic?: boolean
  ignored?: boolean
  time?: { start: number; end?: number }
  metadata?: { [key: string]: unknown }
}

type ToolPart = {
  id: string
  sessionID: string
  messageID: string
  type: "tool"
  callID: string
  tool: string
  state: ToolState
  metadata?: { [key: string]: unknown }
}

type ToolState =
  | { status: "pending"; input: object; raw: string }
  | { status: "running"; input: object; title?: string; metadata?: object; time: { start: number } }
  | { status: "completed"; input: object; output: string; title: string; metadata: object; time: { start: number; end: number; compacted?: number }; attachments?: FilePart[] }
  | { status: "error"; input: object; error: string; time: { start: number; end: number } }
```

### Permission

```typescript
type Permission = {
  id: string
  type: string
  pattern?: string | string[]
  sessionID: string
  messageID: string
  callID?: string
  title: string
  metadata: { [key: string]: unknown }
  time: { created: number }
}
```

### Todo

```typescript
type Todo = {
  id: string
  content: string
  status: "pending" | "in_progress" | "completed" | "cancelled"
  priority: "high" | "medium" | "low"
}
```

## Event Patterns

### Wait for Session Completion

```typescript
async function waitForIdle(client: OpencodeClient, sessionId: string) {
  const events = await client.event.subscribe()
  
  for await (const event of events.stream) {
    if (event.type === "session.idle" && event.properties.sessionID === sessionId) {
      return
    }
  }
}
```

### Stream Assistant Responses

```typescript
async function streamResponse(client: OpencodeClient, sessionId: string) {
  const events = await client.event.subscribe()
  
  for await (const event of events.stream) {
    if (event.type === "message.part.updated") {
      const { part, delta } = event.properties
      if (part.sessionID === sessionId && part.type === "text" && delta) {
        process.stdout.write(delta)
      }
    }
    
    if (event.type === "session.idle" && event.properties.sessionID === sessionId) {
      break
    }
  }
}
```

### Auto-Approve Permissions

```typescript
async function autoApprove(client: OpencodeClient, patterns: string[]) {
  const events = await client.event.subscribe()
  
  for await (const event of events.stream) {
    if (event.type === "permission.updated") {
      const perm = event.properties
      
      // Check if permission matches allowed patterns
      const shouldAllow = patterns.some(p => perm.type.includes(p))
      
      await client.postSessionIdPermissionsPermissionId({
        path: { id: perm.sessionID, permissionId: perm.id },
        body: { response: shouldAllow ? "allow" : "deny" }
      })
    }
  }
}
```

### Track Tool Execution

```typescript
async function trackTools(client: OpencodeClient, sessionId: string) {
  const events = await client.event.subscribe()
  const tools = new Map<string, ToolState>()
  
  for await (const event of events.stream) {
    if (event.type === "message.part.updated") {
      const { part } = event.properties
      if (part.sessionID === sessionId && part.type === "tool") {
        tools.set(part.callID, part.state)
        
        if (part.state.status === "completed") {
          console.log(`Tool ${part.tool} completed:`, part.state.output)
        } else if (part.state.status === "error") {
          console.log(`Tool ${part.tool} failed:`, part.state.error)
        }
      }
    }
  }
}
```
