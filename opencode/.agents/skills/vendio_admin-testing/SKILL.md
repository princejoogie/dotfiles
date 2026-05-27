---
name: vendio_admin-testing
description: Validates Admin app behavior in a real browser, including Google OAuth, onboarding, protected navigation, vendor setup or edit flows, save persistence, reload behavior, and session handoff. Use when testing the Admin app in a browser, especially auth-gated flows, onboarding, vendor bootstrap, vendor config, vendor content, or account-switching behavior.
---

# Vendio Admin Browser Testing

## Quick Start

Use this skill when validating Admin app behavior in a real browser. Use the `agent-browser` skill for agent-driven runs so interactions are based on accessibility snapshots, and screenshots.

1. Confirm the local dev server is running at `http://localhost:<ADMIN_APP_PORT>`.
2. Confirm the Google account to use. If account isolation matters, confirm a second account is available.
3. Open `http://localhost:<ADMIN_APP_PORT>` or the protected Admin URL.
4. Complete the login flow, then run the target workflow checks.

## Existing Chrome Profile

Alway use this unless specified by the user to use another profile.

Ask the user to run this in another terminal window and keep it open if this process/cdp port doesnt exist yet:

```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 --user-data-dir="$HOME/.local/state/agent-browser/chrome-cdp-9222"
```

Before testing, connect `agent-browser` to that browser:

```bash
agent-browser connect 9222
```

Then use the normal `agent-browser open`, `snapshot`, `click`, `fill`, `wait`, `screenshot`, etc commands.

## Login Flow

1. Open `http://localhost:<ADMIN_APP_PORT>` or the protected Admin URL under test.
2. If already logged in, click `Log out` from the sidebar.
3. On the sign-in screen, click the Google sign-in button.
4. Wait for Google login or account chooser.
5. Ask which Google account to use unless the user already specified it.
6. If Google asks for credentials, passkeys, or two-factor approval, pause for the user to complete the secure step.
7. After Google redirects back to Admin, check the current URL.
8. If redirected to `/onboarding`, fill required onboarding fields with clear test values unless the user provided specific values.
9. Continue only after the Admin sidebar or target protected page is visible.

Expected outcomes:

- Sign-out lands on the sign-in screen.
- Google sign-in returns to the Admin app.
- Existing users land on a protected Admin page.
- New users can complete `/onboarding` and then reach the Admin app.

## General Persistence Test Flow

1. Sign in using the login flow.
2. Navigate to the target Admin workflow from the sidebar or direct URL.
3. Record the starting URL, account, target entity, and relevant initial field values.
4. Make the edits that proves the behavior under test.
5. Save or submit the form.
6. Verify success feedback appears and edited values remain visible.
7. Reload the page and verify saved state is still present.
8. Navigate away and back to the same Admin screen, then verify saved state again.
9. Sign out, sign in with the same account, and verify saved state again when persistence matters.
10. If account isolation matters, repeat with a second account and verify no stale state from the first account is leaked.

## Failure Capture

If any assertion fails, capture:

- Exact URL path where it failed.
- Account used.
- Target workflow and entity id or slug.
- Fields edited and values used.
- Screenshot or `agent-browser snapshot -i` output at the failure point.
- Refresh result, navigation result, and re-auth result where relevant.
- Timestamp of the failure.
- Any console, network, toast, or validation hints visible during the flow.
- Save any screenshots in the relative `.tmp/` directory and notify the user about these files.

## Reporting

Record every run with the account used, workflow tested, target entity id or slug, edited values, save result, refresh result, navigation result, re-auth result, exact failure text, and any screenshots, snapshots, console hints, or network hints captured during the flow.
