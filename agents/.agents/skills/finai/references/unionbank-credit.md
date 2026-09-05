# Import UnionBank credit-card statements

Use for the original UnionBank credit-card XLSX statement. Adapter: `unionbank-credit-xlsx`. This is different from the debit-account export.

1. Follow the shared Monthly ingest procedure in SKILL.md. Do not call the nonexistent `finai import` command.
2. Keep the original encrypted workbook in FinAI's `statements/` directory. Use `unionbank-credit_<mmm>_<yyyy>.xlsx`, for example `unionbank-credit_sep_2026.xlsx`. Choose the statement month, not the month of the oldest purchase.
3. Using the absolute CLI path from SKILL.md, import only that filename with `api finai.import.filesystem --data '{"file":"unionbank-credit_sep_2026.xlsx"}'` and the shared private password flow. Let FinAI decrypt and read the workbook.
4. Run shared verification. Check the card's last four digits, statement date, due date, statement balance, minimum due, and transaction amounts against the source where present.

## Format-specific checks

- The current adapter requires CARD NUMBER and STATEMENT BALANCE in the first 14 rows, with transactions starting at row 15. Transaction columns are date, description, currency, and signed amount.
- Positive amounts are outflows that increase card liability. Negative amounts are inflows, such as payments or credits. Do not treat every negative amount as income or every positive amount as a bank-account cash withdrawal.
- Statement balance and minimum due are metadata, not extra transactions. Do not add them to spending.
- A statement can contain purchases from the previous calendar year. Preserve their transaction dates; use those dates for annual totals.
- Zero amounts and date/amount parsing problems produce warnings and can skip rows. Investigate those before claiming complete ingestion.
- Match card payments against debit-account outflows only through validated FinAI transfer links; purchases remain spending.

Implementation: `/Users/pjuguilon/Documents/codes/personal/finai/packages/ingest/finai_ingest/adapters/unionbank_credit.py` and `adapters/common.py` in the same directory.
