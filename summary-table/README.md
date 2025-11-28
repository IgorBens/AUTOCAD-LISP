# Summary Table Module

This module provides data collection and summary table generation for floor heating projects in AutoCAD.

## Overview

The summary table system collects data from various floor heating commands (VV, FHAREA, etc.) and generates a comprehensive summary table in a dedicated layout.

## Features

- **Global Data Collection**: Stores results from multiple commands in a persistent global variable
- **Automatic Layout Creation**: Creates a "SUMMARY" layout if it doesn't exist
- **Formatted Summary Table**: Displays project information, zones, areas, and manifolds in an organized MText table
- **Optional Data Entry**: Commands can optionally skip data collection if desired

## Installation

1. Load the summary table module first:
   ```lisp
   (load "summary-table/summary-table.lsp")
   ```

2. Load your working commands (they will automatically integrate with the summary system):
   ```lisp
   (load "vloerverwarming-tekenen/vloerverwarming.lsp")
   (load "vloerverwarming-oppervlakte/area-calculator.lsp")
   ```

## Commands

### TD_PROJECT
Set project information for the summary table.

**Usage:**
```
Command: TD_PROJECT
Enter project number: 2024-001
Enter project name (optional): Residential Building
```

**Purpose:** Stores project identification information that will appear at the top of the summary table.

---

### TD_SUMTAB
Create the summary table in a SUMMARY layout.

**Usage:**
```
Command: TD_SUMTAB
Click insertion point for summary table: [click point]
```

**What it does:**
1. Creates a "SUMMARY" layout if it doesn't exist
2. Switches to the SUMMARY layout
3. Prompts for an insertion point
4. Creates an MText object with all collected data

**Summary includes:**
- Project number and name
- Total number of zones
- Total heating loops created
- Total area covered
- Number of manifolds
- Detailed breakdown by zone
- Detailed breakdown by room/area
- Manifold information

---

### TD_SHOWDATA
Display all collected data in the command line (for debugging/verification).

**Usage:**
```
Command: TD_SHOWDATA
```

**Output:** Lists all collected data entries with their types and values.

---

### TD_CLEARDATA
Clear all collected data from memory.

**Usage:**
```
Command: TD_CLEARDATA
```

**Warning:** This removes all collected data. You'll need to re-run your commands to collect data again.

---

## Integration with Existing Commands

The following commands have been enhanced to optionally collect data:

### VV (Floor Heating Circuits)
After creating heating circuits, you'll be prompted:
```
Geef zone naam voor samenvatting (of Enter om over te slaan):
```

Enter a zone name (e.g., "Woonkamer", "Slaapkamer 1") to store:
- Zone name
- Number of loops created
- Pipe spacing distance

Press Enter to skip data collection.

### FHAREA / FHAREA2 (Area Calculation)
After calculating areas, you'll be prompted:
```
Geef ruimte naam voor samenvatting (of Enter om over te slaan):
```

Enter a room name to store:
- Room/area name
- Total calculated area
- Number of polylines measured

Press Enter to skip data collection.

## Workflow Example

### Basic Workflow

1. **Set Project Info** (optional but recommended):
   ```
   TD_PROJECT
   Project number: 2024-042
   Project name: Villa Jansen
   ```

2. **Create Floor Heating Zones**:
   ```
   VV
   [select zone contour]
   [specify spacing: 150]
   Zone name: Woonkamer
   ```

3. **Calculate Areas**:
   ```
   FHAREA
   [select polylines]
   Room name: Woonkamer
   ```

4. **Repeat** for additional zones and rooms

5. **Generate Summary Table**:
   ```
   TD_SUMTAB
   [click insertion point in drawing]
   ```

### Advanced Workflow

You can also:
- Check collected data anytime: `TD_SHOWDATA`
- Clear and restart: `TD_CLEARDATA`
- Skip data collection for specific zones (just press Enter when prompted)
- Add manifold data programmatically using `td-add-manifold` function

## Data Structure

The module uses a global variable `*td-summary-data*` that stores data as:

```lisp
(
  ("PROJECT" ((number . "2024-042") (name . "Villa Jansen")))
  ("ZONE" ((name . "Woonkamer") (loops . 15) (spacing . 150.0)))
  ("AREA" ((room . "Woonkamer") (area . 45.5) (polylines . 3)))
  ("MANIFOLD" ((name . "M1") (location . (x y z)) (circuits . 8)))
)
```

## Helper Functions

For advanced users and scripting:

### Data Collection Functions
- `(td-add-zone zone-name loop-count pipe-spacing)` - Add zone data
- `(td-add-area room-name area poly-count)` - Add area data
- `(td-add-manifold manifold-name location circuit-count)` - Add manifold data
- `(td-set-project project-num project-name)` - Set project info
- `(td-clear-data)` - Clear all data

### Data Query Functions
- `(td-get-entries entry-type)` - Get all entries of a specific type ("ZONE", "AREA", etc.)
- `(td-get-project)` - Get project information
- `(td-calc-total-area)` - Calculate total area from all AREA entries
- `(td-count-zones)` - Count total zones
- `(td-count-manifolds)` - Count total manifolds
- `(td-calc-total-loops)` - Calculate total loops across all zones

## Tips

1. **Load Order**: Always load `summary-table.lsp` before other commands for full integration
2. **Optional Entry**: You can always press Enter to skip data collection if you don't want to track a particular zone/area
3. **Multiple Tables**: Run `TD_SUMTAB` multiple times to place the summary in different locations/layouts
4. **Data Persistence**: Data persists during your AutoCAD session until cleared with `TD_CLEARDATA`
5. **Backup**: Consider using `TD_SHOWDATA` to review your data before generating the table

## Troubleshooting

**Q: Commands don't prompt for zone/room names**
- A: Make sure you loaded `summary-table.lsp` first

**Q: TD_SUMTAB says "No data collected yet"**
- A: You need to run VV or FHAREA commands and enter names when prompted

**Q: I want to start over**
- A: Use `TD_CLEARDATA` to remove all collected data

**Q: Can I edit the summary table after creation?**
- A: Yes! It's just an MText object. Double-click to edit or run `TD_SUMTAB` again to create a new one

## Future Enhancements

Possible improvements:
- Export to Excel/CSV
- Store data in drawing database (XDATA/Dictionary) for persistence between sessions
- Interactive table editing
- Graphical zone visualization
- Automatic manifold detection
