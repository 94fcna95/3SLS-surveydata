# QUICKSTART GUIDE

Get up and running with the 3SLS system in 5 minutes.

## 1. Clone

```bash
git clone https://github.com/94fcna95/3SLS-surveydata.git
cd 3SLS-surveydata
```

> **Alternative:** Click `Code` → `Download ZIP`, extract, and set as your working directory.

---

## 2. Open

In R or RStudio, set your working directory to the repository root:

```r
setwd("path/to/3SLS-surveydata")
```

> All file paths in the repository are relative — the scripts will not work unless you are running from the root directory.

---

## 3. Load

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

## 4. Run the Example (Labor Market)

```r
source("Examples/Example_Labor_Economics.R")
```

This teaching example demonstrates the 3SLS methodology using freely distributable synthetic data, addressing a classic simultaneity problem:

```
log_wage  ~ education + experience + employment + region
education ~ ability + family_background + age + experience
employment ~ log_wage + education + age + region
```
It produces:
- Structural coefficient estimates
- Reduced form and impact multipliers
- Publication-ready LaTeX tables
- Residual diagnostics and correlations

**Expected runtime:** 5–30 seconds depending on your machine.

---

## 5. View Results

```r
# Full summary with diagnostics
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

## 6. Common Tasks

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

## 7. Going Further (3SLS Meritocracy)

The labor market example is a pedagogical entry point. The full research application is the **meritocracy and redistribution in China** study (Zhou & Lubrano, 2026), which uses a 6-equation system on CGSS 2006 survey data.

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
