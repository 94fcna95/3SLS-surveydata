# Three-Stage Least Squares (3SLS) Implementation in R

## Summary

This repository contains the code accompanying research studying **meritocracy dynamics, migration decisions, and preferences for redistribution** in China. All main functions and dependencies required to apply the **3SLS estimation methodology** using R are available in this repository, along with comprehensive examples.

The implementation provides novel extensions to standard 3SLS estimation:
- **Sub-sampling capability** for equation-specific sample restrictions via `subset()` syntax
- **Full weight support** (essential for survey data)
- **Flexible instrumental variable specification**
- **Comprehensive LaTeX output** for academic papers
- **Robust variance estimation** with multiple covariance options
- **Reduced-form analysis** and structural inference tools
- **Complete diagnostic suite** (residuals, correlations, fitted values)

The code is compatible with most survey data structures and can be applied to various research questions. We provide two such examples in this repository.

## Key Features

### Core Functions

**`threeSLS_system()`** — Main 3SLS estimation function
- Estimates structural equation systems using three-stage least squares
- Supports equation-specific sample restrictions via `subset()` syntax
- Handles survey weights directly in the estimation
- Returns complete coefficient vectors, variance-covariance matrices, residuals, fitted values
- Includes both ML and robust variance estimates
- Produces comprehensive diagnostic information

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

### Supporting Tools

**`Meritocracy-lib.r`** — Utility functions
- Factor analysis and index construction
- Data preprocessing and missing value handling
- Survey weighting implementation

**`CGT-LaTex-lib.r`** — Custom LaTeX formatting
- Unified table output formatting
- Significance testing and star annotation
- Equation-specific reporting

## How to Use These Materials

### 1. **Installation**

Download the package and extract the files. Add to working directory.

### 2. **Loading Dependencies**

Run the main dependency script first:

```r
source("Deps.R")
```

This loads all required R libraries and core functions. Ensure the following packages are installed:

- `MASS` - Generalized inverse (ginv)
- `Matrix` - Matrix operations (bdiag)
- `weights` - Weighted statistics
- `xtable` - LaTeX table generation
- `DescTools` - Additional statistics functions
- `psych` - Factor analysis (fa, factor.scores)

### 3. **Running Examples**

Two illustrative examples are provided:

**For learning the 3SLS methodology (open data):**
```r
source("Examples/Example_Labor_Economics.R")
```

**For the meritocracy research application (CGSS data structure):**
```r
source("Examples/Example_Meritocracy.R")
```

## Repository Structure

```
.
├── README.md                          # This file
├── QUICKSTART.md                      # Quick reference guide
├── CONTRIBUTING.md                    # Contribution guidelines
├── Deps.R                             # Central dependency loader
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore file
│
├── R/                                 # Core library functions
│   ├── CGT-3SLS-lib.r                # Main 3SLS estimation & tools
│   ├── CGT-LaTex-lib.r               # LaTeX output functions
│   └── Meritocracy-lib.r             # Utility functions
│
├── Examples/                          # Illustrative examples
│   ├── Example_Labor_Economics.R      # Teaching example (open data)
│   ├── labor_data_generator.R         # Synthetic labor market data
│   ├── Example_Meritocracy.R          # Research application (CGSS structure)
│   └── synthetic_data_generator.R     # Generates synthetic CGSS-like data
│
├── Data/                              # Data directory
│   └── README_DATA.md                 # Data documentation & licensing
│
└── docs/                              # Additional documentation
    └── VARIABLE_GUIDE.md              # Variable definitions & structure
```

## Research Application: Meritocracy Dynamics in China

### Research Questions

This project studies the interconnected dynamics of:

1. **How do environmental shocks affect migration decisions?**
   - Small-scale internal migration (Migs)
   - Large-scale internal migration (Migl)
   - Sample restriction to rural populations

2. **What drives preferences for redistribution (RP)?**
   - Direct environmental effects
   - Indirect effects through migration and beliefs

3. **How do meritocratic beliefs evolve?**
   - Merit-based factors (FcM1, FcM2): talent, education, work ethic
   - Non-merit factors (FcAM): family background, social networks, luck

### Structural Model

The research employs a 6-equation system estimated simultaneously:

```
Migs ~ water + flood + age + age² + female + believer | subset(Urb == 0)
Migl ~ flood + age + age² + linc + FcM1 | subset(Urb == 0)
RP ~ water + party + believer + Rur + Migs + Migl + Dif + FcM1 + FcM2
FcM1 ~ water + rev + yeduc + Rur + Migl + Dif + FcAM
FcM2 ~ water + rev + yeduc + Rur + Migs + Migl + Dif + FcAM
FcAM ~ water + rev + age + age² + party + Rur + Migl + FcM1 + FcM2
```

**Key Features:**
- **Endogenous variables:** Migs, Migl, RP, FcM1, FcM2, FcAM (determined jointly)
- **Exogenous variables:** water, rev, flood, age, age², female, linc, yeduc, party, believer, Dif, Rur
- **Sample restrictions:** Migration equations estimated only for rural residents (Urb=0)
- **Unique feature:** The `| subset()` syntax enables equation-specific sample restrictions

See `docs/VARIABLE_GUIDE.md` for detailed variable definitions and data preparation.

## Teaching Example: Labor Market Outcomes

In addition to the meritocracy research application, a **labor economics example** is included to demonstrate the 3SLS methodology using freely distributable synthetic data.

### Example Research Questions

This teaching example addresses:

1. **What are the returns to education in the labor market?**
2. **How do wages affect educational investment?**
3. **What drives employment decisions?**

### Example Structural Model

The teaching example uses a simplified 3-equation system:

```
log_wage ~ education + experience + employment + region
education ~ ability + family_background + age + experience
employment ~ log_wage + education + age + region
```

**Why this example?**
- Demonstrates clear simultaneity (wages ↔ education ↔ employment)
- Uses open, freely distributable synthetic data
- Shows how to structure systems with different types of variables
- Illustrates instrumental variable strategy
- Provides a template for other applications

### Running the Teaching Example

```r
source("Deps.R")
source("Examples/Example_Labor_Economics.R")
```

This reproduces a complete analysis pipeline:
- Synthetic data generation
- System specification with endogenous variables
- 3SLS estimation with instrumental variables
- Reduced-form analysis
- Publication-ready LaTeX output
- Diagnostic testing and interpretation

## Data

### Meritocracy Research: CGSS Data

The main research uses the **China General Social Survey (CGSS) 2006** microdata.

**Data Access:**
1. Visit the [CGSS website](http://www.chinagss.org)
2. Request access to the 2006 wave microdata
3. Place the CGSS data file in the `Data/` directory
4. Update the file path in `Example_Meritocracy.R`

**Copyright Notice:** The original CGSS data cannot be included in this repository due to copyright restrictions.

### Teaching Example: Synthetic Labor Data

For the labor economics teaching example, synthetic data is generated automatically:

**`Examples/labor_data_generator.R`** creates a synthetic dataset that:
- Replicates realistic labor market relationships
- Demonstrates proper structure for 3SLS systems
- Preserves meaningful correlations
- Is freely distributable and publicly available
- Requires no external data files

### Using Synthetic CGSS-like Data

For testing and demonstration of the meritocracy model without access to CGSS data:

**`Examples/synthetic_data_generator.R`** creates synthetic CGSS-like data that:
- Mirrors the structure of CGSS 2006
- Preserves variable relationships and distributions
- Maintains survey weighting structure
- Is freely distributable

```r
source("Examples/synthetic_data_generator.R")
# Creates: CGSS_synthetic (3,000 observations)
```

## Example Workflow

### Meritocracy Research Pipeline

```r
# 1. Load dependencies
source("Deps.R")

# 2. Load your CGSS data or use synthetic data
source("Examples/synthetic_data_generator.R")
data <- CGSS_synthetic  # or load your CGSS data

# 3. Define the meritocracy system
equations <- list(
  Migs = Migs ~ water + flood + age + age2 + female + believer | subset(Urb == 0),
  Migl = Migl ~ flood + age + age2 + linc + FcM1 | subset(Urb == 0),
  RP = RP ~ water + party + believer + Rur + Migs + Migl + Dif + FcM1 + FcM2,
  # ... remaining equations
)

inst <- ~ water + rev + flood + age + age2 + female + linc + yeduc + party + believer + Dif + Rur

# 4. Estimate the system
fit <- threeSLS_system(
  equations = equations,
  inst = inst,
  data = data,
  weights = weight,
  verbose = TRUE
)

# 5. Generate publication-ready output
summary(fit)
latex_struct <- latex_structural_3SLS(fit, robust = TRUE)
rf <- reduced_form_3SLS(fit, data = data)
```

### Labor Economics Teaching Example

```r
source("Deps.R")
source("Examples/Example_Labor_Economics.R")
```

This runs the complete teaching pipeline automatically.

## Key Output Components

### Structural Results

```r
# Full summary with all diagnostics
summary(fit)

# Access specific equations
fit$structural$coefficients
fit$structural$vcov_robust
```

### Reduced Form & Elasticities

```r
# Compute total effects
rf <- reduced_form_3SLS(fit, data = data)
Pi <- rf$Pi  # Reduced form coefficients
```

### LaTeX Output

```r
# Generate publication tables
latex_struct <- latex_structural_3SLS(fit, robust = TRUE, digits = 3)
print(latex_struct$RP)  # Specific equation
```

## Technical Notes

### Survey Weights

Properly handle survey weights at all stages:

```r
fit <- threeSLS_system(
  equations = equations,
  inst = inst,
  data = data,
  weights = data$weight
)
```

### Sub-sampling by Equation

The `| subset()` syntax enables equation-specific sample restrictions:

```r
# Include only non-urban observations
eq1 = Migs ~ water + flood + age | subset(Urb == 0)

# Regional analysis
eq2a = outcome ~ x1 + x2 | subset(region == "North")
```

### Variance Estimation

Multiple variance estimators are available:

```r
vcov_ml <- fit$structural$vcov_ml        # ML estimate
vcov_robust <- fit$structural$vcov_robust # Robust estimate
```

## Citation

If you use this code in your research, please cite:

```
[Your Name]. 2026. "Meritocracy Dynamics and Redistribution Preferences in China"
Working paper.
```

For the 3SLS methodology implementation:

```
[Your Name]. 2026. "Three-Stage Least Squares with Applications to Survey Data"
GitHub repository: https://github.com/94fcna95/3SLS-Survey
```

## License

This code is released under the **MIT License**. See `LICENSE` file for details.

You are free to:
- Use this code for research and commercial projects
- Modify and distribute the code
- Include this code in your own projects

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

See `CONTRIBUTING.md` for detailed guidelines.

## Contact

For questions regarding the research or code:
- **Malo Raballand**: [malo.raballand@sciencespo.fr](mailto:malo.raballand@sciencespo.fr)
- **Michel Lubrano**: [michel.lubrano@univ-amu.fr](mailto:michel.lubrano@univ-amu.fr)

For GitHub issues: Open an issue on the repository

## References

### Methodological References

- Zellner, A. (1962). "An efficient method of estimating seemingly unrelated regressions and tests for aggregation bias." *Journal of the American Statistical Association*, 57(298), 348-368.

- Greene, W. H. (2012). *Econometric Analysis* (7th ed.). Prentice Hall. [Chapter 10: Systems of Equations]

- Wooldridge, J. M. (2010). *Econometric Analysis of Cross Section and Panel Data* (2nd ed.). MIT Press.

### Research References

- [Your meritocracy paper references here]

---

**Repository Version:** 2.0  
**Last Updated:** May 2026  
**Status:** Production Ready ✅  
**Maintainer:** [94fcna95] (Malo Raballand)
