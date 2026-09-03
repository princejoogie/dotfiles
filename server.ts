import type { Plugin } from "@opencode-ai/plugin/promise/plugin"
import { spawn } from "node:child_process"
import { PullRequestRpc } from "./rpc"
import type { Check, PullRequest, PullRequestRequest, PullRequestResponse } from "./rpc"

type PullRequestResult = Omit<PullRequest, "checks"> & {
  readonly headRepositoryOwner?: { readonly login: string }
}

type CommandResult = {
  readonly stdout: string
  readonly stderr: string
  readonly code: number
}

type PullRequestFlight = {
  readonly controller: AbortController
  readonly promise: Promise<PullRequestResponse>
  subscribers: number
  settled: boolean
}

function run(command: string, args: string[], cwd: string, signal: AbortSignal, accepted = [0]) {
  return new Promise<CommandResult>((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
      env: process.env,
      signal,
      stdio: ["ignore", "pipe", "pipe"],
    })
    let stdout = ""
    let stderr = ""
    let settled = false

    child.stdout.setEncoding("utf8")
    child.stderr.setEncoding("utf8")
    child.stdout.on("data", (chunk) => (stdout += chunk))
    child.stderr.on("data", (chunk) => (stderr += chunk))
    child.once("error", (error) => {
      if (settled) return
      settled = true
      reject(error)
    })
    child.once("close", (code) => {
      if (settled) return
      settled = true
      const exit = code ?? 1
      if (accepted.includes(exit)) return resolve({ stdout: stdout.trim(), stderr: stderr.trim(), code: exit })
      reject(new Error(stderr.trim() || `${command} exited with code ${exit}`))
    })
  })
}

function remoteOwner(remote: string) {
  return remote.replace(/\/$/, "").match(/[:/]([^/:]+)\/[^/]+(?:\.git)?$/)?.[1]
}

async function load(cwd: string, signal: AbortSignal): Promise<PullRequest | null> {
  const branchResult = await run("git", ["branch", "--show-current"], cwd, signal)
  if (!branchResult.stdout) throw new Error("No branch is checked out")
  const originResult = await run("git", ["remote", "get-url", "origin"], cwd, signal)
  const owner = remoteOwner(originResult.stdout)
  if (!owner) throw new Error("Could not identify the origin owner")

  const fields = [
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
    "headRepositoryOwner",
  ].join(",")
  const result = await run(
    "gh",
    ["pr", "list", "--head", branchResult.stdout, "--state", "all", "--limit", "100", "--json", fields],
    cwd,
    signal,
  )
  const list = JSON.parse(result.stdout) as PullRequestResult[]
  const item = list.find((candidate) => candidate.headRepositoryOwner?.login === owner)
  if (!item) return null

  const checks =
    item.state === "OPEN"
      ? (JSON.parse(
          (
            await run(
              "gh",
              ["pr", "checks", String(item.number), "--json", "name,state,bucket,link"],
              cwd,
              signal,
              [0, 8],
            )
          ).stdout || "[]",
        ) as Check[])
      : []

  return {
    number: item.number,
    title: item.title,
    url: item.url,
    state: item.state,
    isDraft: item.isDraft,
    headRefName: item.headRefName,
    baseRefName: item.baseRefName,
    additions: item.additions,
    deletions: item.deletions,
    changedFiles: item.changedFiles,
    mergeable: item.mergeable,
    reviewDecision: item.reviewDecision,
    reviews: item.reviews,
    checks,
  }
}

export default {
  id: "dotfiles.pull-request",
  async setup(context) {
    const cache = new Map<string, PullRequestResponse>()
    const inflight = new Map<string, PullRequestFlight>()
    const registration = await context.rpc.register(PullRequestRpc, {
      get(input, call) {
        const request = input as PullRequestRequest
        const key = request.branch ?? ""
        const cached = cache.get(key)
        const existing = inflight.get(key)
        const active = existing && !existing.controller.signal.aborted ? existing : undefined
        if (active) return waitForFlight(active, call.signal)
        if (!request.refresh && cached) return Promise.resolve(cached)

        const controller = new AbortController()
        const pending = load(context.location.directory, controller.signal)
          .then((pullRequest): PullRequestResponse => ({ pullRequest, warning: false, updatedAt: Date.now() }))
          .catch((error): PullRequestResponse => {
            if (controller.signal.aborted) throw error
            return {
              pullRequest: cached?.pullRequest ?? null,
              warning: Boolean(cached?.pullRequest),
              updatedAt: Date.now(),
            }
          })
          .then((result) => {
            cache.set(key, result)
            return result
          })
        const flight: PullRequestFlight = { controller, promise: pending, subscribers: 0, settled: false }
        pending.then(
          () => finishFlight(key, flight),
          () => finishFlight(key, flight),
        )
        inflight.set(key, flight)
        return waitForFlight(flight, call.signal)
      },
    })

    function finishFlight(key: string, flight: PullRequestFlight) {
      flight.settled = true
      if (inflight.get(key) === flight) inflight.delete(key)
    }

    return async () => {
      for (const flight of inflight.values()) flight.controller.abort()
      await registration.dispose()
    }
  },
} satisfies Plugin

async function waitForFlight(flight: PullRequestFlight, signal: AbortSignal) {
  if (signal.aborted) {
    if (flight.subscribers === 0) flight.controller.abort()
    throw cancellation(signal)
  }
  flight.subscribers++
  const abort = new Promise<never>((_, reject) => {
    const onAbort = () => reject(cancellation(signal))
    signal.addEventListener("abort", onAbort, { once: true })
    const remove = () => signal.removeEventListener("abort", onAbort)
    flight.promise.then(remove, remove)
  })
  try {
    return await Promise.race([flight.promise, abort])
  } finally {
    flight.subscribers--
    if (!flight.settled && flight.subscribers === 0) flight.controller.abort()
  }
}

function cancellation(signal: AbortSignal) {
  return signal.reason instanceof Error ? signal.reason : new Error("Refresh cancelled")
}
