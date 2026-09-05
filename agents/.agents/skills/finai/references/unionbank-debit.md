# Import UnionBank debit statements

Use for the original UnionBank debit-account XLSX export. Adapter: `unionbank-debit-xlsx`. Do not use the credit-card reference for this layout.

1. Follow the shared Monthly ingest procedure in SKILL.md. Do not call the nonexistent `finai import` command.
2. Keep the original encrypted workbook in FinAI's `statements/` directory. Use `unionbank-debit_<mmm>_<yyyy>.xlsx`, for example `unionbank-debit_sep_2026.xlsx`.
3. Using the absolute CLI path from SKILL.md, import only that filename with `api finai.import.filesystem --data '{"file":"unionbank-debit_sep_2026.xlsx"}'` and the shared private password flow. FinAI handles workbook decryption and incorrect `A1:A1` worksheet dimensions; do not resave or repair the source workbook manually.
4. Run shared verification. Check the account's last four digits, transaction range, debit/credit totals, and closing balance against the export.

## Format-specific checks

- The current adapter expects a DATE header in spreadsheet row 4 and transaction rows starting at row 5. It reads date, references, description, currency, debit, credit, and balance.
- A populated debit is an outflow; a populated credit is an inflow. Rows with both amounts or a zero amount generate warnings and are skipped. Parsing warnings therefore require checking for missing transactions.
- The adapter takes the first transaction's balance as the closing balance, relying on the export's ordering. Check it against the source, particularly for a changed layout or ordering.
- Transfers to GCash and credit-card payments can have counterparts in other tracked accounts. Use FinAI's transfer validation; do not manually subtract every transfer description.

Implementation: `/Users/pjuguilon/Documents/codes/personal/finai/packages/ingest/finai_ingest/adapters/unionbank_debit.py` and `adapters/common.py` in the same directory.
