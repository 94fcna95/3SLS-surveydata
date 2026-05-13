# ============================================================================
# LABOR ECONOMICS SYNTHETIC DATA GENERATOR
# ============================================================================
#
# Generates realistic labor market data for demonstrating 3SLS estimation.
#
# System of equations:
#   eq1: log_wage    ~ education + experience + hours_worked + region
#   eq2: education   ~ ability + family_background + age + experience
#   eq3: hours_worked ~ log_wage + education + age + region
#
# Usage:
#   source("Examples/labor_data_generator.R")
#   data <- labor_data
#
# ============================================================================

set.seed(42)
n <- 1500

# ============================================================================
# 1. EXOGENOUS VARIABLES
# ============================================================================

age               <- round(pmax(22, pmin(65, rnorm(n, 42, 12))))
family_background <- rnorm(n, 0, 1)
ability           <- rnorm(n, 0, 1)
region            <- rbinom(n, 1, prob = 0.45)

# ============================================================================
# 2. EXPERIENCE
# ============================================================================

experience <- pmax(0, pmin(40, 0.5 * (age - 22) + rnorm(n, 0, 8)))

# ============================================================================
# 3. EDUCATION (endogenous)
# ============================================================================

education <- pmax(8, pmin(20,
               12 +
               1.5 * ability +
               0.8 * family_background +
               0.05 * age +
               rnorm(n, 0, 1.5)))

# ============================================================================
# 4. HOURS WORKED (endogenous, weekly hours 0-60)
# ============================================================================

hours_worked <- pmax(0, pmin(60,
                  25 +
                  3.0 * (education - 12) +
                  0.5 * experience +
                  -0.02 * (age - 40)^2 / 10 +
                  5.0 * region +
                  rnorm(n, 0, 8)))

# ============================================================================
# 5. LOG WAGES (endogenous, hourly)
# ============================================================================

log_wage <- 2.0 +
            0.08  * education +
            0.03  * experience +
            0.005 * hours_worked +
            0.20  * region +
            0.10  * ability +
            rnorm(n, 0, 0.5)

wage <- exp(log_wage)

# ============================================================================
# 6. DATA FRAME
# ============================================================================

labor_data <- data.frame(
  id                = 1:n,
  age               = age,
  family_background = round(family_background, 2),
  ability           = round(ability, 2),
  region            = region,
  experience        = round(experience, 1),
  education         = round(education, 1),
  hours_worked      = round(hours_worked, 1),
  wage              = round(wage, 2),
  log_wage          = round(log_wage, 3),
  weight            = rep(1, n)
)

# ============================================================================
# 7. SUMMARY
# ============================================================================

cat(paste(rep("=", 70), collapse=""), "\n")
cat("LABOR ECONOMICS SYNTHETIC DATA GENERATOR\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

cat("Dataset Summary:\n")
cat("  - Observations:    ", nrow(labor_data), "\n")
cat("  - Complete cases:  ", sum(complete.cases(labor_data)), "\n")
cat("  - Mean wage:      $", round(mean(labor_data$wage), 2), "\n")
cat("  - Mean education:  ", round(mean(labor_data$education), 2), "years\n")
cat("  - Mean experience: ", round(mean(labor_data$experience), 2), "years\n")
cat("  - Mean hours/week: ", round(mean(labor_data$hours_worked), 1), "\n\n")

cat("Correlation Matrix:\n\n")
key_vars <- c("education", "hours_worked", "log_wage",
              "age", "ability", "family_background", "experience", "region")
print(round(cor(labor_data[, key_vars]), 3))

cat("\n")
cat(paste(rep("=", 70), collapse=""), "\n")
cat("Ready for analysis. Use: labor_data\n")
cat(paste(rep("=", 70), collapse=""), "\n")
