# ============================================================================
# EXAMPLE: 3SLS ANALYSIS OF LABOR MARKET OUTCOMES
# ============================================================================
#
# This script demonstrates 3SLS estimation of a labor economics model
# with simultaneous equations for wages, education, and employment.
#
# The system demonstrates:
# - Wage determination with endogenous education and employment
# - Education investment decisions
# - Employment selection effects
# - Instrument variable strategy
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

# Select all variables
all_vars <- c("weight", "log_wage", "education", "employment", 
              "age", "family_background", "ability", "experience", "region")

Data <- Data_raw[, all_vars]

# Remove any missing values
complete_idx <- complete.cases(Data)
Data_clean <- Data[complete_idx, ]
weight <- Data_clean$weight

cat("  - Raw observations:", nrow(Data_raw), "\n")
cat("  - After removing missing:", nrow(Data_clean), "\n")
cat("  - Weight vector length:", length(weight), "\n\n")

# ============================================================================
# 4. DEFINE SYSTEM OF EQUATIONS
# ============================================================================

cat("\nStep 4: Defining structural equations...\n\n")

cat("System specification:\n")
cat("  Eq 1: log_wage ~ education + experience + employment + region\n")
cat("  Eq 2: education ~ ability + family_background + age + experience\n")
cat("  Eq 3: employment ~ log_wage + education + age + region\n\n")

equations <- list(
  # Equation 1: Log wage determination
  # Endogenous: education, employment
  # Exogenous: experience, region
  log_wage = log_wage ~ education + experience + employment + region,
  
  # Equation 2: Education investment
  # Depends on ability, family background, age, and experience
  education = education ~ ability + family_background + age + experience,
  
  # Equation 3: Employment decision
  # Depends on wages, education, age, and region
  employment = employment ~ log_wage + education + age + region
)

cat("✓ System of 3 equations defined\n")

# All exogenous variables used as instruments
instruments <- ~ age + family_background + ability + experience + region

cat("✓ Instruments specified: age, family_background, ability, experience, region\n\n")

# ============================================================================
# 5. ESTIMATE 3SLS SYSTEM
# ============================================================================

cat("\nStep 5: Estimating 3SLS system...\n")
cat("  (Estimating simultaneous equations...)\n\n")

fit <- threeSLS_system(
  equations = equations,
  inst = instruments,
  data = Data_clean,
  weights = weight,
  verbose = FALSE
)

cat("✓ 3SLS estimation complete\n\n")

# ============================================================================
# 6. DISPLAY STRUCTURAL RESULTS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("STRUCTURAL ESTIMATES (3SLS)\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

summary(fit)

# ============================================================================
# 7. INTERPRETATION OF RESULTS
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("INTERPRETATION\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Wage Equation (log_wage):\n")
cat("  - education coefficient: Return to years of schooling\n")
cat("  - experience coefficient: Return to labor market experience\n")
cat("  - employment coefficient: Wage premium for employed vs unemployed\n")
cat("  - region coefficient: Regional wage differential\n\n")

cat("Education Equation:\n")
cat("  - ability coefficient: Effect of ability on educational attainment\n")
cat("  - family_background coefficient: Family socioeconomic effect\n")
cat("  - age/experience coefficients: Lifecycle education patterns\n\n")

cat("Employment Equation:\n")
cat("  - log_wage coefficient: Job search/labor supply response to wages\n")
cat("  - education coefficient: Effect of education on employment probability\n")
cat("  - age coefficient: Age/lifecycle employment patterns\n")
cat("  - region coefficient: Regional labor market conditions\n\n")

# ============================================================================
# 8. LaTeX OUTPUT
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("LATEX OUTPUT - FOR PUBLICATION\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Generate LaTeX tables
latex_structural <- latex_structural_3SLS(fit, robust = TRUE, digits = 4)

cat("Wage Equation (LaTeX):\n")
cat(paste(rep("-", 60), collapse=""), "\n\n")
print(latex_structural$log_wage)

cat("\n\nEducation Equation (LaTeX):\n")
cat(paste(rep("-", 60), collapse=""), "\n\n")
print(latex_structural$education)

cat("\n\nEmployment Equation (LaTeX):\n")
cat(paste(rep("-", 60), collapse=""), "\n\n")
print(latex_structural$employment)

# ============================================================================
# 9. REDUCED FORM ANALYSIS
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("REDUCED FORM ANALYSIS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Computing reduced form (impact of exogenous variables)...\n\n")

rf <- reduced_form_3SLS(fit, data = Data_clean)

cat("Reduced form shows total effects of exogenous variables\n")
cat("on endogenous outcomes (direct + indirect effects).\n\n")

cat("Example interpretation:\n")
cat("  - ability → education (direct)\n")
cat("  - ability → wages (via education)\n")
cat("  - ability → employment (via education and wages)\n\n")

# ============================================================================
# 10. DIAGNOSTICS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("DIAGNOSTIC STATISTICS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Residual Summary Statistics:\n\n")

eq_names <- fit$eq_names
residuals_summary <- data.frame(
  Equation = eq_names,
  Mean = round(sapply(fit$residuals, function(r) mean(r, na.rm = TRUE)), 6),
  SD = round(sapply(fit$residuals, function(r) sd(r, na.rm = TRUE)), 4),
  Min = round(sapply(fit$residuals, function(r) min(r, na.rm = TRUE)), 3),
  Max = round(sapply(fit$residuals, function(r) max(r, na.rm = TRUE)), 3)
)

print(residuals_summary)

cat("\n\nResidual Correlations (Testing Joint Significance):\n\n")

residual_matrix <- do.call(cbind, fit$residuals)
colnames(residual_matrix) <- eq_names

corr_residuals <- cor(residual_matrix, use = "complete.obs")
print(round(corr_residuals, 3))

cat("\nNon-zero correlations indicate simultaneity bias,\n")
cat("justifying 3SLS over single-equation estimation.\n\n")

# ============================================================================
# 11. ECONOMIC INSIGHTS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("ECONOMIC INSIGHTS FROM 3SLS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Why 3SLS is important here:\n\n")

cat("1. Simultaneity:\n")
cat("   - Wages affect education (higher returns incentivize schooling)\n")
cat("   - Education affects wages (human capital productivity)\n")
cat("   - Employment affects wages (selection effects)\n")
cat("   → OLS would be biased; 3SLS corrects this\n\n")

cat("2. Endogeneity:\n")
cat("   - Education choice depends on expected wages\n")
cat("   - Employment depends on wage opportunities\n")
cat("   → These are endogenous decisions, not exogenous\n\n")

cat("3. Instruments:\n")
cat("   - Ability, family background → education (not wages directly)\n")
cat("   - Age, region → employment and education opportunities\n")
cat("   → These affect outcomes only through structural channels\n\n")

# ============================================================================
# 12. ACCESSING RESULTS
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("HOW TO ACCESS RESULTS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("In your R workspace:\n\n")
cat("1. Structural coefficients:\n")
cat("   fit$structural$coefficients$log_wage\n")
cat("   fit$structural$coefficients$education\n")
cat("   fit$structural$coefficients$employment\n\n")

cat("2. Standard errors:\n")
cat("   sqrt(diag(fit$structural$vcov_ml))\n")
cat("   sqrt(diag(fit$structural$vcov_robust))\n\n")

cat("3. Residuals and fitted values:\n")
cat("   fit$residuals$log_wage\n")
cat("   fit$fitted$log_wage\n\n")

cat("4. Reduced form:\n")
cat("   rf$Pi  (reduced form coefficients)\n")
cat("   rf$B_inv  (impact multiplier matrix)\n\n")

cat("5. Save all results:\n")
cat("   save(fit, rf, file='labor_3sls_results.RData')\n\n")

# ============================================================================
# 13. CONCLUSION
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("ANALYSIS COMPLETE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("✓ 3SLS system successfully estimated\n")
cat("✓ Simultaneous equations properly accounted for\n")
cat("✓ Results ready for interpretation and publication\n\n")

cat("This example demonstrates:\n")
cat("  - How to structure simultaneous equation systems\n")
cat("  - How to select appropriate instruments\n")
cat("  - How to interpret 3SLS results\n")
cat("  - How to generate publication-ready output\n\n")

cat("For more details on the methodology, see:\n")
cat("  - README.md (full documentation)\n")
cat("  - docs/VARIABLE_GUIDE.md (variable definitions)\n")
cat("  - QUICKSTART.md (quick reference)\n\n")

cat(paste(rep("=", 80), collapse=""), "\n\n")
