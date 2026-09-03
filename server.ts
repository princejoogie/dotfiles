import type { Context, Plugin } from "@opencode-ai/plugin/promise/plugin"
import { spawn } from "node:child_process"
import { readFile } from "node:fs/promises"
import { homedir } from "node:os"
import { join } from "node:path"
import { UsageRpc } from "./rpc"
import type { ProviderState, UsageResponse, UsageSnapshot } from "./rpc"

const REFRESH_MS = 5 * 60 * 1000

type CodexRateWindow = {
  usedPercent?: number
  resetsAt?: number | null
  windowDurationMins?: number | null
}

type CodexRateLimitsResponse = {
  rateLimits?: {
    primary?: CodexRateWindow | null
    secondary?: CodexRateWindow | null
    planType?: string | null
  }
}

type XaiCredential = {
  token: string
  userID?: string
  expiresAt?: number
}

type XaiBillingConfig = {
  creditUsagePercent?: number
  currentPeriod?: { start?: string; end?: string }
  productUsage?: Array<{ product?: string; usagePercent?: number }>
  monthlyLimit?: { val?: number }
  used?: { val?: number }
  prepaidBalance?: { val?: number }
  billingPeriodStart?: string
  billingPeriodEnd?: string
}

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
      Promise.allSettled([fetchCodexUsage(signal), fetchXaiUsage(context, signal)]).then((results) => {
        if (signal.aborted) throw new Error("Refresh cancelled")
        const response = {
          codex: providerState(results[0]),
          xai: providerState(results[1]),
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

function cancellation(signal: AbortSignal) {
  return signal.reason instanceof Error ? signal.reason : new Error("Refresh cancelled")
}

function providerState(result: PromiseSettledResult<UsageSnapshot>): ProviderState {
  return result.status === "fulfilled"
    ? { status: "ready", snapshot: result.value }
    : { status: "error", message: errorMessage(result.reason) }
}

function errorMessage(error: unknown) {
  if (error instanceof Error && error.message) return error.message
  if (typeof error === "object" && error !== null && "message" in error && typeof error.message === "string")
    return error.message
  if (typeof error === "string" && error) return error
  return "Usage unavailable"
}

function clampPercent(value: number) {
  return Math.max(0, Math.min(100, value))
}

function requestCodexUsage(signal: AbortSignal) {
  return new Promise<CodexRateLimitsResponse>((resolve, reject) => {
    const child = spawn("codex", ["-s", "read-only", "-a", "never", "app-server"], {
      stdio: ["pipe", "pipe", "pipe"],
    })
    let stdout = ""
    let settled = false

    const finish = (result: CodexRateLimitsResponse | Error) => {
      if (settled) return
      settled = true
      clearTimeout(timeout)
      signal.removeEventListener("abort", abort)
      child.stdin.end()
      child.kill("SIGTERM")
      if (result instanceof Error) reject(result)
      else resolve(result)
    }
    const abort = () => finish(new Error("Refresh cancelled"))
    const timeout = setTimeout(() => finish(new Error("Codex usage timed out")), 15_000)
    timeout.unref?.()
    signal.addEventListener("abort", abort, { once: true })

    child.once("error", (error) =>
      finish(new Error(error.message.includes("ENOENT") ? "Codex CLI not found" : error.message)),
    )
    child.once("close", (code) => {
      if (!settled) finish(new Error(`Codex app-server exited with code ${code ?? 1}`))
    })
    child.stdout.setEncoding("utf8")
    child.stdout.on("data", (chunk) => {
      stdout += chunk
      let newline = stdout.indexOf("\n")
      while (newline !== -1) {
        const line = stdout.slice(0, newline)
        stdout = stdout.slice(newline + 1)
        newline = stdout.indexOf("\n")
        if (!line.trim()) continue

        let message: {
          id?: number
          result?: CodexRateLimitsResponse
          error?: { message?: string }
        }
        try {
          message = JSON.parse(line)
        } catch {
          continue
        }
        if (message.id === 1) {
          child.stdin.write(`${JSON.stringify({ id: 2, method: "account/rateLimits/read" })}\n`)
        }
        if (message.id !== 2) continue
        if (message.error) finish(new Error(message.error.message || "Codex usage unavailable"))
        else finish(message.result ?? {})
      }
    })

    child.stdin.write(
      `${JSON.stringify({
        id: 1,
        method: "initialize",
        params: {
          clientInfo: {
            name: "opencode-usage-sidebar",
            title: "OpenCode Usage Sidebar",
            version: "0.1.0",
          },
          capabilities: { experimentalApi: true },
        },
      })}\n`,
    )
  })
}

async function fetchCodexUsage(signal: AbortSignal): Promise<UsageSnapshot> {
  const response = await requestCodexUsage(signal)
  const limits = response.rateLimits
  if (!limits) throw new Error("Connect a Codex subscription")

  const windows = [limits.primary, limits.secondary]
    .filter((window): window is CodexRateWindow => Boolean(window && Number.isFinite(window.usedPercent)))
    .map((window) => {
      const resetsAt = typeof window.resetsAt === "number" && Number.isFinite(window.resetsAt)
        ? window.resetsAt * 1_000
        : undefined
      const windowMinutes =
        typeof window.windowDurationMins === "number" && Number.isFinite(window.windowDurationMins)
          ? window.windowDurationMins
          : undefined
      return {
        usedPercent: clampPercent(window.usedPercent ?? 0),
        ...(resetsAt === undefined ? {} : { resetsAt }),
        ...(windowMinutes === undefined ? {} : { windowMinutes }),
      }
    })
  if (!windows.length) throw new Error("Codex did not return a usage window")

  return {
    provider: "codex",
    ...(limits.planType ? { plan: limits.planType } : {}),
    windows,
  }
}

function jwtSubject(token: string) {
  try {
    const payload = JSON.parse(Buffer.from(token.split(".")[1] ?? "", "base64url").toString("utf8")) as {
      sub?: string
      exp?: number
    }
    return {
      userID: payload.sub,
      expiresAt: payload.exp ? payload.exp * 1_000 : undefined,
    }
  } catch {
    return {}
  }
}

async function integrationXaiCredentials(context: Context) {
  try {
    const connection = await context.integration.connection.active("xai")
    const credential = connection ? await context.integration.connection.resolve(connection) : undefined
    if (!credential) return []

    const token = credential.type === "oauth" ? credential.access : credential.key
    const claims = jwtSubject(token)
    const metadata = credential.metadata
    const userID =
      typeof metadata?.userID === "string"
        ? metadata.userID
        : typeof metadata?.user_id === "string"
          ? metadata.user_id
          : claims.userID
    return [
      {
        token,
        userID,
        expiresAt: credential.type === "oauth" ? credential.expires : claims.expiresAt,
      },
    ]
  } catch {
    return []
  }
}

async function grokXaiCredentials() {
  try {
    const auth = JSON.parse(
      await readFile(join(process.env.GROK_HOME || join(homedir(), ".grok"), "auth.json"), "utf8"),
    ) as Record<string, { key?: string; user_id?: string; expires_at?: string }>
    const credentials = Object.values(auth).flatMap((entry) => {
      if (!entry?.key) return []
      const claims = jwtSubject(entry.key)
      return [
        {
          token: entry.key,
          userID: entry.user_id ?? claims.userID,
          expiresAt: entry.expires_at ? Date.parse(entry.expires_at) : claims.expiresAt,
        },
      ]
    })
    const now = Date.now() + 60_000
    return credentials.filter(
      (credential, index) =>
        (!credential.expiresAt || credential.expiresAt > now) &&
        credentials.findIndex((candidate) => candidate.token === credential.token) === index,
    )
  } catch {
    return []
  }
}

async function xaiRequest(path: string, credential: XaiCredential, signal: AbortSignal) {
  const response = await fetch(`https://cli-chat-proxy.grok.com/v1/${path}`, {
    headers: {
      Authorization: `Bearer ${credential.token}`,
      "X-XAI-Token-Auth": "xai-grok-cli",
      ...(credential.userID ? { "x-userid": credential.userID } : {}),
      Accept: "application/json",
    },
    signal,
  })
  if (!response.ok) {
    throw new Error(
      response.status === 401 || response.status === 403
        ? "xAI login expired"
        : `xAI usage failed (${response.status})`,
    )
  }
  return response.json() as Promise<Record<string, unknown>>
}

async function fetchXaiUsage(context: Context, signal: AbortSignal): Promise<UsageSnapshot> {
  const integration = await integrationXaiCredentials(context)
  const errors: unknown[] = []

  for (const source of ["integration", "grok"] as const) {
    const credentials = source === "integration" ? integration : await grokXaiCredentials()
    for (const credential of credentials) {
      try {
        return await fetchXaiCredentialUsage(credential, signal)
      } catch (error) {
        if (signal.aborted) throw error
        errors.push(error)
      }
    }
  }

  if (!integration.length && !errors.length) throw new Error("Connect xAI or run grok login")
  throw errors.at(-1) ?? new Error("xAI usage unavailable")
}

async function fetchXaiCredentialUsage(credential: XaiCredential, signal: AbortSignal): Promise<UsageSnapshot> {
  const billing = await xaiRequest("billing?format=credits", credential, signal)
  const config = (billing.config ?? billing) as XaiBillingConfig
  const period = config.currentPeriod
  const startsAt = parseDate(period?.start ?? config.billingPeriodStart)
  const resetsAt = parseDate(period?.end ?? config.billingPeriodEnd)
  const windowMinutes = startsAt && resetsAt ? Math.round((resetsAt - startsAt) / 60_000) : undefined
  const legacyLimit = config.monthlyLimit?.val
  const productUsage = config.productUsage?.find(
    (item) => item.product === "GrokBuild" && Number.isFinite(item.usagePercent),
  )?.usagePercent
  // Protobuf JSON omits zero-valued usage fields while retaining the active period.
  const usedPercent = Number.isFinite(config.creditUsagePercent)
    ? config.creditUsagePercent
    : Number.isFinite(productUsage)
      ? productUsage
      : legacyLimit && Number.isFinite(config.used?.val)
        ? (config.used!.val! / legacyLimit) * 100
        : period
          ? 0
          : undefined
  if (!Number.isFinite(usedPercent)) throw new Error("xAI did not return a usage percentage")

  const settings: Record<string, unknown> = await xaiRequest("settings", credential, signal).catch(() => ({}))
  const plan =
    typeof settings.subscription_tier_display === "string"
      ? settings.subscription_tier_display
      : typeof settings.subscriptionTierDisplay === "string"
        ? settings.subscriptionTierDisplay
        : "SuperGrok"
  return {
    provider: "xai",
    plan,
    windows: [
      {
        usedPercent: clampPercent(usedPercent!),
        ...(startsAt === undefined ? {} : { startsAt }),
        ...(resetsAt === undefined ? {} : { resetsAt }),
        ...(windowMinutes === undefined ? {} : { windowMinutes }),
      },
    ],
    ...(Number.isFinite(config.prepaidBalance?.val) ? { credits: config.prepaidBalance!.val! } : {}),
  }
}

function parseDate(value?: string) {
  if (!value) return undefined
  const timestamp = Date.parse(value)
  return Number.isFinite(timestamp) ? timestamp : undefined
}
