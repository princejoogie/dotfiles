#!/usr/bin/env -S npx tsx
/**
 * Get a session's transcript as a readable file on disk — pass 2 of 2. Given a session id (from
 * find-current-session.ts), produce its transcript and print the file path, which a sub-agent then
 * reads to extract the worklog. By harness:
 *   - OpenCode: runs `opencode export <id>` to a temp JSON file and prints that path.
 *   - Claude Code: locates the on-disk JSONL under ~/.claude/projects and prints it.
 *   - Pi: resolves the id to its JSONL under the cwd's session directory and prints it.
 *
 * Usage:
 *   .../scripts/get-session-transcript.ts <session-id> [--cwd PATH]
 *
 * Prints the transcript path on stdout (nothing else), so the caller can use it directly.
 */

import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import process from 'node:process';

type Harness = 'claude' | 'opencode' | 'pi';

interface Args {
  id: string;
  cwd: string;
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
  let id = '';
  let cwd = process.cwd();
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = (): string => (i + 1 < argv.length ? argv[++i] : die(`${arg} requires a value`));
    if (arg === '--cwd') cwd = resolve(next());
    else if (arg === '--session' || arg === '--id') id = next();
    else if (!arg.startsWith('--') && !id) id = arg;
    else die(`unexpected argument: ${arg}`);
  }
  if (!id) die('usage: get-session-transcript.ts <session-id> [--cwd PATH]');
  return { id, cwd };
}

function detectHarness(): Harness {
  if (process.env.CLAUDE_CODE_SESSION_ID || process.env.CLAUDECODE) return 'claude';
  if (process.env.OPENCODE || process.env.OPENCODE_RUN_ID) return 'opencode';
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

// ── OpenCode ── export the SQLite-stored session to a stable temp file.
function opencodeTranscript(id: string): string {
  const out = join(tmpdir(), `worklog-session-${id}.json`);
  try {
    const data = execFileSync('opencode', ['export', id], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
    writeFileSync(out, data);
  } catch (err) {
    return die(`\`opencode export ${id}\` failed: ${(err as Error).message}`);
  }
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

function main(): void {
  const args = parseArgs();
  const harness = detectHarness();
  const path =
    harness === 'claude'
      ? claudeTranscript(args.id)
      : harness === 'opencode'
        ? opencodeTranscript(args.id)
        : piTranscript(args.id, args.cwd);
  console.log(path);
}

main();
