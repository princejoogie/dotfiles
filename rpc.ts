import type { Rpc } from "@opencode/plugin/rpc"

export type UsageWindow = {
  label?: string
  usedPercent: number | null
  resetsAt?: number
  windowMinutes?: number
  startsAt?: number
}

export type UsageSnapshot = {
  provider: "codex" | "claude" | "xai"
  plan?: string
  windows: UsageWindow[]
  credits?: number
}

export type ProviderState =
  | { status: "unavailable" }
  | { status: "ready"; snapshot: UsageSnapshot }
  | { status: "error"; message: string }

export type UsageResponse = {
  codex: ProviderState
  claude: ProviderState
  xai: ProviderState
  updatedAt: number
}

const window = {
  type: "object",
  properties: {
    label: { type: "string" },
    usedPercent: { type: ["number", "null"] },
    resetsAt: { type: "number" },
    windowMinutes: { type: "number" },
    startsAt: { type: "number" },
  },
  required: ["usedPercent"],
  additionalProperties: false,
} as const

const snapshot = {
  type: "object",
  properties: {
    provider: { enum: ["codex", "claude", "xai"] },
    plan: { type: "string" },
    windows: { type: "array", items: window },
    credits: { type: "number" },
  },
  required: ["provider", "windows"],
  additionalProperties: false,
} as const

const provider = {
  oneOf: [
    {
      type: "object",
      properties: { status: { const: "unavailable" } },
      required: ["status"],
      additionalProperties: false,
    },
    {
      type: "object",
      properties: {
        status: { const: "ready" },
        snapshot,
      },
      required: ["status", "snapshot"],
      additionalProperties: false,
    },
    {
      type: "object",
      properties: {
        status: { const: "error" },
        message: { type: "string" },
      },
      required: ["status", "message"],
      additionalProperties: false,
    },
  ],
} as const

export const UsageRpc = {
  id: "dotfiles.usage",
  methods: {
    refresh: {
      input: {
        type: "object",
        properties: { force: { type: "boolean" } },
        required: ["force"],
        additionalProperties: false,
      },
      output: {
        type: "object",
        properties: {
          codex: provider,
          claude: provider,
          xai: provider,
          updatedAt: { type: "number" },
        },
        required: ["codex", "claude", "xai", "updatedAt"],
        additionalProperties: false,
      },
    },
  },
  events: {},
} as const satisfies Rpc.PortableDefinition
