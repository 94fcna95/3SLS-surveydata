# Three-Stage Least Squares (3SLS) Implementation in R

## Summary

This repository contains the code accompanying research studying **meritocracy dynamics, migration decisions, and preferences for redistribution** in China. All main functions and dependencies required to apply the **3SLS estimation methodology** using R are available in this repository, along with comprehensive examples. _Xun Zhou and Michel Lubrano (2026) Meritocracy and preference for redistribution in China: the impact of internal migrations. Amse Working Paper._

The implementation provides novel extensions to standard 3SLS estimations available in the R package _systemfit_ :
- **Sub-sampling capability** for equation-specific sample restrictions via `subset()` syntax
- **Full weight support** (essential for survey data)
- **Flexible instrumental variable specification**
- **Comprehensive LaTeX output** for academic papers
- **Robust variance estimation** with multiple covariance options
- **Reduced-form analysis** and structural inference tools
- **Complete diagnostic suite** (residuals, correlations, fitted values)
- ****For compatibility reasons**, the calling syntax is very similar to that of systemfit.

The code is compatible with most survey data structures and can be applied to various research questions. We provide two such examples in this repository. Moreover, the functions are optimal for large data sets. The quoted research paper makes use of a survey dataset with more than 10,000 observations.

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
- Called through **`CGT-LaTex-lib.r`**

## How to Use These Materials

### 1. **Installation**

To download the package, click on 'Code' -> 'Download Zip' and extract the files. Add to your working directory.

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

**For the meritocracy and redistribution research application (CGSS data structure):**
```r
source("Examples/Example_Meritocracy.R")
```
**Note:** This example is designed for actual CGSS 2006 data or 
similarly structured survey data. With proper data, a demonstration 
example is provided in Example_Labor_Economics.R


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
│   
│
├── Data/                              # Data directory
│   └── README_DATA.md                 # Data documentation & licensing
│
└── docs/                              # Additional documentation
    └── VARIABLE_GUIDE.md              # Variable definitions & structure
```

## Research Application: Meritocracy Dynamics in China

### Research Questions
This project studies the interconnected dynamics of the desire for redistribution in a compartimented world with rural and urban indidivudals, both with two individual beliefs systems. These two spheres are commected, via migrants who seek better fortunes in urban hubs. For studying this effect, we need to endogeneise the two types of migration and use 3SLS with weights and a subsample as migrants come only from the rural world. 

Thus, we wish to determine : 

1. **How do environmental shocks affect migration decisions?**
   - Seasonal migration (Migs)
   - Long-term migration (Migl)
   - Sample restriction to rural populations

2. **What drives preferences for redistribution (RP)?**
   - Indirect effects through migration and beliefs
   - Direct environmental effects
  
3. **How do meritocratic beliefs evolve?**
   - Merit-based factors (FcM1, FcM2): talent, education, work ethic
   - Non-merit factors (FcAM): family background, social networks, luck

### Structural Model

The research employs a 6-equation system estimated simultaneously. For the purpouse of this demonstration, we simplify to a 3 equation model

```
eq1 = Migs~water+flood+age+female+linc+idlinc | subset(Urb == 0)
eq2 = Migl~water+flood+age+Single+linc+idlinc+Dif | subset(Urb == 0)
eq3 = RP~water+party+lowerfin+linc+idlinc+Rur+Migs+Migl
```

**Key Features:**
- **Endogenous variables:** Migs, Migl, RP  (determined jointly)
- **Exogenous variables:** water, rev, flood, age, female, linc, idlinc, lowerfin, party, believer, Dif.
- **Sample restrictions:** Migration equations estimated only for rural residents (Urb=0) through the **Unique feature** of `| subset()` syntax enableing equation-specific sample restrictions

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

**Copyright Notice:** The original CGSS data cannot be included in this repository due to copyright restrictions.

**Data Access:**
1. Visit the [CGSS website](http://www.chinagss.org)
2. Request access to the 2006 wave microdata
3. Place the CGSS data file in the `Data/` directory
4. Update the file path in `Example_Meritocracy.R`

### Teaching Example: Synthetic Labor Data

For the labor economics teaching example, synthetic data is generated automatically:

**`Examples/labor_data_generator.R`** creates a synthetic dataset that:
- Replicates realistic labor market relationships
- Demonstrates proper structure for 3SLS systems
- Preserves meaningful correlations
- Is freely distributable and publicly available
- Requires no external data files


## Example Workflow

### Meritocracy Research Pipeline

```r
# 1. Load dependencies
source("Deps.R")

# 2. Load your CGSS data, use synthetic data or another data source
data <- CGSS  

# 3. Define the 3SLS system
Data3SLS = data.frame(Migs,Migl,RP,water,flood,age,Single,female, linc,idlinc,Dif,party,lowerfin,Rur,Urb)

eq1 = Migs~water+flood+age+female+linc+idlinc | subset(Urb == 0)
eq2 = Migl~water+flood+age+Single+linc+idlinc+Dif | subset(Urb == 0)
eq3 = RP~water+party+lowerfin+linc+idlinc+Rur+Migs+Migl

equations <- list(Migs=eq1,Migl=eq2,RP=eq3)

inst = ~water+flood+age+female+linc+idlinc+lowerfin+party+Dif+Rur+Single

# 4. Estimate the system
fit <-threeSLS_system(
    equations = equations,
    inst = inst,
    data = Data3SLS,
    weights = weight)

# 5. Generate publication-ready output
summary(fit)
print(latex_structural_3SLS(fit, robust = TRUE))
```
### Results

The last command produces output ready for inclusion in a LaTeX file. Results are summarised below. GitHub does not render LaTeX math, so the output is screenshotted from a LaTeX Document.

#### Structural Equation: `Migs`
<img width="229" height="145" alt="Screenshot 2026-05-13 114837" src="https://github.com/user-attachments/assets/6e14a423-fd84-4bb5-a08a-ba3bdc2a4938" />


#### Structural Equation: `Migl`

<img width="399" height="272" alt="Screenshot 2026-05-13 114956" src="https://github.com/user-attachments/assets/31cecb35-101c-4d25-bcf7-1da09b130e40" />


#### Structural Equation: `RP`

<img width="398" height="293" alt="Screenshot 2026-05-13 115029" src="https://github.com/user-attachments/assets/443da5ce-cc44-4dae-9554-a990f38d44dc" />

*Significance codes: \*\*\* p < 0.001 · \*\* p < 0.01 · \* p < 0.05 · . p < 0.1*


### Labor Economics Teaching Example

```r
source("Deps.R")
source("Examples/Example_Labor_Economics.R")
```

This runs the complete teaching pipeline automatically.

## Zhou, Lubrano (2026) 3SLS model

```
eq1 = Migs~water+rev+flood+age+age2+female+believer+idlinc  | subset(Urb == 0) #+party
eq2 = Migl~water+rev+flood+age+Single+yeduc+Dif+idlinc      | subset(Urb == 0) #+age2 

eq3 = FcAM~water+rev+age+age2+party+believer+Dif+Urb   # flood+linc

eq4 = FcM1~water+rev+yeduc+beterfin+FcAM+Dif+Urb # linc+idlinc
eq5 = FcM2~water+rev+yeduc+FcAM+FcM1+Dif+Urb # linc+beterfin

eq6 = RP~water+rev+lowerfin+linc+idlinc+
      FcAM+FcM1+FcM2+Rur+Migs+Migl

eq7 = linc~water+rev+age+age2+female+Single+yeduc+idlinc+Urb #+Rur #+Migs+Migl

equations <- list(linc=eq7,Migs=eq1,Migl=eq2,FcAM=eq3,FcM1=eq4,FcM2=eq5,RP=eq6)

inst = ~water+rev+flood+age+age2+female+beterfin+lowerfin+
  yeduc+party+believer+Dif+Rur+Single+Urb+idlinc # +Dife
```

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
[Michel Lubrano, Malo Raballand]. 2026. "Three-Stage Least Squares with Applications to Survey Data"
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

---

**Repository Version:** 1.0  
**Last Updated:** May 2026  
**Status:** Production Ready ✅  
**Maintainer:** [94fcna95] (Malo Raballand)
