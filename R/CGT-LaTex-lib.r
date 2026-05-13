#Printing LaTex 3SLS output

# latex_struct <- latex_structural_3SLS(fit, robust = TRUE)
# print(latex_struct[[1]], include.rownames = TRUE)

# latex_rf <- latex_reduced_3SLS(fit)
# print(latex_rf[[1]], include.rownames = TRUE)

.R2_structural <- function(fit, i) {
  r       <- fit$residuals[[i]]
  idx     <- fit$idx_list[[i]]
  eq_name <- fit$eq_names[i]
  y <- tryCatch(
    get(eq_name, envir = .GlobalEnv)[idx],
    error = function(e) NULL
  )
  if (is.null(y) || length(y) != length(r)) return(NA_real_)
  cor(y, y - r)^2
}


.star_fun <- function(p) {
  ifelse(p < 0.001, "***",
         ifelse(p < 0.01, "**",
                ifelse(p < 0.05, "*",
                       ifelse(p < 0.1, ".", ""))))
}


latex_structural_3SLS <- function(object, digits = 3, robust = TRUE) {
  
  if (!inherits(object, "threeSLS_fit"))
    stop("Object must be of class 'threeSLS_fit'")
  
  require(xtable)
  
  eq_names <- object$eq_names
  K <- length(eq_names)
  
  vcov_all <- if (robust && !is.null(object$structural$vcov_robust))
    object$structural$vcov_robust
  else
    object$structural$vcov_ml
  
  lens <- sapply(object$structural$coefficients, length)
  cum_lens <- cumsum(c(0, lens))
  
  out <- vector("list", K)
  names(out) <- eq_names
  
  for (i in seq_len(K)) {
    
    coef_i <- object$structural$coefficients[[i]]
    start <- cum_lens[i] + 1
    end   <- cum_lens[i + 1]
    
    se_i <- sqrt(diag(vcov_all)[start:end])
    t_i  <- coef_i / se_i
    p_i  <- 2 * pnorm(-abs(t_i))
    stars <- .star_fun(p_i)
    
    coef_txt <- paste0(
      formatC(coef_i, digits = digits, format = "f"),
      stars
    )
    
    se_txt <- paste0("(", formatC(se_i, digits = digits, format = "f"), ")")
    t_txt  <- formatC(t_i, digits = digits, format = "f")
    
    tab <- data.frame(
      Estimate = coef_txt,
      #`Std. Error` = se_txt,
      `t value` = t_txt,
      row.names = names(coef_i),
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
    
    # ---- Add R² as a separate row ----
    R2 <- .R2_structural(object, i)
    R2_row <- data.frame(
      Estimate = formatC(R2, digits = digits, format = "f"),
      #`Std. Error` = "",
      `t value` = "",
      row.names = "R-squared",
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
    
    tab <- rbind(tab, R2_row)
    
    out[[i]] <- xtable(
      tab,
      caption = paste("Structural equation:", eq_names[i]),
      align = c("l", "l", "l")
    )
  }
  
  return(out)
}

latex_reduced_3SLS <- function(fit, data, digits = 3) {
  
  if (!inherits(fit, "threeSLS_fit"))
    stop("fit must be of class 'threeSLS_fit'")
  
  require(xtable)
  
  # ------------------------------------------------------------
  # Compute restricted reduced form and its VCov
  # ------------------------------------------------------------
  
  B <- diag(K)
  rownames(B) <- colnames(B) <- eq_names
  
  coef_list <- fit$structural$coefficients
  for (j in seq_len(K)) {
    bj <- coef_list[[j]]
    for (nm in names(bj))
      if (nm %in% eq_names)
        B[nm, j] <- -bj[nm]
  }
  
  rf <- reduced_form_3SLS(fit, data = data, digits = digits)
  
  Pi      <- rf$Pi
  vcov_Pi <- rf$vcov
  
  inst_names <- rownames(Pi)
  eq_names   <- colnames(Pi)
  
  q <- length(inst_names)
  K <- length(eq_names)
  
  Pi_vec <- as.vector(Pi)
  se_vec <- sqrt(diag(vcov_Pi))
  
  t_vec <- Pi_vec / se_vec
  p_vec <- 2 * pnorm(-abs(t_vec))
  stars <- .star_fun(p_vec)
  
  DF <- as.data.frame(data)
  inst_no_int <- setdiff(inst_names, "(Intercept)")
  Zbar <- vapply(inst_no_int, function(z) {
    if (!z %in% names(DF)) stop(sprintf("Instrument '%s' not found in data", z))
    mean(DF[[z]], na.rm = TRUE)
  }, numeric(1))
  Ybar <- vapply(eq_names, function(y) {
    if (!y %in% names(DF)) stop(sprintf("Dependent variable '%s' not found in data", y))
    mean(DF[[y]], na.rm = TRUE)
  }, numeric(1))
  
  # ------------------------------------------------------------
  # Split equation by equation
  # ------------------------------------------------------------
  out <- vector("list", K+3)
  names(out) <- c(eq_names,"Means Z","Means Y","B-1")
  
  Tab = matrix(NA,q,K)
  colnames(Tab) = eq_names
  row.names(Tab) = inst_names
  for (j in seq_len(K)) {
    
    rows <- ((j - 1) * q + 1):(j * q)
    
    coef_j <- Pi_vec[rows]
    se_j   <- se_vec[rows]
    t_j    <- t_vec[rows]
    p_j    <- p_vec[rows]
    st_j   <- stars[rows]
    
    # Exclusion restrictions → exact zeros
    is_zero <- abs(coef_j) < .Machine$double.eps
    
    coef_txt <- ifelse(
      is_zero,
      "0",
      paste0(formatC(coef_j, digits = digits, format = "f"), st_j)
    )
    
    se_txt <- ifelse(
      is_zero,
      "",
      paste0("(", formatC(se_j, digits = digits, format = "f"), ")")
    )
    
    t_txt <- ifelse(
      is_zero,
      "",
      formatC(t_j, digits = digits, format = "f")
    )
    
    tab <- data.frame(
      Estimate     = coef_txt,
      #`Std. Error` = se_txt,
      #`t value`    = t_txt,
      row.names = inst_names,
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
    
    out[[j]] <- xtable(
      tab,
      caption = paste("Reduced-form equation:", eq_names[j]),
      align = c("l", "l")
    )
    Tab[,j] = tab[,1]
  }
  
  Tabm = cbind(Tab,c(1,round(Zbar,digits=3)))
  out[[K+1]] = xtable(Tabm,digits=3)
  out[[K+2]] = xtable(data.frame(Ybar),digits=3)
  out[[K+3]] = xtable(solve(B),digits=3)
  
  return(out)
}
