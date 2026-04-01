# ECG-PWave-Detection

QRS removal and P-wave enhancement from QT Database (sel33.dat, 250Hz ch1).

## Overview
Implements preprocessing for P-wave delineation:
- QRS replacement (110ms linear interpolation)
- 3-11Hz linear-phase bandpass filtering
- Adaptive P-search windows (2/9 mean RR pre-QRS)
- Ensemble average of P segments

**Academic project**: Biomedical signal processing assignment.

## Requirements
- MATLAB
- Signal Processing Toolbox
- `sel33.dat`, `sel33.q1c` (QTdb)
- `coeff.mat` (filter coeffs)

## Usage
```matlab
run('Main.m')
```
Generates 6 figures: raw spectra, QRS removal, filtering, P-search overlays.

## Pipeline
1. Parse annotations → QRS positions
2. Remove QRS → baseline
3. Filter 3-11Hz → P enhancement
4. Extract P-windows → average template

## Outputs
- Time: Raw → QRS-free → filtered
- Freq: Spectra pre/post
- P-waves: Individual + mean (black)

## Files
| File | Purpose |
|------|---------|
| `Main.m` | Complete analysis |
| `coeff.mat` | Bandpass filter coefficients |
| `sel33.dat` | ECG data |
| `sel33.q1c` | QRS annotations |

## Results
- Clean QRS suppression
- Enhanced P-waves visible pre-QRS
- Mean template shows typical P morphology

Run script for plots.
