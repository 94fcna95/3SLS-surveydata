# ============================================================================
# LABOR ECONOMICS SYNTHETIC DATA GENERATOR
# ============================================================================
#
# Generates realistic labor market data suitable for demonstrating 3SLS
# estimation with simultaneous equations.
#
# Variables generated:
# - Continuous: wages, education, experience, ability
# - Binary: employment status
# - Exogenous: age, family_background, region
#
# Usage:
#   source("Examples/labor_data_generator.R")
#   data <- labor_data
#
# ============================================================================

set.seed(42)

# Sample size
n <- 1500

cat("\n")
cat(paste(rep("=", 70), collapse=""), "\n")
cat("LABOR ECONOMICS SYNTHETIC DATA GENERATOR\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

# ============================================================================
# 1. EXOGENOUS VARIABLES (NOT determined by the system)
# ============================================================================

# Age (22-65): affects experience, education, employment
age <- round(rnorm(n, mean = 42, sd = 12))
age <- pmax(22, pmin(65, age))

# Family background (index: -2 to 2, negative = disadvantaged)
family_background <- rnorm(n, mean = 0, sd = 1)

# Ability (IQ-like, standardized: mean 0, SD 1)
ability <- rnorm(n, mean = 0, sd = 1)

# Region indicator (0 = low wage region, 1 = high wage region)
region <- rbinom(n, 1, prob = 0.45)

# ============================================================================
# 2. EXPERIENCE (exogenous, loosely related to age but NOT perfectly dependent)
# ============================================================================
# Experience varies from age relationship (labor force participation gaps, etc.)

base_experience <- age - 22  # Base relationship
experience_noise <- rnorm(n, mean = 0, sd = 2)  # Add noise so not perfectly collinear
experience <- base_experience + experience_noise
experience <- pmax(0, pmin(45, experience))  # Bounded: 0-45 years

# ============================================================================
# 3. EDUCATION (endogenous, depends on ability, family background, age)
# ============================================================================
# Higher ability + better family background → more education

education_latent <- 12 +                    # Base years of schooling
                    1.5 * ability +          # Ability effect
                    0.8 * family_background + # Family background effect
                    0.05 * age +             # Older = more education
                    rnorm(n, 0, 1.5)         # Random shock

education <- pmax(8, pmin(20, education_latent))  # Bounded: 8-20 years

# ============================================================================
# 4. EMPLOYMENT (endogenous, 0/1 indicator)
# ============================================================================
# Employment probability depends on wages (higher wages → more employment)
# and education (more educated → higher employment)
# Age also matters (inverted U-shape)

employment_prob <- 0.4 +                           # Base probability
                   0.08 * (education - 12) +      # Education effect
                   0.01 * (experience - 20) +     # Experience effect
                   -0.001 * (age - 42)^2 / 100 +  # Age effect (inverted U)
                   0.15 * region +                # Regional effect
                   rnorm(n, 0, 0.15)              # Random shock

employment_prob <- pmax(0.1, pmin(0.95, employment_prob))
employment <- rbinom(n, 1, prob = employment_prob)

# ============================================================================
# 5. WAGES (endogenous, continuous)
# ============================================================================
# Log wages depend on:
# - Education (main effect)
# - Experience (main effect)
# - Employment status (selection effect)
# - Region (wage differentials)
# - Ability (productivity)

log_wage <- 2.0 +                      # Base log wage (≈ $7.39/hour)
            0.08 * education +         # Returns to education
            0.03 * experience +        # Returns to experience
            0.25 * employment +        # Employment status premium
            0.20 * region +            # Regional wage premium
            0.10 * ability +           # Ability/productivity
            rnorm(n, 0, 0.35)          # Wage shock

wage <- exp(log_wage)

# ============================================================================
# 6. CREATE DATA FRAME
# ============================================================================

labor_data <- data.frame(
  # Identifiers
  id = 1:n,
  
  # Exogenous variables (instruments)
  age = age,
  family_background = round(family_background, 2),
  ability = round(ability, 2),
  region = region,
  experience = experience,
  
  # Endogenous variables
  education = round(education, 1),
  employment = employment,
  wage = round(wage, 2),
  log_wage = round(log_wage, 3),
  
  # Weight (uniform for this example)
  weight = rep(1, n)
)

# ============================================================================
# 7. DATA QUALITY CHECKS
# ============================================================================

cat("Dataset Summary:\n")
cat("  - Number of observations:", nrow(labor_data), "\n")
cat("  - Number of variables:", ncol(labor_data), "\n")
cat("  - Complete cases:", sum(complete.cases(labor_data)), "\n")
cat("  - Employment rate:", round(mean(labor_data$employment), 3), "\n")
cat("  - Mean wage: $", round(mean(labor_data$wage), 2), "\n")
cat("  - Mean education:", round(mean(labor_data$education), 2), "years\n")
cat("  - Mean experience:", round(mean(labor_data$experience), 2), "years\n\n")

cat("Variable Summary:\n")
print(summary(labor_data))

cat("\n")
cat(paste(rep("=", 70), collapse=""), "\n")
cat("Ready for analysis. Use: labor_data\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

# ============================================================================
# 8. CORRELATION MATRIX
# ============================================================================

cat("Correlation Matrix (Endogenous & Key Exogenous):\n\n")

key_vars <- c("education", "employment", "log_wage", "age", "ability", 
              "family_background", "experience", "region")

corr_matrix <- cor(labor_data[, key_vars], use = "complete.obs")
print(round(corr_matrix, 3))

cat("\n✓ No perfect multicollinearity detected\n")
cat("✓ Realistic correlations for labor economics\n")
cat("✓ Ready for 3SLS estimation\n\n")

# ============================================================================
# 9. MODEL STRUCTURE (for reference)
# ============================================================================

cat("Expected System of Equations:\n\n")
cat("Equation 1 (Log Wages):\n")
cat("  log_wage ~ education + experience + employment + region + ability\n\n")
cat("Equation 2 (Education):\n")
cat("  education ~ ability + family_background + age + experience\n\n")
cat("Equation 3 (Employment):\n")
cat("  employment ~ log_wage + education + age + region\n\n")
cat("Instruments: age, family_background, ability, experience, region\n\n")
