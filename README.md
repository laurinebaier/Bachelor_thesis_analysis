# Locust Behavioral Analysis Pipeline

MATLAB scripts for analyzing ***Schistocerca gregaria*** behavioral data on phase polymphenism and juvenile hormone signaling (Bachelor's thesis).

## 📋 **Requirements**
- **MATLAB** (Statistics Toolbox required).
- **Raw data**: `~/.../{gregarious,solitarious}/[animal]_[treatment]_[date]/tracked.csv` + `annotation.mat`.
- Adjust paths (e.g., `cd ~/.../plot/`).

> [!TIP]  
> Ensure `01PIdata.mat` exists (from prior preprocessing).

## 🔄 **Execution Order**

1. **`ArenaAnalysis02plotting.m`** – Computes **PoolData** (PIs, distances), initial plots (*optional: comment out*), `PIdaten.csv`.  
   *Essential for PoolData generation.*

2. **`locusttable.m`** – Creates/saves **`tablelocustdata.mat`** + `WalkingLong` from PoolData.

3. **`locustdata.m`** – Trajectories & **Heatmaps** (uses `loadAndAlign.m`, `getTreatmentFromGreg.m/Soli.m`).

4. **`statswalkingdistance.m`** – **Walking stats** (normality, ANOVA/KW, t-tests), custom boxplot.

5. **`statsPIsimple.m`** – Simple PI stats & CSVs.

6. **`statsPI15to15.m`** – Shelter PI stats.

7. **`plotwalkingdistanceviolin.m`** – **Violin plots** (loads `tablelocustdata.mat`).

## 📊 **Outputs**
- **Plots**: Figures (PNG in `experiments/plots/`), heatmaps, boxplots/violins.
- **Tables/CSVs**: `tablelocustdata.mat`, `PIdaten.csv` (Downloads/, experiments/).

## 🎯 **Metrics & Treatments**

| **Metric** | **Description** |
|------------|-----------------|
| PI simple | Left vs. right arena half |
| PI15/PI15to15 | Frames in stimulus/control ROIs (shelters) |
| Walking Distance | Total path length (m) |

**Phases**: gregarious 🟢, solitarious 🟣  
**Treatments**: `control_locust_saline`, `methoprene`, `control_DMSO`, `precocene_II`, `control_untreated`.

## ⚠️ **Notes**
> [!WARNING]  
> Skip ArenaAnalysis02plotting.m figures? Comment out plotting sections (from "Plotting 1."), manually save PoolData.

> [!CAUTION]  
> `pxpercm = 38.8` in locustdata.m must be calibrated **per camera/arena** using Fiji/ImageJ (pixel-to-cm conversion for heatmaps).

