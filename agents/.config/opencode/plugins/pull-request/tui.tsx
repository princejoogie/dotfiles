/** @jsxImportSource @opentui/solid */

import type { Context } from "@opencode-ai/plugin/tui/context"
import { For, Show, createEffect, createMemo, createSignal, on, onCleanup } from "solid-js"
import { spawn } from "node:child_process"
import { isAbsolute, relative } from "node:path"
import { PullRequestRpc } from "./rpc"
import type { Check, PullRequest, PullRequestResponse, Review } from "./rpc"

const IDLE_REFRESH_MS = 30 * 60 * 1000
const PENDING_REFRESH_MS = 10 * 1000
const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

type ProjectState = {
  pullRequestOpen: boolean
  checksOpen: boolean
}

type ProjectStateCache = Record<string, ProjectState>

function openURL(url: string) {
  const command = process.platform === "darwin" ? "open" : process.platform === "win32" ? "cmd" : "xdg-open"
  const args = process.platform === "win32" ? ["/c", "start", "", url] : [url]
  const child = spawn(command, args, { detached: true, stdio: "ignore" })
  child.on("error", () => {})
  child.unref()
}

function gitPush(command: string) {
  return /\bgit\b(?:\s+(?:"[^"]*"|'[^']*'|[^\s;&|]+))*\s+push\b/.test(command)
}

function pullRequestCreate(command: string) {
  return /\bgh\b(?:\s+(?:"[^"]*"|'[^']*'|[^\s;&|]+))*\s+pr\s+create\b/.test(command)
}

function label(value: string, fallback: string) {
  if (!value) return fallback
  return value
    .toLowerCase()
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ")
}

function initialProjectState(): ProjectState {
  return {
    pullRequestOpen: true,
    checksOpen: false,
  }
}

function View(props: {
  context: Context
  sessionID: string
  cache: ProjectStateCache
  updateCache: (update: (draft: ProjectStateCache) => void) => void
}) {
  const theme = props.context.theme
  const rpc = props.context.client.rpc(PullRequestRpc)
  const [result, setResult] = createSignal<PullRequestResponse>()
  const [refreshing, setRefreshing] = createSignal(false)
  const [spinnerFrame, setSpinnerFrame] = createSignal(0)
  const session = createMemo(() => props.context.data.session.get(props.sessionID))
  const location = createMemo(() => session()?.location)
  const branch = createMemo(() => props.context.data.location.vcs.info(location())?.branch.current)
  const cacheKey = createMemo(
    () => `${location()?.directory ?? ""}\0${location()?.workspaceID ?? ""}\0${branch() ?? ""}`,
  )
  const project = createMemo(() => props.cache[cacheKey()])
  const pullRequest = () => result()?.pullRequest ?? undefined
  const pullRequestOpen = () => project()?.pullRequestOpen ?? true
  const checksOpen = () => project()?.checksOpen ?? false
  const warning = () => result()?.warning ?? false
  const updateProject = (update: (draft: ProjectState) => void) => {
    const key = cacheKey()
    if (!location()) return
    props.updateCache((draft) => {
      const current = draft[key] ?? (draft[key] = initialProjectState())
      update(current)
    })
  }
  const refreshCommands = new Set<string>()
  let timer: ReturnType<typeof setTimeout> | undefined
  let controller: AbortController | undefined
  let generation = 0
  let request = 0

  const clearTimer = () => {
    if (!timer) return
    clearTimeout(timer)
    timer = undefined
  }

  const schedule = (delay: number) => {
    clearTimer()
    timer = setTimeout(() => void refresh(true), delay)
    timer.unref?.()
  }

  const delayFor = (item: PullRequest | null | undefined) =>
    item?.checks.some((check) => check.bucket === "pending") ? PENDING_REFRESH_MS : IDLE_REFRESH_MS

  const refresh = async (force: boolean) => {
    const current = location()
    if (!current) return

    clearTimer()
    controller?.abort()
    controller = new AbortController()
    const signal = controller.signal
    const currentGeneration = generation
    const currentRequest = ++request
    const currentBranch = branch()
    setRefreshing(true)

    try {
      const response = (await rpc.get(
        { refresh: force, ...(currentBranch ? { branch: currentBranch } : {}) },
        {
          signal,
          location: {
            directory: current.directory,
            ...(current.workspaceID ? { workspace: current.workspaceID } : {}),
          },
        },
      )) as PullRequestResponse
      if (currentGeneration !== generation || currentRequest !== request) return
      setResult(response)
      const delay = delayFor(response.pullRequest)
      const age = Date.now() - response.updatedAt
      if (!force && age >= delay) {
        void refresh(true)
        return
      }
      schedule(Math.max(0, delay - age))
    } catch {
      if (signal.aborted || currentGeneration !== generation || currentRequest !== request) return
      const currentResult = result()
      const failed = {
        pullRequest: currentResult?.pullRequest ?? null,
        warning: Boolean(currentResult?.pullRequest),
        updatedAt: Date.now(),
      }
      setResult(failed)
      schedule(delayFor(failed.pullRequest))
    } finally {
      if (currentRequest === request) setRefreshing(false)
    }
  }

  createEffect(() => {
    if (!refreshing()) {
      setSpinnerFrame(0)
      return
    }
    const interval = setInterval(() => setSpinnerFrame((frame) => (frame + 1) % SPINNER_FRAMES.length), 80)
    interval.unref?.()
    onCleanup(() => clearInterval(interval))
  })

  createEffect(
    on(
      cacheKey,
      () => {
        generation++
        request++
        controller?.abort()
        clearTimer()
        setResult(undefined)
        const current = location()
        if (!current) return
        void props.context.data.location.vcs.sync(current)
        void refresh(false)
      },
    ),
  )

  const sameWorkspace = (cwd: string, eventLocation?: { directory: string; workspaceID?: string }) => {
    const current = location()
    if (!current) return false
    if (current.workspaceID && eventLocation?.workspaceID) return current.workspaceID === eventLocation.workspaceID
    const path = relative(current.directory, cwd)
    return path === "" || (!path.startsWith("..") && !isAbsolute(path))
  }

  const dispose = [
    props.context.data.on("shell.created", (event) => {
      const command = event.data.info.command
      if ((!gitPush(command) && !pullRequestCreate(command)) || !sameWorkspace(event.data.info.cwd, event.location)) return
      refreshCommands.add(event.data.info.id)
    }),
    props.context.data.on("shell.exited", (event) => {
      const shouldRefresh = refreshCommands.delete(event.data.id)
      if (!shouldRefresh || event.data.status !== "exited" || event.data.exit !== 0) return
      void refresh(true)
    }),
    props.context.data.on("shell.deleted", (event) => refreshCommands.delete(event.data.id)),
  ]

  onCleanup(() => {
    generation++
    request++
    controller?.abort()
    clearTimer()
    refreshCommands.clear()
    for (const cleanup of dispose) cleanup()
  })

  const state = (item: PullRequest) => (item.isDraft ? "Draft" : label(item.state, "Unknown"))
  const stateIcon = (item: PullRequest) => {
    if (item.isDraft) return ""
    if (item.state === "MERGED") return ""
    if (item.state === "CLOSED") return ""
    return ""
  }
  const stateColor = (item: PullRequest) => {
    if (item.state === "MERGED") return theme.text.feedback.success.default
    if (item.state === "CLOSED") return theme.text.subdued
    if (item.isDraft) return theme.text.feedback.warning.default
    return theme.text.feedback.success.default
  }
  const checkColor = (check: Check) => {
    if (check.bucket === "pass") return theme.text.feedback.success.default
    if (check.bucket === "fail" || check.bucket === "cancel") return theme.text.feedback.error.default
    if (check.bucket === "pending") return theme.text.feedback.warning.default
    return theme.text.subdued
  }
  const reviewColor = (decision: string) => {
    if (decision === "APPROVED") return theme.text.feedback.success.default
    if (decision === "CHANGES_REQUESTED") return theme.text.feedback.error.default
    return theme.text.feedback.warning.default
  }
  const reviewDecision = (item: PullRequest) => {
    if (item.reviewDecision) return item.reviewDecision
    const latest = new Map<string, Review>()
    for (const review of item.reviews.toSorted((a, b) => a.submittedAt.localeCompare(b.submittedAt))) {
      latest.set(review.author.login, review)
    }
    const states = [...latest.values()].map((review) => review.state)
    if (states.includes("CHANGES_REQUESTED")) return "CHANGES_REQUESTED"
    if (states.includes("APPROVED")) return "APPROVED"
    return ""
  }
  const checkIcon = (check: Check) => {
    if (check.bucket === "pass") return ""
    if (check.bucket === "fail") return ""
    if (check.bucket === "pending") return ""
    if (check.bucket === "cancel") return ""
    return ""
  }

  return (
    <box>
      <box flexDirection="row" justifyContent="space-between">
        <box
          flexDirection="row"
          gap={1}
          onMouseDown={() =>
            pullRequest() &&
            updateProject((draft) => {
              draft.pullRequestOpen = !draft.pullRequestOpen
            })
          }
        >
          <Show when={pullRequest()}>
            <text fg={refreshing() ? theme.text.subdued : theme.text.default}>{pullRequestOpen() ? "▼" : "▶"}</text>
          </Show>
          <text fg={pullRequest() && !refreshing() ? theme.text.default : theme.text.subdued}>
            <b>Pull Request</b>
            <Show
              when={pullRequest()}
              fallback={<span style={{ fg: theme.text.subdued }}> ({refreshing() ? "Checking..." : "No pull request"})</span>}
            >
              {(item) => <span style={{ fg: theme.text.subdued }}> (#{item().number})</span>}
            </Show>
          </text>
        </box>
        <box flexDirection="row" gap={1}>
          <Show when={warning()}>
            <text fg={theme.text.feedback.warning.default}></text>
          </Show>
          <text
            fg={refreshing() ? theme.text.feedback.warning.default : theme.text.subdued}
            onMouseUp={() => void refresh(true)}
          >
            {refreshing() ? SPINNER_FRAMES[spinnerFrame()] : "󰑐"}
          </text>
        </box>
      </box>

      <Show when={pullRequest()}>
        {(item) => (
          <Show when={pullRequestOpen()}>
            <text fg={theme.markdown.link} wrapMode="word" onMouseUp={() => openURL(item().url)}>
              <a href={item().url}>
                <b>{item().title}</b>
              </a>
            </text>
            <text fg={theme.text.subdued} wrapMode="word">
               {item().headRefName} → {item().baseRefName}
            </text>
            <text fg={theme.text.subdued} wrapMode="word">
              <span style={{ fg: stateColor(item()) }}>
                {stateIcon(item())} {state(item())}
              </span>
              {" · "}
              {label(item().mergeable, "Mergeability unknown")}
              <Show when={reviewDecision(item())}>
                {(decision) => (
                  <>
                    {" · "}
                    <span style={{ fg: reviewColor(decision()) }}>{label(decision(), "")}</span>
                  </>
                )}
              </Show>
            </text>
            <text>
              <span style={{ fg: theme.text.subdued }}></span>
              {" "}
              <span style={{ fg: theme.diff.text.added }}>+{item().additions.toLocaleString()}</span>
              {" "}
              <span style={{ fg: theme.diff.text.removed }}>-{item().deletions.toLocaleString()}</span>
              {" "}
              <span style={{ fg: theme.text.subdued }}>
                {item().changedFiles.toLocaleString()} {item().changedFiles === 1 ? "file" : "files"}
              </span>
            </text>

            <Show when={item().state === "OPEN"}>
              <box paddingTop={1}>
                <box
                  flexDirection="row"
                  gap={1}
                  onMouseDown={() =>
                    updateProject((draft) => {
                      draft.checksOpen = !draft.checksOpen
                    })
                  }
                >
                  <text fg={theme.text.default}>{checksOpen() ? "▼" : "▶"}</text>
                  <text fg={theme.text.default}>
                    <b>Checks</b>
                    <Show when={!checksOpen()}>
                      <Show when={item().checks.some((check) => check.bucket === "pass")}>
                        <span style={{ fg: theme.text.feedback.success.default }}>
                          {`   ${item().checks.filter((check) => check.bucket === "pass").length}`}
                        </span>
                      </Show>
                      <Show when={item().checks.some((check) => check.bucket === "fail" || check.bucket === "cancel")}>
                        <span style={{ fg: theme.text.feedback.error.default }}>
                          {`   ${item().checks.filter((check) => check.bucket === "fail" || check.bucket === "cancel").length}`}
                        </span>
                      </Show>
                      <Show when={item().checks.some((check) => check.bucket === "pending")}>
                        <span style={{ fg: theme.text.feedback.warning.default }}>
                          {`   ${item().checks.filter((check) => check.bucket === "pending").length}`}
                        </span>
                      </Show>
                      <Show when={item().checks.some((check) => check.bucket === "skipping")}>
                        <span style={{ fg: theme.text.subdued }}>
                          {`   ${item().checks.filter((check) => check.bucket === "skipping").length}`}
                        </span>
                      </Show>
                    </Show>
                  </text>
                </box>
                <Show when={checksOpen()}>
                  <Show when={item().checks.length > 0} fallback={<text fg={theme.text.subdued}>No checks</text>}>
                    <For each={item().checks}>
                      {(check) => (
                        <box flexDirection="row" gap={1}>
                          <text flexShrink={0} fg={checkColor(check)}>
                            {checkIcon(check)}
                          </text>
                          <text
                            fg={theme.markdown.link}
                            wrapMode="word"
                            onMouseUp={() => openURL(check.link || item().url)}
                          >
                            <a href={check.link || item().url}>{check.name}</a>
                          </text>
                        </box>
                      )}
                    </For>
                  </Show>
                </Show>
              </box>
            </Show>
          </Show>
        )}
      </Show>
    </box>
  )
}

export default {
  id: "dotfiles.pull-request",
  setup(context: Context) {
    const [cache, updateCache] = context.storage.memory<ProjectStateCache>("projects", { initial: {} })
    return context.ui.slot({
      append: "sidebar.content",
      render: (props) => (
        <View context={context} sessionID={props.sessionID} cache={cache} updateCache={updateCache} />
      ),
    })
  },
}
