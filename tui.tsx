/** @jsxImportSource @opentui/solid */

import type { Context } from "@opencode-ai/plugin/tui/context"
import type { Definition } from "@opencode-ai/plugin/tui/plugin"
import { RGBA } from "@opentui/core"
import { For, Show, createEffect, createMemo, createSignal, onCleanup } from "solid-js"
import { UsageRpc } from "./rpc"
import type { ProviderState, UsageResponse, UsageWindow } from "./rpc"

const REFRESH_MS = 5 * 60 * 1000
const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

type UsageState = {
  codex: ProviderState | { status: "loading" }
  xai: ProviderState | { status: "loading" }
  refreshing: boolean
  updatedAt: number
  open: boolean
}

function errorMessage(error: unknown) {
  if (error instanceof Error && error.message) return error.message
  if (typeof error === "object" && error !== null && "message" in error && typeof error.message === "string")
    return error.message
  if (typeof error === "string" && error) return error
  return "Usage unavailable"
}

function mutedBarColor(theme: Context["theme"]) {
  const foreground = theme.text.subdued.toInts()
  const background = theme.background.default.toInts()
  return RGBA.fromInts(
    Math.round(background[0] + (foreground[0] - background[0]) * 0.25),
    Math.round(background[1] + (foreground[1] - background[1]) * 0.25),
    Math.round(background[2] + (foreground[2] - background[2]) * 0.25),
  )
}

function formatPlan(plan?: string) {
  if (!plan) return ""
  return plan
    .replace(/^prolite$/i, "Pro")
    .split(/[_-]/)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ")
}

function formatDuration(milliseconds: number) {
  if (!Number.isFinite(milliseconds) || milliseconds <= 0) return "now"
  const minutes = Math.max(1, Math.round(milliseconds / 60_000))
  if (minutes < 60) return `${minutes}m`
  const hours = Math.floor(minutes / 60)
  const remainingMinutes = minutes % 60
  if (hours < 24) return `${hours}h${remainingMinutes ? ` ${remainingMinutes}m` : ""}`
  const days = Math.floor(hours / 24)
  const remainingHours = hours % 24
  return `${days}d${remainingHours ? ` ${remainingHours}h` : ""}`
}

function resetText(window: UsageWindow, now: number) {
  if (!window.resetsAt) return "Reset unknown"
  const remaining = window.resetsAt - now
  if (remaining <= 0) return "Resetting"
  return `Resets in ${formatDuration(remaining)}`
}

function pace(window: UsageWindow, now: number) {
  if (!window.resetsAt || !window.windowMinutes) return undefined
  const duration = window.windowMinutes * 60_000
  const start = window.startsAt ?? window.resetsAt - duration
  const elapsed = Math.max(0, Math.min(duration, now - start))
  if (elapsed <= 0) return undefined

  const expected = (elapsed / duration) * 100
  const delta = window.usedPercent - expected
  const remaining = Math.max(0, window.resetsAt - now)
  const eta = window.usedPercent > 0 ? ((100 - window.usedPercent) * elapsed) / window.usedPercent : Infinity
  const willLast = eta >= remaining
  const position =
    !willLast || delta >= 5
      ? `${Math.max(1, Math.round(delta))}% over pace`
      : delta <= -5
        ? `${Math.round(-delta)}% under pace`
        : "On pace"
  return {
    text: `${position} · ${willLast ? "lasts to reset" : `empty in ${formatDuration(eta)}`}`,
    warning: !willLast || delta >= 5,
  }
}

function ProviderCard(props: {
  context: Context
  name: string
  state: UsageState["codex"]
  now: number
}) {
  const theme = props.context.theme
  const fallback = () => (props.state.status === "error" ? ` · ${props.state.message}` : " · Checking...")
  return (
    <box>
      <Show
        when={props.state.status === "ready" ? props.state.snapshot : undefined}
        fallback={
          <text
            fg={props.state.status === "error" ? theme.text.feedback.error.default : theme.text.subdued}
            wrapMode="word"
          >
            <b>{props.name}</b>
            {fallback()}
          </text>
        }
      >
        {(snapshot) => (
          <>
            <box flexDirection="row" justifyContent="space-between">
              <text fg={theme.text.default}>
                <b>{props.name}</b>
              </text>
              <Show when={snapshot().plan}>
                {(plan) => <text fg={theme.text.subdued}>{formatPlan(plan())}</text>}
              </Show>
            </box>
            <For each={snapshot().windows}>
              {(window) => {
                const used = () => Math.round(window.usedPercent)
                const pacing = () => pace(window, props.now)
                return (
                  <box>
                    <box width="100%" height={1} flexDirection="row">
                      <box height={1} flexBasis={0} flexGrow={used()} overflow="hidden">
                        <text
                          fg={used() >= 85 ? theme.text.feedback.warning.default : theme.markdown.link}
                          wrapMode="none"
                        >
                          {"▄".repeat(100)}
                        </text>
                      </box>
                      <box height={1} flexBasis={0} flexGrow={100 - used()} overflow="hidden">
                        <text fg={mutedBarColor(theme)} wrapMode="none">
                          {"▄".repeat(100)}
                        </text>
                      </box>
                    </box>
                    <box flexDirection="row" justifyContent="space-between">
                      <text fg={theme.text.subdued}>{resetText(window, props.now)}</text>
                      <text fg={theme.text.subdued}>{used()}% used</text>
                    </box>
                    <Show when={pacing()}>
                      {(item) => (
                        <text
                          fg={
                            item().warning
                              ? theme.text.feedback.warning.default
                              : theme.text.feedback.success.default
                          }
                        >
                          {item().text}
                        </text>
                      )}
                    </Show>
                  </box>
                )
              }}
            </For>
            <Show when={(snapshot().credits ?? 0) > 0}>
              <text fg={theme.text.subdued}>
                Extra credits ${((snapshot().credits ?? 0) / 100).toFixed(2)}
              </text>
            </Show>
          </>
        )}
      </Show>
    </box>
  )
}

function View(props: {
  context: Context
  state: UsageState
  refresh: (force?: boolean) => Promise<void>
  setOpen: (open: boolean) => void
}) {
  const theme = props.context.theme
  const [spinnerFrame, setSpinnerFrame] = createSignal(0)
  const [now, setNow] = createSignal(Date.now())
  const connected = createMemo(
    () => [props.state.codex, props.state.xai].filter((state) => state.status === "ready").length,
  )

  createEffect(() => {
    if (!props.state.refreshing) {
      setSpinnerFrame(0)
      return
    }
    const timer = setInterval(() => setSpinnerFrame((frame) => (frame + 1) % SPINNER_FRAMES.length), 80)
    timer.unref?.()
    onCleanup(() => clearInterval(timer))
  })

  const clock = setInterval(() => setNow(Date.now()), 60_000)
  clock.unref?.()
  onCleanup(() => clearInterval(clock))

  return (
    <box>
      <box flexDirection="row" justifyContent="space-between">
        <box flexDirection="row" gap={1} onMouseDown={() => props.setOpen(!props.state.open)}>
          <text fg={theme.text.default}>{props.state.open ? "▼" : "▶"}</text>
          <text fg={theme.text.default}>
            <b>Usage</b>
            <span style={{ fg: theme.text.subdued }}> ({connected()}/2)</span>
          </text>
        </box>
        <text
          fg={props.state.refreshing ? theme.text.feedback.warning.default : theme.text.subdued}
          onMouseUp={() => void props.refresh(true)}
        >
          {props.state.refreshing ? SPINNER_FRAMES[spinnerFrame()] : "󰑐"}
        </text>
      </box>
      <Show when={props.state.open}>
        <ProviderCard context={props.context} name="OpenAI Codex" state={props.state.codex} now={now()} />
        <ProviderCard context={props.context} name="xAI Grok" state={props.state.xai} now={now()} />
      </Show>
    </box>
  )
}

export default {
  id: "dotfiles.ai-usage-sidebar",
  setup(context) {
    const usage = context.client.rpc(UsageRpc)
    const [state, updateState] = context.storage.memory<UsageState>("usage", {
      initial: {
        codex: { status: "loading" },
        xai: { status: "loading" },
        refreshing: false,
        updatedAt: 0,
        open: true,
      },
    })
    updateState((draft) => {
      draft.refreshing = false
    })
    let controller: AbortController | undefined
    let refreshTimer: ReturnType<typeof setTimeout> | undefined

    const schedule = (delay = REFRESH_MS) => {
      clearTimeout(refreshTimer)
      refreshTimer = setTimeout(() => void refresh(), delay)
      refreshTimer.unref?.()
    }
    const refresh = async (force = false) => {
      controller?.abort()
      controller = new AbortController()
      const signal = controller.signal
      updateState((draft) => {
        draft.refreshing = true
      })

      try {
        const current = context.location ?? context.data.location.default()
        const response = (await usage.refresh(
          { force },
          {
            signal,
            location: {
              directory: current.directory,
              ...(current.workspaceID ? { workspace: current.workspaceID } : {}),
            },
          },
        )) as UsageResponse
        if (signal.aborted) return
        updateState((draft) => {
          draft.codex = response.codex
          draft.xai = response.xai
          draft.refreshing = false
          draft.updatedAt = response.updatedAt
        })
        schedule()
      } catch (error) {
        if (signal.aborted) return
        updateState((draft) => {
          const message = errorMessage(error)
          draft.codex = { status: "error", message }
          draft.xai = { status: "error", message }
          draft.refreshing = false
          draft.updatedAt = Date.now()
        })
        schedule()
      }
    }

    const unregister = context.ui.slot({
      append: "sidebar.content",
      render: () => (
        <View
          context={context}
          state={state}
          refresh={refresh}
          setOpen={(open) =>
            updateState((draft) => {
              draft.open = open
            })
          }
        />
      ),
    })

    const age = Date.now() - state.updatedAt
    if (state.updatedAt && age < REFRESH_MS) schedule(REFRESH_MS - age)
    else void refresh()

    return () => {
      controller?.abort()
      clearTimeout(refreshTimer)
      unregister()
    }
  },
} satisfies Definition
