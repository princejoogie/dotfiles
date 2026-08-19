#!/usr/bin/env -S npx tsx
/**
 * Identify the CURRENT coding session, so its transcript can be read (via get-session-transcript.ts).
 * This is the single entry point; how it behaves depends on the harness:
 *
 *   - Claude Code exposes the session id in the environment, so a plain call resolves immediately:
 *       find-current-session.ts            → prints `session: <id>`
 *
 *   - OpenCode V2 resolves the active session for the cwd through its authenticated service API. If
 *     that is ambiguous, and on Pi, it's a two-call dance the script walks you through. The first
 *     call MARKS this session — it prints a unique token (which the harness records as this
 *     command's result in the transcript) and the exact command to run next:
 *       find-current-session.ts            → "session marked; now run: … --marker <token>"
 *       find-current-session.ts --marker <token>   → prints `session: <id>` (the one whose
 *                                                     transcript contains the token)
 *
 * Run the mark call as its own command so its result is flushed to disk before the lookup reads.
 *
 * Output of the lookup:
 *   - RESOLVED: `session: <id>` — a unique marker hit, or a single session for the cwd.
 *   - CANDIDATES: up to N (default 5) most-recent sessions for the cwd with signifiers (title,
 *     recency, model), labelled to be VALIDATED — printed when the marker matched none (e.g. not yet
 *     flushed) so you can retry or pick by hand. `--limit` widens the net.
 *
 * Marker mechanism (OpenCode via session exports; Pi via the cwd-derived session dir): session
 * lists are recency-sorted, so the current session is only *near* the top, never provably the top
 * when sessions share a cwd — the marker (recorded by the mark call's own output) is what makes the
 * match deterministic. Verified that shell-command output is persisted on Claude Code, OpenCode, Pi.
 */

import { execFileSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { homedir } from 'node:os';
import { join, resolve } from 'node:path';
import process from 'node:process';
import { readOpenCodeApi, type OpenCodeMessage } from './opencode-v2.ts';

type Harness = 'claude' | 'opencode' | 'pi';

interface Candidate {
  id: string;
  title?: string;
  updated?: number;
  created?: number;
  model?: string;
}

interface Result {
  resolved?: string;
  how?: string;
  candidates?: Candidate[];
}

interface Args {
  marker?: string;
  cwd: string;
  limit: number;
  json: boolean;
}

function die(message: string): never {
  console.error(`error: ${message}`);
  return process.exit(1);
}

function expandTilde(p: string): string {
  return p.startsWith('~') ? join(homedir(), p.slice(1)) : p;
}

function parseArgs(): Args {
  const argv = process.argv.slice(2);
  const out: Args = { cwd: process.cwd(), limit: 5, json: false };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = (): string => (i + 1 < argv.length ? argv[++i] : die(`${arg} requires a value`));
    if (arg === '--marker') out.marker = next();
    else if (arg === '--cwd') out.cwd = resolve(next());
    else if (arg === '--limit') out.limit = Math.max(1, Number(next()) || 5);
    else if (arg === '--json') out.json = true;
    else die(`unexpected argument: ${arg}`);
  }
  return out;
}

function detectHarness(): Harness {
  if (process.env.CLAUDE_CODE_SESSION_ID || process.env.CLAUDECODE) return 'claude';
  if (process.env.OPENCODE_TERMINAL) return 'opencode';
  if (process.env.PI_CODING_AGENT || existsSync(join(homedir(), '.pi', 'agent', 'sessions'))) return 'pi';
  return die('could not detect the harness — run this inside a Claude Code, OpenCode, or Pi session');
}

// ── Claude Code ── exact: the session id is in the environment.
function claudeCurrent(_args: Args): Result {
  const id = process.env.CLAUDE_CODE_SESSION_ID;
  if (id) return { resolved: id, how: 'CLAUDE_CODE_SESSION_ID' };
  return die('CLAUDE_CODE_SESSION_ID is not set — cannot identify the current Claude session');
}

// ── OpenCode V2 ── discover and authenticate through `opencode2 api`.
interface OpenCodeSession {
  id: string;
  title?: string;
  model?: { id?: string };
  time?: { created?: number; updated?: number };
}

function opencodeCandidates(cwd: string, limit: number): Candidate[] {
  const response = readOpenCodeApi<{ data?: OpenCodeSession[] }>(
    `/api/session?directory=${encodeURIComponent(cwd)}&limit=${limit}&order=desc`,
  );
  if (!Array.isArray(response.data)) return die('OpenCode session API returned an unsupported response');
  return response.data.map((session) => ({
    id: session.id,
    title: session.title,
    updated: session.time?.updated,
    created: session.time?.created,
    model: session.model?.id,
  }));
}

function opencodeActiveIds(): Set<string> {
  const response = readOpenCodeApi<{ data?: Record<string, unknown> }>('/api/session/active');
  return new Set(Object.keys(response.data ?? {}));
}

function opencodeMarkerHits(ids: string[], marker: string): string[] {
  const hits: string[] = [];
  for (const id of ids) {
    try {
      const response = readOpenCodeApi<{ data?: { messages?: OpenCodeMessage[] } }>(`/api/session/${id}/export`);
      if (JSON.stringify(response.data?.messages ?? []).includes(marker)) hits.push(id);
    } catch {
      /* skip */
    }
  }
  return hits;
}

function opencodeCurrent(args: Args): Result {
  let all: Candidate[];
  let active: Set<string>;
  try {
    all = opencodeCandidates(args.cwd, Math.max(50, args.limit));
    active = opencodeActiveIds();
  } catch (err) {
    return die(`could not query the OpenCode V2 service: ${(err as Error).message}`);
  }
  if (all.length === 0) return die('no OpenCode sessions found for this directory');
  const activeHere = all.filter((candidate) => active.has(candidate.id));
  if (activeHere.length === 1) return { resolved: activeHere[0].id, how: 'active session for cwd' };
  if (all.length === 1) return { resolved: all[0].id, how: 'single candidate for cwd' };
  const pool = (activeHere.length > 0 ? activeHere : all).slice(0, args.limit);
  if (args.marker) {
    const hits = opencodeMarkerHits(pool.map((c) => c.id), args.marker);
    if (hits.length === 1) return { resolved: hits[0], how: 'unique marker match' };
  }
  return { candidates: pool };
}

// ── Pi ── cwd-derived session dir (badlogic/pi-mono session-manager.ts); marker via file grep.
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

function piCurrent(args: Args): Result {
  const dir = piSessionDir(args.cwd);
  if (!existsSync(dir)) return die(`no Pi session directory for this cwd: ${dir}`);
  const files = readdirSync(dir)
    .filter((f) => f.endsWith('.jsonl'))
    .map((f) => ({ id: f.replace(/\.jsonl$/, ''), path: join(dir, f), updated: statSync(join(dir, f)).mtimeMs }))
    .sort((a, b) => b.updated - a.updated);
  if (files.length === 0) return die(`no Pi session files in ${dir}`);
  if (files.length === 1) return { resolved: files[0].id, how: 'single candidate for cwd' };
  const pool = files.slice(0, args.limit);
  if (args.marker) {
    const hits = pool.filter((x) => {
      try {
        return readFileSync(x.path, 'utf8').includes(args.marker!);
      } catch {
        return false;
      }
    });
    if (hits.length === 1) return { resolved: hits[0].id, how: 'unique marker match' };
  }
  return { candidates: pool.map((x) => ({ id: x.id, updated: x.updated })) };
}

// ── Output ──
function rel(ms: number | undefined): string {
  if (!ms) return '?';
  const secs = Math.max(0, Math.round((Date.now() - ms) / 1000));
  if (secs < 90) return `${secs}s ago`;
  if (secs < 5400) return `${Math.round(secs / 60)}m ago`;
  if (secs < 129600) return `${Math.round(secs / 3600)}h ago`;
  return `${Math.round(secs / 86400)}d ago`;
}

function report(harness: Harness, result: Result, args: Args): void {
  if (args.json) {
    console.log(JSON.stringify({ harness, ...result }, null, 2));
    return;
  }
  if (result.resolved) {
    console.log(`session: ${result.resolved}  (${result.how})`);
    console.log(`next: get-session-transcript.ts ${result.resolved}`);
    return;
  }
  const candidates = result.candidates ?? [];
  console.log(`UNRESOLVED — the ${candidates.length} most recent CANDIDATE sessions for this directory (most recent first).`);
  console.log('These are candidates, NOT a confirmed match — validate which one is the current session before using it.\n');
  candidates.forEach((c, i) => {
    console.log(`${i + 1}. ${c.id}`);
    if (c.title) console.log(`   title:   ${c.title}`);
    console.log(`   updated: ${rel(c.updated)}${c.created ? `   created: ${rel(c.created)}` : ''}`);
    if (c.model) console.log(`   model:   ${c.model}`);
    console.log('');
  });
  console.log('your marker matched none of these. Validate the current session:');
  console.log('  1. if you just marked the session, its record may not be flushed yet — wait a moment and re-run the');
  console.log('     same --marker lookup;');
  console.log('  2. otherwise read a candidate via `get-session-transcript.ts <id>` and confirm its latest turns are your own;');
  console.log('  3. recency and title are weak hints only — never assume the top candidate is yours.');
}

/** Non-Claude first call: stamp a marker into the transcript and tell the caller how to look it up. */
function markSession(args: Args): void {
  const marker = `wl-session-marker-${randomUUID()}`;
  if (args.json) {
    console.log(JSON.stringify({ marked: true, marker, next: `find-current-session.ts --marker ${marker}` }, null, 2));
    return;
  }
  console.log('This session has been marked.');
  console.log(`marker: ${marker}`);
  console.log('\nNow locate this session by running this again with that marker:');
  console.log(`  find-current-session.ts --marker ${marker}`);
}

function main(): void {
  const args = parseArgs();
  const harness = detectHarness();
  // Claude exposes the session id — resolve immediately, no marking needed.
  if (harness === 'claude') {
    report(harness, claudeCurrent(args), args);
    return;
  }
  if (harness === 'opencode') {
    const result = opencodeCurrent(args);
    if (result.resolved || args.marker) report(harness, result, args);
    else markSession(args);
    return;
  }
  // Pi: first call (no marker) marks the session; second call (--marker) looks it up.
  if (!args.marker) {
    markSession(args);
    return;
  }
  report(harness, piCurrent(args), args);
}

main();
