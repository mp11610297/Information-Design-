# README: Monopolistic Screening & Welfare Analysis

## Overview

This project analyses optimal taxation and redistribution in a two-type
monopolistic screening model. A monopolist serves high- and low-valuation
consumers, extracts profit, and redistributes it as a Universal Basic
Income (UBI). Social welfare is evaluated under a spectrum of planning
criteria parameterized by a weight alpha on low-type consumers.

Three files form the core of the analysis:

---

## File 1: `screening_problem.m`

### What it does
Solves the monopolist's optimal screening problem for a given population
share of low types, lambda. Returns the optimal quantities, prices,
consumer utilities, and total profit.

### Model
- Two consumer types: theta_H = 10 (high), theta_L = 3 (low)
- Share lambda of consumers are low type; (1 - lambda) are high type
- Consumer utility: U(q, p) = theta * q - p
- Cost function: c(q) = (1/2) * q^2

### Key results
- High type always receives the first-best quantity: q_H* = theta_H
- Low type quantity is distorted downward to reduce informational rents:

      q_L* = max(0, theta_L - ((1 - lambda) / lambda) * (theta_H - theta_L))

- Low type is excluded (q_L* = 0) when lambda < 1 - theta_L/theta_H = 0.70
- Low type IR binds: U_L = 0
- High type earns an information rent: U_H = (theta_H - theta_L) * q_L*

### Inputs
| Argument | Description |
|----------|-------------|
| `lambda` | Share of low types in [0, 1] |

### Outputs
| Output | Description |
|--------|-------------|
| `q_H_star` | Optimal quantity for high type |
| `q_L_star` | Optimal quantity for low type (0 if excluded) |
| `p_H_star` | Optimal price for high type |
| `p_L_star` | Optimal price for low type |
| `U_H` | High-type consumer utility (information rent) |
| `U_L` | Low-type consumer utility (= 0 at optimum) |
| `total_profit` | Monopolist's total profit (= UBI transfer) |
| `theta_H` | High-type valuation (returned for reference) |
| `theta_L` | Low-type valuation (returned for reference) |

### Dependencies
None. 
---

## File 2: `welfare_alpha.m`

### What it does
Evaluates social welfare across a grid of lambda values under three
ethical criteria, each parameterized by alpha. Produces four figures
and a console summary table.

### Welfare criteria
```
Randian:      W = (1 - lambda) * (1 - alpha) * (V_H + UBI)
Utilitarian:  W = lambda * alpha * (V_L + UBI)
                + (1 - lambda) * (1 - alpha) * (V_H + UBI)
Rawlsian:     W = lambda * alpha * (V_L + UBI)
```

Note: Utilitarian = Randian + Rawlsian exactly, for any alpha.

### Alpha values evaluated
| alpha | Label | Interpretation |
|-------|-------|----------------|
| 0 | Randian | Full weight on high types |
| 0.5 | Utilitarian | Symmetric / neutral |
| 1 | Rawlsian | Full weight on low types |

### UBI redistribution
Total monopoly profit pi(lambda) is fully redistributed as UBI:

    UBI = pi(lambda)
    V_H_tax = V_H + UBI
    V_L_tax = V_L + UBI

### Figures produced
| Figure | Content |
|--------|---------|
| 1 | Three diagonal welfare criteria (Randian alpha=0, Utilitarian alpha=0.5, Rawlsian alpha=1) |
| 2 | Overlay of all alpha values, one panel per criterion |
| 3 | Randian vs Rawlsian ideology gap by alpha |
| 4 | Normalized welfare [0,1] for all criteria and alpha values |

### Console output
- Welfare values at lambda = 0.3, 0.5, 0.7 for each (alpha, criterion) pair
- Expected welfare table: E[W], argmax lambda, argmin lambda

### Dependencies
Requires `screening_problem.m` in the MATLAB path.

---

## File 3: `secant_tangent.m`

### What it does
Searches for a line that is tangent to the Randian welfare curve on the
lower hump segment (lambda > lambda_kink = 0.70) using a 2D grid scan
over left-pin and right-endpoint pairs.

### Method
A secant line connecting (lambda_L, W(lambda_L)) to (lambda_R, W(lambda_R))
is tangent to the curve at lambda_R if and only if:

    secant slope = dW/dlambda at lambda_R

The gap function measures how close a pair is to satisfying this:

    gap(lambda_L, lambda_R) = |secant slope - dW/dlambda at lambda_R|

The algorithm:
1. Sweep lambda_L over [0.60, 0.99] in steps of 0.005
2. For each lambda_L, sweep lambda_R over [0.60, 0.99], requiring lambda_R > lambda_L + 0.01
3. Compute gap for every valid (lambda_L, lambda_R) pair
4. Find the pair with the smallest gap — this is the best tangent

### Grids
| Variable | Range | Step |
|----------|-------|------|
| lambda_L (left pin) | [0.60, 0.99] | 0.005 |
| lambda_R (right endpoint) | [0.60, 0.99] | 0.005 |

### Key outputs (console)
- Best (lambda_L*, lambda_R*) pair and its slope
- Gap at optimum (how close to exact tangency)
- Top 5 distinct candidates

### Figures produced
| Figure | Content |
|--------|---------|
| 1 (left) | Heatmap of gap matrix — dark = small gap = good tangent candidate |
| 1 (middle) | Gap vector for best lambda_L, sweeping over lambda_R |
| 1 (right) | Signed gap showing zero crossing at lambda_R* |
| 2 | Clean plot: blue welfare curve + red tangent line + endpoint markers |



### Dependencies
Requires `screening_problem.m` in the MATLAB path.

---


All scripts call `screening_problem.m` via the wrapper `get_screening_solution`
defined at the bottom of each file. Ensure `screening_problem.m` is on the
MATLAB path before running.

---

## Parameter summary

| Parameter | Value | Description |
|-----------|-------|-------------|
| theta_H | 10 | High-type valuation |
| theta_L | 3 | Low-type valuation |
| lambda_kink | 0.70 | Exclusion threshold (= 1 - theta_L/theta_H) |
| lambda grid | [0.05, 0.95] step 0.05 | Welfare evaluation grid |
| alpha values | {0, 0.5, 1} | Ethical weight on L-types |
