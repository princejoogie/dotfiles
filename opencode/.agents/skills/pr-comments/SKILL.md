---
name: pr-comments
description: Fetch, filter, and format GitHub PR review comments into Markdown. Use when the user asks to extract, compile, or summarize PR comments, unresolved threads, or review feedback.
---

# PR Comments Extractor

## Quick start

To fetch and format all unresolved comments for the current PR into `.tmp/pr-<number>-comments.md`:

```bash
# Note: Execute this script using the absolute path of this skill's base directory
scripts/extract-unresolved-comments.sh
```

To fetch for a specific PR and output to a specific file:
```bash
scripts/extract-unresolved-comments.sh 123 docs/feedback.md
```

## Workflows

### 1. Extracting PR Comments
When the user asks to compile or fetch PR comments:
1. Verify you are in a Git repository connected to GitHub.
2. Determine the target PR number:
   - If a PR link is provided by the user, extract the PR number from the URL.
   - If a specific number is provided, use that.
   - If no PR is specified, retrieve the current branch's PR number using `gh pr view --json number -q .number`.
3. Execute the `scripts/extract-unresolved-comments.sh` script (using the skill's base directory to form the absolute path) to fetch data via the `gh` GraphQL API.
4. Read the generated output file and respond to the user with a summary. The summary must include the total number of unresolved comments and a high-level overview or general consensus of the feedback.
   - Note: The diff hunks in the output file are capped at 15 lines. Use your `read` or `grep` tools to inspect the target files if you need more context around a comment.

### 2. Output Format
The script automatically filters out resolved threads and generates a Markdown file with the following strict structure:

```markdown
# PR Comments for <pr_number>
## <pr_title>

- <pr_status>
- <pr_author>

## Comments

File: `path/to/file.ts:123`

```ts
@@ -10,5 +10,5 @@
  <hunk_info>
```

> `@<user>`: <comment_body>

> `@<user_2>`: <reply_body>

---
```

## Utility Scripts

* `scripts/extract-unresolved-comments.sh`: Handles the complete GraphQL query construction, data fetching, JSON parsing, and Markdown templating to ensure deterministic and consistent outputs.
