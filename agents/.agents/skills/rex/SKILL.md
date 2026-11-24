---
name: rex
description: Inspect or manage the Rex terminal multiplexer with its CLI. Use for Rex sessions, tabs, panes, connected apps, and reading terminal output in another Rex tab without switching focus.
---

# Rex

Run `rex skill show` and follow the guide from the installed Rex CLI. Use Rex CLI commands for Rex tasks. If the CLI cannot do what the user asks, report the limitation rather than switching to GUI automation.

For read-only checks, identify the session with `rex --autostart=false whoami --json` or `rex --autostart=false ls --json`. A Rex tab is a window and a pane is a block. Match the tab to its block with `rex window ls` and `rex block ls`, then run `rex capture -s SESSION -b BLOCK --trim --unwrap` to read its output without changing focus.
