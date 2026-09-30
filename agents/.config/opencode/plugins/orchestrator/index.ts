import { Plugin } from "@opencode/plugin/effect"
import { Agent } from "@opencode/schema/agent"
import { Model } from "@opencode/schema/model"
import { Provider } from "@opencode/schema/provider"
import { Session } from "@opencode/schema/session"
import { SessionMessage } from "@opencode/schema/session-message"
import { Tool } from "@opencode/schema/tool"
import { createHash, randomUUID } from "node:crypto"
import { Effect, Option, Schedule, Schema, Semaphore } from "effect"
import { LaunchInput, OrchestratorRpc, Task as TaskSchema } from "./rpc.js"
import type { LaunchRequest, TaskRecord } from "./rpc.js"
import { reconcileThreads, registerThreadTools } from "./threads.js"

const key = (id: string) => `tasks/${id}`
const terminal = (status: TaskRecord["status"]) => ["completed", "failed", "cancelled"].includes(status)
const message = (error: unknown) => error instanceof Error ? error.message : String(error)
const digest = (value: string) => createHash("sha256").update(value).digest("hex")

function latestText(messages: readonly SessionMessage.Info[]) {
  const assistant = messages.filter((item): item is SessionMessage.Assistant => item.type === "assistant")
  return assistant.flatMap((item) => item.content.filter((part) => part.type === "text").map((part) => part.text))
    .filter(Boolean).at(-1)
}

export default Plugin.define({
  id: "orchestrator",
  effect: (ctx) => Effect.gen(function* () {
    const lock = yield* Semaphore.make(1)
    const synchronized = <A, E, R>(effect: Effect.Effect<A, E, R>) => lock.withPermits(1)(effect)
    let emit = (_task: TaskRecord): Effect.Effect<void, unknown> => Effect.void

    function read(id: string) {
      return Effect.gen(function* () {
        const value = yield* ctx.storage.get(key(id))
        if (!value) throw new Error(`Task ${id} not found`)
        return yield* Schema.decodeUnknownEffect(TaskSchema)(value)
      })
    }

    function scan(parentSessionID?: string) {
      return Effect.gen(function* () {
        const tasks: TaskRecord[] = []
        let after: string | undefined
        do {
          const page = yield* ctx.storage.scan({ prefix: "tasks/", after, limit: 100 })
          for (const entry of page.entries) {
            const task = yield* Schema.decodeUnknownEffect(TaskSchema)(entry.value)
            if (!parentSessionID || task.parentSessionID === parentSessionID) tasks.push(task)
          }
          after = page.next
        } while (after)
        return { tasks: tasks.sort((a, b) => a.createdAt - b.createdAt) }
      })
    }

    function update(id: string, change: (previous: TaskRecord) => TaskRecord) {
      return synchronized(Effect.gen(function* () {
        const previous = yield* read(id)
        const next = { ...change(previous), updatedAt: Date.now() }
        yield* ctx.storage.set(key(id), next)
        yield* emit(next).pipe(Effect.catchCause(() => Effect.void))
        return next
      }))
    }

    function notify(task: TaskRecord) {
      return Effect.gen(function* () {
        if (task.notified || !terminal(task.status)) return
        yield* ctx.session.synthetic({
          sessionID: Session.ID.make(task.parentSessionID),
          id: SessionMessage.ID.make(`msg_orchestrator_${task.id}`),
          text: `Orchestrator task ${task.id} (${task.status}). Child session: ${task.childSessionID}. ${task.result ?? task.error ?? ""}`,
          delivery: "queue",
          resume: false,
        })
        yield* update(task.id, (previous) => ({ ...previous, notified: true }))
      }).pipe(Effect.catchCause((cause) => Effect.logWarning("Orchestrator notification failed", { taskID: task.id, error: String(cause) })))
    }

    function launch(input: LaunchRequest) {
      return Effect.gen(function* () {
        const parent = yield* ctx.session.get({ sessionID: Session.ID.make(input.parentSessionID) })
        const id = input.requestID ? digest(`${parent.id}\u0000${input.requestID}`).slice(0, 32) : randomUUID()
        const existing = yield* synchronized(ctx.storage.get(key(id)))
        if (existing) {
          const task = yield* Schema.decodeUnknownEffect(TaskSchema)(existing)
          if (task.task !== input.task || task.agent !== input.agent || task.requestedWorktree !== !!input.worktree
            || JSON.stringify(task.model) !== JSON.stringify(input.model))
            throw new Error("Request ID was already used for a different task")
          return task
        }
        const record: TaskRecord = {
          id,
          parentSessionID: parent.id,
          ownerDirectory: parent.location.directory,
          childSessionID: Session.ID.create(),
          promptID: SessionMessage.ID.create(),
          task: input.task,
          status: "pending",
          agent: input.agent,
          model: input.model,
          requestedWorktree: !!input.worktree,
          createdAt: Date.now(),
          updatedAt: Date.now(),
        }
        yield* synchronized(Effect.gen(function* () {
          const prior = yield* ctx.storage.get(key(id))
          if (prior) throw new Error("Concurrent launch with the same request ID; retry to read its state")
          yield* ctx.storage.set(key(id), record)
        }))
        return yield* Effect.gen(function* () {
          let current = yield* update(id, (task) => ({ ...task, status: "starting" }))
          let directory = parent.location.directory
          if (input.worktree) {
            const created = yield* ctx.worktree.create({
              projectID: parent.projectID,
              from: parent.location.directory,
              name: `orchestrator-${id.slice(0, 8)}`,
            })
            current = yield* update(id, (task) => ({ ...task, worktree: created.directory }))
            directory = created.directory
          }
          yield* ctx.session.create({
            id: Session.ID.make(current.childSessionID),
            title: `Task: ${input.task.slice(0, 72)}`,
            location: { directory },
            ...(parent.permissions ? { permissions: parent.permissions } : {}),
            ...(input.agent ? { agent: Agent.ID.make(input.agent) } : {}),
            ...(input.model ? { model: {
              providerID: Provider.ID.make(input.model.providerID),
              id: Model.ID.make(input.model.id),
              ...(input.model.variant ? { variant: Model.VariantID.make(input.model.variant) } : {}),
            } } : {}),
          })
          yield* ctx.session.prompt({
            sessionID: Session.ID.make(current.childSessionID),
            id: SessionMessage.ID.make(current.promptID),
            text: `You are working on orchestrator task ${id}. Work only on the request below. When finished, call orchestrator_complete with the task ID and a concise result, including changes, checks, and remaining problems.\n\n${input.task}`,
          })
          return yield* update(id, (task) => task.status === "starting" ? { ...task, status: "running" } : task)
        }).pipe(Effect.catchCause((cause) => {
          // A remote operation may have committed before its response was lost.
          return update(id, (task) => terminal(task.status) ? task
            : { ...task, status: "unknown", error: String(cause) })
        }))
      })
    }

    function send(id: string, text: string, requestID?: string) {
      return Effect.gen(function* () {
        const task = yield* read(id)
        if (terminal(task.status) || task.status === "unknown") throw new Error("Task is not running; inspect it before retrying")
        yield* ctx.session.prompt({
          sessionID: Session.ID.make(task.childSessionID), text, delivery: "queue",
          ...(requestID ? { id: SessionMessage.ID.make(`msg_orchestrator_${digest(`${id}\u0000${requestID}`)}`) } : {}),
        })
        return yield* update(id, (previous) => ({ ...previous, status: "running" }))
      })
    }

    function cancel(id: string) {
      return Effect.gen(function* () {
        const task = yield* read(id)
        if (terminal(task.status)) return task
        if (task.status === "starting") throw new Error("Launch is ambiguous; inspect the child session before cancelling")
        if (task.status !== "pending") {
          yield* ctx.session.interrupt({ sessionID: Session.ID.make(task.childSessionID) })
        }
        const next = yield* update(id, (previous) => ({ ...previous, status: "cancelled" }))
        yield* notify(next)
        return next
      })
    }

    function complete(id: string, childSessionID: string, result: string) {
      return Effect.gen(function* () {
        const task = yield* read(id)
        if (task.childSessionID !== childSessionID) throw new Error("Only this task's child session can complete it")
        if (terminal(task.status)) return task
        if (task.status !== "running" && task.status !== "starting") throw new Error("Task is not running")
        const children = (yield* scan(childSessionID)).tasks
        const pending = children.some((child) => !terminal(child.status))
        const next = yield* update(id, (previous) => ({ ...previous, status: pending ? "running" : "completed", result }))
        if (!pending) yield* notify(next)
        return next
      })
    }

    function refresh(id: string) {
      return Effect.gen(function* () {
        const task = yield* read(id)
        if (task.status !== "running") return task
        const children = (yield* scan(task.childSessionID)).tasks
        if (children.some((child) => !terminal(child.status))) return task
        const child = yield* ctx.session.get({ sessionID: Session.ID.make(task.childSessionID) })
        if (!child.time.idle) return task
        if (child.outcome === "succeeded") {
          const history = yield* ctx.session.context({ sessionID: child.id })
          const result = task.result ?? latestText(history) ?? `Child session ${child.id} finished without a written result.`
          const next = yield* update(id, (previous) => previous.status === "running"
            ? { ...previous, status: "completed", result } : previous)
          yield* notify(next)
          return next
        }
        if (child.outcome === "failed" || child.outcome === "interrupted") {
          const next = yield* update(id, (previous) => previous.status === "running"
            ? { ...previous, status: "failed", error: `Child session ${child.outcome}` } : previous)
          yield* notify(next)
          return next
        }
        return task
      })
    }

    const tool = <A, E, R>(effect: Effect.Effect<A, E, R>) => effect.pipe(
      Effect.catchCause((cause) => Effect.fail(new Tool.Error({ message: String(cause) }))),
    )

    const rpc = yield* ctx.rpc.register(OrchestratorRpc, {
      snapshot: ({ parentSessionID }) => scan(parentSessionID).pipe(Effect.orDie),
      launch: (input) => launch(input).pipe(Effect.orDie),
      send: ({ taskID, text, requestID }) => send(taskID, text, requestID).pipe(Effect.orDie),
      cancel: ({ taskID }) => cancel(taskID).pipe(Effect.orDie),
    }).pipe(Effect.orDie)
    emit = (task) => rpc.events.emit("updated", { task })

    yield* ctx.tool.transform((editor) => {
      editor.namespace({ name: "orchestrator", description: "Delegate work to isolated OpenCode sessions and inspect their results." })
      editor.add({
        name: "capabilities", description: "List available OpenCode agents and models for delegated tasks.",
        input: Schema.Struct({}), options: { namespace: "orchestrator" },
        execute: () => tool(Effect.gen(function* () {
          const agents = yield* ctx.agent.list()
          const models = yield* ctx.model.list()
          return { content: JSON.stringify({
            agents: agents.data.map((agent) => ({ id: agent.id, description: agent.description })),
            models: models.data.map((model) => ({ providerID: model.providerID, id: model.id })),
            features: { delegation: true, cancellation: true, worktrees: true, boundedWait: true },
          }) }
        })),
      })
      editor.add({
        name: "delegate", description: "Start a child task. Set worktree for filesystem isolation. Returns a task ID.",
        input: LaunchInput, options: { namespace: "orchestrator" },
        execute: (input, context) => tool(launch({ ...input, parentSessionID: context.sessionID }).pipe(
          Effect.map((task) => ({ content: JSON.stringify(task) })),
        )),
      })
      editor.add({
        name: "send", description: "Queue a follow-up instruction for a running child task.",
        input: Schema.Struct({ taskID: Schema.String, text: Schema.NonEmptyString, requestID: Schema.optional(Schema.String) }), options: { namespace: "orchestrator" },
        execute: ({ taskID, text, requestID }, context) => tool(Effect.gen(function* () {
          const task = yield* read(taskID)
          if (task.parentSessionID !== context.sessionID) throw new Error("Only the parent can send to this task")
          return { content: JSON.stringify(yield* send(taskID, text, requestID)) }
        })),
      })
      editor.add({
        name: "wait", description: "Wait for a child task to finish and return its result.",
        input: Schema.Struct({ taskID: Schema.String, timeoutMs: Schema.optional(Schema.Number) }), options: { namespace: "orchestrator" },
        execute: ({ taskID, timeoutMs }, context) => tool(Effect.gen(function* () {
          const task = yield* read(taskID)
          if (task.parentSessionID !== context.sessionID) throw new Error("Only the parent can wait for this task")
          if (timeoutMs !== undefined && (!Number.isFinite(timeoutMs) || timeoutMs < 0))
            throw new Error("timeoutMs must be a nonnegative finite number")
          const waited = task.status === "running"
            ? yield* ctx.session.wait({ sessionID: Session.ID.make(task.childSessionID) }).pipe(Effect.timeoutOption(timeoutMs ?? 86_400_000))
            : Option.some(undefined)
          if (Option.isNone(waited)) return { content: JSON.stringify({ ...yield* read(taskID), waitTimedOut: true }) }
          return { content: JSON.stringify({ ...yield* refresh(taskID), waitTimedOut: false }) }
        })),
      })
      editor.add({
        name: "status", description: "Read a task or list tasks for the current parent session.",
        input: Schema.Struct({ taskID: Schema.optional(Schema.String) }), options: { namespace: "orchestrator" },
        execute: ({ taskID }, context) => tool(Effect.gen(function* () {
          if (taskID) {
            const task = yield* read(taskID)
            if (task.parentSessionID !== context.sessionID && task.childSessionID !== context.sessionID)
              throw new Error("Task does not belong to this session")
            return { content: JSON.stringify(task) }
          }
          return { content: JSON.stringify(yield* scan(context.sessionID)) }
        })),
      })
      editor.add({
        name: "inspect", description: "Inspect the child session of a task, including ambiguous tasks after a restart.",
        input: Schema.Struct({ taskID: Schema.String }), options: { namespace: "orchestrator" },
        execute: ({ taskID }, context) => tool(Effect.gen(function* () {
          const task = yield* read(taskID)
          if (task.parentSessionID !== context.sessionID) throw new Error("Only the parent can inspect this task")
          const session = yield* ctx.session.get({ sessionID: Session.ID.make(task.childSessionID) })
          const history = yield* ctx.session.context({ sessionID: session.id })
          return { content: JSON.stringify({ task, outcome: session.outcome ?? null,
            idle: !!session.time.idle, lastAssistantText: latestText(history) ?? null,
            messageCount: history.length }) }
        })),
      })
      editor.add({
        name: "cancel", description: "Interrupt a child task and mark it cancelled.",
        input: Schema.Struct({ taskID: Schema.String }), options: { namespace: "orchestrator" },
        execute: ({ taskID }, context) => tool(Effect.gen(function* () {
          const task = yield* read(taskID)
          if (task.parentSessionID !== context.sessionID) throw new Error("Only the parent can cancel this task")
          return { content: JSON.stringify(yield* cancel(taskID)) }
        })),
      })
      editor.add({
        name: "retry", description: "Start a new task after inspecting a failed, cancelled, or unknown child. Does not replay the old task.",
        input: Schema.Struct({ taskID: Schema.String }), options: { namespace: "orchestrator" },
        execute: ({ taskID }, context) => tool(Effect.gen(function* () {
          const prior = yield* read(taskID)
          if (prior.parentSessionID !== context.sessionID) throw new Error("Only the parent can retry this task")
          if (prior.status !== "failed" && prior.status !== "cancelled" && prior.status !== "unknown")
            throw new Error("Only a terminal or unknown task can be retried")
          const next = yield* launch({ parentSessionID: context.sessionID, task: prior.task, agent: prior.agent,
            model: prior.model, worktree: prior.requestedWorktree })
          return { content: JSON.stringify(yield* update(next.id, (task) => ({ ...task, retryOf: prior.id }))) }
        })),
      })
      editor.add({
        name: "merge_back", description: "Queue a completed child task's result as an explicit context handoff to its parent session.",
        input: Schema.Struct({ taskID: Schema.String, requestID: Schema.optional(Schema.String) }),
        options: { namespace: "orchestrator" },
        execute: ({ taskID, requestID }, context) => tool(Effect.gen(function* () {
          const task = yield* read(taskID)
          if (task.parentSessionID !== context.sessionID) throw new Error("Only the parent can merge this task")
          if (task.status !== "completed" || !task.result) throw new Error("Task has no completed result")
          const id = requestID ? digest(`${taskID}\u0000${requestID}`) : randomUUID()
          const handoff = { id, sourceTaskID: taskID, sourceSessionID: task.childSessionID,
            targetSessionID: task.parentSessionID, text: task.result, createdAt: Date.now() }
          const existing = yield* ctx.storage.get(`handoffs/${id}`)
          if (!existing) yield* ctx.storage.set(`handoffs/${id}`, handoff)
          yield* ctx.session.prompt({
            sessionID: Session.ID.make(task.parentSessionID),
            id: SessionMessage.ID.make(`msg_handoff_${id}`),
            text: `Context handoff from completed task ${taskID} (child ${task.childSessionID}):\n\n${task.result}`,
            delivery: "queue",
          })
          return { content: JSON.stringify(existing ?? handoff) }
        })),
      })
      editor.add({
        name: "complete", description: "Finish your assigned child task with a concise result.",
        input: Schema.Struct({ taskID: Schema.String, result: Schema.NonEmptyString }), options: { namespace: "orchestrator" },
        execute: ({ taskID, result }, context) => tool(complete(taskID, context.sessionID, result).pipe(
          Effect.map((task) => ({ content: JSON.stringify(task) })),
        )),
      })
    })
    yield* registerThreadTools(ctx)
    yield* reconcileThreads(ctx).pipe(Effect.orDie)

    // Live monitoring is best effort. Reload does not replay an ambiguous model call.
    const existing = yield* scan().pipe(Effect.orDie)
    yield* Effect.forEach(existing.tasks.filter((task) => task.ownerDirectory === ctx.location.directory), (task) => task.status === "running" || task.status === "starting"
      ? update(task.id, (previous) => ({ ...previous, status: "unknown", error: "Plugin restarted during task execution; inspect the child session." }))
      : terminal(task.status) && !task.notified ? notify(task) : Effect.void,
    { discard: true }).pipe(Effect.orDie)

    yield* Effect.repeat(
      scan().pipe(Effect.flatMap(({ tasks }) => Effect.forEach(tasks.filter((task) => task.ownerDirectory === ctx.location.directory
        && (task.status === "running" || terminal(task.status) && !task.notified)),
        (task) => Effect.gen(function* () {
          if (task.status === "running") yield* refresh(task.id)
          else yield* notify(task)
        }).pipe(Effect.catchCause((cause) => Effect.logWarning("Task check failed", { taskID: task.id, error: String(cause) }))),
        { discard: true },
      ))),
      { schedule: Schedule.spaced("5 seconds") },
    ).pipe(Effect.forkScoped)
  }).pipe(Effect.orDie),
})
