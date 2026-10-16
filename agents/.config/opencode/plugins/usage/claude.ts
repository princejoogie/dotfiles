import { execFile } from "node:child_process"
import { createHash } from "node:crypto"
import { readFile } from "node:fs/promises"
import { homedir } from "node:os"
import { join } from "node:path"
import { promisify } from "node:util"
import { cancellation, clampPercent, parseDate } from "./helpers"
import type { UsageSnapshot } from "./rpc"

const execFileAsync = promisify(execFile)

type ClaudeCredential = {
  accessToken?: string
  expiresAt?: number
  subscriptionType?: string
}

type ClaudeRateWindow = {
  utilization?: number | null
  resets_at?: string | null
}

type ClaudeRateLimit = {
  kind?: string
  percent?: number | null
  resets_at?: string | null
  scope?: { model?: { display_name?: string | null } | null } | null
}

type ClaudeUsageResponse = {
  five_hour?: ClaudeRateWindow | null
  seven_day?: ClaudeRateWindow | null
  limits?: ClaudeRateLimit[] | null
}

async function claudeCredentials(signal: AbortSignal): Promise<ClaudeCredential> {
  const configDir = process.env.CLAUDE_CONFIG_DIR || join(homedir(), ".claude")
  const file = () => readFile(join(configDir, ".credentials.json"), { encoding: "utf8", signal })
  const keychain = async () => {
    const storageDir = process.env.CLAUDE_SECURESTORAGE_CONFIG_DIR ?? process.env.CLAUDE_CONFIG_DIR
    const suffix = storageDir
      ? `-${createHash("sha256").update(storageDir.normalize("NFC")).digest("hex").slice(0, 8)}`
      : ""
    const result = await execFileAsync(
      "/usr/bin/security",
      ["find-generic-password", "-s", `Claude Code-credentials${suffix}`, "-w"],
      { signal, timeout: 5_000, maxBuffer: 1024 * 1024 },
    )
    return result.stdout
  }
  // macOS uses Keychain as its primary store. A leftover fallback file can be months out of date.
  return readClaudeCredential(process.platform === "darwin" ? [keychain, file] : [file], signal)
}

export async function readClaudeCredential(
  sources: Array<() => Promise<string>>,
  signal: AbortSignal,
): Promise<ClaudeCredential> {
  let raw: string | undefined
  for (const source of sources) {
    if (signal.aborted) throw cancellation(signal)
    try {
      raw = await source()
      if (raw) break
    } catch {
      if (signal.aborted) throw cancellation(signal)
    }
  }

  let credential: ClaudeCredential | undefined
  try {
    credential = raw ? (JSON.parse(raw) as { claudeAiOauth?: ClaudeCredential }).claudeAiOauth : undefined
  } catch {
    throw new Error("Claude credentials could not be read")
  }
  if (!credential?.accessToken) throw new Error("Sign in with Claude Code")
  if (credential.expiresAt && credential.expiresAt <= Date.now()) {
    throw new Error("Saved Claude usage token expired. Claude Code may need to refresh it")
  }
  return credential
}

export async function fetchClaudeUsage(signal: AbortSignal): Promise<UsageSnapshot> {
  const credential = await claudeCredentials(signal)
  const response = await fetch("https://api.anthropic.com/api/oauth/usage", {
    headers: {
      Authorization: `Bearer ${credential.accessToken}`,
      "anthropic-beta": "oauth-2025-04-20",
      Accept: "application/json",
    },
    redirect: "error",
    signal: AbortSignal.any([signal, AbortSignal.timeout(15_000)]),
  })
  if (!response.ok) {
    throw new Error(
      response.status === 401 || response.status === 403
        ? "Claude usage access denied. Sign in again with Claude Code"
        : `Claude usage failed (${response.status})`,
    )
  }
  const usage = (await response.json()) as ClaudeUsageResponse
  const session = usage.limits?.find((limit) => limit.kind === "session")
  const weekly = usage.limits?.find((limit) => limit.kind === "weekly_all")
  // Scoped weekly caps, including Fable, now live in limits rather than seven_day_* fields.
  const fable = usage.limits?.find(
    (limit) => limit.kind === "weekly_scoped" && limit.scope?.model?.display_name?.toLowerCase() === "fable",
  )
  const windows = [
    {
      label: "5-hour window",
      percent: usage.five_hour?.utilization ?? session?.percent,
      reset: usage.five_hour?.resets_at ?? session?.resets_at,
      windowMinutes: 300,
    },
    {
      label: "Weekly",
      percent: usage.seven_day?.utilization ?? weekly?.percent,
      reset: usage.seven_day?.resets_at ?? weekly?.resets_at,
      windowMinutes: 7 * 24 * 60,
    },
    {
      label: "Weekly Fable",
      percent: fable?.percent,
      reset: fable?.resets_at,
      windowMinutes: 7 * 24 * 60,
    },
  ].map(({ label, percent, reset, windowMinutes }) => {
    const resetsAt = parseDate(reset ?? undefined)
    return {
      label,
      usedPercent: typeof percent === "number" && Number.isFinite(percent) ? clampPercent(percent) : null,
      windowMinutes,
      ...(resetsAt === undefined ? {} : { resetsAt }),
    }
  })
  if (windows.every((window) => window.usedPercent === null)) {
    throw new Error("Claude did not return a usage window")
  }
  return {
    provider: "claude",
    ...(credential.subscriptionType ? { plan: credential.subscriptionType } : {}),
    windows,
  }
}
