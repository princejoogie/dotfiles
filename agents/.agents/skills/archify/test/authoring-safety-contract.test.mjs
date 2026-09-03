import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const skillRoot = path.resolve(__dirname, '..');
const skill = fs.readFileSync(path.join(skillRoot, 'SKILL.md'), 'utf8');
const authoringContract = fs.readFileSync(
  path.join(skillRoot, 'references', 'authoring-contract.md'),
  'utf8',
);

test('relationship labels remain semantic data and deletion is an auditable last resort', () => {
  for (const [name, source] of [['SKILL.md', skill], ['authoring contract', authoringContract]]) {
    assert.match(source, /Relationship labels are semantic data/i, name);
    assert.match(source, /move the label[\s\S]*adjust the route or spacing[\s\S]*shorten/i, name);
    assert.match(source, /protocol[\s\S]*action[\s\S]*direction[\s\S]*synchronous[\s\S]*asynchronous[\s\S]*cross-boundary mechanism/i, name);
    assert.match(source, /Never\s+delete[\s\S]*merely to pass `?showcase`?/i, name);
    assert.match(source, /explain why[\s\S]*redundant/i, name);
  }
});

test('deployment ownership stays explicit, fact-backed, and cannot be removed to pass', () => {
  assert.match(skill, /Omit `meta\.engineering_profile` by default/);
  assert.match(skill, /Region.*cluster.*security boundar.*do not.*enable/i);
  assert.match(skill, /production deployment topology.*ownership.*fail-closed deployment review/i);
  assert.match(skill, /must not remove.*engineering profile.*pass validation/i);
});

test('visual-check stays a pending sidecar receipt instead of a polish claim', () => {
  const deliveryContract = fs.readFileSync(
    path.join(skillRoot, 'references', 'delivery-contract.md'),
    'utf8',
  );
  for (const [name, source] of [['SKILL.md', skill], ['delivery contract', deliveryContract]]) {
    assert.match(source, /visual-check <output\.html> --json/, name);
    assert.match(source, /1440×900[\s\S]*1600×1000[\s\S]*1920×1080[\s\S]*2048×1320/, name);
    assert.match(source, /visualReview: "pending"/, name);
    assert.match(source, /never changes.*delivered|without (?:rerendering or )?modifying/i, name);
  }
});
