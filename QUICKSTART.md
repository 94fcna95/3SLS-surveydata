# QUICKSTART GUIDE

Get up and running with the 3SLS system in 5 minutes.

## 1. **Clone the Repository, or download the package**

```bash
git clone https://github.com/yourusername/3sls-meritocracy.git
cd 3sls-meritocracy

# install.packages("devtools")
devtools::install_github("94fcna95/surveysearch")

To download the package, click on 'Code' -> 'Download Zip' and extract the files. Add to working directory.
```

## 2. **Open R/RStudio**

From the repository directory:

```r
setwd("path/to/3sls-meritocracy")
```

## 3. **Load Everything**

```r
source("Deps.R")
```

This single command:
- Installs/loads all required packages
- Loads the 3SLS estimation functions
- Loads LaTeX formatting tools
- Loads application-specific utilities

## 4. **Run the Example (with Synthetic Data)**

```r
source("Examples/Example_Meritocracy.R")
```

This will:
- Generate synthetic CGSS-like data
- Estimate a 6-equation 3SLS system
- Display structural results
- Generate LaTeX tables
- Show reduced-form analysis
- Compute elasticities
- Run diagnostics

**Total runtime:** 5-30 seconds (depending on your computer)

## 5. **View the Results**

Results are stored in the `fit` object:

```r
# View summary
summary(fit)

# Access coefficients for a specific equation
fit$structural$coefficients$RP

# Get residuals
fit$residuals$RP

# Get fitted values
fit$fitted$RP

# Get variance-covariance
fit$structural$vcov_ml
```

---

## Common Tasks

### **Get LaTeX Tables for Publication**

```r
# Structural equations
latex_struct <- latex_structural_3SLS(fit, robust = TRUE)
print(latex_struct$RP)  # Redistribution preference equation

# Reduced form
latex_reduced <- latex_reduced_3SLS(fit, data = Data_clean)
print(latex_reduced$RP)
```

### **Compute Elasticities**

```r
# Reduced form provides impact multipliers
rf <- reduced_form_3SLS(fit, data = Data_clean)
Pi <- rf$Pi  # Reduced form coefficients
```

### **Check Residual Correlations**

```r
# Justifies use of 3SLS (should show interdependence)
residual_matrix <- do.call(cbind, fit$residuals)
cor(residual_matrix, use = "complete.obs")
```

### **Use Your Own Data**

Replace the synthetic data generation with your data:

```r
source("Deps.R")

# Load YOUR data instead of synthetic
load("path/to/your/CGSS2006.RData")
# or: your_data <- read.csv("your_file.csv")

# Define equations
equations <- list(
  Migs = Migs ~ water + ...,
  # ... your equations
)

# Run 3SLS
fit <- threeSLS_system(
  equations = equations,
  inst = your_instruments,
  data = your_data,
  weights = your_weights
)
```

---

## Troubleshooting

### **"Cannot find file Deps.R"**
Make sure you're in the repository directory:
```r
getwd()  # Check current directory
setwd("/path/to/repo")  # Change if needed
```

### **"Package X not found"**
They'll install automatically. If not:
```r
install.packages("package_name")
```

### **"object 'threeSLS_system' not found"**
Run `source("Deps.R")` first. This loads all functions.

### **Results look weird / NA values**
Check for:
1. Missing data: `sum(complete.cases(your_data))`
2. Sample size too small for subsets: `sum(Urb == 0)` for rural-only equations
3. Perfect multicollinearity: Check correlations

---

## Next Steps

- 📖 Read [README.md](README.md) for full documentation
- 🔍 Check [Data/README_DATA.md](Data/README_DATA.md) for variable definitions
- 📊 Review [Examples/Example_Meritocracy.R](Examples/Example_Meritocracy.R) for detailed comments
- 💻 Explore the [R/](R/) directory to understand function structure

---

## Key Functions

| Function | Purpose |
|----------|---------|
| `threeSLS_system()` | Main 3SLS estimation |
| `summary.threeSLS_fit()` | Display results |
| `reduced_form_3SLS()` | Compute reduced form |
| `latex_structural_3SLS()` | LaTeX structural tables |
| `latex_reduced_3SLS()` | LaTeX reduced form tables |
| `POLS()` | Polychoric transformation for ordinal data |
| `Transl()` | Translate vector to start at 1 |

---

## Questions?

- 📧 Contact: [your.email@institution.edu]
- 📚 See: README.md (detailed documentation)
- 🐛 Found a bug? Open an issue on GitHub

---

**Happy analyzing! 📊**
