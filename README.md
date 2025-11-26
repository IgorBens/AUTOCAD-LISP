# AUTOCAD-LISP

AutoCAD LISP scripts voor vloerverwarming en template beheer.

## Scripts

### 1. vloerverwarming.lsp
Automatisch vloerverwarming kringen maken.

**Gebruik:**
1. Laad het script in AutoCAD: `(load "vloerverwarming.lsp")`
2. Type `VV` in de command line
3. Selecteer een object (rechthoek, polyline, etc.)
4. Geef offset afstand op (bijv. 100 of 150mm)

**Functionaliteit:**
- Maakt automatisch 50mm contour naar binnen (als rand)
- Offset vanaf die contour verder naar binnen zoveel mogelijk keer

### 2. clean-template.lsp
DWG template schoonmaken door ongewenste elementen te verwijderen.

**Gebruik:**
1. Open je template DWG in AutoCAD
2. Laad het script: `(load "clean-template.lsp")`
3. Type `CLEANTEMPLATE` in de command line
4. Bevestig de actie

**Functionaliteit:**
- Verwijdert alle elementen BEHALVE de layers die je wilt behouden
- Standaard behouden layers:
  - VLOERVERWARMING (floor heating)
  - MUREN / WANDEN (walls)
  - COLLECTOR
  - LEIDINGEN (pipes)
- Purge alle ongebruikte blocks, styles, layers, etc.
- Audit de tekening voor errors

**Aanpassen:**
Open `clean-template.lsp` en pas de `keep_layers` lijst aan (regel 16-24) met jouw specifieke layer namen.

## Installatie

### In AutoCAD
```lisp
(load "C:/path/to/vloerverwarming.lsp")
(load "C:/path/to/clean-template.lsp")
```

### Autoload (acaddoc.lsp)
Maak een `acaddoc.lsp` bestand in je AutoCAD support folder:
```lisp
(load "C:/path/to/vloerverwarming.lsp")
(load "C:/path/to/clean-template.lsp")
(princ "\nCustom scripts geladen!")
```

## Buiten AutoCAD gebruiken

Om deze scripts buiten AutoCAD te gebruiken, kun je:

1. **OpenLISP** - Open source LISP interpreter
2. **AutoCAD Core Console** - Command line versie van AutoCAD
3. **LibreCAD** - Ondersteunt beperkte LISP functionaliteit
4. **BricsCAD** - Heeft volledige LISP support

De scripts gebruiken AutoCAD specifieke commando's (`command`, `entsel`, etc.), dus volledige compatibiliteit vereist een CAD engine.
