# ============================================================================
# DEPENDENCIES AND CORE FUNCTIONS LOADER
# ============================================================================
#
# This script loads all required R libraries and core functions for the 
# 3SLS system estimation and analysis.
#
# Usage:
#   source("Deps.R")
#
# This will:
# 1. Install missing packages
# 2. Load all required libraries
# 3. Load the 3SLS estimation functions
# 4. Load LaTeX formatting tools
# 5. Load utility functions (POLS, Transl, etc.)
#
# ============================================================================

# ============================================================================
# 1. REQUIRED LIBRARIES
# ============================================================================

cat("\n============================================\n")
cat("Loading dependencies...\n")
cat("============================================\n\n")

# List of required packages
packages_required <- c(
  "MASS",      # For ginv() - generalized matrix inverse
  "Matrix",    # For bdiag() - block diagonal matrices
  "weights",   # For wpct() - weighted percentages
  "xtable",    # For LaTeX table generation
  "DescTools", # For weighted median and other statistics
  "psych"      # For fa() and factor.scores()
)

# Check and install missing packages
for (pkg in packages_required) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing package:", pkg, "\n")
    install.packages(pkg, dependencies = TRUE, quiet = TRUE)
    library(pkg, character.only = TRUE, quietly = TRUE)
  } else {
    cat("✓", pkg, "\n")
  }
}

cat("\n✓ All required packages loaded successfully.\n\n")

# ============================================================================
# 2. LOAD CORE LIBRARIES
# ============================================================================

cat("Loading core 3SLS libraries...\n\n")

# Check if files exist before sourcing
source_safe <- function(filename) {
  if (!file.exists(filename)) {
    stop(paste("Error: Cannot find file:", filename, 
               "\nMake sure you're in the repository directory."))
  }
  source(filename, verbose = FALSE)
}

# Source the main 3SLS estimation library
source_safe("R/CGT-3SLS-lib.r")
cat("✓ Loaded: CGT-3SLS-lib.r (3SLS estimation functions)\n")

# Source the LaTeX output library
source_safe("R/CGT-LaTex-lib.r")
cat("✓ Loaded: CGT-LaTex-lib.r (LaTeX output functions)\n")

# Source the utility functions library
# IMPORTANT: This file contains ONLY utility functions
# (Transl, POLS, EGP, etc.)
# Do NOT add data loading code to this file!
source_safe("R/Meritocracy-lib.r")
cat("✓ Loaded: Meritocracy-lib.r (Utility functions)\n")

cat("\n✓ All core libraries loaded successfully.\n\n")

# ============================================================================
# 3. VERIFY FUNCTIONS ARE LOADED
# ============================================================================

cat("Verifying functions are available...\n\n")

# Check for main functions
required_functions <- c(
  "threeSLS_system",
  "reduced_form_3SLS",
  "latex_structural_3SLS",
  "latex_reduced_3SLS",
  "POLS",
  "Transl"
)

for (func in required_functions) {
  if (exists(func)) {
    cat("✓", func, "\n")
  } else {
    warning(paste("Warning: Function", func, "not found!"))
  }
}

cat("\n")

# ============================================================================
# 4. GLOBAL CONFIGURATION (Optional)
# ============================================================================

# Set options for improved output
options(digits = 4)           # Display 4 decimal places
options(scipen = 999)         # Avoid scientific notation
options(width = 120)          # Console width
options(stringsAsFactors = FALSE)  # Avoid automatic factor conversion

# ============================================================================
# 5. READY MESSAGE
# ============================================================================

cat("============================================\n")
cat("3SLS SYSTEM READY FOR ANALYSIS\n")
cat("============================================\n\n")

cat("Key functions:\n")
cat("  • threeSLS_system()           : Main 3SLS estimation\n")
cat("  • summary.threeSLS_fit()      : Summary statistics\n")
cat("  • reduced_form_3SLS()         : Reduced form computation\n")
cat("  • latex_structural_3SLS()     : LaTeX structural results\n")
cat("  • latex_reduced_3SLS()        : LaTeX reduced form results\n")
cat("  • POLS()                      : Ordinal transformation\n")
cat("  • Transl()                    : Vector translation\n")
cat("  • EGP()                       : Occupational class recoding\n\n")

cat("Next step:\n")
cat("  source(\"Examples/Example_Meritocracy.R\")\n\n")

cat("Documentation:\n")
cat("  • README.md                   : Full documentation\n")
cat("  • QUICKSTART.md               : Quick start guide\n")
cat("  • docs/VARIABLE_GUIDE.md      : Variable definitions\n\n")

# ============================================================================
# END OF DEPS.R
# ============================================================================
