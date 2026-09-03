import type { Rpc } from "@opencode-ai/schema/rpc"

export type Review = {
  readonly author: { readonly login: string }
  readonly state: string
  readonly submittedAt: string
}

export type Check = {
  readonly name: string
  readonly state: string
  readonly bucket: "pass" | "fail" | "pending" | "skipping" | "cancel"
  readonly link: string
}

export type PullRequest = {
  readonly number: number
  readonly title: string
  readonly url: string
  readonly state: "OPEN" | "CLOSED" | "MERGED"
  readonly isDraft: boolean
  readonly headRefName: string
  readonly baseRefName: string
  readonly additions: number
  readonly deletions: number
  readonly changedFiles: number
  readonly mergeable: string
  readonly reviewDecision: string
  readonly reviews: readonly Review[]
  readonly checks: readonly Check[]
}

export type PullRequestRequest = {
  readonly refresh: boolean
  readonly branch?: string
}

export type PullRequestResponse = {
  readonly pullRequest: PullRequest | null
  readonly warning: boolean
  readonly updatedAt: number
}

const review = {
  type: "object",
  properties: {
    author: {
      type: "object",
      properties: { login: { type: "string" } },
      required: ["login"],
      additionalProperties: false,
    },
    state: { type: "string" },
    submittedAt: { type: "string" },
  },
  required: ["author", "state", "submittedAt"],
  additionalProperties: false,
} as const

const check = {
  type: "object",
  properties: {
    name: { type: "string" },
    state: { type: "string" },
    bucket: { enum: ["pass", "fail", "pending", "skipping", "cancel"] },
    link: { type: "string" },
  },
  required: ["name", "state", "bucket", "link"],
  additionalProperties: false,
} as const

const pullRequest = {
  type: "object",
  properties: {
    number: { type: "integer", minimum: 0 },
    title: { type: "string" },
    url: { type: "string" },
    state: { enum: ["OPEN", "CLOSED", "MERGED"] },
    isDraft: { type: "boolean" },
    headRefName: { type: "string" },
    baseRefName: { type: "string" },
    additions: { type: "integer", minimum: 0 },
    deletions: { type: "integer", minimum: 0 },
    changedFiles: { type: "integer", minimum: 0 },
    mergeable: { type: "string" },
    reviewDecision: { type: "string" },
    reviews: { type: "array", items: review },
    checks: { type: "array", items: check },
  },
  required: [
    "number",
    "title",
    "url",
    "state",
    "isDraft",
    "headRefName",
    "baseRefName",
    "additions",
    "deletions",
    "changedFiles",
    "mergeable",
    "reviewDecision",
    "reviews",
    "checks",
  ],
  additionalProperties: false,
} as const

export const PullRequestRpc = {
  id: "dotfiles.pull-request",
  methods: {
    get: {
      input: {
        type: "object",
        properties: {
          refresh: { type: "boolean" },
          branch: { type: "string" },
        },
        required: ["refresh"],
        additionalProperties: false,
      },
      output: {
        type: "object",
        properties: {
          pullRequest: { anyOf: [pullRequest, { type: "null" }] },
          warning: { type: "boolean" },
          updatedAt: { type: "integer", minimum: 0 },
        },
        required: ["pullRequest", "warning", "updatedAt"],
        additionalProperties: false,
      },
    },
  },
  events: {},
} as const satisfies Rpc.PortableDefinition
