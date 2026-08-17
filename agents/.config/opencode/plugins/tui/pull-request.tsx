/** @jsxImportSource @opentui/solid */

import type { Context } from "@opencode-ai/plugin/tui/context"
import { For, Show, createEffect, createMemo, createSignal, on, onCleanup } from "solid-js"
import { spawn } from "node:child_process"
import { isAbsolute, relative } from "node:path"

const IDLE_REFRESH_MS = 30 * 60 * 1000
const PENDING_REFRESH_MS = 10 * 1000
const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

type PullRequest = {
  number: number
  title: string
  url: string
  state: "OPEN" | "CLOSED" | "MERGED"
  isDraft: boolean
  headRefName: string
  baseRefName: string
  additions: number
  deletions: number
  changedFiles: number
  mergeable: string
  checks: Check[]
}

type Check = {
  name: string
  state: string
  bucket: "pass" | "fail" | "pending" | "skipping" | "cancel"
  link: string
}

type PullRequestResult = Omit<PullRequest, "checks"> & {
  headRepositoryOwner?: { login: string }
}

type CommandResult = {
  stdout: string
  stderr: string
  code: number
}

function run(command: string, args: string[], cwd: string, signal: AbortSignal, accepted = [0]) {
  return new Promise<CommandResult>((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
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

function remoteOwner(remote: string) {
  return remote.replace(/\/$/, "").match(/[:/]([^/:]+)\/[^/]+(?:\.git)?$/)?.[1]
}

function label(value: string, fallback: string) {
  if (!value) return fallback
  return value
    .toLowerCase()
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ")
}

function View(props: { context: Context; sessionID: string }) {
  const theme = props.context.theme
  const [pullRequest, setPullRequest] = createSignal<PullRequest>()
  const [pullRequestOpen, setPullRequestOpen] = createSignal(true)
  const [checksOpen, setChecksOpen] = createSignal(false)
  const [refreshing, setRefreshing] = createSignal(false)
  const [spinnerFrame, setSpinnerFrame] = createSignal(0)
  const [warning, setWarning] = createSignal(false)
  const session = createMemo(() => props.context.data.session.get(props.sessionID))
  const location = createMemo(() => session()?.location)
  const branch = createMemo(() => props.context.data.location.vcs.info(location())?.branch.current)
  const pushes = new Set<string>()
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
    timer = setTimeout(() => void refresh(), delay)
    timer.unref?.()
  }

  const refresh = async () => {
    const cwd = location()?.directory
    if (!cwd) return

    clearTimer()
    controller?.abort()
    controller = new AbortController()
    const signal = controller.signal
    const currentGeneration = generation
    const currentRequest = ++request
    setRefreshing(true)

    try {
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

      if (currentGeneration !== generation || currentRequest !== request) return
      if (!item) {
        setPullRequest(undefined)
        setWarning(false)
        schedule(IDLE_REFRESH_MS)
        return
      }

      let checks: Check[] = []
      if (item.state === "OPEN") {
        const checkResult = await run(
          "gh",
          ["pr", "checks", String(item.number), "--json", "name,state,bucket,link"],
          cwd,
          signal,
          [0, 8],
        )
        checks = JSON.parse(checkResult.stdout || "[]") as Check[]
      }

      if (currentGeneration !== generation || currentRequest !== request) return
      setPullRequest({ ...item, checks })
      setWarning(false)
      schedule(checks.some((check) => check.bucket === "pending") ? PENDING_REFRESH_MS : IDLE_REFRESH_MS)
    } catch (error) {
      if (signal.aborted || currentGeneration !== generation || currentRequest !== request) return
      setWarning(Boolean(pullRequest()))
      const pending = pullRequest()?.checks.some((check) => check.bucket === "pending")
      schedule(pending ? PENDING_REFRESH_MS : IDLE_REFRESH_MS)
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
      () => `${location()?.directory ?? ""}\0${location()?.workspaceID ?? ""}\0${branch() ?? ""}`,
      () => {
        generation++
        request++
        controller?.abort()
        clearTimer()
        setPullRequest(undefined)
        setWarning(false)
        setPullRequestOpen(true)
        setChecksOpen(false)
        const current = location()
        if (!current) return
        void props.context.data.location.vcs.sync(current)
        void refresh()
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
      if (!gitPush(event.data.info.command) || !sameWorkspace(event.data.info.cwd, event.location)) return
      pushes.add(event.data.info.id)
    }),
    props.context.data.on("shell.exited", (event) => {
      const push = pushes.delete(event.data.id)
      if (!push || event.data.status !== "exited" || event.data.exit !== 0) return
      void refresh()
    }),
    props.context.data.on("shell.deleted", (event) => pushes.delete(event.data.id)),
  ]

  onCleanup(() => {
    generation++
    request++
    controller?.abort()
    clearTimer()
    pushes.clear()
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
  const checkIcon = (check: Check) => {
    if (check.bucket === "pass") return ""
    if (check.bucket === "fail") return ""
    if (check.bucket === "pending") return ""
    if (check.bucket === "cancel") return ""
    return ""
  }

  return (
    <Show when={pullRequest()}>
      {(item) => (
        <box>
          <box flexDirection="row" justifyContent="space-between">
            <box flexDirection="row" gap={1} onMouseDown={() => setPullRequestOpen((value) => !value)}>
              <text fg={theme.text.default}>{pullRequestOpen() ? "▼" : "▶"}</text>
              <text fg={theme.text.default}>
                <b>Pull Request</b> <span style={{ fg: theme.text.subdued }}>(#{item().number})</span>
              </text>
            </box>
            <box flexDirection="row" gap={1}>
              <Show when={warning()}>
                <text fg={theme.text.feedback.warning.default}></text>
              </Show>
              <text
                fg={refreshing() ? theme.text.feedback.warning.default : theme.text.subdued}
                onMouseUp={() => void refresh()}
              >
                {refreshing() ? SPINNER_FRAMES[spinnerFrame()] : "󰑐"}
              </text>
            </box>
          </box>

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
                <box flexDirection="row" gap={1} onMouseDown={() => setChecksOpen((value) => !value)}>
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
        </box>
      )}
    </Show>
  )
}

export default {
  id: "dotfiles.pull-request-sidebar",
  setup(context) {
    context.ui.slot({
      append: "sidebar.content",
      render: (props) => <View context={context} sessionID={props.sessionID} />,
    })
  },
}
