#!/usr/bin/env -S npx tsx
/**
 * Get a session's transcript as a readable file on disk — pass 2 of 2. Given a session id (from
 * find-current-session.ts), produce its transcript and print the file path, which a sub-agent then
 * reads to extract the worklog. By harness:
 *   - OpenCode: exports projected messages through its authenticated V2 service API.
 *   - Claude Code: locates the on-disk JSONL under ~/.claude/projects and prints it.
 *   - Pi: resolves the id to its JSONL under the cwd's session directory and prints it.
 *
 * Usage:
 *   .../scripts/get-session-transcript.ts <session-id> [--cwd PATH] [--since ISO] [--until ISO]
 *
 * With --since (and/or --until) it writes a SLICE of the transcript — only the records in that
 * instant range — and prints its path plus the `through` instant of the last record in the slice.
 * That is what makes an appended worklog entry cheap: each epoch of the session is read once,
 * rather than the whole transcript being re-read on every regeneration. The `through` it prints is
 * the bookmark to hand to append-entry.ts.
 *
 * Slicing is implemented for Claude Code and OpenCode. On any other harness it fails rather than
 * quietly handing back the whole transcript, which would silently reintroduce the cost slicing removes.
 *
 * Output — the transcript (or slice) path on the first line, so a caller can still take line 1
 * directly; when slicing, a `through:` and a `records:` line follow.
 */

import { existsSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import process from 'node:process';
import { projectOpenCodeMessages, readOpenCodeApi, sliceOpenCodeRecords, type OpenCodeMessage } from './opencode-v2.ts';

type Harness = 'claude' | 'opencode' | 'pi';

interface Args {
  id: string;
  cwd: string;
  since?: string;
  until?: string;
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
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = (): string => (i + 1 < argv.length ? argv[++i] : die(`${arg} requires a value`));
    if (arg === '--cwd') cwd = resolve(next());
    else if (arg === '--session' || arg === '--id') id = next();
    else if (arg === '--since') since = parseInstant(next(), '--since');
    else if (arg === '--until') until = parseInstant(next(), '--until');
    else if (!arg.startsWith('--') && !id) id = arg;
    else die(`unexpected argument: ${arg}`);
  }
  if (!id) die('usage: get-session-transcript.ts <session-id> [--cwd PATH] [--since ISO] [--until ISO]');
  if (since && until && Date.parse(since) >= Date.parse(until)) {
    die(`--since (${since}) must be earlier than --until (${until})`);
  }
  return { id, cwd, since, until };
}

function detectHarness(): Harness {
  if (process.env.CLAUDE_CODE_SESSION_ID || process.env.CLAUDECODE) return 'claude';
  if (process.env.OPENCODE_TERMINAL) return 'opencode';
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

// ── OpenCode V2 ── projected exports preserve timestamps on individual assistant content items.
function writeOpenCodeJsonl(
  id: string,
  since: string | undefined,
  until: string | undefined,
  out: string,
): { records: number; through?: string } {
  try {
    const response = readOpenCodeApi<{ data?: { info?: { id?: string }; messages?: OpenCodeMessage[] } }>(
      `/api/session/${id}/export`,
    );
    if (response.data?.info?.id !== id || !Array.isArray(response.data.messages)) {
      return die(`OpenCode session ${id} export has an unsupported response`);
    }
    const slice = sliceOpenCodeRecords(projectOpenCodeMessages(response.data.messages), since, until);
    writeFileSync(out, slice.records.map((record) => JSON.stringify(record)).join('\n') + (slice.records.length ? '\n' : ''));
    return { records: slice.records.length, through: slice.through };
  } catch (err) {
    return die(`could not export OpenCode session ${id}: ${(err as Error).message}`);
  }
}

function opencodeTranscript(id: string): string {
  const out = join(tmpdir(), `worklog-session-${id}.jsonl`);
  writeOpenCodeJsonl(id, undefined, undefined, out);
  return out;
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

/** Claude Code writes one JSON record per line, each carrying an ISO-8601 `timestamp`. */
function sliceClaudeJsonl(path: string, since: string | undefined, until: string | undefined): { lines: string[]; through?: string } {
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

function main(): void {
  const args = parseArgs();
  const harness = detectHarness();
  const slicing = args.since !== undefined || args.until !== undefined;

  if (!slicing) {
    let path: string;
    switch (harness) {
      case 'claude':
        path = claudeTranscript(args.id);
        break;
      case 'opencode':
        path = opencodeTranscript(args.id);
        break;
      case 'pi':
        path = piTranscript(args.id, args.cwd);
        break;
    }
    console.log(path);
    return;
  }

  const stamp = (args.since ?? 'start').replace(/[:.]/g, '-');
  const out = join(tmpdir(), `worklog-slice-${args.id}-${stamp}.jsonl`);
  let slice: { records: number; through?: string };
  switch (harness) {
    case 'claude': {
      const { lines, through } = sliceClaudeJsonl(claudeTranscript(args.id), args.since, args.until);
      writeFileSync(out, lines.length > 0 ? `${lines.join('\n')}\n` : '');
      slice = { records: lines.length, through };
      break;
    }
    case 'opencode':
      slice = writeOpenCodeJsonl(args.id, args.since, args.until, out);
      break;
    case 'pi':
      die(
        'slicing (--since/--until) is implemented for Claude Code and OpenCode, not Pi.\n' +
          '  Falling back to the whole transcript would silently undo the saving slicing exists for,\n' +
          '  so this stops here. Add a Pi adapter, or run the worklog on Claude Code.',
      );
  }
  const { records, through } = slice;

  console.log(out);
  console.log(`records: ${records}`);
  if (records === 0) {
    console.log(`through: ${args.since ?? ''}`);
    console.log(
      '\nNOTHING NEW — no records in this range, so this epoch is empty.' +
        '\nDo not append an entry and do not move the bookmark; there is nothing to record yet.',
    );
    return;
  }
  console.log(`through: ${through}`);
  console.log(`\nnext: extract this slice into an entry, then append it with:\n  append-entry.ts --worklog <path> --entry <file> --session ${args.id} --through ${through} --label "<short locator>"`);
}

main();
