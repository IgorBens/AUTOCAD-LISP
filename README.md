# AUTOCAD-LISP

AutoCAD LISP scripts collection - each project in its own folder.

## Projects

### 🔥 [vloerverwarming](./vloerverwarming/)
Automatic underfloor heating circuit generator
- Creates 50mm inner contour
- Generates offset loops for heating circuits
- Command: `VV`

### 📐 [vloerverwarming-oppervlakte](./vloerverwarming-oppervlakte/)
Floor heating area calculator
- Select multiple floor heating polylines
- Calculates area of each polyline
- Shows total area in m²
- Command: `VVO`

## Structure

Each project lives in its own folder:
```
/
├── vloerverwarming/
│   └── vloerverwarming.lsp
├── vloerverwarming-oppervlakte/
│   └── oppervlakte.lsp
├── [next-project]/
│   └── ...
└── README.md
```

## Usage

1. Load the desired `.lsp` file in AutoCAD: `(load "path/to/script.lsp")`
2. Use the command listed in the project description

## Adding New Projects

Just create a new folder for each project and add your `.lsp` files there!
