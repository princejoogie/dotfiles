# OpenCode SDK Events Reference

Current event guidance for `@opencode-ai/sdk@1.17.7`.

## Subscribe

```typescript
const events = await client.event.subscribe()

for await (const event of events.stream) {
  console.log(event.type, event.properties)
}
```

Use `client.event.subscribe()` for top-level event streams. Use `client.v2.event.subscribe({ location })` when working specifically with native `/api` location-scoped event streams.

## Common Event Families

| Family | Event types |
| --- | --- |
| Server/global | `server.connected`, `server.instance.disposed`, `global.disposed` |
| Installation | `installation.updated`, `installation.update-available` |
| Catalog/plugins | `models-dev.refreshed`, `plugin.added`, `integration.updated`, `catalog.updated` |
| Session lifecycle | `session.created`, `session.updated`, `session.deleted`, `session.status`, `session.idle`, `session.compacted`, `session.diff`, `session.error` |
| Message lifecycle | `message.updated`, `message.removed`, `message.part.updated`, `message.part.removed`, `message.part.delta` |
| Agent loop progress | `session.next.*` events for prompt, step, text, reasoning, tool, shell, retry, and compaction progress |
| Permissions | `permission.asked`, `permission.replied`, `permission.v2.asked`, `permission.v2.replied` |
| Questions | `question.asked`, `question.replied`, `question.rejected`, `question.v2.asked`, `question.v2.replied`, `question.v2.rejected` |
| Files/VCS | `file.edited`, `file.watcher.updated`, `vcs.branch.updated` |
| PTY | `pty.created`, `pty.updated`, `pty.exited`, `pty.deleted` |
| Project/workspace | `project.updated`, `project.directories.updated`, `workspace.ready`, `workspace.failed`, `workspace.status`, `worktree.ready`, `worktree.failed` |
| Other | `todo.updated`, `lsp.updated`, `mcp.tools.changed`, `mcp.browser.open.failed`, `command.executed`, `reference.updated` |

Legacy root `@opencode-ai/sdk` events still include `permission.updated`; v2 direct clients emit the newer `permission.asked`/`permission.v2.asked` families.

## Wait For Completion

Use events when you need progress details:

```typescript
async function waitForIdle(client: OpencodeClient, sessionID: string) {
  const events = await client.event.subscribe()

  for await (const event of events.stream) {
    if (event.type === "session.idle" && event.properties.sessionID === sessionID) {
      return
    }
  }
}
```

For native v2 session prompts, use the built-in wait endpoint when progress details are unnecessary:

```typescript
await client.v2.session.wait({ sessionID })
```

## Stream Text Deltas

Native loop progress uses `session.next.text.*` events.

```typescript
async function streamText(client: OpencodeClient, sessionID: string) {
  const events = await client.event.subscribe()

  for await (const event of events.stream) {
    if (event.type === "session.next.text.delta" && event.properties.sessionID === sessionID) {
      process.stdout.write(event.properties.delta)
    }

    if (event.type === "session.idle" && event.properties.sessionID === sessionID) {
      break
    }
  }
}
```

Legacy message part streaming still uses `message.part.updated` and `message.part.delta`.

## Handle Permissions

Top-level v2 permission event:

```typescript
for await (const event of events.stream) {
  if (event.type !== "permission.asked") continue

  const request = event.properties
  const allowed = request.permission === "read"

  await client.permission.reply({
    requestID: request.id,
    reply: allowed ? "once" : "reject",
  })
}
```

Native v2 session-owned permission event:

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

Valid replies are `"once"`, `"always"`, and `"reject"`.

## Handle Questions

```typescript
for await (const event of events.stream) {
  if (event.type !== "question.asked") continue

  await client.question.reply({
    requestID: event.properties.id,
    answers: [["Proceed"]],
  })
}
```

For `question.v2.asked`, use `client.v2.session.question.reply({ sessionID, requestID, questionV2Reply: { answers } })` or `client.v2.session.question.reject()` with the event `sessionID` and request ID.

## Track Tools

```typescript
for await (const event of events.stream) {
  if (event.type === "session.next.tool.called") {
    console.log("tool called", event.properties.tool, event.properties.input)
  }

  if (event.type === "session.next.tool.success") {
    console.log("tool success", event.properties.callID, event.properties.result)
  }

  if (event.type === "session.next.tool.failed") {
    console.log("tool failed", event.properties.callID, event.properties.error)
  }
}
```
