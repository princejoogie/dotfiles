import { Rpc } from "@opencode/plugin/rpc"
import { Schema } from "effect"

export const ModelInput = Schema.Struct({
  providerID: Schema.String,
  id: Schema.String,
  variant: Schema.optional(Schema.String),
})

export const LaunchInput = Schema.Struct({
  parentSessionID: Schema.String,
  task: Schema.NonEmptyString,
  agent: Schema.optional(Schema.String),
  model: Schema.optional(ModelInput),
  worktree: Schema.optional(Schema.Boolean),
  requestID: Schema.optional(Schema.String),
})

export const Task = Schema.Struct({
  id: Schema.String,
  parentSessionID: Schema.String,
  ownerDirectory: Schema.optional(Schema.String),
  childSessionID: Schema.String,
  promptID: Schema.String,
  task: Schema.String,
  status: Schema.Literals(["pending", "starting", "running", "completed", "failed", "cancelled", "unknown"]),
  agent: Schema.optional(Schema.String),
  model: Schema.optional(ModelInput),
  worktree: Schema.optional(Schema.String),
  requestedWorktree: Schema.optional(Schema.Boolean),
  retryOf: Schema.optional(Schema.String),
  result: Schema.optional(Schema.String),
  error: Schema.optional(Schema.String),
  notified: Schema.optional(Schema.Boolean),
  createdAt: Schema.Number,
  updatedAt: Schema.Number,
})

export type TaskRecord = typeof Task.Type
export type LaunchRequest = typeof LaunchInput.Type

export const OrchestratorRpc = Rpc.define({
  id: "orchestrator",
  methods: {
    snapshot: {
      input: Schema.Struct({ parentSessionID: Schema.optional(Schema.String) }),
      output: Schema.Struct({ tasks: Schema.Array(Task) }),
    },
    launch: { input: LaunchInput, output: Task },
    send: {
      input: Schema.Struct({ taskID: Schema.String, text: Schema.NonEmptyString, requestID: Schema.optional(Schema.String) }),
      output: Task,
    },
    cancel: { input: Schema.Struct({ taskID: Schema.String }), output: Task },
  },
  events: {
    updated: { schema: Schema.Struct({ task: Task }) },
  },
})
