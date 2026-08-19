import { spawnSync } from 'node:child_process';
import { closeSync, openSync, readFileSync, unlinkSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { randomUUID } from 'node:crypto';

export interface OpenCodeMessage {
  id: string;
  time: { created: number; [key: string]: unknown };
  content?: OpenCodeContent[];
  [key: string]: unknown;
}

export interface OpenCodeContent {
  id?: string;
  type?: string;
  time?: { created?: number; [key: string]: unknown };
  [key: string]: unknown;
}

export interface OpenCodeRecord {
  id: string;
  type: 'message' | 'content';
  messageId?: string;
  timestamp: string;
  data: Record<string, unknown>;
}

/** Use the CLI's service discovery/auth and redirect stdout so large exports are never capture-limited. */
export function readOpenCodeApi<T>(path: string): T {
  const output = join(tmpdir(), `worklog-opencode-api-${randomUUID()}.json`);
  const fd = openSync(output, 'w');
  let result;
  try {
    result = spawnSync('opencode2', ['api', 'get', path], {
      encoding: 'utf8',
      stdio: ['ignore', fd, 'pipe'],
    });
  } finally {
    closeSync(fd);
  }

  try {
    if (result.error) throw result.error;
    if (result.status !== 0) {
      throw new Error(result.stderr.trim() || `opencode2 api exited with status ${result.status}`);
    }
    return JSON.parse(readFileSync(output, 'utf8')) as T;
  } finally {
    unlinkSync(output);
  }
}

/** Flatten projected messages without losing content timestamps within a long assistant message. */
export function projectOpenCodeMessages(messages: OpenCodeMessage[]): OpenCodeRecord[] {
  const records: Array<OpenCodeRecord & { order: number }> = [];
  let order = 0;
  for (const message of messages) {
    if (!message.id || !Number.isFinite(message.time?.created)) {
      throw new Error('unsupported message shape in OpenCode session export');
    }
    const { content = [], ...messageData } = message;
    records.push({
      id: message.id,
      type: 'message',
      timestamp: new Date(message.time.created).toISOString(),
      data: messageData,
      order: order++,
    });
    for (let i = 0; i < content.length; i++) {
      const item = content[i];
      const created = item.time?.created ?? message.time.created;
      if (!Number.isFinite(created)) throw new Error('unsupported content shape in OpenCode session export');
      records.push({
        id: item.id ?? `${message.id}-content-${i}`,
        type: 'content',
        messageId: message.id,
        timestamp: new Date(created).toISOString(),
        data: item,
        order: order++,
      });
    }
  }
  return records
    .sort((a, b) => Date.parse(a.timestamp) - Date.parse(b.timestamp) || a.order - b.order)
    .map(({ order: _order, ...record }) => record);
}

export function sliceOpenCodeRecords(
  records: OpenCodeRecord[],
  since?: string,
  until?: string,
): { records: OpenCodeRecord[]; through?: string } {
  const from = since ? Date.parse(since) : Number.NEGATIVE_INFINITY;
  const to = until ? Date.parse(until) : Number.POSITIVE_INFINITY;
  const sliced = records.filter((record) => {
    const created = Date.parse(record.timestamp);
    return created > from && created <= to;
  });
  return { records: sliced, through: sliced.at(-1)?.timestamp };
}
