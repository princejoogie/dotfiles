/** @jsxImportSource @opentui/solid */

import type { Context } from "@opencode/plugin/tui/context"
import type { Definition } from "@opencode/plugin/tui/plugin"
import { RGBA } from "@opentui/core"
import { For, Show, createEffect, createMemo, createSignal, onCleanup } from "solid-js"
import { errorMessage } from "./helpers"
import { UsageRpc } from "./rpc"
import type { ProviderState, UsageResponse, UsageSnapshot, UsageWindow } from "./rpc"

const REFRESH_MS = 5 * 60 * 1000
const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

type UsageState = {
  codex: ProviderState | { status: "loading" }
  claude: ProviderState | { status: "loading" }
  xai: ProviderState | { status: "loading" }
  refreshing: boolean
  updatedAt: number
  open: boolean
  expanded: Record<UsageSnapshot["provider"], boolean>
}

function mutedBarColor(theme: Context["theme"]) {
  const foreground = theme.text.muted.toInts()
  const background = theme.background.base.toInts()
  return RGBA.fromInts(
    Math.round(background[0] + (foreground[0] - background[0]) * 0.25),
    Math.round(background[1] + (foreground[1] - background[1]) * 0.25),
    Math.round(background[2] + (foreground[2] - background[2]) * 0.25),
  )
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
  if (window.usedPercent === null || !window.resetsAt || !window.windowMinutes) return undefined
  const duration = window.windowMinutes * 60_000
  const start = window.startsAt ?? window.resetsAt - duration
  const elapsed = Math.max(0, Math.min(duration, now - start))
  if (elapsed <= 0) return undefined

  const expected = (elapsed / duration) * 100
  const delta = window.usedPercent - expected
  const difference = Math.round(delta)
  return {
    text: `${Math.abs(difference)}% ${difference > 0 ? "over" : "under"}`,
    warning: difference > 0,
  }
}

function WindowUsage(props: {
  context: Context
  title: string
  window: UsageWindow
  expanded: boolean
  now: number
  onToggle?: () => void
}) {
  const theme = props.context.theme
  const used = () => Math.round(props.window.usedPercent ?? 0)
  const pacing = () => pace(props.window, props.now)
  return (
    <box>
      <box flexDirection="row" justifyContent="space-between" onMouseDown={props.onToggle}>
        <box flexDirection="row" gap={1}>
          <text fg={theme.text.base} wrapMode="none">
            <b>{props.title}</b>
          </text>
          <Show when={props.onToggle}>
            <text fg={theme.text.muted}>{props.expanded ? "-" : "+"}</text>
          </Show>
        </box>
        <text fg={theme.text.muted} wrapMode="none">
          {props.window.usedPercent === null ? "Unavailable" : `${used()}% used`}
        </text>
      </box>
      <box width="100%" height={1} flexDirection="row">
        <box height={1} flexBasis={0} flexGrow={used()} overflow="hidden">
          <text fg={used() >= 85 ? theme.text.feedback.warning.base : theme.markdown.link} wrapMode="none">
            {"▄".repeat(100)}
          </text>
        </box>
        <box height={1} flexBasis={0} flexGrow={100 - used()} overflow="hidden">
          <text fg={mutedBarColor(theme)} wrapMode="none">
            {"▄".repeat(100)}
          </text>
        </box>
      </box>
      <Show when={props.expanded}>
        <box flexDirection="row" justifyContent="space-between">
          <text fg={theme.text.muted}>{resetText(props.window, props.now)}</text>
          <Show when={pacing()}>
            {(item) => (
              <text fg={item().warning ? theme.text.feedback.warning.base : theme.text.feedback.success.base}>
                {item().text}
              </text>
            )}
          </Show>
        </box>
      </Show>
    </box>
  )
}

function windowTitle(window: UsageWindow) {
  if (window.label) return window.label
  if (window.windowMinutes === 300) return "5-hour window"
  if (window.windowMinutes === 7 * 24 * 60) return "Weekly"
  return "Usage window"
}

function ProviderCard(props: {
  context: Context
  name: string
  state: UsageState["codex"]
  now: number
  expanded: boolean
  onToggle: () => void
}) {
  const theme = props.context.theme
  const fallback = () => (props.state.status === "error" ? ` · ${props.state.message}` : " · Checking...")
  return (
    <box>
      <Show
        when={props.state.status === "ready" ? props.state.snapshot : undefined}
        fallback={
          <text
            fg={props.state.status === "error" ? theme.text.feedback.error.base : theme.text.muted}
            wrapMode="word"
          >
            <b>{props.name}</b>
            {fallback()}
          </text>
        }
      >
        {(snapshot) => {
          const primary = createMemo(
            () => snapshot().windows.find((window) => window.windowMinutes === 300) ?? snapshot().windows[0],
          )
          return (
            <>
              <Show when={primary()}>
                {(window) => (
                  <WindowUsage
                    context={props.context}
                    title={props.name}
                    window={window()}
                    expanded={props.expanded}
                    now={props.now}
                    onToggle={props.onToggle}
                  />
                )}
              </Show>
              <Show when={props.expanded}>
                <For each={snapshot().windows.filter((window) => window !== primary())}>
                  {(window) => (
                    <WindowUsage
                      context={props.context}
                      title={windowTitle(window)}
                      window={window}
                      expanded={true}
                      now={props.now}
                    />
                  )}
                </For>
                <Show when={(snapshot().credits ?? 0) > 0}>
                  <text fg={theme.text.muted}>
                    Extra credits ${((snapshot().credits ?? 0) / 100).toFixed(2)}
                  </text>
                </Show>
              </Show>
            </>
          )
        }}
      </Show>
    </box>
  )
}

function View(props: {
  context: Context
  state: UsageState
  refresh: (force?: boolean) => Promise<void>
  setOpen: (open: boolean) => void
  setExpanded: (provider: UsageSnapshot["provider"], expanded: boolean) => void
}) {
  const theme = props.context.theme
  const [spinnerFrame, setSpinnerFrame] = createSignal(0)
  const [now, setNow] = createSignal(Date.now())
  const providers = createMemo(() =>
    [
      { id: "codex" as const, name: "OpenAI Codex", state: props.state.codex },
      { id: "claude" as const, name: "Claude", state: props.state.claude },
      { id: "xai" as const, name: "xAI Grok", state: props.state.xai },
    ].filter(({ state }) => state.status === "ready" || state.status === "error"),
  )
  const connected = createMemo(() => providers().filter(({ state }) => state.status === "ready").length)

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
    <Show when={providers().length > 0}>
      <box>
        <box flexDirection="row" justifyContent="space-between">
          <box flexDirection="row" gap={1} onMouseDown={() => props.setOpen(!props.state.open)}>
            <text fg={theme.text.base}>{props.state.open ? "▼" : "▶"}</text>
            <text fg={theme.text.base}>
              <b>Usage</b>
              <span style={{ fg: theme.text.muted }}> ({connected()}/{providers().length})</span>
            </text>
          </box>
          <text
            fg={props.state.refreshing ? theme.text.feedback.warning.base : theme.text.muted}
            onMouseUp={() => void props.refresh(true)}
          >
            {props.state.refreshing ? SPINNER_FRAMES[spinnerFrame()] : "󰑐"}
          </text>
        </box>
        <Show when={props.state.open}>
          <box gap={1}>
            <For each={providers()}>
              {(provider) => (
                <ProviderCard
                  context={props.context}
                  name={provider.name}
                  state={provider.state}
                  now={now()}
                  expanded={props.state.expanded[provider.id]}
                  onToggle={() => props.setExpanded(provider.id, !props.state.expanded[provider.id])}
                />
              )}
            </For>
          </box>
        </Show>
      </box>
    </Show>
  )
}

export default {
  id: "dotfiles.ai-usage-sidebar",
  setup(context) {
    const usage = context.client.rpc(UsageRpc)
    const [state, updateState] = context.storage.memory<UsageState>("usage-v2", {
      initial: {
        codex: { status: "loading" },
        claude: { status: "loading" },
        xai: { status: "loading" },
        refreshing: false,
        updatedAt: 0,
        open: true,
        expanded: { codex: false, claude: false, xai: false },
      },
    })
    updateState((draft) => {
      draft.expanded ??= { codex: false, claude: false, xai: false }
      draft.codex = { status: "loading" }
      draft.claude = { status: "loading" }
      draft.xai = { status: "loading" }
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
          draft.claude = response.claude
          draft.xai = response.xai
          draft.refreshing = false
          draft.updatedAt = response.updatedAt
        })
        schedule()
      } catch (error) {
        if (signal.aborted) return
        updateState((draft) => {
          const message = errorMessage(error)
          for (const provider of ["codex", "claude", "xai"] as const) {
            if (draft[provider].status === "ready" || draft[provider].status === "error") {
              draft[provider] = { status: "error", message }
            }
          }
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
          setExpanded={(provider, expanded) =>
            updateState((draft) => {
              draft.expanded[provider] = expanded
            })
          }
        />
      ),
    })

    void refresh(true)

    return () => {
      controller?.abort()
      clearTimeout(refreshTimer)
      unregister()
    }
  },
} satisfies Definition
