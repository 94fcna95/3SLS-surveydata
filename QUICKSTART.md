# QUICKSTART GUIDE

Get up and running with the 3SLS system in 5 minutes.

## 1. Clone, open and load

```bash
git clone https://github.com/94fcna95/3SLS-surveydata.git
cd 3SLS-surveydata
```

> **Alternative:** Click `Code` → `Download ZIP`, extract, and set as your working directory.

---

#### Open

In R or RStudio, set your working directory to the repository root:

```r
setwd("path/to/3SLS-surveydata")
```

> All file paths in the repository are relative — the scripts will not work unless you are running from the root directory.

---

#### Load

```r
source("Deps.R")
```

This single command:
- Installs and loads all required packages (`MASS`, `Matrix`, `weights`, `xtable`, `DescTools`, `psych`)
- Sources the three core libraries:
  - `R/CGT-3SLS-lib.r` — 3SLS estimation functions
  - `R/CGT-LaTex-lib.r` — LaTeX output functions
  - `R/Meritocracy-lib.r` — utility functions (`POLS`, `Transl`, `EGP`)
- Verifies all key functions are available before analysis begins

> You do not need to call `source("Deps.R")` manually if running an example script — it is called automatically.

---

## 2. Run the Example (Labor Market)

```r
source("Examples/Example_Labor_Economics.R")
```

This teaching example demonstrates the 3SLS methodology using freely distributable synthetic data, addressing a classic simultaneity problem:

```
eq1 = log_wage    ~ education + experience + hours_worked + region
eq2 = education   ~ ability + family_background + age + experience
eq3 = hours_worked ~ log_wage + education + age + region
```
It produces:
- Structural coefficient estimates
- Reduced form and impact multipliers
- Publication-ready LaTeX tables
- Residual diagnostics and correlations

**Expected runtime:** 5–30 seconds depending on your machine.

---

## 3. View Results

```r
# Full summary with diagnostics (lengthy, we recommend using the functions below)
summary(fit)
```

| Slot | Contents |
|------|----------|
| `fit$structural$coefficients` | Structural coefficients by equation |
| `fit$structural$vcov_ml` | ML variance-covariance matrix |
| `fit$structural$vcov_robust` | Robust variance-covariance matrix |
| `fit$residuals$education` | Residuals for a given equation |
| `fit$fitted$education` | Fitted values for a given equation |

---

## 4. Common Tasks

### Available Functions

#### `R/CGT-3SLS-lib.r` — Estimation

| Function | Arguments | Description |
|----------|-----------|-------------|
| `threeSLS_system()` | `equations, inst, data, weights, ridge_ZZ, ridge_Omega, auto_drop_instruments, verbose` | Main 3SLS estimation. Returns structural coefficients, ML and robust variance-covariance matrices, residuals, fitted values, Omega, and reduced form per equation |
| `summary.threeSLS_fit()` | `object, digits, robust` | Prints structural estimates with significance stars, residual diagnostics, Omega matrix, residual correlations, and pseudo log-likelihood |
| `reduced_form_3SLS()` | `fit, data, digits` | Computes the restricted reduced form Π = CB⁻¹ from structural parameters. Returns impact multipliers, delta-method standard errors, and elasticities at sample means |

#### `R/CGT-LaTex-lib.r` — Output

| Function | Arguments | Description |
|----------|-----------|-------------|
| `latex_structural_3SLS()` | `object, digits, robust` | Generates a list of `xtable` objects, one per equation, with coefficients, t-values, significance stars, and R² |
| `latex_reduced_3SLS()` | `fit, data, digits` | Generates a list of `xtable` objects for reduced form equations, plus instrument means, dependent variable means, and B⁻¹ |

#### (Chinese 3SLS specific!) `R/Meritocracy-lib.r` — Utilities 

| Function | Arguments | Description |
|----------|-----------|-------------|
| `POLS()` | `ys, w, inorm` | Polychoric ordinal transformation. Converts Likert-scale responses to a continuous approximation using weighted percentiles and inverse normal CDF |
| `Transl()` | `x` | Shifts a vector so its minimum value is 1 |
| `EGP()` | `x, urban` | Recodes raw occupational codes to the EGP class schema (1 = higher controllers … 9 = farm labor) |
| `C_to_symbolic_df()` | `C, tol` | Converts a matrix to symbolic representation (`0` or `c`) for displaying structural restriction patterns |
| `make_X_from_Pi()` | `Pi, data` | Builds a design matrix aligned with a reduced form Π matrix |

### Get LaTeX Tables

```r
# Structural equations
latex_struct <- latex_structural_3SLS(fit, robust = TRUE)
print(latex_struct$RP)

# Reduced form
latex_reduced <- latex_reduced_3SLS(fit, data = Data_clean)
print(latex_reduced$RP)
```

### Compute Reduced Form and Elasticities

```r
rf <- reduced_form_3SLS(fit, data = Data_clean)
Pi <- rf$Pi  # Reduced form coefficients and impact multipliers
```

### Check Residual Correlations

```r
# High correlations justify 3SLS over equation-by-equation OLS
residual_matrix <- do.call(cbind, fit$residuals)
cor(residual_matrix, use = "complete.obs")
```

### Troubleshooting

| Error | Fix |
|-------|-----|
| `Cannot find file Deps.R` | Check `getwd()` — must be in repository root |
| `Package X not found` | Packages install automatically; if not: `install.packages("X")` |
| `object 'threeSLS_system' not found` | Run `source("Deps.R")` first |
| Unexpected `NA` values | Check `sum(complete.cases(your_data))` and subset sizes (e.g. `sum(Urb == 0)`) |

---

## 5. Going Further (3SLS Meritocracy)

The labor market example is a pedagogical entry point. The full research application is the **meritocracy and redistribution in China** study (Zhou & Lubrano, 2026), which uses a 7-equation system on CGSS 2006 survey data.

## Next Steps

| Resource | Contents |
|----------|----------|
| `README.md` | Complete documentation, the 3-equation model, and research context with 7-equation model|
| `Data/README_DATA.md` | CGSS data access, licensing, and citation |
| `docs/VARIABLE_GUIDE.md` | Full variable definitions and structure |

> The meritocracy example requires CGSS 2006 data or a similarly structured survey dataset. See `Data/README_DATA.md` for access instructions.

---

## Questions?

- Contact: [malo.raballand@sciencespo.fr]
- See: README.md (detailed documentation)
- Found a bug? Open an issue on GitHub

---

**Happy analyzing! 📊**
