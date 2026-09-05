---
name: finai
description: "Use when importing or querying personal bank statements."
version: 3.1.0
metadata:
  hermes:
    tags: [finance, finai, statements, gcash, unionbank, sqlite, categorization, transfers]
---

# FinAI

FinAI is the sole source of truth for Prince's personal-finance data. Use its project CLI for statement ingestion, account queries, categories, transfers, integrity checks, and report data. Do not create or use a separate finance database, parser copy, virtual environment, statement archive, or compatibility wrapper.

## Canonical paths

- Project: `/Users/pjuguilon/Documents/codes/personal/finai`
- CLI: `/Users/pjuguilon/Documents/codes/personal/finai/bin/finai`
- Python ingestion package: `/Users/pjuguilon/Documents/codes/personal/finai/packages/ingest`
- SQLite: `/Users/pjuguilon/Documents/codes/personal/finai/data/finai.db`
- Encrypted artifacts: `/Users/pjuguilon/Documents/codes/personal/finai/statements/`
- Optional legacy password map: `/Users/pjuguilon/Documents/codes/personal/finai/.finai/passwords.json`

## Supported data model

FinAI owns:

1. GCash password-protected transaction-history PDFs.
2. UnionBank debit password-protected XLSX exports, including their incorrect `A1:A1` worksheet dimensions.
3. UnionBank credit password-protected XLSX exports.
4. Atomic statement imports, file-hash and semantic transaction deduplication.
5. Accounts, statement artifacts, transactions, categories, merchant rules, warnings, transfer links, notes, reviews, and AI insights.
6. Rule/AI/user categorization and durable user corrections.
7. Confirmed and suggested internal-transfer matching.

API responses use camelCase (`postedDate`, `amountCents`, `categoryId`). All money fields ending in `Cents` are integer centavos. Convert them to PHP in the same local `jq`/script that summarizes the response; do not call a separate calculation tool.

## API first

Always invoke the absolute CLI path. It resolves the repository from any working directory and connects to FinAI's loopback-only Hono API. If the matching local API is not running, the CLI starts it. The service profile includes the resolved ledger and statement paths, so a disposable configuration cannot attach to the live service by accident.

Use the documented operation IDs below directly. The CLI resolves an operation ID from `/openapi.json` itself, so do not preflight it with a separate OpenAPI request. Fetch `/openapi.json` only when the needed operation is not documented here, a call reports `operation not found`, or an unfamiliar request shape must be inspected. Fetch it at most once per task and filter it to the relevant operation.

```bash
/Users/pjuguilon/Documents/codes/personal/finai/bin/finai --help
/Users/pjuguilon/Documents/codes/personal/finai/bin/finai api finai.accounts.list
```

Call an operation by its OpenAPI `operationId`, or use an HTTP method and path. Use `--param name=value` for path and query parameters and `--data` for JSON bodies. Prefer operation IDs for isolated calls. In loops or bulk shell scripts, use the known method/path so each short-lived CLI process does not fetch OpenAPI again.

```bash
/Users/pjuguilon/Documents/codes/personal/finai/bin/finai api finai.accounts.list
/Users/pjuguilon/Documents/codes/personal/finai/bin/finai api get '/api/transactions?limit=100'
```

### Read fast paths

- Latest transaction in a range: call `finai.transactions.list` with `from`, `to`, and `limit=1`. Results are already ordered by `postedDate` descending; do not fetch the full range or compute `max`.
- Plain total in/out: call `finai.summary.get` once with `year`, or with both `from` and `to`.
- Monthly detail: call `finai.ledger.get --param month=YYYY-MM` once. Reuse that response for transaction, account, and category groupings instead of re-querying the same range.
- All unresolved work: call `finai.review.get` once. It already returns all uncategorized non-transfer transactions, categories, transfer suggestions, warnings, and counts.
- Raw/custom analysis: call `finai.transactions.list` once with the narrowest filters. Capture the JSON once and derive all requested groupings from that payload.

Do not run `finai.ledger.verify` for an ordinary read-only question. Do not inspect source code or SQLite merely to discover response field names documented here. Direct SQLite is a read-only fallback only when the API cannot express the requested aggregation; open `data/finai.db` with `mode=ro`. Never bypass FinAI's API for writes.

## Statement import references

Read only the reference matching the supplied statement before importing:

- [GCash transaction-history PDF](references/gcash.md)
- [UnionBank debit-account XLSX](references/unionbank-debit.md)
- [UnionBank credit-card XLSX](references/unionbank-credit.md)

These references cover supported layouts and provider-specific checks. Use the OpenAPI document for current request options. For another provider or a changed layout, inspect FinAI's supported adapters before importing; do not force it through a similar bank's parser.

## Monthly ingest

1. Copy the encrypted artifact into FinAI's `statements/` directory with the exact canonical filename `gcash_<mmm>_<yyyy>.pdf`, `unionbank-debit_<mmm>_<yyyy>.xlsx`, or `unionbank-credit_<mmm>_<yyyy>.xlsx`.
2. If that canonical destination already exists with different contents, stop and ask how to handle the replacement. Do not invent a suffix such as `_full`, overwrite the existing artifact, or assume overlapping statements will deduplicate cleanly.
3. Keep the artifact and password private. Prefer a one-off environment variable instead of persisting a new password:

```bash
FINAI_IMPORT_PASSWORD='<password>' \
  /Users/pjuguilon/Documents/codes/personal/finai/bin/finai api \
  finai.import.filesystem --data '{"file":"gcash_sep_2026.pdf"}'
```

The CLI forwards `FINAI_IMPORT_PASSWORD` to this local operation without printing or persisting it.

Never interpolate a password from chat into a shell command or tool input; those arguments are retained in the session transcript. Ask the user to set `FINAI_IMPORT_PASSWORD` outside the agent session and confirm when ready, or use the web uploader. Do not repeat a password the user pasted.

4. Call `finai.import.filesystem` directly. There is no `finai import` subcommand and no `--file` flag.
5. The importer parses before persistence, writes atomically, skips known file hashes, semantically deduplicates compatible transactions, and runs transfer matching after import. Do not promise deduplication for a replacement or overlapping export before seeing the import result.
6. Run `finai.ledger.verify` once after the import and inspect the import response plus the affected statement/range. Any failed file, SQLite/foreign-key error, import warning, or invalid transfer link blocks a claim of complete ingestion.
7. Never print passwords or store them in the skill, database, shell history, report, or chat. The web uploader is preferred when convenient because it never saves passwords.

## Finance semantics

- `direction=inflow` means money entered an account; `outflow` means money left or a credit-card purchase increased the liability.
- For plain "total in/out," use `totals.consolidated.inCents` and `totals.consolidated.outCents` from `finai.summary.get`. These exclude only validated confirmed internal-transfer pairs. Unmatched transfers remain because their counterpart account is outside the tracked ledger.
- Do not hardcode transaction IDs or manually remove suggested transfers from headline totals. Use the consolidated summary as returned. Present any hypothetical adjustment for pending suggestions separately.
- `totals.gross` includes every account side and double-counts matched internal movement.
- `totals.nonTransfer` is category-based and is not the default meaning of total in/out.
- Credit-card payments are internal movements; card purchases are spending.
- Cash withdrawals are outflows but are not necessarily consumed spending; report them separately when relevant.
- A statement year can include prior-year card purchases. Use transaction dates for calendar-year questions and statement coverage for statement-period questions.
- Preserve FinAI's user-assigned categories. Never overwrite them with an external categorizer.

## Transfer safety

The CLI validates confirmed links before consolidated totals. Strong evidence includes exact amount/date plus the explicit UnionBank→GCash corridor or UnionBank debit→UnionBank credit-card payment wording. Weak or ambiguous same-amount matches remain suggestions.

`finai.summary.get` and `finai.ledger.verify` expose `suspiciousConfirmedLinks`. A low-confidence link with real GCash/card evidence can remain effective but should be disclosed when relevant. A confirmed weak link without transfer evidence is excluded from consolidated totals without silently mutating the database. Do not change transfer review status without clear user intent.

## Corrections

For a single correction, list categories if the ID is not already known, then make an explicit write:

```bash
/Users/pjuguilon/Documents/codes/personal/finai/bin/finai api finai.categories.list
/Users/pjuguilon/Documents/codes/personal/finai/bin/finai api \
  finai.transactions.update --param id=123 --data '{"categoryId":4}'
```

Resolve a category slug to its numeric ID before the update. Inspect the exact transaction returned by every write. User category corrections are authoritative.

The update response already contains the exact updated row under `transaction`; validate that response instead of issuing a separate transaction-list request. Only read again if the response is missing or ambiguous.

For "categorize all," treat `all` as the whole ledger unless the user explicitly limits the scope. Use `finai.review.get` once to obtain both categories and every uncategorized non-transfer transaction. Reuse already categorized ledger transactions as precedents. Do not web-search merchants by default; when the ledger and description do not support a confident category, choose `Other` conservatively or ask the user.

For multiple updates, submit them in one shell tool call using direct paths such as `PATCH /api/transactions/123`, inspect each returned `transaction`, and stop on the first mismatch. Do not fetch a full day or full ledger after every row. Run one aggregate read and one ledger verification after the entire batch.

## Verification

Run after imports, deletions, transfer changes, or a completed batch of transaction writes:

```bash
/Users/pjuguilon/Documents/codes/personal/finai/bin/finai api finai.ledger.verify
```

Check `ok`, SQLite integrity, foreign keys, counts, statement statuses/warnings, import warnings, and transfer diagnostics. Do not hardcode current totals as a future baseline.

One successful verification at the end of a mutation batch is enough. Repeat it only if a mutation response, process interruption, or integrity result leaves the final state uncertain. Skip it for read-only questions.

When changing FinAI itself, preserve pre-existing dirty files, run `npm run check`, inspect `git diff --check`, and smoke-test `finai api` from outside the repository against disposable paths. New provider layouts require a failing parser fixture and validation against a temporary database before canonical ingestion.
