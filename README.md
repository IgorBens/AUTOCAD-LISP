# AUTOCAD-LISP

AutoCAD LISP scripts voor verschillende taken. Elk project heeft zijn eigen folder.

## 📁 Repository Structuur

```
AUTOCAD-LISP/
├── vloerverwarming/          # Vloerverwarming kringen automatisch maken
│   └── vloerverwarming.lsp
├── template-cleanup/         # DWG templates schoonmaken
│   └── clean-template.lsp
└── README.md                 # Dit bestand
```

---

## 🔥 Vloerverwarming

**Locatie:** `vloerverwarming/vloerverwarming.lsp`

### Gebruik
1. Laad: `(load "vloerverwarming/vloerverwarming.lsp")`
2. Type: `VV`
3. Selecteer object (rechthoek, polyline)
4. Geef offset afstand (bijv. 100 of 150mm)

### Wat doet het?
- Maakt 50mm contour naar binnen (als rand)
- Offset loops naar binnen toe tot geen ruimte meer

---

## 🧹 Template Cleanup

**Locatie:** `template-cleanup/clean-template.lsp`

### Gebruik
1. Open je DWG template in AutoCAD
2. Laad: `(load "template-cleanup/clean-template.lsp")`
3. Type: `CLEANTEMPLATE`
4. **Selecteer** alle elementen die je wilt **BEHOUDEN** (vloerverwarming, muren, collectors, etc.)
5. Bevestig met "Ja"

### Wat doet het?
✅ Vraagt je om elementen te selecteren die je wilt behouden
❌ Verwijdert ALLES wat je NIET selecteerde
🗑️ Verwijdert alle ongebruikte layout tabs (Layout1, Layout2, etc.)
🧹 Purge ALLES (blocks, layers, styles, materials, etc.)
🔍 Audit de tekening voor errors

**Perfecte workflow:**
1. Window-select je vloerverwarming
2. Shift+Window-select je muren
3. Shift+Click collectors en andere elementen
4. Run CLEANTEMPLATE
5. Klaar! Alles wat je niet selecteerde is weg

---

## 🚀 Installatie

### In AutoCAD (Handmatig)
```lisp
(load "C:/pad/naar/AUTOCAD-LISP/vloerverwarming/vloerverwarming.lsp")
(load "C:/pad/naar/AUTOCAD-LISP/template-cleanup/clean-template.lsp")
```

### Automatisch laden (acaddoc.lsp)
Maak `acaddoc.lsp` in je AutoCAD support folder:
```lisp
(load "C:/pad/naar/AUTOCAD-LISP/vloerverwarming/vloerverwarming.lsp")
(load "C:/pad/naar/AUTOCAD-LISP/template-cleanup/clean-template.lsp")
(princ "\nCustom scripts geladen: VV, CLEANTEMPLATE")
```

---

## 💡 Version Control

**Git Workflow:**
- Elke wijziging wordt direct in het bestand gemaakt (geen nieuwe bestanden)
- Push regelmatig naar GitHub zodat je collega's de updates krijgen
- Gebruik `git pull` om de laatste versie binnen te halen

**Voor nieuwe projecten:**
1. Maak nieuwe folder: `mkdir nieuw-project`
2. Maak je .lsp file: `nieuw-project/script.lsp`
3. Update deze README
4. Commit & push

---

## 🌐 Buiten AutoCAD gebruiken

Deze scripts gebruiken AutoCAD-specifieke commando's (`command`, `ssget`, `entsel`), dus je hebt een CAD engine nodig:

1. **AutoCAD Core Console** - Command line AutoCAD
2. **BricsCAD** - Volledige LISP support
3. **OpenDCL** - Open source optie (beperkt)

---

## 📝 Tips

- **ALTIJD** eerst testen op een kopie van je template!
- Gebruik `Ctrl+Z` (UNDO) als het niet goed gaat
- Layout tabs worden automatisch verwijderd (behalve Model tab)
- PURGE draait meerdere keren voor nested references

