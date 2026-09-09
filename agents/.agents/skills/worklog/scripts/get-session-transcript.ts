#!/usr/bin/env -S npx tsx
/**
 * Get a session's transcript — pass 2 of 2. Given a session id (from find-current-session.ts),
 * produce its transcript for extraction. By harness:
 *   - OpenCode 1: reads timestamped messages and parts from its local SQLite store.
 *   - OpenCode 2: exports projected messages through its authenticated service API.
 *   - Claude Code: locates the on-disk JSONL under ~/.claude/projects.
 *   - Pi: resolves the id to its JSONL under the cwd's session directory.
 *
 * Usage:
 *   .../scripts/get-session-transcript.ts <session-id> [--cwd PATH] [--since ISO] [--until ISO] [--output PATH]
 *
 * With --since (and/or --until) it produces a SLICE of the transcript — only the records in that
 * instant range — and reports the `through` instant of the last record in the slice.
 * That is what makes an appended worklog entry cheap: each epoch of the session is read once,
 * rather than the whole transcript being re-read on every regeneration. The `through` it prints is
 * the bookmark to hand to append-entry.ts.
 *
 * Output: with --output, writes the transcript or slice to PATH (creating its parent directory) and
 * prints PATH. Sliced file output additionally prints `records:` and `through:` metadata. Without
 * --output, JSONL is written to stdout; sliced metadata goes to stderr, keeping stdout redirectable.
 *
 * This replaces the old implicit tmpdir() file output.
 */

import { execFileSync, spawn } from 'node:child_process';
import { once } from 'node:events';
import { copyFileSync, createReadStream, createWriteStream, existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import process from 'node:process';
import { createInterface } from 'node:readline';
import { projectOpenCodeMessages, readOpenCodeApi, sliceOpenCodeRecords, type OpenCodeMessage } from './opencode-v2.ts';
import { isOpenCodeV1 } from './opencode-version.ts';

type Harness = 'claude' | 'opencode' | 'pi';

interface Args {
  id: string;
  cwd: string;
  since?: string;
  until?: string;
  output?: string;
}

function die(message: string): never {
  console.error(`error: ${message}`);
  return process.exit(1);
}

function expandTilde(p: string): string {
  return p.startsWith('~') ? join(homedir(), p.slice(1)) : p;
}

function parseInstant(raw: string, flag: string): string {
  if (Number.isNaN(Date.parse(raw))) {
    die(`${flag} must be an ISO-8601 instant (e.g. 2026-06-29T06:41:22.918Z), got: ${raw}`);
  }
  return raw;
}

function parseArgs(): Args {
  const argv = process.argv.slice(2);
  let id = '';
  let cwd = process.cwd();
  let since: string | undefined;
  let until: string | undefined;
  let output: string | undefined;
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = (): string => (i + 1 < argv.length ? argv[++i] : die(`${arg} requires a value`));
    if (arg === '--cwd') cwd = resolve(next());
    else if (arg === '--session' || arg === '--id') id = next();
    else if (arg === '--since') since = parseInstant(next(), '--since');
    else if (arg === '--until') until = parseInstant(next(), '--until');
    else if (arg === '--output') output = resolve(next());
    else if (!arg.startsWith('--') && !id) id = arg;
    else die(`unexpected argument: ${arg}`);
  }
  if (!id) die('usage: get-session-transcript.ts <session-id> [--cwd PATH] [--since ISO] [--until ISO] [--output PATH]');
  if (since && until && Date.parse(since) >= Date.parse(until)) {
    die(`--since (${since}) must be earlier than --until (${until})`);
  }
  return { id, cwd, since, until, output };
}

function detectHarness(): Harness {
  if (process.env.CLAUDE_CODE_SESSION_ID || process.env.CLAUDECODE) return 'claude';
  if (process.env.OPENCODE || process.env.OPENCODE_RUN_ID || process.env.OPENCODE_TERMINAL) return 'opencode';
  if (process.env.PI_CODING_AGENT || existsSync(join(homedir(), '.pi', 'agent', 'sessions'))) return 'pi';
  return die('could not detect the harness — run this inside a Claude Code, OpenCode, or Pi session');
}

// ── Claude Code ── transcripts are ~/.claude/projects/<slug>/<id>.jsonl, already on disk.
function claudeTranscript(id: string): string {
  const root = join(homedir(), '.claude', 'projects');
  if (existsSync(root)) {
    for (const slug of readdirSync(root)) {
      const path = join(root, slug, `${id}.jsonl`);
      if (existsSync(path)) return path;
    }
  }
  return die(`no Claude transcript on disk for session ${id}`);
}

// ── OpenCode V1 ── messages and parts are timestamped independently in the local SQLite store.
interface OpenCodeV1Record {
  id: string;
  kind: 'message' | 'part';
  message_id?: string;
  time_created: number;
  data: string;
}

function opencodeDbPath(): string {
  const base = (process.env.OPENCODE_DATA_DIR?.split(',')[0] || join(homedir(), '.local', 'share', 'opencode')).trim();
  return join(base, 'opencode.db');
}

function sqliteString(value: string): string {
  return value.replace(/'/g, "''");
}

function opencodeSessionExists(db: string, id: string): boolean {
  try {
    return execFileSync('sqlite3', [db, `SELECT count(*) FROM session WHERE id='${sqliteString(id)}';`], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
    }).trim() === '1';
  } catch (err) {
    return die(`could not inspect OpenCode session storage at ${db}: ${(err as Error).message}`);
  }
}

async function writeOpenCodeV1Jsonl(
  id: string,
  since: string | undefined,
  until: string | undefined,
  output: NodeJS.WritableStream,
): Promise<{ records: number; through?: string }> {
  const db = opencodeDbPath();
  if (!existsSync(db)) die(`no OpenCode session database at ${db}`);
  if (!opencodeSessionExists(db, id)) die(`no OpenCode session ${id} in ${db}`);

  const session = sqliteString(id);
  const interval = [
    `session_id='${session}'`,
    ...(since ? [`time_created > ${Date.parse(since)}`] : []),
    ...(until ? [`time_created <= ${Date.parse(until)}`] : []),
  ].join(' AND ');
  const query =
    `SELECT json_object('id', id, 'kind', kind, 'message_id', message_id, 'time_created', time_created, 'data', data) ` +
    'FROM (' +
    `SELECT id, 'message' AS kind, NULL AS message_id, time_created, data FROM message WHERE ${interval} ` +
    `UNION ALL SELECT id, 'part' AS kind, message_id, time_created, data FROM part WHERE ${interval}` +
    ') ORDER BY time_created, kind, id;';

  const child = spawn('sqlite3', ['-noheader', db, query], { stdio: ['ignore', 'pipe', 'pipe'] });
  let stderr = '';
  child.stderr.setEncoding('utf8');
  child.stderr.on('data', (chunk: string) => {
    stderr += chunk;
  });
  const exited = new Promise<void>((resolveExit, rejectExit) => {
    child.once('error', rejectExit);
    child.once('close', (code) => {
      if (code === 0) resolveExit();
      else rejectExit(new Error(stderr.trim() || `sqlite3 exited with status ${code}`));
    });
  });

  let records = 0;
  let through: string | undefined;
  try {
    for await (const rawRecord of createInterface({ input: child.stdout })) {
      let record: OpenCodeV1Record;
      try {
        record = JSON.parse(rawRecord) as OpenCodeV1Record;
      } catch {
        die(`OpenCode session ${id} has an unsupported record shape in ${db}`);
      }
      if (!Number.isFinite(record.time_created) || !record.id || (record.kind !== 'message' && record.kind !== 'part')) {
        die(`OpenCode session ${id} has an unsupported record shape in ${db}`);
      }
      const timestamp = new Date(record.time_created).toISOString();
      let data: unknown;
      try {
        data = JSON.parse(record.data);
      } catch {
        die(`OpenCode session ${id} has unreadable ${record.kind} record ${record.id} in ${db}`);
      }
      if (!output.write(`${JSON.stringify({ id: record.id, type: record.kind, ...(record.message_id ? { messageId: record.message_id } : {}), timestamp, data })}\n`)) {
        await once(output, 'drain');
      }
      records++;
      if (through === undefined || timestamp > through) through = timestamp;
    }
    await exited;
  } catch (err) {
    return die(`could not read OpenCode session ${id} from ${db}: ${(err as Error).message}`);
  }
  return { records, through };
}

// ── OpenCode V2 ── projected exports preserve timestamps on individual assistant content items.
async function writeOpenCodeV2Jsonl(
  id: string,
  since: string | undefined,
  until: string | undefined,
  output: NodeJS.WritableStream,
): Promise<{ records: number; through?: string }> {
  try {
    const response = readOpenCodeApi<{ data?: { info?: { id?: string }; messages?: OpenCodeMessage[] } }>(
      `/api/session/${id}/export`,
    );
    if (response.data?.info?.id !== id || !Array.isArray(response.data.messages)) {
      return die(`OpenCode session ${id} export has an unsupported response`);
    }
    const slice = sliceOpenCodeRecords(projectOpenCodeMessages(response.data.messages), since, until);
    const content = slice.records.map((record) => JSON.stringify(record)).join('\n') + (slice.records.length ? '\n' : '');
    if (content && !output.write(content)) await once(output, 'drain');
    return { records: slice.records.length, through: slice.through };
  } catch (err) {
    return die(`could not export OpenCode session ${id}: ${(err as Error).message}`);
  }
}

async function writeOpenCodeTranscript(
  id: string,
  since: string | undefined,
  until: string | undefined,
  output: string | undefined,
): Promise<{ records: number; through?: string }> {
  const destination = output ? fileOutput(output) : process.stdout;
  try {
    return await (isOpenCodeV1() ? writeOpenCodeV1Jsonl : writeOpenCodeV2Jsonl)(id, since, until, destination);
  } finally {
    if (output) {
      destination.end();
      await once(destination, 'finish');
    }
  }
}

// ── Pi ── resolve the id (filename stem, or a path) to its JSONL under the cwd's session dir.
function piEncodeCwd(cwd: string): string {
  return `--${cwd.replace(/^[/\\]/, '').replace(/[/\\:]/g, '-')}--`;
}

function piSessionDir(cwd: string): string {
  const override = process.env.PI_CODING_AGENT_SESSION_DIR?.trim();
  if (override) {
    const base = expandTilde(override);
    const sub = join(base, piEncodeCwd(cwd));
    return existsSync(sub) ? sub : base;
  }
  const agentDir = expandTilde(process.env.PI_CODING_AGENT_DIR?.trim() || join(homedir(), '.pi', 'agent'));
  return join(agentDir, 'sessions', piEncodeCwd(cwd));
}

function piTranscript(id: string, cwd: string): string {
  if (existsSync(id) && statSync(id).isFile()) return id; // an explicit path was passed
  const dir = piSessionDir(cwd);
  const direct = join(dir, id.endsWith('.jsonl') ? id : `${id}.jsonl`);
  if (existsSync(direct)) return direct;
  if (existsSync(dir)) {
    const hit = readdirSync(dir).find((f) => f.endsWith('.jsonl') && f.includes(id));
    if (hit) return join(dir, hit);
  }
  return die(`no Pi transcript for ${id} under ${dir}`);
}

// ── Slicing ── keep only the records in an instant range, so an appended entry reads one epoch.
//
// The bookmark is exclusive at the `--since` end (`t > since`) and inclusive at `--until`, so
// consecutive slices tile the session without re-reading or skipping a record.

/** Native timestamped JSONL records carry an ISO-8601 `timestamp`. */
function sliceTimestampedJsonl(path: string, since: string | undefined, until: string | undefined): { lines: string[]; through?: string } {
  const from = since ? Date.parse(since) : Number.NEGATIVE_INFINITY;
  const to = until ? Date.parse(until) : Number.POSITIVE_INFINITY;
  const lines: string[] = [];
  let through: string | undefined;
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    if (!line.trim()) continue;
    let stamp: string | undefined;
    try {
      stamp = (JSON.parse(line) as { timestamp?: string }).timestamp;
    } catch {
      continue; // a partially-flushed trailing line; skip it rather than fail the slice
    }
    // Records with no timestamp (session metadata) can't be placed in time, so they stay out of
    // every slice but the first, which has no lower bound to exclude them.
    if (!stamp) {
      if (since === undefined) lines.push(line);
      continue;
    }
    const t = Date.parse(stamp);
    if (Number.isNaN(t) || t <= from || t > to) continue;
    lines.push(line);
    if (through === undefined || t > Date.parse(through)) through = stamp;
  }
  return { lines, through };
}

function fileOutput(path: string) {
  mkdirSync(dirname(path), { recursive: true });
  return createWriteStream(path, { encoding: 'utf8' });
}

async function streamTranscript(path: string): Promise<void> {
  const input = createReadStream(path);
  input.pipe(process.stdout, { end: false });
  await once(input, 'end');
}

async function writeNativeTranscript(source: string, output: string | undefined): Promise<void> {
  if (output) {
    mkdirSync(dirname(output), { recursive: true });
    if (resolve(source) !== output) copyFileSync(source, output);
    return;
  }
  await streamTranscript(source);
}

function reportSlice(output: string | undefined, records: number, through: string | undefined, since: string | undefined): void {
  const report = output ? console.log : console.error;
  if (output) console.log(output);
  report(`records: ${records}`);
  report(`through: ${records === 0 ? since ?? '' : through}`);
}

async function main(): Promise<void> {
  const args = parseArgs();
  const harness = detectHarness();
  const slicing = args.since !== undefined || args.until !== undefined;

  if (!slicing) {
    switch (harness) {
      case 'claude':
        await writeNativeTranscript(claudeTranscript(args.id), args.output);
        break;
      case 'opencode':
        await writeOpenCodeTranscript(args.id, undefined, undefined, args.output);
        break;
      case 'pi':
        await writeNativeTranscript(piTranscript(args.id, args.cwd), args.output);
        break;
    }
    if (args.output) console.log(args.output);
    return;
  }

  let slice: { records: number; through?: string };
  switch (harness) {
    case 'claude': {
      const { lines, through } = sliceTimestampedJsonl(claudeTranscript(args.id), args.since, args.until);
      const content = lines.length > 0 ? `${lines.join('\n')}\n` : '';
      if (args.output) {
        mkdirSync(dirname(args.output), { recursive: true });
        writeFileSync(args.output, content);
      } else {
        process.stdout.write(content);
      }
      slice = { records: lines.length, through };
      break;
    }
    case 'opencode':
      slice = await writeOpenCodeTranscript(args.id, args.since, args.until, args.output);
      break;
    case 'pi': {
      const { lines, through } = sliceTimestampedJsonl(piTranscript(args.id, args.cwd), args.since, args.until);
      const content = lines.length > 0 ? `${lines.join('\n')}\n` : '';
      if (args.output) {
        mkdirSync(dirname(args.output), { recursive: true });
        writeFileSync(args.output, content);
      } else {
        process.stdout.write(content);
      }
      slice = { records: lines.length, through };
      break;
    }
  }
  const { records, through } = slice;
  reportSlice(args.output, records, through, args.since);
}

void main();
