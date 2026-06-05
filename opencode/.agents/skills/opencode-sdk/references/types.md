# OpenCode SDK Types Reference

All TypeScript types exported from `@opencode-ai/sdk`.

## Import

```typescript
import type {
  Session,
  Message,
  UserMessage,
  AssistantMessage,
  Part,
  TextPart,
  ReasoningPart,
  FilePart,
  ToolPart,
  Permission,
  SessionStatus,
  Todo,
  Project,
  Config,
  Provider,
  Agent
} from "@opencode-ai/sdk"
```

## Core Types

### Session

```typescript
type Session = {
  id: string
  projectID: string
  directory: string
  parentID?: string
  summary?: {
    additions: number
    deletions: number
    files: number
    diffs?: FileDiff[]
  }
  share?: { url: string }
  title: string
  version: string
  time: {
    created: number
    updated: number
    compacting?: number
  }
  revert?: {
    messageID: string
    partID?: string
    snapshot?: string
    diff?: string
  }
}
```

### Message Types

```typescript
type Message = UserMessage | AssistantMessage

type UserMessage = {
  id: string
  sessionID: string
  role: "user"
  time: { created: number }
  summary?: {
    title?: string
    body?: string
    diffs: FileDiff[]
  }
  agent: string
  model: { providerID: string; modelID: string }
  system?: string
  tools?: { [key: string]: boolean }
}

type AssistantMessage = {
  id: string
  sessionID: string
  role: "assistant"
  time: {
    created: number
    completed?: number
  }
  error?: ProviderAuthError | UnknownError | MessageOutputLengthError | MessageAbortedError | ApiError
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

type ReasoningPart = {
  id: string
  sessionID: string
  messageID: string
  type: "reasoning"
  text: string
  metadata?: { [key: string]: unknown }
  time: { start: number; end?: number }
}

type FilePart = {
  id: string
  sessionID: string
  messageID: string
  type: "file"
  mime: string
  filename?: string
  url: string
  source?: FileSource | SymbolSource
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

type SubtaskPart = {
  id: string
  sessionID: string
  messageID: string
  type: "subtask"
  prompt: string
  description: string
  agent: string
}

type StepStartPart = {
  id: string
  sessionID: string
  messageID: string
  type: "step-start"
  snapshot?: string
}

type StepFinishPart = {
  id: string
  sessionID: string
  messageID: string
  type: "step-finish"
  reason: string
  snapshot?: string
  cost: number
  tokens: {
    input: number
    output: number
    reasoning: number
    cache: { read: number; write: number }
  }
}

type SnapshotPart = {
  id: string
  sessionID: string
  messageID: string
  type: "snapshot"
  snapshot: string
}

type PatchPart = {
  id: string
  sessionID: string
  messageID: string
  type: "patch"
  hash: string
  files: string[]
}

type AgentPart = {
  id: string
  sessionID: string
  messageID: string
  type: "agent"
  name: string
  source?: { value: string; start: number; end: number }
}

type RetryPart = {
  id: string
  sessionID: string
  messageID: string
  type: "retry"
  attempt: number
  error: ApiError
  time: { created: number }
}

type CompactionPart = {
  id: string
  sessionID: string
  messageID: string
  type: "compaction"
  auto: boolean
}
```

### Tool State Types

```typescript
type ToolState =
  | ToolStatePending
  | ToolStateRunning
  | ToolStateCompleted
  | ToolStateError

type ToolStatePending = {
  status: "pending"
  input: { [key: string]: unknown }
  raw: string
}

type ToolStateRunning = {
  status: "running"
  input: { [key: string]: unknown }
  title?: string
  metadata?: { [key: string]: unknown }
  time: { start: number }
}

type ToolStateCompleted = {
  status: "completed"
  input: { [key: string]: unknown }
  output: string
  title: string
  metadata: { [key: string]: unknown }
  time: {
    start: number
    end: number
    compacted?: number
  }
  attachments?: FilePart[]
}

type ToolStateError = {
  status: "error"
  input: { [key: string]: unknown }
  error: string
  time: {
    start: number
    end: number
  }
}
```

### File Source Types

```typescript
type FilePartSourceText = {
  value: string
  start: number
  end: number
}

type FileSource = {
  text: FilePartSourceText
  type: "file"
  path: string
}

type SymbolSource = {
  text: FilePartSourceText
  type: "symbol"
  path: string
  range: Range
  name: string
  kind: number
}

type Range = {
  start: { line: number; character: number }
  end: { line: number; character: number }
}
```

### Error Types

```typescript
type ProviderAuthError = {
  name: "ProviderAuthError"
  data: { providerID: string; message: string }
}

type UnknownError = {
  name: "UnknownError"
  data: { message: string }
}

type MessageOutputLengthError = {
  name: "MessageOutputLengthError"
  data: { [key: string]: unknown }
}

type MessageAbortedError = {
  name: "MessageAbortedError"
  data: { message: string }
}

type ApiError = {
  name: "APIError"
  data: {
    message: string
    statusCode?: number
    isRetryable: boolean
    responseHeaders?: { [key: string]: string }
    responseBody?: string
  }
}
```

### Permission Types

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

### Session Status

```typescript
type SessionStatus =
  | { type: "idle" }
  | { type: "retry"; attempt: number; message: string; next: number }
  | { type: "busy" }
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

### FileDiff

```typescript
type FileDiff = {
  file: string
  before: string
  after: string
  additions: number
  deletions: number
}
```

## Client Configuration Types

```typescript
type Config = {
  model?: string
  // Additional config options from opencode.json
  [key: string]: unknown
}

type ServerOptions = {
  hostname?: string    // Default: "127.0.0.1"
  port?: number        // Default: 4096
  signal?: AbortSignal
  timeout?: number     // Default: 5000
  config?: Config
}

type TuiOptions = {
  project?: string
  model?: string
  session?: string
  agent?: string
  signal?: AbortSignal
  config?: Config
}

type ClientConfig = {
  baseUrl?: string        // Default: "http://localhost:4096"
  fetch?: typeof fetch
  parseAs?: string
  responseStyle?: "data" | "fields"
  throwOnError?: boolean
  directory?: string
}
```
