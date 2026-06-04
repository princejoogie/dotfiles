---
name: vendio-admin-preview-auth-testing
description: Validates deployed Vendio Admin preview auth, session persistence, tRPC grant checks, organization switching, vendor CRUD, and account switching. Use when testing Admin preview deployments, Better Auth/JWT/tRPC regressions, Vercel preview auth behavior, Google OAuth flows, or refresh persistence after org/vendor changes.
---

# Vendio Admin Preview Auth Testing

## Quick Start

Use this for deployed Admin preview regressions, especially when OAuth succeeds but refresh or tRPC requests sign the user out.
1. Load `agent-browser` and `vendio_admin-testing` if available.
2. Use the existing Chrome CDP profile unless told otherwise: `agent-browser connect 9222`.
3. Use bounded waits only; never run unbounded waits.
4. Use Vercel CLI through `pnpm dlx vercel`; plain `vercel` may not be on `PATH`.
5. Test both local Admin and deployed preview when auth behavior differs.

## Preflight

Check local Admin when comparing behavior:
```bash
scripts/dev-server.sh status
scripts/dev-server.sh start
```

Find and wait for a preview:
```bash
pnpm dlx vercel ls vendio-admin --scope vervio
pnpm dlx vercel inspect "https://vendio-admin-<id>-vervio.vercel.app" --wait --timeout 5m --scope vervio
```

Use the browser session:
```bash
agent-browser connect 9222
agent-browser network requests --clear
agent-browser console --clear
agent-browser open https://vendio-admin-<id>-vervio.vercel.app/sign-in
```

## Auth Diagnosis Workflow

1. Sign in with Google and record the account used.
2. If OAuth reaches the protected shell, immediately check `/api/auth/get-session` before tRPC can sign out:
```js
fetch('/api/auth/get-session', { credentials: 'include' })
  .then(async (r) => ({ status: r.status, text: await r.text() }))
```

3. Force the original failing batched tRPC shape and capture status/body:
```js
fetch('/api/trpc/organization.listCurrent,config.all?batch=1&input=<encoded-input>', {
  credentials: 'include',
  headers: { 'trpc-accept': 'application/jsonl', 'x-trpc-source': 'manual-debug' },
}).then(async (r) => ({ status: r.status, text: await r.text() }))
```

4. If automatic tRPC clears cookies before you can inspect the token path, block tRPC, sign in, inspect session/cookies, then unblock for one manual call:
```bash
agent-browser network route "**/api/trpc/**" --abort
agent-browser network unroute
```

5. Pull runtime logs if tRPC is `401`:
```bash
pnpm dlx vercel logs --deployment "https://vendio-admin-<id>-vervio.vercel.app" --scope vervio --since 30m --expand
```

## Known Root Cause Pattern

If logs show `Expected 200 OK from the JSON Web Key Set HTTP response`, the deployed server is likely self-fetching `/api/auth/jwks` through Vercel Preview Deployment Protection. Cookies may be valid and `/api/auth/get-session` may still return a session. Fix the verifier to avoid protected HTTP self-fetches, for example by verifying against the database-backed JWKS table locally before parsing grants.

Do not treat `get-session` success as sufficient; browser tRPC also needs `auth.api.getToken({ headers })` plus `verifyTokenGrants(token, headers)` or its current equivalent to succeed.

## Regression Matrix

Run against the final deployed preview after a fix:
1. Google sign-in reaches the authenticated shell.
2. Forced `organization.listCurrent,config.all` returns `200`.
3. Full refresh stays authenticated and `/api/auth/get-session` returns a session.
4. Create a vendor from `/settings/vendors`; verify redirect to `/vendors/<id>/config`.
5. Edit public vendor config; verify save request and values persist after refresh.
6. Create an organization from `/settings/organizations`; verify it becomes active.
7. Switch orgs both ways; verify active org persists after refresh.
8. Create a vendor in the newly active org; verify it appears after refresh.
9. Sign out; verify `/api/auth/get-session` returns `null`.
10. Sign in with another Google account if available; verify separate org/vendor state and tRPC `200`.
11. Sign back into the original account; verify expected org/vendor access and tRPC `200`.

## Browser Testing Notes

- Use `joogie.dev@gmail.com` for known Admin preview auth unless the user specifies otherwise.
- If Google asks for credentials or MFA, stop and ask the user to complete the secure step.
- Clear network and console logs before each meaningful action.
- Prefer real UI interactions, but if a save button appears not to submit under automation, verify with `document.querySelector('button[type=submit]')?.click()` or `document.querySelector('form')?.requestSubmit()` before calling it an app bug.
- Leave test record names obvious, such as `IH-1085 QA Vendor <timestamp>` and `IH-1085 QA Org <timestamp>`.
- Report exact preview URL, account, created IDs, request statuses, refresh result, account-switch result, and any records left in the preview database.
- Temporary client-visible debug responses and auth token logging are acceptable only while proving root cause. Remove them after the deployed preview verifies the fix, then redeploy and rerun the core auth checks.
