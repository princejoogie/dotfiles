import type { Context } from "@opencode/plugin/promise/plugin"
import { readFile } from "node:fs/promises"
import { homedir } from "node:os"
import { join } from "node:path"
import { clampPercent, parseDate } from "./helpers"
import type { UsageSnapshot } from "./rpc"

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

export async function fetchGrokUsage(context: Context, signal: AbortSignal): Promise<UsageSnapshot> {
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
