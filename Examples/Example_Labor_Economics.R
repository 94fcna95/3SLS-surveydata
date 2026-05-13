# ============================================================================
# EXAMPLE: 3SLS ANALYSIS OF LABOR MARKET OUTCOMES
# ============================================================================
#
# This script demonstrates 3SLS estimation of a labor economics model
# with simultaneous equations for wages, education, and hours worked.
#
# System of equations:
#   eq1: log_wage    ~ education + experience + hours_worked + region
#   eq2: education   ~ ability + family_background + age + experience
#   eq3: hours_worked ~ log_wage + education + age + region
#
# Run this with:
#   source("Examples/Example_Labor_Economics.R")
#
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("3SLS ANALYSIS: LABOR MARKET OUTCOMES\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# ============================================================================
# 1. LOAD DEPENDENCIES
# ============================================================================

cat("Step 1: Loading dependencies...\n")
source("Deps.R")

# ============================================================================
# 2. GENERATE DATA
# ============================================================================

cat("\nStep 2: Generating labor market data...\n")

source("Examples/labor_data_generator.R")
Data_raw <- labor_data

# ============================================================================
# 3. DATA PREPARATION
# ============================================================================

cat("\nStep 3: Data preparation...\n")

all_vars <- c("weight", "log_wage", "education", "hours_worked",
              "age", "family_background", "ability", "experience", "region")

Data       <- Data_raw[, all_vars]
Data_clean <- Data[complete.cases(Data), ]
weight     <- Data_clean$weight

cat("  - Raw observations:    ", nrow(Data_raw), "\n")
cat("  - After removing missing:", nrow(Data_clean), "\n\n")

# ============================================================================
# 4. DEFINE SYSTEM OF EQUATIONS
# ============================================================================

cat("\nStep 4: Defining structural equations...\n\n")

equations <- list(
  log_wage     = log_wage     ~ education + experience + hours_worked + region,
  education    = education    ~ ability + family_background + age + experience,
  hours_worked = hours_worked ~ log_wage + education + age + region
)

instruments <- ~ age + family_background + ability + experience + region

cat("✓ System of 3 equations defined\n")
cat("✓ Instruments: age, family_background, ability, experience, region\n\n")

# ============================================================================
# 5. ESTIMATE 3SLS SYSTEM
# ============================================================================

cat("\nStep 5: Estimating 3SLS system...\n\n")

fit <- threeSLS_system(
  equations = equations,
  inst      = instruments,
  data      = Data_clean,
  weights   = weight,
  verbose   = FALSE
)

cat("✓ 3SLS estimation complete\n\n")

# ============================================================================
# 6. STRUCTURAL RESULTS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("STRUCTURAL ESTIMATES (3SLS)\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

summary(fit)

# ============================================================================
# 7. LATEX OUTPUT
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("LATEX OUTPUT\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

latex_structural <- latex_structural_3SLS(fit, robust = TRUE, digits = 4)

cat("Wage Equation:\n")
cat(paste(rep("-", 60), collapse=""), "\n\n")
print(latex_structural$log_wage)

cat("\n\nEducation Equation:\n")
cat(paste(rep("-", 60), collapse=""), "\n\n")
print(latex_structural$education)

cat("\n\nHours Worked Equation:\n")
cat(paste(rep("-", 60), collapse=""), "\n\n")
print(latex_structural$hours_worked)

# ============================================================================
# 8. REDUCED FORM
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("REDUCED FORM ANALYSIS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

rf <- reduced_form_3SLS(fit, data = Data_clean)

cat("Total effects of exogenous variables on all endogenous outcomes.\n\n")
cat("Example interpretation:\n")
cat("  - ability → education (direct)\n")
cat("  - ability → wages (via education)\n")
cat("  - ability → hours worked (via education and wages)\n\n")

# ============================================================================
# 9. DIAGNOSTICS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("DIAGNOSTICS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

eq_names <- fit$eq_names

residuals_summary <- data.frame(
  Equation = eq_names,
  Mean     = round(sapply(fit$residuals, mean, na.rm = TRUE), 6),
  SD       = round(sapply(fit$residuals, sd,   na.rm = TRUE), 4),
  Min      = round(sapply(fit$residuals, min,  na.rm = TRUE), 3),
  Max      = round(sapply(fit$residuals, max,  na.rm = TRUE), 3)
)

cat("Residual Summary:\n\n")
print(residuals_summary)

residual_matrix         <- do.call(cbind, fit$residuals)
colnames(residual_matrix) <- eq_names

cat("\n\nResidual Correlations:\n\n")
print(round(cor(residual_matrix, use = "complete.obs"), 3))
cat("\nNon-zero correlations justify 3SLS over single-equation estimation.\n\n")

# ============================================================================
# 10. ACCESSING RESULTS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("ACCESSING RESULTS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Structural coefficients:\n")
cat("  fit$structural$coefficients$log_wage\n")
cat("  fit$structural$coefficients$education\n")
cat("  fit$structural$coefficients$hours_worked\n\n")

cat("Standard errors:\n")
cat("  sqrt(diag(fit$structural$vcov_ml))\n")
cat("  sqrt(diag(fit$structural$vcov_robust))\n\n")

cat("Residuals and fitted values:\n")
cat("  fit$residuals$log_wage\n")
cat("  fit$fitted$log_wage\n\n")

cat("Reduced form:\n")
cat("  rf$Pi     (reduced form coefficients)\n")
cat("  rf$B_inv  (impact multiplier matrix)\n\n")

cat("Save results:\n")
cat("  save(fit, rf, file = 'labor_3sls_results.RData')\n\n")

cat(paste(rep("=", 80), collapse=""), "\n")
cat("ANALYSIS COMPLETE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("For more details see:\n")
cat("  README.md            — full documentation\n")
cat("  QUICKSTART.md        — quick reference\n")
cat("  docs/VARIABLE_GUIDE.md — variable definitions\n\n")

cat(paste(rep("=", 80), collapse=""), "\n\n")
