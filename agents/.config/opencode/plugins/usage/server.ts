import type { Plugin } from "@opencode/plugin/promise/plugin"
import { constants } from "node:fs"
import { access, stat } from "node:fs/promises"
import { delimiter, join } from "node:path"
import { fetchClaudeUsage } from "./claude"
import { fetchCodexUsage } from "./codex"
import { fetchGrokUsage } from "./grok"
import { cancellation, errorMessage } from "./helpers"
import { UsageRpc } from "./rpc"
import type { ProviderState, UsageResponse, UsageSnapshot } from "./rpc"

const REFRESH_MS = 5 * 60 * 1000

type UsageFlight = {
  controller: AbortController
  promise: Promise<UsageResponse>
  subscribers: number
  settled: boolean
}

export default {
  id: "dotfiles.ai-usage-sidebar",
  async setup(context) {
    let cache: UsageResponse | undefined
    let inFlight: UsageFlight | undefined

    const load = (signal: AbortSignal) =>
      Promise.all([
        loadProvider("codex", () => fetchCodexUsage(signal)),
        loadProvider("claude", () => fetchClaudeUsage(signal)),
        loadProvider("grok", () => fetchGrokUsage(context, signal)),
      ]).then((results) => {
        if (signal.aborted) throw new Error("Refresh cancelled")
        const response = {
          codex: results[0],
          claude: results[1],
          xai: results[2],
          updatedAt: Date.now(),
        } satisfies UsageResponse
        cache = response
        return response
      })

    const registration = await context.rpc.register(UsageRpc, {
      refresh: async (input, call) => {
        const request = input as { force: boolean }
        if (!request.force && cache && Date.now() - cache.updatedAt < REFRESH_MS) return cache

        const active = inFlight && !inFlight.controller.signal.aborted ? inFlight : undefined
        const flight =
          active ??
          (() => {
            const controller = new AbortController()
            const promise = load(controller.signal)
            const created: UsageFlight = { controller, promise, subscribers: 0, settled: false }
            promise.then(
              () => finishFlight(created),
              () => finishFlight(created),
            )
            inFlight = created
            return created
          })()

        return waitForFlight(flight, call.signal)
      },
    })

    function finishFlight(flight: UsageFlight) {
      flight.settled = true
      if (inFlight === flight) inFlight = undefined
    }

    return async () => {
      inFlight?.controller.abort()
      await registration.dispose()
    }
  },
} satisfies Plugin

async function waitForFlight(flight: UsageFlight, signal: AbortSignal) {
  if (signal.aborted) throw cancellation(signal)
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

async function cliAvailable(command: string) {
  const paths = (process.env.PATH ?? "").split(delimiter)
  const matches = await Promise.all(
    paths.map(async (directory) => {
      const path = join(directory, command)
      try {
        await access(path, constants.X_OK)
        return (await stat(path)).isFile()
      } catch {
        return false
      }
    }),
  )
  return matches.some(Boolean)
}

async function loadProvider(command: string, load: () => Promise<UsageSnapshot>): Promise<ProviderState> {
  if (!(await cliAvailable(command))) return { status: "unavailable" }
  try {
    return { status: "ready", snapshot: await load() }
  } catch (error) {
    return { status: "error", message: errorMessage(error) }
  }
}
