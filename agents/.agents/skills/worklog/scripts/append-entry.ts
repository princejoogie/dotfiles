#!/usr/bin/env -S npx tsx
/**
 * Append one epoch's entry to a worklog and advance its bookmark — as a single operation.
 *
 * Usage:
 *   .../scripts/append-entry.ts --worklog .worklogs/<slug>.md --entry <file> \
 *     --session <id> --through <ISO> --label "<short locator>" [--harness claude-code]
 *
 * The two halves are one command on purpose. If the bookmark advanced but the entry did not land,
 * that span of the session would never be read again — and in an append-only worklog there is no
 * later regeneration to catch it. So both are written together, via a temp file and a rename.
 *
 * Passing the entry as a FILE, rather than having the extracting sub-agent write into the worklog
 * itself, is also deliberate: the sub-agent never holds the worklog, so it cannot edit entries that
 * are already there. Append-only stops being a rule an agent has to keep and becomes a property of
 * how the task runs.
 */

import { readFileSync, renameSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import process from 'node:process';
import { formatWorklog, isInstant, parseWorklog, type Source } from './worklog-file.ts';

interface Args {
  worklog: string;
  entry: string;
  session: string;
  through: string;
  label: string;
  harness: string;
}

function die(message: string): never {
  console.error(`error: ${message}`);
  return process.exit(1);
}

function parseArgs(): Args {
  const argv = process.argv.slice(2);
  const out: Partial<Args> = { harness: 'claude-code' };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = (): string => (i + 1 < argv.length ? argv[++i] : die(`${arg} requires a value`));
    if (arg === '--worklog') out.worklog = resolve(next());
    else if (arg === '--entry') out.entry = resolve(next());
    else if (arg === '--session') out.session = next();
    else if (arg === '--through') out.through = next();
    else if (arg === '--label') out.label = next();
    else if (arg === '--harness') out.harness = next();
    else die(`unexpected argument: ${arg}`);
  }
  for (const key of ['worklog', 'entry', 'session', 'through', 'label'] as const) {
    if (!out[key]) die(`--${key} is required`);
  }
  if (!isInstant(out.through!)) {
    die(`--through must be an ISO-8601 UTC instant (e.g. 2026-06-29T06:41:22.918Z), got: ${out.through}`);
  }
  return out as Args;
}

/** `2026-06-29T06:41:22.918Z` → `2026-06-29T06:41Z` — minute precision is enough to locate an entry. */
function headingStamp(instant: string): string {
  return `${instant.slice(0, 16)}Z`;
}

function main(): void {
  const args = parseArgs();

  let file;
  try {
    file = parseWorklog(readFileSync(args.worklog, 'utf8'));
  } catch (err) {
    return die(`cannot read ${args.worklog}: ${(err as Error).message}`);
  }

  // An absent `worklog` field predates the version field, so it means v1.
  const version = file.frontmatter.worklog ?? 1;
  if (version !== 2) {
    die(
      `${args.worklog} is a v${version} worklog, which is not appended to.\n` +
        '  v1 worklogs are whole-document records; scaffold a new one with new-worklog.ts.',
    );
  }

  const entry = readFileSync(args.entry, 'utf8').trim();
  if (!entry) die(`${args.entry} is empty — nothing to append`);

  const source = file.frontmatter.sources.find((s: Source) => s.session === args.session);
  if (!source) {
    die(
      `session ${args.session} is not in this worklog's \`sources\`.\n` +
        `  known: ${file.frontmatter.sources.map((s) => s.session).join(', ') || '(none)'}\n` +
        '  A new session working the same branch should be added to `sources` first.',
    );
  }
  if (Date.parse(args.through) < Date.parse(source.through)) {
    die(
      `--through (${args.through}) is behind this session's bookmark (${source.through}).\n` +
        '  That would re-record an epoch already in the worklog. Slice from the bookmark forward.',
    );
  }

  const heading = `## ${headingStamp(args.through)} — ${args.label}`;
  const body = `${file.body.replace(/\s*$/, '')}\n\n${heading}\n\n${entry}\n`;
  source.through = args.through;

  const temp = `${args.worklog}.tmp`;
  writeFileSync(temp, formatWorklog({ frontmatter: file.frontmatter, body }));
  renameSync(temp, args.worklog);

  console.log(`appended to ${args.worklog}`);
  console.log(`  ${heading}`);
  console.log(`  bookmark for ${args.session} advanced to ${args.through}`);
  console.log(`\nnext: validate-worklog.ts ${args.worklog}, then commit the worklog with the change.`);
}

main();
