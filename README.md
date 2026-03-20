# Power BI Luminance & Contrast Checker

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Power BI](https://img.shields.io/badge/Power%20BI-Contrast%20Toolkit-yellow.svg)
![WCAG](https://img.shields.io/badge/WCAG-2.1%20Compliant-blue.svg)
![Status](https://img.shields.io/badge/Status-Active-brightgreen.svg)

A lightweight toolkit for checking **WCAG 2.x contrast ratios** inside Power BI.  
It includes:

- DAX helpers for relative luminance, contrast ratio, and a **nearest passing colour** suggestion  
- A Power Query (M) function to pre‑compute luminance from HEX colours  
- A ready‑to‑use PBIX example and sample foreground/background palettes  

WCAG defines contrast ratio as **(L1 + 0.05) / (L2 + 0.05)** with a numeric range of **1–21**.  
Common targets: **4.5:1** (normal text), **3:1** (large text), **7:1** (enhanced).  
Relative luminance uses sRGB → linear RGB conversion and the weighted formula  
**Y = 0.2126R + 0.7152G + 0.0722B**, using the current gamma threshold **0.04045**.

## What’s in this repository
src/
dax/
HexLuminance.dax
ColorDistance2.dax
Measures.dax
powerquery/
fxHexLuminance.pq
Background HEX Sample.csv
Foreground HEX Sample.csv
Luminance Contrast Checker.pbix
LICENSE
README.md

The DAX helpers are designed for DAX Query View / DAX Studio / Tabular Editor.  
Power BI Desktop does not persist DEFINE FUNCTION blocks, so `Measures.dax` includes fully inline formulas.  
The Power Query function precomputes luminance for improved performance.

## WCAG Background

- Contrast ratio: (L1 + 0.05) / (L2 + 0.05), where L1 ≥ L2 (range: 1–21)  
- Minimum targets: **4.5:1** for normal text, **3:1** for large text  
- Enhanced techniques often use **7:1**  
- Relative luminance uses sRGB → linear conversion with threshold **0.04045**

## Quick Start (PBIX Demo)

1. Open the included PBIX file.  
2. Use slicers to choose foreground and background colours.  
3. View the computed contrast ratio.  
4. If a pair fails, the **Nearest Passing HEX** measure suggests an accessible alternative.

## Use in Your Own Report

### Option A — Power Query (Precompute Luminance)

1. In Power Query, add a Blank Query and paste `fxHexLuminance.pq`, naming it **fxHexLuminance**.  
2. Add a new column to your colour tables:  
   ```m
   Luminance = fxHexLuminance([Hex Code])
3. Create a contrast measure
   
Contrast Ratio =
VAR Lb = SELECTEDVALUE( Background[Luminance] )
VAR Lf = SELECTEDVALUE( Foreground[Luminance] )
RETURN IF(
    ISBLANK(Lb) || ISBLANK(Lf),
    BLANK(),
    DIVIDE(MAX(Lb, Lf) + 0.05, MIN(Lb, Lf) + 0.05)
)
4. Use visuals (Cards, Tables, Slicers) to explore contrast combinations.

### Option B — Pure DAX (inline)
Create simple measures that return the selected HEX values:

Hex (Background) = SELECTEDVALUE('BackgroundColours'[HexCode])
Hex (Foreground) = SELECTEDVALUE('ForegroundColours'[HexCode])

(Optional WCAG parameter for WCAG Level AA for Regular Text):
WCAG Target (User) = SELECTEDVALUE('WCAG Targets'[Ratio], 4.5)

Then use the generic measures included in Measures.dax:

Luminance Background (Generic)
Luminance Foreground (Generic)
Contrast Ratio (Generic)
Nearest Passing HEX (Generic)
Contrast Ratio (Proposed, Generic)

### Nearest Passing Colour
This project includes a Nearest Passing Colour feature that suggests an accessible alternative when your chosen foreground/background pair fails the WCAG target.
The repository already includes two sample palette files:

Background HEX Sample.csv
Foreground HEX Sample.csv

These serve as your colour pools. Import them into Power BI (or replace them with your own lists).
The DAX logic will automatically:

Detect whether your current colour pair passes WCAG
Search the combined list of all HEX values
Suggest the nearest accessible alternative (foreground first, then background)
Use squared RGB distance to determine “closeness”

Display the suggestion using a Card visual bound to Nearest Passing HEX (Generic).
Use Contrast Ratio (Proposed, Generic) to see the ratio achieved by the suggested colour.

### Folder Structure

src/dax/HexLuminance.dax — DAX luminance helper
src/dax/ColorDistance2.dax — RGB distance helper
src/dax/Measures.dax — Inline luminance, contrast, and suggestion measures
src/powerquery/fxHexLuminance.pq — Power Query luminance function
Sample palette CSV files
Example PBIX file

### Limitations

Nearest-colour logic uses squared RGB distance, not perceptual Lab/ΔE
HEX must be provided as #RRGGBB, RRGGBB, or #RGB
DEFINE FUNCTION DAX helpers cannot be stored inside PBIX models
WCAG contrast rules exclude decorative text and logos

### Contributing
Pull requests and issues are welcome.
If proposing formula changes, please include WCAG references and a before/after example.
