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

### 🧹 [template-cleanup](./template-cleanup/)
**Clean AutoCAD template** - Use at end of project
- Cleans up .dwg file for final delivery
- Removes unnecessary elements
- Command: `CLEANTEMPLATE`

### 🔧 [thermoduct-tools](./thermoduct-tools/)
**Floor heating design library** - Structured data management
- Define rooms with heating parameters
- Attach loops (circuits) to rooms
- Measure pipe lengths and generate summaries
- No auto-drawing - you maintain full control
- Commands: `TD_ROOMDEF`, `TD_LOOPDEF`, `TD_LISTROOMS`, `TD_LISTLOOPS`

## Workflow

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
├── template-cleanup/
│   └── clean-template.lsp
├── thermoduct-tools/
│   ├── thermoduct-tools.lsp
│   └── README.md
└── README.md
```

## Usage

Load the desired `.lsp` file in AutoCAD:
```lisp
(load "path/to/script.lsp")
```

Then use the command listed in the project description.
