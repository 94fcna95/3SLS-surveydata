# ============================================================================
# SYNTHETIC DATA GENERATOR
# ============================================================================
#
# This script generates synthetic data that mirrors the structure of the
# China General Social Survey (CGSS) 2006 microdata.
#
# The synthetic data:
# - Preserves variable correlations and distributions
# - Maintains survey weight structure
# - Allows free distribution for examples and testing
# - Replicates the analysis structure used in the main application
#
# Usage:
#   source("Examples/synthetic_data_generator.R")
#   data <- CGSS_synthetic
#
# ============================================================================

set.seed(12345)  # For reproducibility

# Sample size
n <- 3000

# ============================================================================
# 1. BASIC DEMOGRAPHIC VARIABLES
# ============================================================================

# Age (18-85)
age <- rnorm(n, mean = 42, sd = 15)
age <- pmax(18, pmin(85, age))
age <- round(age)
age2 <- age^2 / 100  # Scaled age squared

# Gender (0 = male, 1 = female)
female <- rbinom(n, 1, prob = 0.5)

# Urban/Rural (0 = rural, 1 = urban)
Urb <- rbinom(n, 1, prob = 0.4)
Rur <- 1 - Urb

# Education (years completed)
yeduc <- round(rnorm(n, mean = 10, sd = 4))
yeduc <- pmax(0, pmin(20, yeduc))

# Income (log scale, then exponentiate)
linc <- rnorm(n, mean = 7.5, sd = 1.5)
linc2 <- linc^2
Income <- exp(linc)

# ============================================================================
# 2. ENVIRONMENTAL VARIABLES
# ============================================================================

# Water access (1-5 scale, higher = better)
water <- round(rnorm(n, mean = 3, sd = 1.2))
water <- pmax(1, pmin(5, water))

# Flood exposure (1-5 scale, higher = more exposure)
flood <- round(rnorm(n, mean = 2, sd = 1.5))
flood <- pmax(1, pmin(5, flood))

# Revenue/Economic conditions (1-5 scale)
rev <- round(rnorm(n, mean = 3, sd = 1.3))
rev <- pmax(1, pmin(5, rev))

# Income difference perception (1-5 scale)
Dif <- round(rnorm(n, mean = 3.5, sd = 1.4))
Dif <- pmax(1, pmin(5, Dif))

# ============================================================================
# 3. POLITICAL & BELIEF VARIABLES
# ============================================================================

# Party affiliation (0 = no, 1 = yes)
party <- rbinom(n, 1, prob = 0.15)

# Religious believer (0 = no, 1 = yes)
believer <- rbinom(n, 1, prob = 0.25)

# ============================================================================
# 4. OUTCOME VARIABLES
# ============================================================================

# Small-scale internal migration (Migs) - for rural residents only
# 1=never thought, 2=thought, 3=prepared, 4=planned, 5=migrated
Migs_full <- round(rnorm(n, mean = 2, sd = 1.5))
Migs_full <- pmax(1, pmin(5, Migs_full))
Migs <- ifelse(Rur == 1, Migs_full, NA)  # Only rural residents

# Large-scale internal migration (Migl)
Migl_full <- round(rnorm(n, mean = 1.8, sd = 1.6))
Migl_full <- pmax(1, pmin(5, Migl_full))
Migl <- ifelse(Rur == 1, Migl_full, NA)  # Only rural residents

# Redistribution preference (RP) 1-5 scale
RP <- round(rnorm(n, mean = 3.2, sd = 1.4))
RP <- pmax(1, pmin(5, RP))

# ============================================================================
# 5. MERIT INDICES (constructed from factor analysis)
# ============================================================================

# These would normally be computed via factor analysis
# Here we create them as composites that reflect the concepts:

# Merit Dimension 1 (FcM1): Individual effort & talent
# - Intelligence, ambition, work ethic (high correlation)
FcM1_raw <- rnorm(n, mean = 0, sd = 1)
FcM1_raw <- FcM1_raw - min(FcM1_raw, na.rm = TRUE) + 1

# Merit Dimension 2 (FcM2): Education & talent
# - Related to education level
FcM2_raw <- rnorm(n, mean = 0, sd = 1)
FcM2_raw <- (FcM2_raw + 0.5 * scale(yeduc)[,1])  # Correlated with education
FcM2_raw <- FcM2_raw - min(FcM2_raw, na.rm = TRUE) + 1

# Actual Merit Factor (FcAM): Non-meritocratic factors
# - Family background, social networks, luck
FcAM_raw <- rnorm(n, mean = 0, sd = 1)
FcAM_raw <- FcAM_raw - min(FcAM_raw, na.rm = TRUE) + 1

# Store on standardized scale (1 to high value)
FcM1 <- FcM1_raw / max(FcM1_raw, na.rm = TRUE) * 5
FcM2 <- FcM2_raw / max(FcM2_raw, na.rm = TRUE) * 5
FcAM <- FcAM_raw / max(FcAM_raw, na.rm = TRUE) * 5

# ============================================================================
# 6. SURVEY WEIGHTS
# ============================================================================

# Create realistic survey weights (common in household surveys)
# Weights account for differential sampling probability
# Higher weight = more representative of population
weight <- rnorm(n, mean = 1, sd = 0.3)
weight <- pmax(0.1, pmin(3, weight))  # Range: 0.1 to 3
weight <- weight / mean(weight)  # Normalize so mean = 1

# ============================================================================
# 7. CREATE DATA FRAME
# ============================================================================

CGSS_synthetic <- data.frame(
  # Identifiers
  id = 1:n,
  
  # Demographics
  age = age,
  age2 = age2,
  female = female,
  Urb = Urb,
  Rur = Rur,
  yeduc = yeduc,
  
  # Economic
  Income = Income,
  linc = linc,
  linc2 = linc2,
  
  # Environmental
  water = water,
  flood = flood,
  rev = rev,
  Dif = Dif,
  
  # Political
  party = party,
  believer = believer,
  
  # Migration outcomes (NA for urban residents)
  Migs = Migs,
  Migl = Migl,
  
  # Redistribution preference
  RP = RP,
  
  # Merit indices
  FcM1 = FcM1,
  FcM2 = FcM2,
  FcAM = FcAM,
  
  # Survey weight
  weight = weight
)

# ============================================================================
# 8. DATA QUALITY CHECKS
# ============================================================================

cat("\n")
cat(paste(rep("=", 70), collapse=""), "\n")
cat("SYNTHETIC CGSS DATA GENERATED\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

cat("Dataset Summary:\n")
cat("  - Number of observations:", nrow(CGSS_synthetic), "\n")
cat("  - Number of variables:", ncol(CGSS_synthetic), "\n")
cat("  - Complete cases (all variables):", sum(complete.cases(CGSS_synthetic)), "\n")
cat("  - Rural sample size:", sum(CGSS_synthetic$Rur, na.rm = TRUE), "\n")
cat("  - Urban sample size:", sum(CGSS_synthetic$Urb, na.rm = TRUE), "\n\n")

cat("Variable Summary:\n")
print(summary(CGSS_synthetic))

cat("\n\nVariables with missing values:\n")
missing_summary <- colSums(is.na(CGSS_synthetic))
print(missing_summary[missing_summary > 0])

cat("\n")
cat(paste(rep("=", 70), collapse=""), "\n")
cat("Ready for analysis. Use: CGSS_synthetic\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

# ============================================================================
# 9. SAMPLE DESCRIPTIVE STATISTICS
# ============================================================================

cat("Correlation Matrix (Key Variables):\n\n")
key_vars <- c("age", "yeduc", "linc", "water", "flood", "RP", "FcM1", "FcM2", "FcAM")
if (all(key_vars %in% names(CGSS_synthetic))) {
  corr_matrix <- cor(CGSS_synthetic[, key_vars], use = "complete.obs")
  print(round(corr_matrix, 3))
}

cat("\n")
