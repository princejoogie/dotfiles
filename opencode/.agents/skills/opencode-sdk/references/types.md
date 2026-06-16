# OpenCode SDK Types Reference

Notable TypeScript types exported from `@opencode-ai/sdk/v2` in SDK version `1.17.7`.

## Import

```typescript
import type {
  AssistantMessage,
  Message,
  OutputFormat,
  Part,
  PermissionRuleset,
  PermissionV2Reply,
  Session,
  SessionStatus,
  Todo,
  ToolState,
  UserMessage,
} from "@opencode-ai/sdk/v2"
```

## Response Handling

Generated clients default to field responses:

```typescript
const response = await client.session.create({ title: "Example" })
const session = response.data
```

For direct data returns:

```typescript
const client = createOpencodeClient({
  baseUrl: "http://localhost:4096",
  throwOnError: true,
  responseStyle: "data",
})
```

Native `client.v2.*` endpoints often return a server envelope such as `{ data: ... }`; `responseStyle: "data"` removes the fetch wrapper, not the API envelope.

## Core Types

### Session

```typescript
type Session = {
  id: string
  slug: string
  projectID: string
  workspaceID?: string
  directory: string
  path?: string
  parentID?: string
  summary?: {
    additions: number
    deletions: number
    files: number
    diffs?: SnapshotFileDiff[]
  }
  cost?: number
  tokens?: TokenUsage
  share?: { url: string }
  title: string
  agent?: string
  model?: { id: string; providerID: string; variant?: string }
  version: string
  metadata?: Record<string, unknown>
  time: {
    created: number
    updated: number
    compacting?: number
    archived?: number
  }
  permission?: PermissionRuleset
  revert?: {
    messageID: string
    partID?: string
    snapshot?: string
    diff?: string
  }
}
```

### Permission Rules

```typescript
type PermissionAction = "allow" | "deny" | "ask"

type PermissionRule = {
  permission: string
  pattern: string
  action: PermissionAction
}

type PermissionRuleset = PermissionRule[]

type PermissionV2Reply = "once" | "always" | "reject"
```

### Messages

```typescript
type Message = UserMessage | AssistantMessage

type UserMessage = {
  id: string
  sessionID: string
  role: "user"
  time: { created: number }
  format?: OutputFormat
  summary?: { title?: string; body?: string; diffs: SnapshotFileDiff[] }
  agent: string
  model: { providerID: string; modelID: string; variant?: string }
  system?: string
  tools?: Record<string, boolean>
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
  agent: string
  path: { cwd: string; root: string }
  summary?: boolean
  cost: number
  tokens: TokenUsage
  structured?: unknown
  variant?: string
  finish?: string
}
```

`MessageError` includes `ProviderAuthError`, `UnknownError`, `MessageOutputLengthError`, `MessageAbortedError`, `StructuredOutputError`, `ContextOverflowError`, `ContentFilterError`, and `ApiError`.

### Output Format

```typescript
type OutputFormat =
  | { type: "text" }
  | {
      type: "json_schema"
      schema: Record<string, unknown>
      retryCount?: number
    }
```

Use v2 `format` on `session.prompt()`, not legacy `outputFormat`.

### Parts

```typescript
type Part =
  | TextPart
  | SubtaskPart
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
```

Notable 1.17.7 fields:

1. `SubtaskPart` may include `model` and `command`.
2. `FilePart.source` may be a file, symbol, or MCP resource source.
3. `StepFinishPart.tokens` may include `total`.
4. `CompactionPart` may include `overflow` and `tail_start_id`.

### Tool State

```typescript
type ToolState =
  | { status: "pending"; input: Record<string, unknown>; raw: string }
  | {
      status: "running"
      input: Record<string, unknown>
      title?: string
      metadata?: Record<string, unknown>
      time: { start: number }
    }
  | {
      status: "completed"
      input: Record<string, unknown>
      output: string
      title: string
      metadata: Record<string, unknown>
      time: { start: number; end: number; compacted?: number }
      attachments?: FilePart[]
    }
  | {
      status: "error"
      input: Record<string, unknown>
      error: string
      metadata?: Record<string, unknown>
      time: { start: number; end: number }
    }
```

### Session Status

```typescript
type SessionStatus =
  | { type: "idle" }
  | {
      type: "retry"
      attempt: number
      message: string
      action?: {
        reason: string
        provider: string
        title: string
        message: string
        label: string
        link?: string
      }
      next: number
    }
  | { type: "busy" }
```

### Todo

```typescript
type Todo = {
  content: string
  status: string
  priority: string
}
```

The schema documents the usual values as `pending`, `in_progress`, `completed`, `cancelled` and `high`, `medium`, `low`, but the latest exported type is `string`.

## Location And Workspace

Top-level v2 APIs usually accept `directory?: string` and `workspace?: string` directly.

Native `client.v2.*` query APIs usually accept a location object:

```typescript
type LocationQuery = {
  directory?: string
  workspace?: string
}

await client.v2.fs.find({
  location: { directory: process.cwd() },
  query: "*.ts",
})
```

Native session creation uses the body `LocationRef` shape:

```typescript
type LocationRef = {
  directory: string
  workspaceID?: string
}
```

The v2 client constructor also supports `directory` and `experimental_workspaceID` defaults.
