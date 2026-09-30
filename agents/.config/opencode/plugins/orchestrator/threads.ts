import type { Plugin } from "@opencode/plugin/effect"
import { Agent } from "@opencode/schema/agent"
import { Model } from "@opencode/schema/model"
import { Provider } from "@opencode/schema/provider"
import { Session } from "@opencode/schema/session"
import { SessionMessage } from "@opencode/schema/session-message"
import { Tool } from "@opencode/schema/tool"
import { Effect, Option, Schema } from "effect"
import { ModelInput } from "./rpc.js"

const Thread = Schema.Struct({
  id: Schema.String,
  projectID: Schema.String,
  creatorSessionID: Schema.String,
  ownerDirectory: Schema.optional(Schema.String),
  status: Schema.Literals(["starting", "ready", "unknown"]),
  title: Schema.optional(Schema.String),
  directory: Schema.optional(Schema.String),
  promptID: Schema.String,
  error: Schema.optional(Schema.String),
  createdAt: Schema.Number,
})
type ThreadRecord = typeof Thread.Type

const Launch = Schema.Struct({
  title: Schema.optional(Schema.String),
  prompt: Schema.optional(Schema.String),
  agent: Schema.optional(Schema.String),
  model: Schema.optional(ModelInput),
  workspace: Schema.optional(Schema.Literals(["parent", "new_worktree"])),
})

export function registerThreadTools(ctx: Plugin.Context) {
  const key = (id: string) => `threads/${id}`
  const tool = <A, E, R>(effect: Effect.Effect<A, E, R>) => effect.pipe(
    Effect.catchCause((cause) => Effect.fail(new Tool.Error({ message: String(cause) }))),
  )

  function read(id: string) {
    return Effect.gen(function* () {
      const value = yield* ctx.storage.get(key(id))
      if (!value) throw new Error(`Thread ${id} not found in plugin inventory`)
      return yield* Schema.decodeUnknownEffect(Thread)(value)
    })
  }

  function authorized(id: string, caller: string, mutate = false) {
    return Effect.gen(function* () {
      const thread = yield* read(id)
      const parent = yield* ctx.session.get({ sessionID: Session.ID.make(caller) })
      if (thread.projectID !== parent.projectID) throw new Error("Thread belongs to another project")
      if (mutate && thread.creatorSessionID !== caller) throw new Error("Only the creator can change this thread")
      return thread
    })
  }

  function launch(input: typeof Launch.Type, caller: string) {
    return Effect.gen(function* () {
      const parent = yield* ctx.session.get({ sessionID: Session.ID.make(caller) })
      const id = Session.ID.create()
      const promptID = SessionMessage.ID.create()
      const record: ThreadRecord = {
        id, promptID, projectID: parent.projectID, creatorSessionID: parent.id,
        ownerDirectory: parent.location.directory,
        status: "starting", title: input.title, createdAt: Date.now(),
      }
      yield* ctx.storage.set(key(id), record)
      return yield* Effect.gen(function* () {
        let directory = parent.location.directory
        if (input.workspace === "new_worktree") {
          const worktree = yield* ctx.worktree.create({
            projectID: parent.projectID, from: directory, name: `orchestrator-${id.slice(-12)}`,
          })
          directory = worktree.directory
          yield* ctx.storage.set(key(id), { ...record, directory })
        }
        yield* ctx.session.create({
          id, title: input.title, location: { directory },
          ...(parent.permissions ? { permissions: parent.permissions } : {}),
          ...(input.agent ? { agent: Agent.ID.make(input.agent) } : {}),
          ...(input.model ? { model: { providerID: Provider.ID.make(input.model.providerID),
            id: Model.ID.make(input.model.id),
            ...(input.model.variant ? { variant: Model.VariantID.make(input.model.variant) } : {}) } } : {}),
        })
        if (input.prompt) yield* ctx.session.prompt({ sessionID: id, id: promptID, text: input.prompt })
        const ready: ThreadRecord = { ...record, status: "ready", directory }
        yield* ctx.storage.set(key(id), ready)
        return ready
      }).pipe(Effect.catchCause((cause) => Effect.gen(function* () {
        const unknown: ThreadRecord = { ...record, status: "unknown", error: String(cause) }
        yield* ctx.storage.set(key(id), unknown)
        return unknown
      })))
    })
  }

  return ctx.tool.transform((editor) => {
    editor.namespace({ name: "orchestrator", description: "Delegate and manage OpenCode sessions." })
    editor.add({
      name: "thread_launch", description: "Create an independent OpenCode session, with an optional first prompt or new worktree.",
      input: Launch, options: { namespace: "orchestrator" },
      execute: (input, context) => tool(launch(input, context.sessionID).pipe(
        Effect.map((thread) => ({ content: JSON.stringify(thread) })),
      )),
    })
    editor.add({
      name: "thread_create_many", description: "Create 1 to 20 independent sessions. A failed entry does not undo earlier entries.",
      input: Schema.Struct({ threads: Schema.Array(Launch) }), options: { namespace: "orchestrator" },
      execute: ({ threads }, context) => tool(Effect.gen(function* () {
        if (threads.length < 1 || threads.length > 20) throw new Error("Expected 1 to 20 threads")
        const created = yield* Effect.forEach(threads, (entry) => launch(entry, context.sessionID))
        return { content: JSON.stringify({ threads: created }) }
      })),
    })
    editor.add({
      name: "thread_list", description: "List sessions launched by this plugin in the current project. Not a list of all OpenCode sessions.",
      input: Schema.Struct({}), options: { namespace: "orchestrator" },
      execute: (_, context) => tool(Effect.gen(function* () {
        const parent = yield* ctx.session.get({ sessionID: Session.ID.make(context.sessionID) })
        const threads: ThreadRecord[] = []
        let after: string | undefined
        do {
          const page = yield* ctx.storage.scan({ prefix: "threads/", after, limit: 100 })
          for (const entry of page.entries) {
            const item = yield* Schema.decodeUnknownEffect(Thread)(entry.value)
            if (item.projectID === parent.projectID) threads.push(item)
          }
          after = page.next
        } while (after)
        return { content: JSON.stringify({ threads: threads.sort((a, b) => b.createdAt - a.createdAt) }) }
      })),
    })
    editor.add({
      name: "thread_read", description: "Read a bounded page of user, assistant, and synthetic messages from a plugin-launched session.",
      input: Schema.Struct({ sessionID: Schema.String, afterIndex: Schema.optional(Schema.Number), limit: Schema.optional(Schema.Number) }),
      options: { namespace: "orchestrator" },
      execute: ({ sessionID, afterIndex = 0, limit = 20 }, context) => tool(Effect.gen(function* () {
        yield* authorized(sessionID, context.sessionID)
        if (!Number.isSafeInteger(afterIndex) || afterIndex < 0 || !Number.isSafeInteger(limit) || limit < 1 || limit > 50)
          throw new Error("afterIndex must be nonnegative and limit must be 1 to 50")
        const history = yield* ctx.session.context({ sessionID: Session.ID.make(sessionID) })
        const visible = history.flatMap((item) => {
          if (item.type === "user" || item.type === "synthetic") return [{ type: item.type, text: item.text.slice(0, 4_000) }]
          if (item.type === "assistant") return item.content.filter((part) => part.type === "text")
            .map((part) => ({ type: "assistant", text: part.text.slice(0, 4_000) }))
          return []
        })
        const page = visible.slice(afterIndex, afterIndex + limit)
        return { content: JSON.stringify({ messages: page, nextIndex: afterIndex + page.length,
          hasMore: afterIndex + page.length < visible.length }) }
      })),
    })
    editor.add({
      name: "thread_send", description: "Queue or steer a prompt into a plugin-launched session.",
      input: Schema.Struct({ sessionID: Schema.String, text: Schema.NonEmptyString,
        delivery: Schema.optional(Schema.Literals(["queue", "steer"])) }), options: { namespace: "orchestrator" },
      execute: ({ sessionID, text, delivery = "queue" }, context) => tool(Effect.gen(function* () {
        yield* authorized(sessionID, context.sessionID, true)
        const admitted = yield* ctx.session.prompt({ sessionID: Session.ID.make(sessionID), text, delivery })
        return { content: JSON.stringify({ sessionID, messageID: admitted.id, delivery }) }
      })),
    })
    editor.add({
      name: "thread_wait", description: "Wait for a plugin-launched session; timeout does not interrupt it.",
      input: Schema.Struct({ sessionID: Schema.String, timeoutMs: Schema.optional(Schema.Number) }), options: { namespace: "orchestrator" },
      execute: ({ sessionID, timeoutMs = 86_400_000 }, context) => tool(Effect.gen(function* () {
        yield* authorized(sessionID, context.sessionID)
        if (!Number.isFinite(timeoutMs) || timeoutMs < 0) throw new Error("timeoutMs must be nonnegative")
        const waited = yield* ctx.session.wait({ sessionID: Session.ID.make(sessionID) }).pipe(Effect.timeoutOption(timeoutMs))
        const current = yield* ctx.session.get({ sessionID: Session.ID.make(sessionID) })
        return { content: JSON.stringify({ sessionID, outcome: current.outcome ?? null,
          waitTimedOut: Option.isNone(waited) }) }
      })),
    })
    editor.add({
      name: "thread_interrupt", description: "Interrupt the active run in a plugin-launched session.",
      input: Schema.Struct({ sessionID: Schema.String }), options: { namespace: "orchestrator" },
      execute: ({ sessionID }, context) => tool(Effect.gen(function* () {
        yield* authorized(sessionID, context.sessionID, true)
        yield* ctx.session.interrupt({ sessionID: Session.ID.make(sessionID) })
        return { content: JSON.stringify({ sessionID, interruptRequested: true }) }
      })),
    })
    editor.add({
      name: "thread_rename", description: "Rename a plugin-launched session.",
      input: Schema.Struct({ sessionID: Schema.String, title: Schema.NonEmptyString }), options: { namespace: "orchestrator" },
      execute: ({ sessionID, title }, context) => tool(Effect.gen(function* () {
        const item = yield* authorized(sessionID, context.sessionID, true)
        yield* ctx.session.update({ sessionID: Session.ID.make(sessionID), title })
        const updated = { ...item, title }
        yield* ctx.storage.set(key(sessionID), updated)
        return { content: JSON.stringify(updated) }
      })),
    })
  })
}

export function reconcileThreads(ctx: Plugin.Context) {
  return Effect.gen(function* () {
    let after: string | undefined
    do {
      const page = yield* ctx.storage.scan({ prefix: "threads/", after, limit: 100 })
      for (const entry of page.entries) {
        const thread = yield* Schema.decodeUnknownEffect(Thread)(entry.value)
        if (thread.ownerDirectory !== ctx.location.directory || thread.status !== "starting") continue
        yield* ctx.storage.set(entry.key, { ...thread, status: "unknown",
          error: "Plugin restarted during thread launch; inspect the session before retrying." })
      }
      after = page.next
    } while (after)
  })
}
