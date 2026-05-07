# ============================================================================
# UTILITY FUNCTIONS FOR 3SLS ANALYSIS
# ============================================================================
#
# This file contains helper functions for data transformation and analysis.
# Application-specific data loading/transformation should be done separately
# in your analysis script.
#
# Functions included:
#  - Transl(): Translate vector to start at 1
#  - POLS(): Polychoric ordinal transformation
#  - EGP(): Occupational class recoding
#  - C_to_symbolic_df(): Matrix to symbolic representation
#  - make_X_from_Pi(): Build design matrix from reduced form
#
# ============================================================================

# Translation function: shift vector so minimum value is 1
Transl <- function(x) {
  # Translate a vector so that its minimum is 1
  y <- x - min(x, na.rm = TRUE) + 1
  return(y)
}

# ============================================================================
# POLS: Polychoric Ordinal Least Squares Transformation
# ============================================================================
# Transforms ordinal (Likert) variables to continuous approximation
# Useful for Likert-scale survey responses (1-5, 1-7, etc.)

POLS <- function(ys, w = weight, inorm = 0) {
  #' Polychoric Ordinal Transformation
  #'
  #' @param ys Vector of ordinal responses
  #' @param w Weight vector (default: global "weight")
  #' @param inorm Normalize to 1-max scale (default: 0 = no normalization)
  #'
  #' @return Continuous approximation to ordinal variable
  
  n <- length(ys)
  y <- ys
  if (min(y, na.rm = TRUE) == 0) y <- ys + 1
  yt <- rep(0, n)
  
  # Compute weighted percentiles for each category
  p <- weights::wpct(ys, weight = w, na.rm = TRUE)
  ni <- length(p)
  N <- cumsum(p)
  N[ni] <- min(N[ni], 0.99999999)
  
  # Apply inverse normal CDF to percentiles
  # This transforms percentiles to continuous scale
  lnz <- rep(NA, ni)
  lnz[1] <- -stats::dnorm(stats::qnorm(N[1])) / stats::pnorm(stats::qnorm(N[1]))
  
  for (i in 2:ni) {
    lnz[i] <- (stats::dnorm(stats::qnorm(N[i-1])) - stats::dnorm(stats::qnorm(N[i]))) /
              (stats::pnorm(stats::qnorm(N[i])) - stats::pnorm(stats::qnorm(N[i-1])))
  }
  
  # Assign continuous scores to each observation
  for (i in 1:n) {
    yt[i] <- lnz[y[i]]
  }
  
  # Shift to start at 1
  yt <- yt - min(yt, na.rm = TRUE) + 1
  
  # Optional: normalize to 1-max_category scale
  if (inorm == 1) {
    a <- 1
    b <- ni
    min_x <- min(yt, na.rm = TRUE)
    max_x <- max(yt, na.rm = TRUE)
    ytt <- a + ((yt - min_x) / (max_x - min_x)) * (b - a)
    return(ytt)
  } else {
    return(yt)
  }
}

# ============================================================================
# EGP: Occupational Class Recoding
# ============================================================================
# Recodes raw occupational codes to EGP class schema
# (1=higher controllers, 2=lower controllers, ..., 9=farm labor)

EGP <- function(x, urban = NULL) {
  #' EGP Occupational Class Recoding
  #'
  #' @param x Raw occupational code
  #' @param urban Optional urban indicator (for missing value handling)
  #'
  #' @return EGP class (1-9)
  #'
  #' Classes:
  #'  1) Higher controllers    
  #'  2) Lower controllers    
  #'  3) Routine nonmanual   
  #'  4) Lower sales/service 
  #'  5) Self-employed       
  #'  6) Manual supervisors    
  #'  7) Skilled workers       
  #'  8) Unskilled workers    
  #'  9) Farm labor
  
  X <- x
  
  # Handle missing values based on urban status
  if (!is.null(urban)) {
    X[is.na(X) == TRUE & urban == 0] <- 10
  }
  
  # Clean invalid codes
  X[X < 0] <- NA
  X[X > 11] <- NA
  
  # Recode original categories
  X[X == 8] <- 6
  X[X == 9] <- 7
  X[X == 10] <- 8
  X[X == 11] <- 9
  X <- X + 10
  X[X == 11] <- 5
  X[X == 12] <- 5
  X[X == 13] <- 4
  X[X == 14] <- 4
  X[X == 15] <- 3
  X[X == 16] <- 2
  X[X == 17] <- 2
  X[X == 18] <- 1
  X[X == 19] <- 1
  
  return(X)
}

# ============================================================================
# HELPER FUNCTIONS FOR 3SLS OUTPUT
# ============================================================================

# Convert matrix to symbolic representation (0 or c for non-zero)
C_to_symbolic_df <- function(C, tol = 1e-10) {
  #' Matrix to Symbolic Representation
  #' Used for displaying structural restriction patterns
  
  sym <- ifelse(abs(C) <= tol, "0", "c")
  df <- as.data.frame(sym, stringsAsFactors = FALSE)
  rownames(df) <- rownames(C)
  colnames(df) <- colnames(C)
  return(df)
}

# Build design matrix from reduced form coefficients
make_X_from_Pi <- function(Pi, data) {
  #' Build Design Matrix from Reduced Form
  #' Creates X matrix aligned with reduced form Pi matrix
  
  vars <- rownames(Pi)
  X <- sapply(vars, function(v) {
    if (v %in% c("(Intercept)", "const", "1")) {
      rep(1, nrow(data))
    } else {
      data[[v]]
    }
  })
  X <- as.matrix(X)
  colnames(X) <- vars
  return(X)
}

# ============================================================================
# END OF UTILITY FUNCTIONS
# ============================================================================
# 
# Usage in analysis scripts:
#   source("R/Meritocracy-lib.r")  # Load these utility functions
#   
#   # Then in your analysis:
#   merit_continuous <- POLS(merit_ordinal, w = survey_weight)
#   class_recoded <- EGP(occupation_code, urban = urban_indicator)
#   X <- make_X_from_Pi(Pi, data)
#
# ============================================================================
