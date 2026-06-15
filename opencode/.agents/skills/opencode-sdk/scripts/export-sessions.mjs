#!/usr/bin/env node
import { spawnSync } from "node:child_process"
import { existsSync, writeFileSync } from "node:fs"
import { basename } from "node:path"
import os from "node:os"

const DEFAULT_DB = "/Users/pjuguilon/.local/share/opencode/opencode.db"
const DEFAULT_TEXT_LIMIT = 20000

main().catch((error) => {
  console.error(error?.stack || error?.message || String(error))
  process.exit(1)
})

async function main() {
  const args = parseArgs(process.argv.slice(2))
  if (args.help) {
    printHelp()
    return
  }

  const timezone =
    args.timezone || Intl.DateTimeFormat().resolvedOptions().timeZone || "UTC"
  process.env.TZ = timezone

  const range = buildRange(args, timezone)
  const textLimit = Number(args["text-limit"] || DEFAULT_TEXT_LIMIT)
  const source = args["base-url"] ? "sdk" : "sqlite"

  const payload =
    source === "sdk"
      ? await exportFromSdk(args["base-url"], range, args, textLimit)
      : exportFromSqlite(args.db || DEFAULT_DB, range, args, textLimit)

  const json = JSON.stringify(payload, null, args.compact ? 0 : 2)
  if (args.output) {
    writeFileSync(args.output, `${json}\n`)
    return
  }
  process.stdout.write(`${json}\n`)
}

function parseArgs(argv) {
  const args = {}
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i]
    if (arg === "--help" || arg === "-h") {
      args.help = true
      continue
    }
    if (!arg.startsWith("--")) {
      throw new Error(`Unexpected argument: ${arg}`)
    }
    const key = arg.slice(2)
    const next = argv[i + 1]
    if (!next || next.startsWith("--")) {
      args[key] = true
      continue
    }
    args[key] = next
    i += 1
  }
  return args
}

function printHelp() {
  console.log(`Usage:
  node export-sessions.mjs --date YYYY-MM-DD [--timezone Asia/Manila] [--output file]
  node export-sessions.mjs --start ISO --end ISO [--base-url http://localhost:4096]

Options:
  --date YYYY-MM-DD       Export one local calendar day.
  --start ISO             Inclusive start time.
  --end ISO               Exclusive end time.
  --timezone IANA         Timezone for --date boundaries. Defaults to system timezone.
  --db PATH               SQLite store path. Defaults to ${DEFAULT_DB}.
  --base-url URL          Use an already-running OpenCode server through @opencode-ai/sdk.
  --output PATH           Write JSON to a file instead of stdout.
  --text-limit N          Max text chars per normalized message. Defaults to ${DEFAULT_TEXT_LIMIT}.
  --include-tools         Include compact tool-call summaries.
  --include-reasoning     Include reasoning text when present.
  --compact               Emit compact JSON.
`)
}

function buildRange(args, timezone) {
  if (args.start && args.end) {
    const start = new Date(args.start)
    const end = new Date(args.end)
    assertValidDate(start, "--start")
    assertValidDate(end, "--end")
    if (end <= start) throw new Error("--end must be after --start")
    return toRange(start, end, timezone)
  }

  if (args.date) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(args.date)) {
      throw new Error("--date must use YYYY-MM-DD")
    }
    const start = new Date(`${args.date}T00:00:00`)
    const end = new Date(start)
    end.setDate(end.getDate() + 1)
    assertValidDate(start, "--date")
    return toRange(start, end, timezone)
  }

  const now = new Date()
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1)
  const end = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  return toRange(start, end, timezone)
}

function toRange(start, end, timezone) {
  return {
    timezone,
    start: start.toISOString(),
    end: end.toISOString(),
    startMs: start.getTime(),
    endMs: end.getTime(),
  }
}

function assertValidDate(date, label) {
  if (Number.isNaN(date.getTime())) throw new Error(`Invalid ${label} date`)
}

async function exportFromSdk(baseUrl, range, args, textLimit) {
  let createOpencodeClient
  try {
    ;({ createOpencodeClient } = await import("@opencode-ai/sdk"))
  } catch (error) {
    throw new Error(
      `Unable to import @opencode-ai/sdk. Run "npm install" in this scripts directory first. ${error.message}`,
    )
  }

  const client = createOpencodeClient({
    baseUrl,
    throwOnError: true,
  })

  const sessions = unwrapResponse(await client.session.list())
  const outputSessions = []

  for (const session of sessions || []) {
    const messages = unwrapResponse(
      await client.session.messages({ path: { id: session.id } }),
    )
    const normalizedMessages = normalizeSdkMessages(
      session.id,
      messages || [],
      range,
      args,
      textLimit,
    )
    if (!normalizedMessages.length && !timeOverlaps(session, range)) continue
    outputSessions.push(normalizeSession(session, normalizedMessages))
  }

  return buildPayload({
    mode: "sdk",
    baseUrl,
    note: "Read from an already-running OpenCode server through @opencode-ai/sdk.",
    range,
    sessions: outputSessions,
  })
}

function exportFromSqlite(dbPath, range, args, textLimit) {
  const expandedDbPath = expandHome(dbPath)
  if (!existsSync(expandedDbPath)) {
    throw new Error(`OpenCode SQLite store not found: ${expandedDbPath}`)
  }

  const sessionRows = sqliteJson(
    expandedDbPath,
    `
      select
        s.id as id,
        s.title as title,
        s.directory as directory,
        s.time_created as time_created,
        s.time_updated as time_updated,
        p.name as project_name,
        p.worktree as project_worktree
      from session s
      left join project p on p.id = s.project_id
      where
        exists (
          select 1
          from session_message sm
          where sm.session_id = s.id
            and sm.time_created >= ${range.startMs}
            and sm.time_created < ${range.endMs}
        )
        or (
          s.time_updated >= ${range.startMs}
          and s.time_updated < ${range.endMs}
        )
      order by coalesce(p.name, p.worktree, s.directory), s.time_created, s.id;
    `,
  )

  if (!sessionRows.length) {
    return buildPayload({
      mode: "sqlite",
      db: expandedDbPath,
      note: "Read directly from the local OpenCode SQLite store in read-only mode.",
      range,
      sessions: [],
    })
  }

  const sessionIds = new Set(sessionRows.map((row) => row.id))
  const quotedIds = [...sessionIds].map(sqlString).join(", ")
  const messageRows = sqliteJson(
    expandedDbPath,
    `
      select
        sm.id as id,
        sm.session_id as session_id,
        sm.type as type,
        sm.seq as seq,
        sm.time_created as time_created,
        sm.time_updated as time_updated,
        sm.data as data
      from session_message sm
      where sm.session_id in (${quotedIds})
        and sm.time_created >= ${range.startMs}
        and sm.time_created < ${range.endMs}
      order by sm.session_id, sm.seq, sm.time_created, sm.id;
    `,
  )

  const messagesBySession = groupBy(messageRows, (row) => row.session_id)
  const sessions = sessionRows.map((row) => {
    const messages = (messagesBySession.get(row.id) || []).map((message) =>
      normalizeSqliteMessage(message, args, textLimit),
    )
    return normalizeSession(row, messages)
  })

  return buildPayload({
    mode: "sqlite",
    db: expandedDbPath,
    note: "Read directly from the local OpenCode SQLite store in read-only mode.",
    range,
    sessions,
  })
}

function sqliteJson(dbPath, sql) {
  const result = spawnSync("sqlite3", ["-readonly", "-json", dbPath, sql], {
    encoding: "utf8",
    maxBuffer: 256 * 1024 * 1024,
  })
  if (result.error) throw result.error
  if (result.status !== 0) {
    throw new Error(result.stderr || `sqlite3 exited with ${result.status}`)
  }
  const stdout = result.stdout.trim()
  return stdout ? JSON.parse(stdout) : []
}

function normalizeSqliteMessage(row, args, textLimit) {
  const data = parseJson(row.data) || {}
  const text = extractText(data, row.type, args, textLimit)
  return {
    id: row.id,
    role: row.type || data.role || "unknown",
    seq: row.seq,
    time: new Date(row.time_created).toISOString(),
    timeCreated: row.time_created,
    text,
  }
}

function normalizeSdkMessages(sessionId, messages, range, args, textLimit) {
  return messages
    .map((message) => {
      const created = getTimeMs(message)
      if (created < range.startMs || created >= range.endMs) return null
      return {
        id: message.id,
        role: message.role || message.type || "unknown",
        seq: message.seq,
        time: new Date(created).toISOString(),
        timeCreated: created,
        text: extractText(message, message.role || message.type, args, textLimit),
      }
    })
    .filter(Boolean)
}

function normalizeSession(session, messages) {
  const worktree = session.project_worktree || session.project?.worktree
  const directory = session.directory || session.path?.cwd || worktree
  const label = projectLabel(session.project_name || session.project?.name, worktree, directory)
  return {
    id: session.id,
    title: session.title || "",
    directory: directory || "",
    project: {
      label,
      name: session.project_name || session.project?.name || null,
      worktree: worktree || directory || null,
    },
    timeCreated: getTimeMs(session, "time_created"),
    timeUpdated: getTimeMs(session, "time_updated"),
    messages,
  }
}

function buildPayload({ mode, baseUrl, db, note, range, sessions }) {
  const projects = []
  const byProject = groupBy(sessions, (session) => session.project.label)
  for (const [label, projectSessions] of byProject) {
    projects.push({
      label,
      worktree: projectSessions[0]?.project.worktree || null,
      sessionCount: projectSessions.length,
      messageCount: projectSessions.reduce(
        (count, session) => count + session.messages.length,
        0,
      ),
      sessions: projectSessions,
    })
  }

  projects.sort((a, b) => a.label.localeCompare(b.label))

  return {
    generatedAt: new Date().toISOString(),
    source: { mode, baseUrl, db, note },
    range,
    counts: {
      projects: projects.length,
      sessions: sessions.length,
      messages: projects.reduce((count, project) => count + project.messageCount, 0),
    },
    projects,
  }
}

function extractText(data, fallbackRole, args, textLimit) {
  const chunks = []
  const content = Array.isArray(data.content)
    ? data.content
    : Array.isArray(data.parts)
      ? data.parts
      : null

  if (typeof data.text === "string") chunks.push(data.text)
  if (typeof data.content === "string") chunks.push(data.content)

  if (content) {
    for (const item of content) {
      if (!item || typeof item !== "object") continue
      if (item.type === "text" && typeof item.text === "string") {
        chunks.push(item.text)
        continue
      }
      if (item.type === "reasoning") {
        if (args["include-reasoning"] && typeof item.text === "string") {
          chunks.push(`[reasoning] ${item.text}`)
        }
        continue
      }
      if (item.type === "tool") {
        if (args["include-tools"]) chunks.push(formatToolItem(item))
        continue
      }
      if (typeof item.text === "string") chunks.push(`[${item.type || fallbackRole}] ${item.text}`)
    }
  }

  return truncate(chunks.filter(Boolean).join("\n\n"), textLimit)
}

function formatToolItem(item) {
  const name = item.name || item.tool || "tool"
  const status = item.state?.status || item.status || "unknown"
  const input = item.state?.input ? ` input=${safeStringify(item.state.input)}` : ""
  const output = item.state?.output ? ` output=${safeStringify(item.state.output)}` : ""
  return truncate(`[tool:${name} status=${status}]${input}${output}`, 4000)
}

function projectLabel(name, worktree, directory) {
  if (name) return name
  const path = worktree && worktree !== "/" ? worktree : directory
  if (!path || path === "/") return "General / Projectless"
  return basename(path) || path
}

function getTimeMs(value, snakeKey) {
  if (!value) return 0
  if (snakeKey && Number.isFinite(value[snakeKey])) return value[snakeKey]
  if (Number.isFinite(value.time_created)) return value.time_created
  if (Number.isFinite(value.time_updated)) return value.time_updated
  if (Number.isFinite(value.timeCreated)) return value.timeCreated
  if (Number.isFinite(value.timeUpdated)) return value.timeUpdated
  if (Number.isFinite(value.time?.created)) return value.time.created
  if (Number.isFinite(value.time?.updated)) return value.time.updated
  if (typeof value.time?.created === "string") return new Date(value.time.created).getTime()
  if (typeof value.createdAt === "string") return new Date(value.createdAt).getTime()
  return 0
}

function timeOverlaps(value, range) {
  const created = getTimeMs(value, "time_created")
  const updated = getTimeMs(value, "time_updated")
  return (
    (created >= range.startMs && created < range.endMs) ||
    (updated >= range.startMs && updated < range.endMs)
  )
}

function unwrapResponse(response) {
  if (Array.isArray(response)) return response
  if (Array.isArray(response?.data)) return response.data
  if (Array.isArray(response?.result)) return response.result
  return response?.data || response
}

function parseJson(value) {
  if (!value || typeof value !== "string") return value
  try {
    return JSON.parse(value)
  } catch {
    return null
  }
}

function safeStringify(value) {
  if (typeof value === "string") return value
  try {
    return JSON.stringify(value)
  } catch {
    return String(value)
  }
}

function truncate(value, limit = DEFAULT_TEXT_LIMIT) {
  if (!value || value.length <= limit) return value || ""
  return `${value.slice(0, limit)}\n[truncated ${value.length - limit} chars]`
}

function groupBy(items, keyFn) {
  const groups = new Map()
  for (const item of items) {
    const key = keyFn(item)
    const group = groups.get(key) || []
    group.push(item)
    groups.set(key, group)
  }
  return groups
}

function expandHome(path) {
  if (path === "~") return os.homedir()
  if (path.startsWith("~/")) return `${os.homedir()}${path.slice(1)}`
  return path
}

function sqlString(value) {
  return `'${String(value).replaceAll("'", "''")}'`
}
