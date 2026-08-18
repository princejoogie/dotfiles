/**
 * Read and write the worklog file's frontmatter — shared by new-worklog.ts, append-entry.ts and
 * validate-worklog.ts.
 *
 * These scripts run from whatever repo the user is in, via `npx tsx`, so there is no dependency to
 * lean on for YAML. The worklog frontmatter is a fixed, small schema that this skill both writes and
 * reads, so a purpose-built reader for exactly that shape is enough — and keeps the scripts
 * dependency-free. It deliberately does not attempt general YAML: anything it does not recognise is
 * reported as an error rather than guessed at.
 *
 *   ---
 *   worklog: 2
 *   related:
 *     - https://github.com/owner/repo/pull/935
 *   date: 2026-06-29
 *   sources:
 *     - harness: claude-code
 *       session: 75168430-de92-4f65-908f-4d413eff4609
 *       through: 2026-06-29T06:41:22.918Z
 *   ---
 */

export interface Source {
  harness: string;
  session: string;
  through: string;
}

export interface Frontmatter {
  worklog?: number;
  related: string[];
  date?: string;
  sources: Source[];
}

export interface WorklogFile {
  frontmatter: Frontmatter;
  /** Everything after the closing `---`, verbatim. */
  body: string;
}

/** An ISO-8601 UTC instant, as the bookmark contract requires. */
export function isInstant(value: string): boolean {
  return /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/.test(value) && !Number.isNaN(Date.parse(value));
}

function stripComment(line: string): string {
  return line.replace(/\s+#.*$/, '');
}

/**
 * Split a worklog into frontmatter and body. Throws when the file has no frontmatter block or the
 * frontmatter uses a shape outside the schema above.
 */
export function parseWorklog(text: string): WorklogFile {
  const match = /^---\n([\s\S]*?)\n---\n?/.exec(text);
  if (!match) {
    throw new Error('no frontmatter block (expected a leading `---` … `---`)');
  }
  const body = text.slice(match[0].length);
  const fm: Frontmatter = { related: [], sources: [] };

  let list: 'related' | 'sources' | undefined;
  for (const raw of match[1].split('\n')) {
    const line = stripComment(raw);
    if (!line.trim()) continue;

    // `  - …` continues whichever list is open.
    const item = /^\s+-\s*(.*)$/.exec(line);
    if (item) {
      if (list === 'related') {
        fm.related.push(item[1].trim());
      } else if (list === 'sources') {
        const pair = /^([a-z_]+):\s*(.*)$/.exec(item[1].trim());
        if (!pair) throw new Error(`unreadable sources entry: ${raw.trim()}`);
        fm.sources.push({ harness: '', session: '', through: '', [pair[1]]: pair[2].trim() } as Source);
      } else {
        throw new Error(`list item outside a known list: ${raw.trim()}`);
      }
      continue;
    }

    // `    key: value` continues the current sources entry.
    const nested = /^\s{4,}([a-z_]+):\s*(.*)$/.exec(line);
    if (nested && list === 'sources' && fm.sources.length > 0) {
      (fm.sources[fm.sources.length - 1] as unknown as Record<string, string>)[nested[1]] = nested[2].trim();
      continue;
    }

    const top = /^([a-z_]+):\s*(.*)$/.exec(line);
    if (!top) throw new Error(`unreadable frontmatter line: ${raw.trim()}`);
    const [, key, value] = top;
    if (key === 'related' || key === 'sources') {
      list = key;
      continue;
    }
    list = undefined;
    if (key === 'worklog') fm.worklog = Number(value);
    else if (key === 'date') fm.date = value.trim();
    // Unknown top-level scalars are ignored rather than rejected, so a repo can carry its own.
  }

  return { frontmatter: fm, body };
}

/** Serialise frontmatter back out in a fixed key order, then the body verbatim. */
export function formatWorklog(file: WorklogFile): string {
  const { worklog, related, date, sources } = file.frontmatter;
  const lines: string[] = ['---'];
  if (worklog !== undefined) lines.push(`worklog: ${worklog}`);
  lines.push('related:');
  if (related.length > 0) {
    for (const url of related) lines.push(`  - ${url}`);
  } else {
    lines.push('  # - https://…  (full links to shared things: the ticket, the PR, related docs)');
  }
  if (date) lines.push(`date: ${date}`);
  lines.push('sources:');
  for (const s of sources) {
    lines.push(`  - harness: ${s.harness}`);
    lines.push(`    session: ${s.session}`);
    lines.push(`    through: ${s.through}`);
  }
  lines.push('---', '');
  return `${lines.join('\n')}${file.body}`;
}
