export function cancellation(signal: AbortSignal) {
  return signal.reason instanceof Error ? signal.reason : new Error("Refresh cancelled")
}

export function errorMessage(error: unknown) {
  if (error instanceof Error && error.message) return error.message
  if (typeof error === "object" && error !== null && "message" in error && typeof error.message === "string")
    return error.message
  if (typeof error === "string" && error) return error
  return "Usage unavailable"
}

export function clampPercent(value: number) {
  return Math.max(0, Math.min(100, value))
}

export function parseDate(value?: string) {
  if (!value) return undefined
  const timestamp = Date.parse(value)
  return Number.isFinite(timestamp) ? timestamp : undefined
}
