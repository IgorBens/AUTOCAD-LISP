# Vloerverwarming

Automatisch vloerverwarming kringen maken.

## Gebruik

```lisp
(load "vloerverwarming.lsp")
```

Type in AutoCAD: `VV`

## Workflow

1. Selecteer een object (rechthoek, polyline, etc.)
2. Geef offset afstand (bijv. 100 of 150mm)
3. Klaar! Script maakt:
   - 50mm contour naar binnen (als rand)
   - Zoveel mogelijk offset loops naar binnen

## Parameters

- **Offset afstand**: 100-150mm is normaal voor vloerverwarming
- Script stopt automatisch als er geen ruimte meer is

## Voorbeeld

```
Input: Rechthoek 5000x3000mm
Offset: 150mm
Result:
  - 1x rand (50mm)
  - ~15-20 loops (150mm spacing)
```
