#!/usr/bin/env -S npx tsx
/**
 * Scaffold a new per-PR worklog file in the repo's worklog store (.worklogs/).
 *
 * Usage:
 *   .../scripts/new-worklog.ts --session <id> [--related URL]... [--title "..."] [--dir PATH]
 *
 * Picks a random, human-readable, collision-checked filename (Changesets-style, e.g.
 * brave-otter-listens.md) so concurrent PRs in the monorepo never clash on the same file, creates
 * the worklog store if absent, writes the v2 template (with any --related links and --title
 * pre-filled), and prints the path. Run once per PR. Pass --related once per link (the ticket, the
 * PR, related docs) as a full URL.
 *
 * --session (from find-current-session.ts) seeds the `sources` bookmark, which is what lets later
 * entries be appended from a slice of the record rather than a re-read of the whole transcript. It
 * is seeded at epoch zero — nothing consumed — so the first entry covers the session from its start.
 *
 * The store defaults to <repo-root>/.worklogs, located via `git rev-parse --show-toplevel`;
 * outside a git repo it errors unless you pass --dir.
 */

import { execFileSync } from 'node:child_process';
import { mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import process from 'node:process';

const ADJECTIVES = [
  'brave',
  'calm',
  'clever',
  'curious',
  'eager',
  'gentle',
  'happy',
  'honest',
  'humble',
  'keen',
  'lucky',
  'mellow',
  'nimble',
  'patient',
  'plucky',
  'quiet',
  'rapid',
  'sly',
  'spry',
  'steady',
  'swift',
  'tidy',
  'vivid',
  'warm',
  'wise',
  'witty',
  'zesty',
];
const NOUNS = [
  'otter',
  'falcon',
  'badger',
  'heron',
  'lynx',
  'magpie',
  'marten',
  'osprey',
  'panda',
  'puffin',
  'raven',
  'salmon',
  'sparrow',
  'tapir',
  'turtle',
  'walrus',
  'weasel',
  'wombat',
  'yak',
  'zebra',
  'beetle',
  'cricket',
  'gecko',
  'newt',
  'urchin',
  'whelk',
];
const VERBS = [
  'ambles',
  'bounds',
  'darts',
  'dreams',
  'drifts',
  'glides',
  'hums',
  'hunts',
  'jumps',
  'listens',
  'lurks',
  'naps',
  'nests',
  'paddles',
  'pounces',
  'prowls',
  'roams',
  'sings',
  'sketches',
  'wanders',
  'whistles',
  'yawns',
];

function pick<T>(items: readonly T[]): T {
  return items[Math.floor(Math.random() * items.length)];
}

function die(message: string): never {
  console.error(`error: ${message}`);
  return process.exit(1);
}

/** Locate the worklog store: <repo-root>/.worklogs, or an explicit --dir; errors outside git. */
function findStore(explicit: string | undefined): string {
  if (explicit) {
    return resolve(explicit);
  }
  try {
    const root = execFileSync('git', ['rev-parse', '--show-toplevel'], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    if (root) {
      return join(root, '.worklogs');
    }
  } catch {
    // fall through to the error below
  }
  return die('not inside a git repository — run from the repo, or pass --dir to set the store');
}

/** A random adjective-noun-verb slug not already present in `taken`. */
function uniqueSlug(taken: Set<string>): string {
  for (let attempt = 0; attempt < 100; attempt++) {
    const slug = `${pick(ADJECTIVES)}-${pick(NOUNS)}-${pick(VERBS)}`;
    if (!taken.has(slug)) {
      return slug;
    }
  }
  return die('could not find a free worklog name after 100 attempts — clear out .worklogs');
}

function template(opts: {
  related: string[];
  title: string;
  date: string;
  harness: string;
  session: string;
  through: string;
}): string {
  const related =
    opts.related.length > 0
      ? opts.related.map((url) => `  - ${url}`).join('\n')
      : '  # - https://…  (full links to shared things: the ticket, the PR, related docs)';
  return `---
worklog: 2
related:
${related}
date: ${opts.date}
sources:
  - harness: ${opts.harness}
    session: ${opts.session}
    through: ${opts.through}
---

# Worklog: ${opts.title}

## Starting point
`;
}

/**
 * How to fill the scaffolded file. Printed rather than written into it: the guidance is the same for
 * every worklog, so committing a copy into each one puts hundreds of identical paragraphs into the
 * repo, in the artifact whose whole point is to carry what is particular to this change. The skill
 * is the durable home for it; this is the reminder at the moment it's needed.
 */
function guidance(path: string, session: string, through: string): string {
  return `
Write the Starting point now, in a few lines: WHERE THE WORK STARTED — what was asked for at
the outset, and anything already true that shaped it. A snapshot of one moment, not a summary
of the brief as it finally stood, and not a narrative.

Anything that arrived LATER belongs to the entry for the stretch it arrived in — an amended or
expanded brief, a new requirement, a change of direction. If you are writing about something
that happened after the work began, it is not the starting point.

Then append the first entry:
  get-session-transcript.ts ${session} --since ${through}
  → extract the slice into an entry via a sub-agent (assets/extraction-brief.md)
  → append-entry.ts --worklog ${path} --entry <file> --session ${session} --through <new> --label "<locator>"

Entries are appended by append-entry.ts and are never edited afterwards — a later entry that
reverses an earlier decision says so and points back. Write to this shape and the skill; don't
read other worklogs for reference, as the store holds worklogs written to older shapes.`;
}

function main(): void {
  const args = process.argv.slice(2);
  const related: string[] = [];
  let title = '';
  let dir: string | undefined;
  let session = '';
  let harness = 'claude-code';
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    const next = (): string => (i + 1 < args.length ? args[++i] : die(`${arg} requires a value`));
    if (arg === '--related') {
      related.push(next());
    } else if (arg === '--title') {
      title = next();
    } else if (arg === '--dir') {
      dir = next();
    } else if (arg === '--session') {
      session = next();
    } else if (arg === '--harness') {
      harness = next();
    } else {
      die(`unexpected argument: ${arg}`);
    }
  }
  if (!session) {
    die('--session is required — run find-current-session.ts first and pass the id it prints');
  }

  const store = findStore(dir);
  mkdirSync(store, { recursive: true });
  const taken = new Set(
    readdirSync(store)
      .filter((name) => name.endsWith('.md'))
      .map((name) => name.slice(0, -3)),
  );
  const slug = uniqueSlug(taken);
  const path = join(store, `${slug}.md`);

  const date = new Date().toISOString().slice(0, 10);
  // Epoch zero means "nothing consumed yet", so the first slice covers the session from its start —
  // including the decisions made before anyone thought to scaffold a worklog.
  const through = '1970-01-01T00:00:00.000Z';
  writeFileSync(path, template({ related, title: title || slug, date, harness, session, through }));

  console.log(`created ${path}`);
  console.log(guidance(path, session, through));
}

main();
