# Thermoduct Tools Library

A structured AutoLISP library for floor heating design in AutoCAD.

## Overview

Thermoduct Tools helps you manage floor heating projects by:
- Defining rooms with heating parameters
- Attaching loops (circuits) to rooms
- Measuring pipe lengths
- Generating summaries

**Important**: This library does **not** auto-draw circuits. You draw all pipes manually. The library only manages data, measurements, and documentation.

## Installation

1. Load the library in AutoCAD:
   ```
   (load "thermoduct-tools.lsp")
   ```

2. Or add to your `acaddoc.lsp` for automatic loading:
   ```lisp
   (load "C:/path/to/thermoduct-tools.lsp")
   ```

## Available Commands

### TD_ROOMDEF - Define a Room

Define a room with floor heating parameters.

**Workflow:**
1. Type `TD_ROOMDEF` at the command line
2. Select a closed polyline representing the room contour
3. Enter room parameters:
   - **Room name**: e.g., "Badkamer", "Woonkamer"
   - **Collector number**: e.g., 1, 2, 3
   - **Pipe diameter**: in mm, e.g., 16, 20
   - **Spacing**: in mm, e.g., 100, 150
   - **Floor type**: e.g., "tacker", "staalnet", "fermacell"
4. The command calculates the area and stores the room data

**Example:**
```
Command: TD_ROOMDEF
Select polyline: [select room contour]
Enter room name: Badkamer
Enter collector number: 1
Enter pipe diameter (mm, e.g., 16 or 20): 16
Enter spacing (mm, e.g., 100 or 150): 100
Enter floor type: tacker

========================================
 Room Defined Successfully!
========================================
 Room Name     : Badkamer
 Collector     : 1
 Diameter      : 16 mm
 Spacing       : 100 mm
 Floor Type    : tacker
 Area          : 8.50 sq units
========================================
```

### TD_LOOPDEF - Define Loops

Define one or more loops (circuits) for a room.

**Workflow:**
1. Type `TD_LOOPDEF` at the command line
2. Enter the room name
3. Confirm or change the collector number
4. Select one or more polylines representing loops
5. The command:
   - Sorts loops from left to right (by X coordinate)
   - Assigns sequential indices (1, 2, 3, ...)
   - Generates loop names: `{collector}-{index}` (e.g., "1-1", "1-2")
   - Calculates the length of each loop
   - Stores all loop data

**Example:**
```
Command: TD_LOOPDEF
Enter room name: Badkamer
Room found. Default collector: 1
Use default collector? [Yes/No] <Yes>: Yes
Select loop polylines: [select multiple polylines]

========================================
 Loops Defined Successfully!
========================================
 Room          : Badkamer
 Number of Loops: 3
----------------------------------------
 Loop 1-1: 68.40 units
 Loop 1-2: 72.15 units
 Loop 1-3: 65.80 units
----------------------------------------
 Total Length  : 206.35 units
========================================
```

### TD_LISTROOMS - List All Rooms

Display all defined rooms with their basic information.

**Example:**
```
Command: TD_LISTROOMS

========================================
 Defined Rooms
========================================
 Badkamer - Collector: 1 - Area: 8.50 sq units
 Woonkamer - Collector: 2 - Area: 24.30 sq units
========================================
```

### TD_LISTLOOPS - List All Loops

Display all defined loops with their information.

**Example:**
```
Command: TD_LISTLOOPS

========================================
 Defined Loops
========================================
 Loop 1-1 - Room: Badkamer - Length: 68.40 units
 Loop 1-2 - Room: Badkamer - Length: 72.15 units
 Loop 1-3 - Room: Badkamer - Length: 65.80 units
========================================
```

### TD_CLEARALL - Clear All Data

Reset the library by clearing all room and loop data.

**Example:**
```
Command: TD_CLEARALL
Clear all room and loop data? [Yes/No] <No>: Yes
All data cleared successfully.
```

## Data Structure

### Room Records

Each room is stored as an association list with the following keys:

| Key | Type | Description |
|-----|------|-------------|
| NAME | String | Room name |
| COLLECTOR | Integer | Collector number |
| DIAMETER | Integer | Pipe diameter in mm |
| SPACING | Integer | Spacing between pipes in mm |
| FLOOR | String | Floor type |
| AREA | Real | Calculated area in drawing units |
| CONTOUR | Entity | Entity name of the room contour polyline |

**Example:**
```lisp
'((NAME . "Badkamer")
  (COLLECTOR . 1)
  (DIAMETER . 16)
  (SPACING . 100)
  (FLOOR . "tacker")
  (AREA . 8.5)
  (CONTOUR . <Entity name: ...>))
```

### Loop Records

Each loop is stored as an association list with the following keys:

| Key | Type | Description |
|-----|------|-------------|
| ROOM | String | Associated room name |
| COLLECTOR | Integer | Collector number |
| INDEX | Integer | Loop index (1-based) |
| NAME | String | Loop name (format: "collector-index") |
| LENGTH | Real | Calculated length in drawing units |
| ENTITY | Entity | Entity name of the loop polyline |

**Example:**
```lisp
'((ROOM . "Badkamer")
  (COLLECTOR . 1)
  (INDEX . 1)
  (NAME . "1-1")
  (LENGTH . 68.4)
  (ENTITY . <Entity name: ...>))
```

## Global Variables

The library uses two global variables to store data:

- **`*td-rooms*`**: List of all room records
- **`*td-loops*`**: List of all loop records

These variables persist during your AutoCAD session and can be accessed programmatically if needed.

## Helper Functions

All helper functions are prefixed with `td-` and include:

### Room-related Functions
- `td-add-room-record`: Add a room to the database
- `td-get-polyline-area`: Calculate polyline area
- `td-print-room-summary`: Display room information
- `td-find-room-by-name`: Find a room by name
- `td-find-room-by-contour`: Find a room by its contour entity

### Loop-related Functions
- `td-add-loop-record`: Add a loop to the database
- `td-get-polyline-length`: Calculate polyline length
- `td-get-polyline-center`: Get the geometric center of a polyline
- `td-sort-loops-by-x`: Sort loops by X coordinate (left to right)
- `td-print-loops-summary`: Display loop information

## Typical Workflow

1. **Draw your floor plan** with room contours as closed polylines
2. **Define rooms** using `TD_ROOMDEF` for each room
3. **Draw heating loops** manually as polylines within each room
4. **Define loops** using `TD_LOOPDEF` to attach them to rooms
5. **Review data** using `TD_LISTROOMS` and `TD_LISTLOOPS`
6. **Generate reports** (future feature - to be implemented)

## Design Principles

- **No automatic drawing**: You maintain full control over geometry
- **Data-driven**: Focus on capturing and organizing information
- **Simple workflow**: Intuitive commands that follow AutoCAD conventions
- **Clean code**: Well-documented, maintainable AutoLISP code
- **Standard AutoLISP**: No external dependencies

## Future Enhancements

Potential features for future versions:
- Summary report generation
- Export to Excel/CSV
- Material calculation
- Cost estimation
- Visualization of collector assignments
- Loop validation (min/max lengths)

## Version History

### Version 1.0 (Current)
- Initial release
- Room definition with parameters
- Loop definition with automatic sorting and naming
- Basic listing commands
- Data management utilities

## License

This library is part of the AUTOCAD-LISP repository.

## Support

For issues, questions, or contributions, please refer to the main repository documentation.
