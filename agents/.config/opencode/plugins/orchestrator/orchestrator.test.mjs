import { test, expect } from "bun:test"
import { Effect } from "effect"
import plugin from "./index.ts"

function harness(seed = []) {
  const records = new Map(seed.map((task) => [`tasks/${task.id}`, task]))
  const sessions = new Map([["ses_parent", {
    id: "ses_parent", projectID: "project_test", location: { directory: "/project" }, time: {},
  }]])
  const tools = new Map()
  const prompts = []
  const notices = []
  const events = []
  const ctx = {
    location: { directory: "/project", project: { id: "project_test" } },
    storage: {
      get: (key) => Effect.succeed(records.get(key)),
      set: (key, value) => Effect.sync(() => { records.set(key, value) }),
      scan: ({ prefix }) => Effect.succeed({ entries: [...records].filter(([key]) => key.startsWith(prefix)).map(([key, value]) => ({ key, value })) }),
    },
    rpc: {
      register: (_definition, handlers) => Effect.succeed({
        handlers, events: { emit: (_event, data) => Effect.sync(() => { events.push(data) }) },
      }),
    },
    tool: {
      transform: (callback) => Effect.sync(() => callback({
        namespace() {},
        add(tool) { tools.set(`orchestrator_${tool.name}`, tool) },
      })),
    },
    session: {
      get: ({ sessionID }) => sessions.has(sessionID)
        ? Effect.succeed(sessions.get(sessionID)) : Effect.fail(new Error("missing session")),
      create: (input) => Effect.sync(() => {
        const session = { ...input, projectID: "project_test", location: input.location, time: {} }
        sessions.set(input.id, session)
        return session
      }),
      prompt: (input) => Effect.sync(() => { prompts.push(input); return { id: input.id ?? "msg_followup" } }),
      synthetic: (input) => Effect.sync(() => { notices.push(input); return { id: input.id } }),
      wait: () => Effect.void,
      context: () => Effect.succeed([]),
      interrupt: () => Effect.void,
      update: ({ sessionID, title }) => Effect.sync(() => { sessions.get(sessionID).title = title }),
    },
    worktree: {
      create: () => Effect.succeed({ directory: "/project-worktree" }),
    },
    agent: { list: () => Effect.succeed({ data: [{ id: "build", description: "Builds things" }] }) },
    model: { list: () => Effect.succeed({ data: [{ providerID: "openai", id: "test-model" }] }) },
  }
  const invoke = (name, input, sessionID = "ses_parent") => tools.get(`orchestrator_${name}`).execute(input, { sessionID })
  return { ctx, records, sessions, tools, prompts, notices, events, invoke }
}

test("delegates to a new session and accepts completion only from its child", async () => {
  const h = harness()
  await Effect.runPromise(Effect.scoped(Effect.gen(function* () {
    yield* plugin.effect(h.ctx)
    const launched = JSON.parse((yield* h.invoke("delegate", { task: "Investigate the issue", parentSessionID: "forged", worktree: true })).content)
    expect(launched.status).toBe("running")
    expect(launched.parentSessionID).toBe("ses_parent")
    expect(launched.worktree).toBe("/project-worktree")
    expect(h.prompts[0].id).toBe(launched.promptID)
    expect(h.sessions.get(launched.childSessionID).location.directory).toBe("/project-worktree")
    const rejected = yield* Effect.exit(h.invoke("complete", { taskID: launched.id, result: "wrong" }, "ses_parent"))
    expect(rejected._tag).toBe("Failure")
    const completed = JSON.parse((yield* h.invoke("complete", { taskID: launched.id, result: "Fixed and tested" }, launched.childSessionID)).content)
    expect(completed.status).toBe("completed")
    expect(completed.result).toBe("Fixed and tested")
    expect(h.notices).toHaveLength(1)
    expect(h.notices[0].id).toStartWith("msg_orchestrator_")
    expect(h.notices[0].resume).toBe(false)
  })))
})

test("parent permission checks and child completion barrier", async () => {
  const h = harness()
  await Effect.runPromise(Effect.scoped(Effect.gen(function* () {
    yield* plugin.effect(h.ctx)
    const parent = JSON.parse((yield* h.invoke("delegate", { task: "Main task", parentSessionID: "ses_parent" })).content)
    const child = JSON.parse((yield* h.invoke("delegate", { task: "Nested task", parentSessionID: "ses_parent" }, parent.childSessionID)).content)
    expect(child.parentSessionID).toBe(parent.childSessionID)
    const denied = yield* Effect.exit(h.invoke("send", { taskID: parent.id, text: "wrong parent" }, child.childSessionID))
    expect(denied._tag).toBe("Failure")
    const pending = JSON.parse((yield* h.invoke("complete", { taskID: parent.id, result: "Main done" }, parent.childSessionID)).content)
    expect(pending.status).toBe("running")
    expect(h.notices).toHaveLength(0)
    yield* h.invoke("complete", { taskID: child.id, result: "Nested done" }, child.childSessionID)
    h.sessions.get(parent.childSessionID).time.idle = new Date()
    h.sessions.get(parent.childSessionID).outcome = "succeeded"
    const final = JSON.parse((yield* h.invoke("wait", { taskID: parent.id })).content)
    expect(final.status).toBe("completed")
    expect(final.result).toBe("Main done")
    expect(h.notices).toHaveLength(2)
  })))
})

test("startup leaves uncertain tasks unknown rather than replaying prompts", async () => {
  const h = harness([{
    id: "old", parentSessionID: "ses_parent", ownerDirectory: "/project", childSessionID: "ses_child", promptID: "msg_old",
    task: "Do work", status: "running", createdAt: 1, updatedAt: 1,
  }])
  await Effect.runPromise(Effect.scoped(plugin.effect(h.ctx)))
  expect(h.records.get("tasks/old").status).toBe("unknown")
  expect(h.prompts).toHaveLength(0)
})

test("stable launch and follow-up IDs do not create duplicate work", async () => {
  const h = harness()
  await Effect.runPromise(Effect.scoped(Effect.gen(function* () {
    yield* plugin.effect(h.ctx)
    const input = { task: "Check logs", parentSessionID: "ses_parent", requestID: "request-1" }
    const first = JSON.parse((yield* h.invoke("delegate", input)).content)
    const again = JSON.parse((yield* h.invoke("delegate", input)).content)
    expect(first.id).toBe(again.id)
    expect(h.prompts).toHaveLength(1)
    yield* h.invoke("send", { taskID: first.id, text: "Also check tests", requestID: "follow-up-1" })
    expect(h.prompts[1].id).toStartWith("msg_orchestrator_")
    const conflict = yield* Effect.exit(h.invoke("delegate", { ...input, task: "Different" }))
    expect(conflict._tag).toBe("Failure")
  })))
})

test("launch errors remain visible and explicit retry creates a new child", async () => {
  const h = harness()
  const original = h.ctx.session.create
  let first = true
  h.ctx.session.create = (input) => first
    ? (first = false, Effect.fail(new Error("connection lost"))) : original(input)
  await Effect.runPromise(Effect.scoped(Effect.gen(function* () {
    yield* plugin.effect(h.ctx)
    const failed = JSON.parse((yield* h.invoke("delegate", { task: "Try again", parentSessionID: "ses_parent" })).content)
    expect(failed.status).toBe("unknown")
    expect(h.prompts).toHaveLength(0)
    const retried = JSON.parse((yield* h.invoke("retry", { taskID: failed.id })).content)
    expect(retried.status).toBe("running")
    expect(retried.retryOf).toBe(failed.id)
    expect(retried.childSessionID).not.toBe(failed.childSessionID)
  })))
})

test("capabilities and bounded wait leave the child running", async () => {
  const h = harness()
  h.ctx.session.wait = () => Effect.never
  await Effect.runPromise(Effect.scoped(Effect.gen(function* () {
    yield* plugin.effect(h.ctx)
    const capabilities = JSON.parse((yield* h.invoke("capabilities", {})).content)
    expect(capabilities.agents[0].id).toBe("build")
    const task = JSON.parse((yield* h.invoke("delegate", { task: "Slow task", parentSessionID: "ses_parent" })).content)
    const timed = JSON.parse((yield* h.invoke("wait", { taskID: task.id, timeoutMs: 1 })).content)
    expect(timed.waitTimedOut).toBe(true)
    expect(h.records.get(`tasks/${task.id}`).status).toBe("running")
  })))
})

test("startup retries an unfinished parent notification once", async () => {
  const h = harness([{
    id: "done", parentSessionID: "ses_parent", ownerDirectory: "/project", childSessionID: "ses_child",
    promptID: "msg_old", task: "Done", status: "completed", result: "Result", createdAt: 1, updatedAt: 1,
  }])
  await Effect.runPromise(Effect.scoped(plugin.effect(h.ctx)))
  expect(h.notices).toHaveLength(1)
  expect(h.notices[0].id).toBe("msg_orchestrator_done")
  expect(h.records.get("tasks/done").notified).toBe(true)
  await Effect.runPromise(Effect.scoped(plugin.effect(h.ctx)))
  expect(h.notices).toHaveLength(1)
})

test("independent session launch, batch, list, read, send, and rename", async () => {
  const h = harness()
  h.ctx.session.context = () => Effect.succeed([
    { type: "user", text: "Investigate" },
    { type: "assistant", content: [{ type: "text", text: "Findings" }] },
  ])
  await Effect.runPromise(Effect.scoped(Effect.gen(function* () {
    yield* plugin.effect(h.ctx)
    const thread = JSON.parse((yield* h.invoke("thread_launch", { title: "Research", prompt: "Investigate",
      workspace: "new_worktree" })).content)
    expect(thread.status).toBe("ready")
    expect(thread.directory).toBe("/project-worktree")
    expect(h.prompts.at(-1).id).toBe(thread.promptID)
    const batch = JSON.parse((yield* h.invoke("thread_create_many", { threads: [{ title: "A" }, { title: "B" }] })).content)
    expect(batch.threads).toHaveLength(2)
    expect(h.prompts).toHaveLength(1)
    const list = JSON.parse((yield* h.invoke("thread_list", {})).content)
    expect(list.threads).toHaveLength(3)
    const page = JSON.parse((yield* h.invoke("thread_read", { sessionID: thread.id, limit: 1 })).content)
    expect(page.messages[0].text).toBe("Investigate")
    expect(page.nextIndex).toBe(1)
    expect(page.hasMore).toBe(true)
    yield* h.invoke("thread_send", { sessionID: thread.id, text: "Continue", delivery: "steer" })
    expect(h.prompts.at(-1).delivery).toBe("steer")
    yield* h.invoke("thread_rename", { sessionID: thread.id, title: "Updated" })
    expect(h.sessions.get(thread.id).title).toBe("Updated")
    const denied = yield* Effect.exit(h.invoke("thread_read", { sessionID: "ses_parent" }))
    expect(denied._tag).toBe("Failure")
  })))
})

test("merge-back stores an auditable handoff and uses a stable parent prompt ID", async () => {
  const h = harness()
  await Effect.runPromise(Effect.scoped(Effect.gen(function* () {
    yield* plugin.effect(h.ctx)
    const task = JSON.parse((yield* h.invoke("delegate", { task: "Explore", parentSessionID: "ses_parent" })).content)
    yield* h.invoke("complete", { taskID: task.id, result: "Changed file A; test B passed" }, task.childSessionID)
    const input = { taskID: task.id, requestID: "merge-1" }
    const first = JSON.parse((yield* h.invoke("merge_back", input)).content)
    const second = JSON.parse((yield* h.invoke("merge_back", input)).content)
    expect(first.id).toBe(second.id)
    expect(h.records.get(`handoffs/${first.id}`).text).toBe("Changed file A; test B passed")
    expect(h.prompts.at(-1).id).toBe(`msg_handoff_${first.id}`)
    expect(h.prompts.at(-1).delivery).toBe("queue")
  })))
})

test("an interrupted independent-thread launch stays inspectable after restart", async () => {
  const h = harness()
  h.records.set("threads/ses_uncertain", {
    id: "ses_uncertain", projectID: "project_test", creatorSessionID: "ses_parent",
    ownerDirectory: "/project", status: "starting", promptID: "msg_uncertain", createdAt: 1,
  })
  await Effect.runPromise(Effect.scoped(plugin.effect(h.ctx)))
  expect(h.records.get("threads/ses_uncertain").status).toBe("unknown")
  expect(h.prompts).toHaveLength(0)
})
