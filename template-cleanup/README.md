# Template Cleanup

Interactief DWG template schoonmaken met automatische kopie.

## Gebruik

```lisp
(load "clean-template.lsp")
```

Type in AutoCAD: `CLEANTEMPLATE`

## Workflow

**BELANGRIJK: Je originele bestand blijft intact!**

1. **Open** je template in AutoCAD (moet opgeslagen zijn)

2. **Type** `CLEANTEMPLATE`
   - Script toont huidige file en nieuwe naam
   - Bijv: `template.dwg` → `template_clean.dwg`

3. **Bevestig** kopie maken
   - Script maakt automatisch `template_clean.dwg`
   - Je zit nu in de nieuwe kopie!

4. **Selecteer** wat je wilt **BEHOUDEN**
   - Window-select vloerverwarming
   - Shift+Window-select muren
   - Shift+Click collectors

5. **Bevestig** cleanup

6. **Klik locatie** voor "CLEAN DWG" tekst
   - Script vraagt waar je de watermark wilt
   - Geef teksthoogte (bijv. 500mm)
   - Grote rode tekst wordt toegevoegd

7. **Klaar!**
   - Alles wat niet geselecteerd was = weg
   - Layout tabs verwijderd
   - Volledig gepurged
   - "CLEAN DWG" watermark toegevoegd
   - Auto-saved als `template_clean.dwg`
   - Origineel `template.dwg` blijft intact!
   - **Beide bestanden blijven open**

## Wat het doet

- 🔒 **Origineel blijft veilig** - maakt automatisch kopie met "_clean"
- ✅ Behoudt alleen wat jij selecteert
- ❌ Verwijdert alle andere elementen
- 🗑️ Verwijdert ALLE layout tabs (A4_Landsc., A3_Portr., etc.)
- 🧹 Purge ALLES (blocks, layers, styles, etc.)
- 🔍 Audit voor errors
- 🔴 **"CLEAN DWG" watermark** - grote rode tekst zodat je weet welke versie je open hebt
- 📂 **Beide bestanden blijven open** - origineel gaat automatisch terug open
- 💾 Auto-save naar nieuwe file

## Voorbeeld

```
Command: CLEANTEMPLATE

=== CLEAN DWG TEMPLATE ===

Huidige file: C:/projecten/template.dwg
Nieuwe file: C:/projecten/template_clean.dwg

Kopie maken en cleanen? [Ja/Nee] <Ja>: J

Kopie wordt gemaakt...
✓ Kopie gemaakt: template_clean.dwg
✓ Je zit nu in de nieuwe file

Selecteer elementen om te BEHOUDEN:
[... selecteer vloerverwarming, muren, etc ...]

1614 elementen geselecteerd om te BEHOUDEN.

Wil je ALLE ANDERE elementen verwijderen? [Ja/Nee] <Nee>: J

[... cleanup process ...]

Tekst 'CLEAN DWG' toevoegen...
Klik waar je de 'CLEAN DWG' tekst wilt plaatsen:
Klik locatie voor tekst (of ENTER voor 0,0): [klik punt]
Geef teksthoogte (bijv. 500): 500
✓ Watermark toegevoegd

Opslaan...
Origineel bestand opnieuw openen...

✓ Template is schoongemaakt!
  - 1614 elementen behouden
  - 72 elementen verwijderd
  - 12 layout tabs verwijderd
  - Lege layers verwijderd
  - Volledig gepurged
  - 'CLEAN DWG' watermark toegevoegd

✓ Origineel intact: template.dwg
✓ Cleaned versie: template_clean.dwg
✓ Beide bestanden zijn open
```

## Edge Cases

- **Bestand niet opgeslagen:** Script geeft error en stopt
- **_clean file bestaat al:** Vraagt of je wilt overschrijven
- **Geen elementen geselecteerd:** Kopie blijft bestaan maar niet opgeschoond
- **Cleanup geannuleerd:** Kopie blijft bestaan maar niet opgeschoond

## Tips

- Script werkt met **elke** layout naam (niet alleen Layout1, Layout2)
- Model tab blijft altijd behouden
- Layer 0 en DEFPOINTS blijven (systeem layers)
- Purge draait 6x voor nested references
- **Watermark voorkomen verwarring** - je ziet meteen dat je in de CLEAN versie zit
- **Switch tussen bestanden** - gebruik Window menu of Ctrl+Tab in AutoCAD
- **Watermark verwijderen** - selecteer de tekst en delete (als je wilt)
