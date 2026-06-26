---
name: research-browser
description: Research public information about people, companies, products, projects, or topics, then open relevant source tabs in Chrome through CDP port 9222. Use when the user asks to research, look up, investigate, find relevant reading, open tabs, or leave browser tabs open for a person, topic, project, company, library, tool, or current event.
---

# Research Browser

Use this skill to research a subject and leave the best source tabs open in the user's Chrome instance.

## Quick Start

```bash
scripts/ensure-cdp-9222.sh
agent-browser --cdp 9222 tab
agent-browser --cdp 9222 tab new "https://example.com/relevant-source"
```

## Workflow

1. Clarify only if the target is ambiguous. Otherwise start researching.
2. Search the web for the exact subject first. Use quoted searches for names, handles, projects, or phrases.
3. Prefer primary sources: official site, portfolio, GitHub, LinkedIn, docs, company page, author profile, repository, paper, or announcement.
4. Add reputable secondary sources only when they add useful context: articles, reviews, interviews, package pages, databases, or search result pages.
5. Avoid opening low-value duplicates, scraper pages, irrelevant namesakes, private-looking personal data, or pages that require questionable access.
6. Run `scripts/ensure-cdp-9222.sh` before any browser command. This must happen before opening tabs.
7. Connect with `agent-browser --cdp 9222 tab` to verify the existing Chrome target.
8. Open each relevant page with `agent-browser --cdp 9222 tab new "<url>"`.
9. Leave the tabs open. Do not close the browser or tabs unless the user asks.
10. Finish with a concise list of opened tabs and any notable exclusions.

## Browser Rules

- Always use CDP port `9222`; do not start a separate agent-browser session for this workflow.
- Always check/start Chrome through `scripts/chrome-cdp.sh` via the helper script before opening tabs.
- Use `agent-browser --cdp 9222 tab` before opening tabs so connection happens first.
- If a page blocks content, still leave the tab open if it is a relevant primary source, and mention the block.
- If the task involves sensitive private information, restrict research to clearly public, professional, or user-provided sources.

## Useful Commands

```bash
# Ensure Chrome CDP is ready.
scripts/ensure-cdp-9222.sh

# Connect/list tabs first.
agent-browser --cdp 9222 tab

# Open relevant tabs.
agent-browser --cdp 9222 tab new "https://example.com"

# Show final tab list.
agent-browser --cdp 9222 tab
```
