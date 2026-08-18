#!/usr/bin/env -S npx tsx
/**
 * Validate one worklog against the schema — frontmatter shape, plus the structural invariants the
 * append-only format depends on.
 *
 * Usage:
 *   .../scripts/validate-worklog.ts <path>
 *
 * It checks the ONE worklog it is given, deliberately: the store is shared, and worklogs written
 * earlier (or by someone else) are not this run's business. Sweeping the whole store would report
 * other people's problems to whoever happens to append next, which is noise they can't act on.
 *
 * Worth having because v2 moves load-bearing state into the frontmatter: a malformed or missing
 * bookmark does not fail loudly, it silently re-reads or skips an epoch. The entry-coverage check is
 * the one that matters most — an entry whose timestamp runs past every bookmark is an entry that was
 * not produced from a slice of the session record, which is the failure the whole artifact exists to
 * prevent.
 *
 * Exits non-zero if the worklog fails.
 */

import { readFileSync } from 'node:fs';
import { relative, resolve } from 'node:path';
import process from 'node:process';
import { isInstant, parseWorklog } from './worklog-file.ts';

function die(message: string): never {
  console.error(`error: ${message}`);
  return process.exit(1);
}

/** `## 2026-06-29T06:41Z — review round 1` — an entry heading, as append-entry.ts writes them. */
const ENTRY_HEADING = /^## (\d{4}-\d{2}-\d{2}T\d{2}:\d{2}Z)\s+—\s+(.+)$/gm;

function checkV2(text: string, problems: string[]): void {
  const { frontmatter, body } = parseWorklog(text);

  if (frontmatter.sources.length === 0) {
    problems.push('`sources` is empty — a worklog must record which session(s) it was extracted from');
  }
  frontmatter.sources.forEach((s, i) => {
    if (!s.harness) problems.push(`sources[${i}]: missing \`harness\``);
    if (!s.session) problems.push(`sources[${i}]: missing \`session\``);
    if (!s.through) problems.push(`sources[${i}]: missing \`through\` bookmark`);
    else if (!isInstant(s.through)) problems.push(`sources[${i}]: \`through\` is not an ISO-8601 UTC instant: ${s.through}`);
  });
  if (frontmatter.date && !/^\d{4}-\d{2}-\d{2}$/.test(frontmatter.date)) {
    problems.push(`\`date\` should be YYYY-MM-DD, got: ${frontmatter.date}`);
  }

  if (!/^## Starting point\s*$/m.test(body)) problems.push('missing the `## Starting point` section');
  if (/^## Final state\s*$/m.test(body)) {
    problems.push('has a `## Final state` section — v2 records decisions as they happen, with no rewritten summary');
  }

  // Every entry must sit at or before a bookmark: an entry past every `through` was not produced
  // from a slice of the record.
  const latest = frontmatter.sources
    .map((s) => Date.parse(s.through))
    .filter((t) => !Number.isNaN(t))
    .reduce((a, b) => Math.max(a, b), Number.NEGATIVE_INFINITY);
  for (const match of body.matchAll(ENTRY_HEADING)) {
    const at = Date.parse(match[1]);
    // Headings are minute-precision, so allow the minute they were truncated from.
    if (at - 60_000 > latest) {
      problems.push(`entry "${match[1]} — ${match[2]}" is past every \`sources\` bookmark — it was not appended from a slice`);
    }
  }
}

function main(): void {
  const args = process.argv.slice(2);
  if (args.some((a) => a === '-h' || a === '--help')) {
    console.log('usage: validate-worklog.ts <path>');
    return;
  }
  if (args.length !== 1) {
    die('usage: validate-worklog.ts <path> — pass the one worklog to check');
  }

  const path = resolve(args[0]);
  const name = relative(process.cwd(), path);
  const problems: string[] = [];
  try {
    const text = readFileSync(path, 'utf8');
    const { frontmatter } = parseWorklog(text);
    // The version field arrived with v2, so an absent one means v1 — which is every worklog
    // written before it existed, and saves stamping an existing corpus to say so.
    const version = frontmatter.worklog ?? 1;
    if (version === 2) {
      checkV2(text, problems);
    } else if (version !== 1) {
      problems.push(`unknown \`worklog\` version: ${version} (expected 1 or 2)`);
    }
    // v1 is the pre-append-only whole-document format. Nothing here polices it beyond parsing:
    // its rules are whatever they were when it was written, and it is never appended to.
  } catch (err) {
    problems.push((err as Error).message);
  }

  if (problems.length > 0) {
    console.error(`FAIL ${name}`);
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }
  console.log(`OK — ${name}`);
}

main();
