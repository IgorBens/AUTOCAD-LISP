# Template Cleanup

Interactief DWG template schoonmaken.

## Gebruik

```lisp
(load "clean-template.lsp")
```

Type in AutoCAD: `CLEANTEMPLATE`

## Workflow

1. **Selecteer** wat je wilt **BEHOUDEN**
   - Window-select vloerverwarming
   - Shift+Window-select muren
   - Shift+Click collectors

2. **Bevestig** met "Ja"

3. **Klaar!**
   - Alles wat niet geselecteerd was = weg
   - Layout tabs verwijderd
   - Volledig gepurged
   - Drawing geaudit

## Wat het doet

- ✅ Behoudt alleen wat jij selecteert
- ❌ Verwijdert alle andere elementen
- 🗑️ Verwijdert layout tabs (Layout1, Layout2, etc.)
- 🧹 Purge ALLES (blocks, layers, styles, etc.)
- 🔍 Audit voor errors

## Tips

- Test ALTIJD op een kopie!
- `Ctrl+Z` om ongedaan te maken
- Model tab blijft behouden
