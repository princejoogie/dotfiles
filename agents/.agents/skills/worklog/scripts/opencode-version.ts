import { spawnSync } from 'node:child_process';

export function isOpenCodeV1(): boolean {
  const result = spawnSync('opencode', ['--version'], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
  if (result.status !== 0) return false;
  return /\b1\.\d+\.\d+\b/.test(`${result.stdout}\n${result.stderr}`);
}
