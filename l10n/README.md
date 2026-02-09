# Localization (l10n)

This folder contains localization assets for the Trust App.

## Files

| File | Purpose |
|------|---------|
| `app_en.arb` | English strings (source of truth). Used by Flutter's `flutter gen-l10n` to generate `AppLocalizations`. |
| `translations_template.csv` | Spreadsheet for translators. Columns: `key`, `en`, `ko`, `vi`, `pt`. Fill in Korean, Vietnamese, and Portuguese. |
| `README.md` | This file. |

## Workflow for translators

1. Open `translations_template.csv` in Excel, Google Sheets, or any CSV editor.
2. Fill in the **ko** (Korean), **vi** (Vietnamese), and **pt** (Portuguese) columns.
3. Keep the **key** column unchanged.
4. Preserve placeholders such as `{currency}` exactly as shown (e.g. in `availableToCurrencyPair`).
5. Return the completed CSV to the development team.

## Converting CSV to ARB

After translations are received, create `app_ko.arb`, `app_vi.arb`, and `app_pt.arb` from the CSV.  
A script or manual copy-paste can be used. Each ARB file should follow the same structure as `app_en.arb`.

## Notes

- **key**: Do not modify. Used by code to look up the string.
- **Placeholders**: Strings like `Available to {currency} pair` must keep `{currency}` in all languages.
- **Newlines**: `\n` in strings represents a line break.
