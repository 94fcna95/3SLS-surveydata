# Three-Stage Least Squares (3SLS) Implementation in R

## Summary

This repository contains the code accompanying research studying **meritocracy dynamics, migration decisions, and preferences for redistribution** in China. All main functions and dependencies required to apply the **3SLS estimation methodology** using R are available in this repository, along with comprehensive examples. _Xun Zhou and Michel Lubrano (2026) Meritocracy and preference for redistribution in China: the impact of internal migrations. AMSE Working Paper._

The implementation provides novel extensions to standard 3SLS estimations available in the R package _systemfit_:
- **Sub-sampling capability** for equation-specific sample restrictions via `subset()` syntax
- **Full weight support** (essential for survey data)
- **Flexible instrumental variable specification**
- **Comprehensive LaTeX output** for academic papers
- **Robust variance estimation** with multiple covariance options
- **Reduced-form analysis** and structural inference tools
- **Complete diagnostic suite** (residuals, correlations, fitted values)
- **For compatibility reasons**, the calling syntax is very similar to that of systemfit

The code is compatible with most survey data structures and can be applied to various research questions. Two illustrative examples are provided. The code has been optimized for use with large survey datasets (10 000+ observations in the quoted paper).

> For installation and a quick start, see [QUICKSTART.md](QUICKSTART.md).

---

## Key Features

### Core Functions

**`threeSLS_system()`** — Main 3SLS estimation function
- Estimates structural equation systems using three-stage least squares
- Supports equation-specific sample restrictions via `subset()` syntax
- Handles survey weights directly in the estimation
- Returns complete coefficient vectors, variance-covariance matrices, residuals, fitted values
- Includes both ML and robust variance estimates

**`reduced_form_3SLS()`** — Reduced form computation
- Computes the reduced form from structural parameters
- Calculates impact multipliers and elasticities
- Provides variance estimates for reduced-form coefficients
- Useful for policy simulation and counterfactual analysis

**`latex_structural_3SLS()`** & **`latex_reduced_3SLS()`** — LaTeX output
- Formats structural equation results in publication-ready LaTeX tables
- Includes significance stars, t-statistics, and R² values
- Supports both structural and reduced-form equations
- Compatible with `xtable` for document integration

---

## Repository Structure
```
├── README.md                          # This file
├── CONTRIBUTING.md                    # Contribution guidelines
├── QUICKSTART.md                      # Quick start guide
├── Deps.R                             # Central dependency loader
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore file
│
├── R/                                 # Core library functions
│   ├── CGT-3SLS-lib.r                 # Main 3SLS estimation & tools
│   ├── CGT-LaTex-lib.r                # LaTeX output functions
│   └── Meritocracy-lib.r              # Utility functions (POLS, Transl, EGP)
│
├── Examples/                          # Illustrative examples
│   ├── Example_Labor_Economics.R      # Teaching example 
│   ├── labor_data_generator.R         # Synthetic labor market data generator
│   └── Example_Meritocracy.R          # Research application (CGSS data required)
│
├── Data/                              # Data directory
│   └── README_DATA.md                 # Data documentation, licensing & variable guide
│
└── docs/                              # Additional documentation
└── VARIABLE_GUIDE.md              # Variable definitions & structure
```
---

## Research Application: Meritocracy Dynamics in China

### Research Questions

This project studies the interconnected dynamics of the desire for redistribution in a divided world of rural and urban individuals, each with distinct value systems. These two spheres are connected via migrants who seek better fortunes in urban hubs. To study this effect, we endogenise two types of migration and use 3SLS with weights and equation-specific subsampling, as migrants come only from the rural world.

1. **How do environmental shocks affect migration decisions?**
   - Seasonal migration (`Migs`) and long-term migration (`Migl`)
   - Sample restriction to rural populations

2. **What drives preferences for redistribution (`RP`)?**
   - Indirect effects through migration and meritocratic beliefs
   - Direct environmental effects

3. **How do meritocratic beliefs evolve?**
   - Merit-based factors (`FcM1`, `FcM2`): talent, education, work ethic
   - Non-merit factors (`FcAM`): family background, social networks, luck

### Structural Model

The research employs a 7-equation system estimated simultaneously. For the purpose of this demonstration, we simplify to a 3-equation model:

```r
eq1 = Migs ~ water + flood + age + female + linc + idlinc | subset(Urb == 0)
eq2 = Migl ~ water + flood + age + Single + linc + idlinc + Dif | subset(Urb == 0)
eq3 = RP   ~ water + party + lowerfin + linc + idlinc + Rur + Migs + Migl

equations <- list(Migs = eq1, Migl = eq2, RP = eq3)

inst = ~ water + flood + age + female + linc + idlinc + lowerfin + party + Dif + Rur + Single

fit <- threeSLS_system(equations = equations, inst = inst, data = Data3SLS, weights = weight)

summary(fit)
print(latex_structural_3SLS(fit, robust = TRUE))
```

**Key features of the specification:**
- **Endogenous variables:** `Migs`, `Migl`, `RP` — determined jointly
- **Exogenous variables:** `water`, `flood`, `age`, `female`, `linc`, `idlinc`, `lowerfin`, `party`, `Dif`
- **Sample restrictions:** Migration equations estimated only for rural residents (`Urb == 0`) via the `| subset()` syntax

See `docs/VARIABLE_GUIDE.md` for detailed variable definitions.

### Results

The last command produces output ready for inclusion in a LaTeX file. GitHub does not render LaTeX math, so results are shown as screenshots.

#### Structural Equation: `Migs`
<img width="229" height="145" alt="Screenshot 2026-05-13 114837" src="https://github.com/user-attachments/assets/6e14a423-fd84-4bb5-a08a-ba3bdc2a4938" />

#### Structural Equation: `Migl`
<img width="399" height="272" alt="Screenshot 2026-05-13 114956" src="https://github.com/user-attachments/assets/31cecb35-101c-4d25-bcf7-1da09b130e40" />

#### Structural Equation: `RP`
<img width="398" height="293" alt="Screenshot 2026-05-13 115029" src="https://github.com/user-attachments/assets/443da5ce-cc44-4dae-9554-a990f38d44dc" />

*Significance codes: \*\*\* p < 0.001 · \*\* p < 0.01 · \* p < 0.05 · . p < 0.1*

---

## Teaching Example: Labor Market Outcomes

A labor economics example is included to demonstrate the 3SLS methodology using freely distributable synthetic data.

### Research Questions

1. What are the returns to education in the labor market?
2. How do wages affect hours worked?
3. What determines hours worked decisions?

### Structural Model

```r
eq1 = log_wage    ~ education + experience + hours_worked + region
eq2 = education   ~ ability + family_background + age + experience
eq3 = hours_worked ~ log_wage + education + age + region

equations <- list(log_wage     = eq1,
                  education    = eq2,
                  hours_worked = eq3)

inst = ~ age + family_background + ability + experience + region

fit <- threeSLS_system(equations = equations, inst = inst, data = Data_clean, weights = weight)
```

Synthetic data is generated automatically by `Examples/labor_data_generator.R` — no external data files required.

```r
source("Examples/Example_Labor_Economics.R")
```

---

## Zhou & Lubrano (2026) Full 7-Equation Model

```r
eq1 = Migs ~ water + rev + flood + age + age2 + female + believer + idlinc | subset(Urb == 0)
eq2 = Migl ~ water + rev + flood + age + Single + yeduc + Dif + idlinc     | subset(Urb == 0)
eq3 = FcAM ~ water + rev + age + age2 + party + believer + Dif + Urb
eq4 = FcM1 ~ water + rev + yeduc + beterfin + FcAM + Dif + Urb
eq5 = FcM2 ~ water + rev + yeduc + FcAM + FcM1 + Dif + Urb
eq6 = RP   ~ water + rev + lowerfin + linc + idlinc + FcAM + FcM1 + FcM2 + Rur + Migs + Migl
eq7 = linc ~ water + rev + age + age2 + female + Single + yeduc + idlinc + Urb

equations <- list(linc = eq7, Migs = eq1, Migl = eq2, FcAM = eq3,
                  FcM1 = eq4, FcM2 = eq5, RP = eq6)

inst = ~ water + rev + flood + age + age2 + female + beterfin + lowerfin +
         yeduc + party + believer + Dif + Rur + Single + Urb + idlinc
```

---

## Key Output Components

### Structural Results

```r
summary(fit)

fit$structural$coefficients
fit$structural$vcov_robust
```

### Reduced Form & Elasticities

```r
rf <- reduced_form_3SLS(fit, data = data)
Pi <- rf$Pi
```

### LaTeX Output

```r
latex_struct <- latex_structural_3SLS(fit, robust = TRUE, digits = 3)
print(latex_struct$RP)
```

---

## Technical Notes

### Survey Weights

```r
fit <- threeSLS_system(equations = equations, inst = inst, data = data, weights = data$weight)
```

### Sub-sampling by Equation

The `| subset()` syntax enables equation-specific sample restrictions:

```r
eq1 = Migs ~ water + flood + age | subset(Urb == 0)
eq2 = outcome ~ x1 + x2         | subset(region == "North")
```

### Variance Estimation

```r
vcov_ml     <- fit$structural$vcov_ml        # ML estimate
vcov_robust <- fit$structural$vcov_robust    # Robust estimate
```

---

## Citation, Licensing & Contributing

If you use this code in your research, please cite:

_Michel Lubrano, Malo Raballand. 2026. "Three-Stage Least Squares with Applications to Survey Data"
GitHub repository: https://github.com/94fcna95/3SLS-Survey_

This code is released under the **MIT License** — see `LICENSE` for details.

Contributions are welcome. Please fork the repository, create a feature branch, and submit a pull request. See `CONTRIBUTING.md` for guidelines.

---

## Contact

- **Malo Raballand**: [malo.raballand@sciencespo.fr](mailto:malo.raballand@sciencespo.fr)
- **Michel Lubrano**: [michel.lubrano@univ-amu.fr](mailto:michel.lubrano@univ-amu.fr)

For bugs or issues, open an issue on the repository.
