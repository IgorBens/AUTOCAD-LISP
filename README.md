# AUTOCAD-LISP

AutoCAD LISP scripts collection - organized by workflow.

## Projects

### 🖊️ [vloerverwarming-tekenen](./vloerverwarming-tekenen/)
**Draw floor heating circuits** - Use at start of project
- Creates 50mm inner contour from zone
- Generates offset loops for heating circuits
- Automatically assigns to correct layers
- Command: `VV`

### 📐 [vloerverwarming-oppervlakte](./vloerverwarming-oppervlakte/)
**Calculate floor heating area** - Use at end of drawing
- Select multiple floor heating polylines
- Calculates total area in m²
- Works with non-closed polylines
- Command: `VVO`

### 📊 [summary-table](./summary-table/)
**Generate project summary table** - Use throughout project
- Collects data from VV and FHAREA commands
- Add existing zones retroactively with TD_ADDZONE
- Generates comprehensive summary table
- Creates dedicated SUMMARY layout
- Commands: `TD_PROJECT`, `TD_ADDZONE`, `TD_SUMTAB`, `TD_SHOWDATA`, `TD_CLEARDATA`

### 🧹 [template-cleanup](./template-cleanup/)
**Clean AutoCAD template** - Use at end of project
- Cleans up .dwg file for final delivery
- Removes unnecessary elements
- Command: `CLEANTEMPLATE`

## Workflow

### Recommended Workflow

1. **Setup:** Load `summary-table` module first (optional but recommended)
2. **Project Info:** Use `TD_PROJECT` to set project number and name
3. **Draw:** Use `vloerverwarming-tekenen` (`VV`) to draw floor heating circuits
4. **Calculate:** Use `vloerverwarming-oppervlakte` (`FHAREA`/`FHAREA2`) to get areas
5. **Repeat:** Steps 3-4 for each zone/room (data is collected automatically)
6. **Summary:** Use `TD_SUMTAB` to generate comprehensive summary table
7. **Finish:** Use `template-cleanup` to prepare final .dwg

### Quick Workflow (without summary)

1. **Start:** Use `vloerverwarming-tekenen` to draw floor heating
2. **Calculate:** Use `vloerverwarming-oppervlakte` to get total area
3. **Finish:** Use `template-cleanup` to prepare final .dwg

## Structure

```
/
├── vloerverwarming-tekenen/
│   └── vloerverwarming.lsp
├── vloerverwarming-oppervlakte/
│   └── area-calculator.lsp
├── summary-table/
│   ├── summary-table.lsp
│   └── README.md
├── template-cleanup/
│   └── clean-template.lsp
└── README.md
```

## Usage

### Basic Usage

Load the desired `.lsp` file in AutoCAD:
```lisp
(load "path/to/script.lsp")
```

Then use the command listed in the project description.

### With Summary Table

For full project tracking and summary table generation:

```lisp
;; 1. Load summary table module first
(load "summary-table/summary-table.lsp")

;; 2. Load working commands (they will integrate automatically)
(load "vloerverwarming-tekenen/vloerverwarming.lsp")
(load "vloerverwarming-oppervlakte/area-calculator.lsp")

;; 3. Set project info (optional)
;; Command: TD_PROJECT

;; 4. Use VV and FHAREA commands as normal
;; They will prompt for zone/room names to collect data

;; 5. Generate summary table when ready
;; Command: TD_SUMTAB
```

See [summary-table/README.md](./summary-table/README.md) for detailed documentation.
