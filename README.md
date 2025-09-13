# How to Use — AMS 595 Project1

This repository contains three MATLAB scripts for estimating π using Monte Carlo methods.  

---

## Requirements
- **MATLAB** R2016b or later (no toolboxes required).
- Place the `.m` files in the **same folder** and `cd` into that folder in MATLAB.

---

## Quick Start
Open MATLAB, change to the folder containing the scripts, and run the commands shown below.

```matlab
% Example: change to the project folder
cd('path/to/your/folder');
```

---

## 1) Task 1 — For-loop with timing & plots
**Run:**
```matlab
mc_pi_task1
```
**What it does:**
- Uses a **for-loop** with fixed sample counts.
- Shows a **running estimate** of π and a plot of **absolute error vs. sample size**.
- Measures **runtime** for different \(N\) values and plots **precision vs. computation cost**.
- Prints a small table (`N`, `Time_s`, `AbsError`) in the Command Window.

**Optional parameters:**
- `N_max`: length of the running estimate.
- `N_values`: list of sample sizes used for timing/accuracy sweeps.
- `rng(123)`: fixed seed for reproducibility (change to `rng('shuffle')` for fresh randomness).

---

## 2) Task 2 — While-loop to a target number of significant figures
**Run:**
```matlab
mc_pi_task2
```
**What it does:**
- Uses a **while-loop** to keep sampling until the estimate is stable to a given number of **significant figures** (without using the true value of π).
- Prints a results table with columns: `SigFigs`, `N`, `pi_hat`, `CI_half`, `Rounded`.
- Displays a figure showing the **final 95% CI** for each target significant-figure level.

**Optional parameters:**
- `sigfigs_list`: e.g., `[2 3 4]`.
- `z`: confidence multiplier (default `1.96` for 95%).
- `batch`: samples drawn per iteration (speed vs. refresh).
- `maxN`: safety cap on total samples.

---

## 3) Task 3 — Function with live scatter plot (returns π estimate)
**Call from the Command Window:**
```matlab
pi_est = mc_pi_task3(3);   % example: target 3 significant figures
```
**Behavior:**
- Plots random points in \\([0,1]^2\\) live; points **inside** the quarter circle are one color, **outside** another.
- Stops automatically when the estimate is stable to the requested **significant figures**.
- Prints the rounded value to the **Command Window** and annotates it on the **figure**.
- Returns the unrounded estimate as `pi_est`.

**Optional parameters:**
- `batch`: samples per iteration (default `2000`).
- `plotCap`: max points kept on screen (default `2e4`) for performance.
- `maxN`: safety cap on total samples.
- `rng(123)`: change to `rng('shuffle')` for non-reproducible runs.

---

## Tips
- If plotting feels slow in Task 3, increase `batch` or reduce `plotCap`.
