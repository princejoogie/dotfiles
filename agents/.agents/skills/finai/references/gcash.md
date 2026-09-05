# Import GCash statements

Use for the original GCash transaction-history PDF, including password-protected files. Adapter: `gcash-pdf`.

1. Follow the shared Monthly ingest procedure in SKILL.md. Do not call the nonexistent `finai import` command.
2. Keep the original PDF in FinAI's `statements/` directory. Use `gcash_<mmm>_<yyyy>.pdf`, with the statement month as a three-letter English abbreviation, for example `gcash_sep_2026.pdf`.
3. Using the absolute CLI path from SKILL.md, import only that filename with `api finai.import.filesystem --data '{"file":"gcash_sep_2026.pdf"}'`. Supply the password through the shared private password flow. Do not convert the PDF into a separate CSV or maintain another parser.
4. Run the shared verification and inspect the imported account, transaction dates, amounts, and closing balance against the statement.

## Format-specific checks

- The current parser requires extractable text and a starting balance. It reads dated transaction entries with amounts and running balances; an image-only scan needs parser support rather than a claim of successful import.
- Direction primarily follows the change in running balance, with description-based fallback. Inspect reconciliation warnings and ambiguous transfers rather than assuming every transfer is income.
- Incorrect passwords, missing starting balances, and no parsed transactions are failures. Review warnings about unidentified amounts/balances or unreconciled running balances before claiming complete ingestion.
- UnionBank-to-GCash movement is internal only when the ledger has a validated counterpart. Leave weak matches for review.

Implementation: `/Users/pjuguilon/Documents/codes/personal/finai/packages/ingest/finai_ingest/adapters/gcash.py`.
