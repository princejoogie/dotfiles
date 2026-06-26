# OpenCode SDK API Reference

Quick API reference for `@opencode-ai/sdk@1.17.7` from `/Users/pjuguilon/Documents/codes/vervio/vendio/opencode`.

## Exports

| Export | Use |
| --- | --- |
| `@opencode-ai/sdk` | Legacy generated client with `{ path, query, body }` method arguments. |
| `@opencode-ai/sdk/server` | Legacy `createOpencodeServer()` and `createOpencodeTui()` helpers. |
| `@opencode-ai/sdk/v2` | Latest generated client with direct parameter objects and `client.v2.*` native endpoints. |
| `@opencode-ai/sdk/v2/server` | V2 server/TUI process helpers. |

Generated clients default to field responses. Use `responseStyle: "data"` for direct data returns or unwrap `.data`.

## Client Creation

### V2 Client

```typescript
import { createOpencodeClient } from "@opencode-ai/sdk/v2"

const client = createOpencodeClient({
  baseUrl: "http://localhost:4096",
  directory: process.cwd(),
  throwOnError: true,
  responseStyle: "data",
})
```

V2 client options include `baseUrl`, `fetch`, `parseAs`, `responseStyle`, `throwOnError`, `headers`, `directory`, and `experimental_workspaceID`.

### Server Helper

```typescript
import { createOpencodeClient, createOpencodeServer } from "@opencode-ai/sdk/v2"

const server = await createOpencodeServer({ hostname: "127.0.0.1", port: 4096 })
const client = createOpencodeClient({ baseUrl: server.url, throwOnError: true, responseStyle: "data" })

server.close()
```

`createOpencodeServer()` options are `hostname`, `port`, `signal`, `timeout`, and `config`.

### TUI Helper

```typescript
import { createOpencodeTui } from "@opencode-ai/sdk/v2/server"

const tui = createOpencodeTui({
  project: "/path/to/project",
  session: "session-id",
  agent: "build",
  config: {},
})

tui.close()
```

## Call Shape Diff

Legacy root export:

```typescript
await legacy.session.prompt({
  path: { id: sessionID },
  query: { directory: process.cwd() },
  body: { parts: [{ type: "text", text: "Hello" }] },
})
```

V2 export:

```typescript
await client.session.prompt({
  sessionID,
  directory: process.cwd(),
  parts: [{ type: "text", text: "Hello" }],
})
```

Native `/api` namespace under the v2 export:

```typescript
await client.v2.session.prompt({
  sessionID,
  prompt: { text: "Hello" },
  delivery: "queue",
  resume: true,
})
```

## Top-Level V2 API Groups

| Group | Methods |
| --- | --- |
| `auth` | `set`, `remove` |
| `app` | `log`, `agents`, `skills` |
| `global` | `health`, `event`, `dispose`, `upgrade`, `config.get`, `config.update` |
| `event` | `subscribe` |
| `config` | `get`, `update`, `providers` |
| `tool` | `list`, `ids` |
| `worktree` | `list`, `create`, `remove`, `reset` |
| `find` | `text`, `files`, `symbols` |
| `file` | `list`, `read`, `status` |
| `instance` | `dispose` |
| `path` | `get` |
| `vcs` | `get`, `status`, `diff`, `apply`, `diff2.raw` |
| `command` | `list` |
| `lsp` | `status` |
| `formatter` | `status` |
| `mcp` | `status`, `add`, `connect`, `disconnect`, `auth.start`, `auth.callback`, `auth.authenticate`, `auth.remove` |
| `project` | `list`, `current`, `initGit`, `update`, `directories` |
| `pty` | `shells`, `list`, `create`, `get`, `update`, `remove`, `connectToken`, `connect` |
| `question` | `list`, `reply`, `reject` |
| `permission` | `list`, `reply`, deprecated `respond` |
| `provider` | `list`, `auth`, `oauth.authorize`, `oauth.callback` |
| `session` | `list`, `create`, `status`, `get`, `update`, `delete`, `children`, `todo`, `diff`, `messages`, `prompt`, `deleteMessage`, `message`, `fork`, `abort`, `init`, `share`, `unshare`, `summarize`, `promptAsync`, `command`, `shell`, `revert`, `unrevert` |
| `part` | `delete`, `update` |
| `sync` | `start`, `replay`, `steal`, `history.list` |
| `tui` | `appendPrompt`, `openHelp`, `openSessions`, `openThemes`, `openModels`, `submitPrompt`, `clearPrompt`, `executeCommand`, `showToast`, `publish`, `selectSession`, `control.next`, `control.response` |
| `experimental` | `controlPlane.moveSession`, `console.get`, `console.listOrgs`, `console.switchOrg`, `session.list`, `session.background`, `resource.list`, `projectCopy.generateName`, `workspace.*` |

## Native `client.v2` API Groups

| Group | Methods |
| --- | --- |
| `health` | `get` |
| `location` | `get` |
| `agent` | `list` |
| `session` | `list`, `create`, `get`, `prompt`, `compact`, `wait`, `context`, `messages`, `permission.list`, `permission.reply`, `question.list`, `question.reply`, `question.reject` |
| `model` | `list` |
| `provider` | `list`, `get` |
| `integration` | `list`, `get`, `connect.key`, `connect.oauth`, `attempt.status`, `attempt.complete`, `attempt.cancel` |
| `credential` | `update`, `remove` |
| `permission` | `request.list`, `saved.list`, `saved.remove` |
| `fs` | `read`, `list`, `find` |
| `command` | `list` |
| `skill` | `list` |
| `event` | `subscribe` |
| `pty` | `list`, `create`, `get`, `update`, `remove`, `connectToken`, `connect` |
| `question` | `request.list` |
| `reference` | `list` |
| `projectCopy` | `create`, `refresh`, `remove` |

## Session Examples

```typescript
const session = await client.session.create({ title: "My session", agent: "build" })

await client.session.prompt({
  sessionID: session.id,
  parts: [{ type: "text", text: "Hello" }],
})

await client.session.promptAsync({
  sessionID: session.id,
  parts: [{ type: "text", text: "Run this in the background" }],
})

const messages = await client.session.messages({ sessionID: session.id, limit: 50 })
```

Native v2 session example:

```typescript
const session = await client.v2.session.create({ location: { directory: process.cwd() } })

await client.v2.session.prompt({
  sessionID: session.data.id,
  prompt: { text: "Implement the fix" },
  delivery: "queue",
  resume: true,
})

await client.v2.session.wait({ sessionID: session.data.id })
```

## Permission Examples

```typescript
await client.permission.reply({
  requestID,
  reply: "once",
})

await client.v2.session.permission.reply({
  sessionID,
  requestID,
  reply: "once",
})
```

Valid permission replies are `"once"`, `"always"`, and `"reject"`.

## Legacy Root Client

The root export remains useful for existing integrations and the bundled `export-sessions.mjs` helper.

```typescript
import { createOpencodeClient } from "@opencode-ai/sdk"

const legacy = createOpencodeClient({
  baseUrl: "http://localhost:4096",
  throwOnError: true,
  responseStyle: "data",
})

const session = await legacy.session.create({ body: { title: "Legacy" } })

await legacy.session.prompt({
  path: { id: session.id },
  body: { parts: [{ type: "text", text: "Hello" }] },
})
```
