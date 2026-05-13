# ============================================================================
# EXAMPLE: 3SLS ANALYSIS OF MERITOCRACY DYNAMICS
# ============================================================================
#
# This script demonstrates the complete workflow for 3SLS system estimation
# using synthetic CGSS-like data.
#
# Workflow:
# 1. Load dependencies
# 2. Generate or load data
# 3. Data preprocessing and variable construction
# 4. Define the structural system of equations
# 5. Estimate 3SLS system
# 6. Generate results and LaTeX output
# 7. Conduct reduced-form analysis
# 8. Diagnostic checks
#
# Run this with:
#   source("Examples/Example_Meritocracy.R")
#
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("3SLS ANALYSIS: MERITOCRACY DYNAMICS IN CHINA\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# ============================================================================
# 1. LOAD DEPENDENCIES
# ============================================================================

cat("Step 1: Loading dependencies...\n")
source("Deps.R")

# ============================================================================
# 2. LOAD OR GENERATE DATA
# ============================================================================

cat("\nStep 2: Loading/generating data...\n")

# Generate synthetic data or load your own dataset
source("Examples/synthetic_data_generator.R")
Data_raw <- CGSS_synthetic # or comparable data

cat("\nOriginal dataset size: ", nrow(Data_raw), " observations\n")

# ============================================================================
# 3. DATA PREPROCESSING & VARIABLE CONSTRUCTION
# ============================================================================

cat("\nStep 3: Data preprocessing...\n")

# Select variables for analysis and remove missing values
all_vars <- c("weight", "Migs", "Migl", "RP", "FcM1", "FcM2", "FcAM", 
              "water", "rev", "flood", "age", "age2", "female", 
              "linc", "linc2", "yeduc", "believer", "party", "Rur", "Dif", "Urb")

Data <- Data_raw[, all_vars]

# Find complete cases
complete_idx <- complete.cases(Data[, all_vars])

# Remove rows with missing values from DATA
Data_clean <- Data[complete_idx, ]

# IMPORTANT: Also subset weights to match data
weight <- Data_clean$weight

cat("  - Raw observations:", nrow(Data_raw), "\n")
cat("  - After removing missing:", nrow(Data_clean), "\n")
cat("  - Observations lost:", nrow(Data_raw) - nrow(Data_clean), "\n")
cat("  - Weight vector length:", length(weight), "\n\n")

# ============================================================================
# 4. DEFINE SYSTEM OF EQUATIONS
# ============================================================================

cat("\nStep 4: Defining structural equations...\n")

# Triangular system with feedback
# Notice the | subset() syntax for equation-specific restrictions

equations <- list(
  # Equation 1: Small-scale migration (internal, short distance)
  Migs = Migs ~ water + rev + flood + age + age2 + female + believer | 
         subset(Urb == 0),
  
  # Equation 2: Large-scale migration (long distance)
  Migl = Migl ~ flood + age + age2 + linc + FcM1 | 
         subset(Urb == 0),
  
  # Equation 3: Redistribution preference
  RP = RP ~ water + rev + party + believer + 
       Rur + Migs + Migl + Dif + FcM1 + FcM2,
  
  # Equation 4: Merit perception - individual effort dimension
  FcM1 = FcM1 ~ water + rev + yeduc + 
         Rur + Migl + Dif + FcAM,
  
  # Equation 5: Merit perception - education/talent dimension
  FcM2 = FcM2 ~ water + rev + yeduc + 
         Rur + Migs + Migl + Dif + FcAM,
  
  # Equation 6: Actual merit factors (non-meritocratic)
  FcAM = FcAM ~ water + rev + age + age2 + party + 
         Rur + Migl + FcM1 + FcM2
)

cat("  ✓ System of 6 equations defined\n")

# Instruments (all exogenous variables)
inst <- ~ water + rev + flood + age + age2 + female + linc + 
          yeduc + party + believer + Dif + Rur

cat("  ✓ Instruments specified\n\n")

# ============================================================================
# 5. ESTIMATE 3SLS SYSTEM
# ============================================================================

cat("\nStep 5: Estimating 3SLS system...\n")
cat("  (This may take a moment...)\n\n")

fit <- threeSLS_system(
  equations = equations,
  inst = inst,
  data = Data_clean,
  weights = weight,
  verbose = FALSE  # Set to TRUE for detailed iteration output
)

cat("✓ 3SLS estimation complete\n\n")

# ============================================================================
# 6. DISPLAY RESULTS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("STRUCTURAL ESTIMATES (3SLS)\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Full summary with all diagnostics
summary(fit)

# ============================================================================
# 7. LaTeX OUTPUT FOR PUBLICATION
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("LATEX OUTPUT - STRUCTURAL EQUATIONS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Generate LaTeX tables for each equation
latex_structural <- latex_structural_3SLS(fit, robust = TRUE, digits = 3)

# Print first equation as example
cat("Example: LaTeX code for Redistribution Preference Equation (RP)\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")
print(latex_structural$RP)

cat("\n\nTo save all equations to a text file:\n")
cat("  for (i in seq_along(latex_structural)) {\n")
cat("    print(latex_structural[[i]])\n")
cat("  }\n\n")

# ============================================================================
# 8. REDUCED FORM ANALYSIS
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("REDUCED FORM ANALYSIS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Computing reduced form equations...\n\n")

# Compute reduced form
rf <- reduced_form_3SLS(fit, data = Data_clean)

cat("Reduced form parameters (Pi):\n")
print(round(rf$Pi, 4))

cat("\n\nStructural parameter matrix (B) inverse:\n")
print(round(rf$B_inv, 4))

# LaTeX reduced form
latex_reduced <- latex_reduced_3SLS(fit, data = Data_clean, digits = 3)

cat("\n\nExample: Reduced form for Redistribution Preference\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")
print(latex_reduced$RP)

# ============================================================================
# 9. ELASTICITY CALCULATIONS
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("ELASTICITY ANALYSIS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Compute mean values
eq_names <- fit$eq_names
eq_means <- sapply(eq_names, function(v) {
  mean(Data_clean[[v]], na.rm = TRUE)
})

cat("Equation means:\n")
print(round(eq_means, 3))

# Compute elasticities for RP (Redistribution Preference)
cat("\n\nPartial elasticities for Redistribution Preference (RP):\n\n")

rhs_vars_rp <- c("water", "rev", "party", "believer", "Rur", "Migs", "Migl", "Dif", "FcM1", "FcM2")
coeffs_rp <- fit$structural$coefficients$RP

elasticities_rp <- data.frame(
  Variable = rhs_vars_rp,
  Coefficient = round(coeffs_rp[rhs_vars_rp], 4),
  Mean_X = round(colMeans(Data_clean[, rhs_vars_rp], na.rm = TRUE), 3),
  Mean_Y = eq_means["RP"],
  Elasticity = NA
)

elasticities_rp$Elasticity <- round(
  elasticities_rp$Coefficient * elasticities_rp$Mean_X / elasticities_rp$Mean_Y,
  4
)

print(elasticities_rp)

# ============================================================================
# 10. RESIDUAL DIAGNOSTICS
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("DIAGNOSTIC ANALYSIS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Residual analysis
cat("Residual Summary Statistics:\n\n")

residuals_summary <- data.frame(
  Equation = eq_names,
  Mean_Residual = sapply(fit$residuals, function(r) round(mean(r, na.rm = TRUE), 6)),
  SD_Residual = sapply(fit$residuals, function(r) round(sd(r, na.rm = TRUE), 4)),
  Min = sapply(fit$residuals, function(r) round(min(r, na.rm = TRUE), 3)),
  Max = sapply(fit$residuals, function(r) round(max(r, na.rm = TRUE), 3))
)

print(residuals_summary)

# Correlation of residuals (tests for joint hypothesis)
cat("\n\nCorrelation of Residuals (testing joint hypothesis):\n\n")

residual_matrix <- do.call(cbind, fit$residuals)
colnames(residual_matrix) <- eq_names

corr_residuals <- cor(residual_matrix, use = "complete.obs")
print(round(corr_residuals, 3))

cat("\nInterpretation: High correlations suggest equation interdependence,\n")
cat("justifying the use of 3SLS over equation-by-equation estimation.\n")

# ============================================================================
# 11. MODEL DIAGNOSTICS
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("SYSTEM SUMMARY\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("System Test Statistics:\n")
cat("  - Sigma (residual correlation matrix):\n")
print(round(fit$Sigma, 4))

cat("\n  - Omega (variance-covariance):\n")
print(round(fit$Omega, 4))

# ============================================================================
# 12. SAVING RESULTS
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("SUMMARY & RECOMMENDATIONS FOR SAVING\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("To save results to files:\n\n")

cat("1. Save workspace:\n")
cat("   save.image('analysis_results.RData')\n\n")

cat("2. Save LaTeX tables:\n")
cat("   cat(capture.output(print(latex_structural[[1]])), \n")
cat("       file='table_rp_structural.txt')\n\n")

cat("3. Save reduced form:\n")
cat("   cat(capture.output(print(latex_reduced[[1]])), \n")
cat("       file='table_rp_reduced.txt')\n\n")

cat("4. Access specific results:\n")
cat("   - Coefficients: fit$structural$coefficients$RP\n")
cat("   - Variance-Covariance: fit$structural$vcov_ml\n")
cat("   - Residuals: fit$residuals$RP\n")
cat("   - Fitted values: fit$fitted$RP\n\n")

# ============================================================================
# 13. END OF ANALYSIS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("ANALYSIS COMPLETE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Key results available:\n")
cat("  - fit: Full 3SLS estimation results\n")
cat("  - rf: Reduced form analysis\n")
cat("  - latex_structural: LaTeX tables for all equations\n")
cat("  - latex_reduced: LaTeX reduced form tables\n\n")

cat("Next steps:\n")
cat("  1. Review structural coefficients\n")
cat("  2. Examine residual diagnostics\n")
cat("  3. Test exclusion restrictions\n")
cat("  4. Compare elasticities across equations\n")
cat("  5. Prepare publication tables\n\n")

cat("For more details, see: README.md\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")
