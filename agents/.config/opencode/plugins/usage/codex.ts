import { spawn } from "node:child_process"
import { clampPercent } from "./helpers"
import type { UsageSnapshot } from "./rpc"

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

export async function fetchCodexUsage(signal: AbortSignal): Promise<UsageSnapshot> {
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
