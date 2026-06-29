#!/usr/bin/env -S npx tsx
/**
 * Scaffold a new per-PR worklog file in the repo's worklog store (.worklogs/).
 *
 * Usage:
 *   .agents/skills/worklog/scripts/new-worklog.ts [--related URL]... [--title "..."] [--dir PATH]
 *
 * Picks a random, human-readable, collision-checked filename (Changesets-style, e.g.
 * brave-otter-listens.md) so concurrent PRs in the monorepo never clash on the same file, creates
 * the worklog store if absent, writes the fixed-schema template (with any --related links and
 * --title pre-filled), and prints the path. The agent then fills the template in. Re-run once per
 * PR. Pass --related once per link (the ticket, the PR, related docs) as a full URL.
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

function template(opts: { related: string[]; title: string; date: string }): string {
  const related =
    opts.related.length > 0
      ? opts.related.map((url) => `  - ${url}`).join('\n')
      : '  # - https://…  (full links to shared things: the ticket, the PR, related docs)';
  return `---
related:
${related}
date: ${opts.date}
---

# Worklog: ${opts.title}

<!-- A decision log, extracted from the session record (not written from memory). Capture the
     notable decisions behind this change: those that shaped what shipped AND could have gone
     another way (surprising, not the obvious approach, contested, or a real pick among options).
     Leave out how the work was run (which agent/model, the testing, ticket/PR mechanics) and the
     cosmetic, copy-level churn. Attach a reason only when one was actually stated ("no reason
     given" is valid — never invent one). Anchor every rationale to something any developer can
     open; where the only anchor is out of reach, put its substance here. -->

## Context

<!-- What this change is, and the brief as it was actually given (what was asked for). Light
     scene-setting — not a story of the work. -->

## Decisions

<!-- The spine. One entry per notable decision: what was decided, the alternatives weighed and why
     they were set aside, and any stated reason. A decision reached through back-and-forth is one
     entry with where it landed; distinct decisions stay separate. -->

## Final state

<!-- What shipped, and where it diverged from the brief (and why, if a reason was stated). -->
`;
}

function main(): void {
  const args = process.argv.slice(2);
  const related: string[] = [];
  let title = '';
  let dir: string | undefined;
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    const next = (): string => (i + 1 < args.length ? args[++i] : die(`${arg} requires a value`));
    if (arg === '--related') {
      related.push(next());
    } else if (arg === '--title') {
      title = next();
    } else if (arg === '--dir') {
      dir = next();
    } else {
      die(`unexpected argument: ${arg}`);
    }
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
  writeFileSync(path, template({ related, title: title || slug, date }));

  console.log(`created ${path}`);
  console.log(
    '\nnext: extract the worklog from the session record into this file (see SKILL.md) —' +
      ' find-current-session.ts → get-session-transcript.ts → sub-agent. Commit it with the PR.',
  );
}

main();
