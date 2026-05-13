# -------------------------
# Example usage (uncomment to run)
# -------------------------
# # Build toy data & system (ensure no NA in variables used)
# # df <- your data.frame
# # equations <- list( y1 = y1 ~ x1 + x2 | subset(z==1), y2 = y2 ~ x3 + y1 )  # example
# # inst <- ~ x1 + x2 + x3 + z
# # fit <- threeSLS_system(equations, inst, data = df, weights = "wt")
# # summary.threeSLS_fit(fit)

# summary(fit, plot_residuals = TRUE)
# summary(fit, plot_residuals = TRUE, residual_type = "hist")
# summary(fit, plot_residuals = TRUE, residual_type = "fitted") 


library(Matrix)
library(MASS)



threeSLS_system <- function(equations, inst, data, weights = NULL,
                            ridge_ZZ = 1e-8, ridge_Omega = 1e-12,
                            auto_drop_instruments = TRUE, verbose = FALSE) {
  # parse helpers
  split_formula_at_pipe <- function(f) {
    txt <- paste(deparse(f), collapse = "\n")
    n <- nchar(txt); paren <- 0; in_single <- FALSE; in_double <- FALSE; pos <- NA
    for (i in seq_len(n)) {
      ch <- substr(txt, i, i)
      if (ch == "'" && !in_double) { in_single <- !in_single; next }
      if (ch == '"' && !in_single) { in_double <- !in_double; next }
      if (in_single || in_double) next
      if (ch == "(") paren <- paren + 1
      if (ch == ")") paren <- paren - 1
      if (ch == "|" && paren == 0) { pos <- i; break }
    }
    if (is.na(pos)) list(lhs = txt, rhs = NULL) else list(lhs = trimws(substr(txt,1,pos-1)), rhs = trimws(substr(txt,pos+1,n)))
  }
  eval_subset_expr <- function(rhs_txt, data_env) {
    if (is.null(rhs_txt) || nchar(trimws(rhs_txt))==0) return(rep(TRUE, nrow(data_env)))
    rhs_trim <- trimws(rhs_txt); m <- regexpr("^subset\\s*\\(", rhs_trim, perl = TRUE)
    expr <- if (m==1) {
      s <- rhs_trim; L <- nchar(s); lvl <- 0; st <- NA; en <- NA
      for (i in seq_len(L)) {
        ch <- substr(s,i,i)
        if (ch=="("){ if (is.na(st)) st<-i; lvl<-lvl+1 }
        else if (ch==")"){ lvl<-lvl-1; if (lvl==0){ en<-i; break } }
      }
      if (is.na(st) || is.na(en)) stop("Bad subset(...) syntax")
      substr(s, st+1, en-1)
    } else rhs_trim
    res <- eval(parse(text=expr), envir = data_env)
    if (!is.logical(res)) stop("subset(...) must evaluate to logical")
    if (length(res) == 1) res <- rep(as.logical(res), nrow(data_env))
    if (length(res) != nrow(data_env)) stop("subset(...) length mismatch")
    res
  }
  
  # checks & setup
  if (is.null(names(equations)) || any(names(equations)=="")) stop("equations must be a named list")
  eq_names <- names(equations); K <- length(eq_names); n <- nrow(data)
  
  if (is.null(weights)) weights_vec <- rep(1, n)
  else if (is.character(weights) && length(weights)==1 && weights %in% names(data)) weights_vec <- as.numeric(data[[weights]])
  else { weights_vec <- as.numeric(weights); if (length(weights_vec) != n) stop("weights length must equal nrow(data)") }
  weights_vec[is.na(weights_vec)] <- 0
  if (any(weights_vec < 0)) stop("weights must be non-negative")
  
  rownames(data) <- seq_len(n)
  
  # containers
  y_list <- X_list <- Z_list <- idx_list <- w_list <- sqrtw_list <- vector("list", K)
  p_vec <- integer(K); q_vec <- integer(K); dropped_instruments <- vector("list", K)
  
  # build per-equation data
  for (i in seq_len(K)) {
    spec <- split_formula_at_pipe(equations[[i]])
    main_f <- as.formula(spec$lhs)
    subset_vec <- eval_subset_expr(spec$rhs, data)
    idx_sub <- which(subset_vec)
    if (length(idx_sub) == 0) stop(sprintf("Equation %s: subset selects zero rows", eq_names[i]))
    data_sub <- data[idx_sub, , drop = FALSE]
    
    mf <- model.frame(main_f, data = data_sub, na.action = na.pass)
    y_i <- model.response(mf)
    X_i <- model.matrix(main_f, mf)
    
    Z_full_i <- model.matrix(inst, data = data_sub)
    
    ok <- complete.cases(y_i, X_i, Z_full_i)
    if (!any(ok)) stop(sprintf("Equation %s: no complete rows after removing NAs in y, X, Z", eq_names[i]))
    
    y_i <- as.numeric(y_i[ok]); X_i <- X_i[ok, , drop = FALSE]; Z_i <- Z_full_i[ok, , drop = FALSE]
    idx_good <- idx_sub[ok]; w_i <- weights_vec[idx_good]; sqrtw_i <- sqrt(w_i)
    
    y_list[[i]] <- y_i; X_list[[i]] <- X_i; Z_list[[i]] <- Z_i
    idx_list[[i]] <- idx_good; w_list[[i]] <- w_i; sqrtw_list[[i]] <- sqrtw_i
    p_vec[i] <- ncol(X_i); q_vec[i] <- ncol(Z_i)
  }
  
  # 2SLS per equation
  beta_2sls <- vector("list", K); resid_unw <- vector("list", K)
  for (i in seq_len(K)) {
    Xi <- X_list[[i]]; yi <- y_list[[i]]; Zi <- Z_list[[i]]; sw <- sqrtw_list[[i]]
    Zi_w <- Zi * sw; Xi_w <- Xi * sw; yi_w <- yi * sw
    
    ZZ <- crossprod(Zi_w)
    if (qr(ZZ)$rank < ncol(ZZ)) {
      if (auto_drop_instruments) {
        qrZ <- qr(Zi_w, tol = 1e-7); rk <- qrZ$rank
        if (rk == 0) stop(sprintf("Equation %s: all instruments collinear or zero", eq_names[i]))
        keep <- qrZ$pivot[seq_len(rk)]; drop_cols <- setdiff(seq_len(ncol(Zi)), keep)
        dropped_instruments[[i]] <- colnames(Zi)[drop_cols]
        Zi <- Zi[, keep, drop = FALSE]; Zi_w <- Zi * sw; ZZ <- crossprod(Zi_w)
      } else {
        ZZ <- ZZ + ridge_ZZ * diag(ncol(ZZ)); dropped_instruments[[i]] <- character(0)
      }
    } else dropped_instruments[[i]] <- character(0)
    
    ZZ_inv <- tryCatch(solve(ZZ), error = function(e) ginv(ZZ))
    ZtW_X <- crossprod(Zi_w, Xi_w)
    X_hat <- Zi %*% (ZZ_inv %*% ZtW_X)
    XtX_w <- crossprod(X_hat * sw, Xi * sw)
    if (qr(XtX_w)$rank < ncol(XtX_w)) stop(sprintf("2SLS normal matrix singular for equation %s", eq_names[i]))
    bi <- solve(XtX_w, crossprod(X_hat * sw, yi * sw))
    beta_2sls[[i]] <- as.numeric(bi)
    resid_unw[[i]] <- as.numeric(yi - Xi %*% bi)
  }
  
  # Omega (weighted pairwise)
  Omega <- matrix(0, nrow = K, ncol = K, dimnames = list(eq_names, eq_names))
  for (i in seq_len(K)) for (j in seq_len(K)) {
    common <- intersect(idx_list[[i]], idx_list[[j]])
    if (length(common) == 0) Omega[i,j] <- 0
    else {
      ri_all <- resid_unw[[i]]; names(ri_all) <- idx_list[[i]]
      rj_all <- resid_unw[[j]]; names(rj_all) <- idx_list[[j]]
      ri <- ri_all[as.character(common)]; rj <- rj_all[as.character(common)]
      w_common <- weights_vec[common]
      if (sum(w_common) == 0) Omega[i,j] <- 0 else Omega[i,j] <- sum(w_common * ri * rj) / sum(w_common)
    }
  }
  if (qr(Omega)$rank < ncol(Omega)) {
    if (verbose) message("Regularizing Omega with ridge_Omega = ", ridge_Omega)
    Omega <- Omega + ridge_Omega * diag(ncol(Omega))
  }
  Omega_inv <- solve(Omega)
  
  # Prepare parameter indexing
  lens <- p_vec; total_p <- sum(lens)
  param_pos <- matrix(NA, nrow = K, ncol = 2)
  start <- 1
  for (i in seq_len(K)) { param_pos[i, ] <- c(start, start + lens[i] - 1); start <- start + lens[i] }
  
  # Build GLS normal matrix M and RHS by looping over observations (memory-efficient)
  M <- matrix(0, nrow = total_p, ncol = total_p)
  rhs <- numeric(total_p)
  
  for (j in seq_len(n)) {
    present_eq <- which(sapply(idx_list, function(v) j %in% v))
    m_j <- length(present_eq)
    if (m_j == 0) next
    # indices and local residuals/y/x
    x_list_j <- vector("list", m_j)
    y_vec_j <- numeric(m_j)
    for (t in seq_len(m_j)) {
      ei <- present_eq[t]
      pos_in_eq <- match(j, idx_list[[ei]])
      x_list_j[[t]] <- as.numeric(X_list[[ei]][pos_in_eq, , drop = TRUE]) # 1 x p_ei
      y_vec_j[t] <- y_list[[ei]][pos_in_eq]
    }
    # sub Omega_inv
    Om_inv_sub <- Omega_inv[present_eq, present_eq, drop = FALSE]
    # Accumulate M and rhs: for a,b in present_eq add t(x_a) * Om_inv[a,b] * x_b
    for (a_idx in seq_len(m_j)) {
      ei <- present_eq[a_idx]; range_a <- param_pos[ei, 1]:param_pos[ei, 2]
      xa <- x_list_j[[a_idx]]
      # compute rhs contribution scalar s_a = sum_b Om_inv[a,b] * y_bj
      s_a <- 0
      for (b_idx in seq_len(m_j)) {
        ej <- present_eq[b_idx]
        ybj <- y_vec_j[b_idx]
        coeff_ab <- Om_inv_sub[a_idx, b_idx]
        s_a <- s_a + coeff_ab * ybj
        # M block
        xb <- x_list_j[[b_idx]]
        range_b <- param_pos[ej, 1]:param_pos[ej, 2]
        M[range_a, range_b] <- M[range_a, range_b] + (xa %*% t(xb)) * coeff_ab
      }
      rhs[range_a] <- rhs[range_a] + xa * s_a
    }
  }
  
  # Solve GLS normal eqns
  if (qr(M)$rank < ncol(M)) stop("GLS normal matrix singular: check identification & overlap")
  beta_gls <- as.numeric(solve(M, rhs))
  vcov_beta_ml <- tryCatch(solve(M), error = function(e) NULL)
  
  # Split structural beta
  coefs_struct <- vector("list", K)
  for (i in seq_len(K)) {
    rng <- param_pos[i, 1]:param_pos[i, 2]
    coefs_struct[[i]] <- beta_gls[rng]
    names(coefs_struct[[i]]) <- colnames(X_list[[i]])
  }
  names(coefs_struct) <- eq_names
  
  # Recompute structural residuals (unweighted) from solved beta_gls (per equation)
  resid_struct_list <- vector("list", K)
  for (i in seq_len(K)) {
    rng <- param_pos[i, 1]:param_pos[i, 2]
    bi <- beta_gls[rng]
    resid_struct_list[[i]] <- as.numeric(y_list[[i]] - X_list[[i]] %*% bi)
  }
  
  # Robust sandwich meat via observation-by-observation accumulation:
  meat <- matrix(0, nrow = total_p, ncol = total_p)
  for (j in seq_len(n)) {
    present_eq <- which(sapply(idx_list, function(v) j %in% v))
    m_j <- length(present_eq)
    if (m_j == 0) next
    # gather x and u per present equation
    x_list_j <- vector("list", m_j); u_vec_j <- numeric(m_j)
    for (t in seq_len(m_j)) {
      ei <- present_eq[t]
      pos_in_eq <- match(j, idx_list[[ei]])
      x_list_j[[t]] <- as.numeric(X_list[[ei]][pos_in_eq, , drop = TRUE])
      u_vec_j[t] <- resid_struct_list[[ei]][pos_in_eq]
    }
    Om_inv_sub <- Omega_inv[present_eq, present_eq, drop = FALSE]
    # B_j = Om_inv_sub %*% diag(u_vec_j^2) %*% Om_inv_sub
    B_j <- Om_inv_sub %*% (diag(u_vec_j^2, nrow = m_j)) %*% Om_inv_sub
    # accumulate meat by blocks
    for (a_idx in seq_len(m_j)) {
      ei <- present_eq[a_idx]; range_a <- param_pos[ei, 1]:param_pos[ei, 2]; xa <- x_list_j[[a_idx]]
      for (b_idx in seq_len(m_j)) {
        ej <- present_eq[b_idx]; range_b <- param_pos[ej, 1]:param_pos[ej, 2]; xb <- x_list_j[[b_idx]]
        meat[range_a, range_b] <- meat[range_a, range_b] + (xa %*% t(xb)) * B_j[a_idx, b_idx]
      }
    }
  }
  vcov_beta_robust <- tryCatch(solve(M) %*% meat %*% solve(M), error = function(e) NULL)
  
  # PSEUDO log-likelihood Option A (observation-by-observation)
  loglik_sum <- 0
  for (j in seq_len(n)) {
    present_eq <- which(sapply(idx_list, function(v) j %in% v))
    m_j <- length(present_eq)
    if (m_j == 0) next
    rj <- numeric(m_j)
    for (t in seq_len(m_j)) {
      ei <- present_eq[t]; pos_in_eq <- match(j, idx_list[[ei]])
      rj[t] <- resid_struct_list[[ei]][pos_in_eq]
    }
    Omega_sub <- Omega[present_eq, present_eq, drop = FALSE]
    if (qr(Omega_sub)$rank < ncol(Omega_sub)) Omega_sub <- Omega_sub + 1e-12 * diag(ncol(Omega_sub))
    Omega_sub_inv <- solve(Omega_sub)
    term <- as.numeric(determinant(Omega_sub, logarithm = TRUE)$modulus) + as.numeric(t(rj) %*% Omega_sub_inv %*% rj) + m_j * log(2*pi)
    loglik_sum <- loglik_sum + weights_vec[j] * term
  }
  loglik <- -0.5 * loglik_sum
  
  out <- list(
    structural = list(coefficients = coefs_struct, beta = beta_gls, vcov_ml = vcov_beta_ml, vcov_robust = vcov_beta_robust),
    Omega = Omega, Omega_inv = Omega_inv,
    residuals = resid_struct_list,
    reduced_form = NULL, # we'll build as before
    dropped_instruments = setNames(dropped_instruments, eq_names),
    eq_names = eq_names, idx_list = setNames(idx_list, eq_names),
    call = match.call(), logLik = loglik, total_params = total_p
  )
  
  # Reduced-form per equation (same as before)
  reduced_form <- vector("list", K)
  for (i in seq_len(K)) {
    idx_i <- idx_list[[i]]
    data_sub <- data[idx_i, , drop = FALSE]
    Zi_all <- model.matrix(inst, data = data_sub)
    yi <- y_list[[i]]
    ok <- complete.cases(yi, Zi_all)
    if (!all(ok)) { yi2 <- yi[ok]; Zi2 <- Zi_all[ok,, drop = FALSE]; wi2 <- weights_vec[idx_i[ok]] }
    else { yi2 <- yi; Zi2 <- Zi_all; wi2 <- weights_vec[idx_i] }
    sw <- sqrt(wi2); Zi_w <- Zi2 * sw; yi_w <- yi2 * sw
    ZZ <- crossprod(Zi_w)
    if (qr(ZZ)$rank < ncol(ZZ)) ZZ <- ZZ + ridge_ZZ * diag(ncol(ZZ))
    b_rf <- tryCatch(solve(ZZ, crossprod(Zi_w, yi_w)), error = function(e) ginv(ZZ) %*% crossprod(Zi_w, yi_w))
    res_rf <- yi2 - Zi2 %*% b_rf
    sigma2_rf <- if (sum(wi2)>0) sum(wi2 * (res_rf^2)) / sum(wi2) else NA_real_
    vcov_rf <- tryCatch(solve(ZZ) * sigma2_rf, error = function(e) ginv(ZZ) * sigma2_rf)
    reduced_form[[i]] <- list(coefficients = as.numeric(b_rf), names = colnames(Zi2), vcov = vcov_rf, resid = res_rf, sigma2 = sigma2_rf)
  }
  names(reduced_form) <- eq_names
  out$reduced_form <- reduced_form
  
  class(out) <- "threeSLS_fit"
  out
}

#####

# Enhanced summary: stars in separate column, robust option
summary.threeSLS_fit <- function(object, digits = 4, robust = TRUE) {
  if (!inherits(object, "threeSLS_fit")) stop("Pass an object returned by threeSLS_system()")
  cat("\nThree-stage least squares (unbalanced, weighted)\n")
  cat("Call:\n"); print(object$call); cat("\n")
  
  eq_names <- object$eq_names; K <- length(eq_names)
  
  stars_fun <- function(p) {
    ifelse(p < 0.001, "***",
           ifelse(p < 0.01,  "**",
                  ifelse(p < 0.05,  "*",
                         ifelse(p < 0.1,   ".", " "))))
  }
  
  vcov_all <- if (robust && !is.null(object$structural$vcov_robust)) object$structural$vcov_robust else object$structural$vcov_ml
  lens <- sapply(object$structural$coefficients, length); cum_lens <- cumsum(c(0, lens))
  
  cat("\nSTRUCTURAL (3SLS) ESTIMATES\n")
  for (i in seq_len(K)) {
    nm <- eq_names[i]; coefs <- object$structural$coefficients[[i]]
    start <- cum_lens[i] + 1; end <- cum_lens[i+1]
    if (!is.null(vcov_all)) se <- sqrt(diag(vcov_all)[start:end]) else se <- rep(NA, length(coefs))
    tval <- coefs / se; pval <- 2 * pnorm(-abs(tval)); stars <- stars_fun(pval)
    tab <- data.frame(Estimate = round(coefs, digits), Std.Error = round(se, digits),
                      "t value" = round(tval, digits+1), "Pr(>|t|)" = signif(pval, 3),
                      Signif = stars, row.names = names(coefs), check.names = FALSE, stringsAsFactors = FALSE)
    cat("\nEquation:", nm, "\n"); print(tab, digits = digits)
    resid_struct <- object$residuals[[i]]
    cat("Residuals (structural): mean =", round(mean(resid_struct), digits), " SD =", round(sd(resid_struct), digits), "\n")
    # R2 calculation removed (undefined function .R2_structural)
    dropped <- object$dropped_instruments[[nm]]
    if (length(dropped) > 0) cat("Dropped instruments:", paste(dropped, collapse = ", "), "\n") else cat("Dropped instruments: none\n")
    cat("-------------------------------\n")
  }
  
  cat("\nEstimated contemporaneous residual covariance matrix (Omega):\n"); print(round(object$Omega, digits))
  sds <- sqrt(diag(object$Omega)); Corr <- object$Omega / (sds %*% t(sds)); diag(Corr) <- 1
  cat("\nCorrelation matrix of structural residuals:\n"); print(round(Corr, digits))
  
  cat("\nPseudo log-likelihood (Option A, Gaussian SUR):", format(object$logLik, digits = digits), "\n")
  cat("Total number of structural parameters:", object$total_params, "\n")
  
  #cat("\nREDUCED-FORM ESTIMATES (per equation)\n")
  #for (i in seq_len(K)) {
  #  nm <- eq_names[i]; rf <- object$reduced_form[[i]]
  #  coef_rf <- rf$coefficients; se_rf <- sqrt(diag(rf$vcov)); t_rf <- coef_rf / se_rf; p_rf <- 2 * pnorm(-abs(t_rf)); stars_rf <- stars_fun(p_rf)
  #  tab_rf <- data.frame(Estimate = round(coef_rf, digits), Std.Error = round(se_rf, digits),
  #                       "t value" = round(t_rf, digits+1), "Pr(>|t|)" = signif(p_rf, 3),
  #                       Signif = stars_rf, row.names = rf$names, check.names = FALSE, stringsAsFactors = FALSE)
  #  cat("\nReduced form for", nm, "\n"); print(tab_rf, digits = digits)
  #}
  
  if (robust && !is.null(object$structural$vcov_robust)) cat("\nRobust sandwich standard errors (HC0-style) used for structural coefficients.\n") else cat("\nModel-based standard errors used for structural coefficients.\n")
  invisible(object)
}

########### Reduced form ##################

reduced_form_3SLS <- function(fit, data, digits = 4) {
  
  if (!inherits(fit, "threeSLS_fit"))
    stop("fit must be an object returned by threeSLS_system()")
  
  DF <- as.data.frame(data)
  eq_names <- fit$eq_names
  K <- length(eq_names)
  
  stars <- function(p)
    ifelse(p < 0.001, "***",
           ifelse(p < 0.01, "**",
                  ifelse(p < 0.05, "*",
                         ifelse(p < 0.1, ".", ""))))
  
  # ---------------------------------------------------------------
  # 1. Structural B matrix
  # ---------------------------------------------------------------
  B <- diag(K)
  rownames(B) <- colnames(B) <- eq_names
  
  coef_list <- fit$structural$coefficients
  for (j in seq_len(K)) {
    bj <- coef_list[[j]]
    for (nm in names(bj))
      if (nm %in% eq_names)
        B[nm, j] <- -bj[nm]
  }
  
  # ---------------------------------------------------------------
  # 2. C matrix from STRUCTURAL coefficients on instruments only
  # ---------------------------------------------------------------
  inst_names <- fit$reduced_form[[1]]$names
  q <- length(inst_names)
  
  C <- matrix(0, q, K, dimnames = list(inst_names, eq_names))
  
  for (j in seq_len(K)) {
    bj <- coef_list[[j]]
    keep <- intersect(names(bj), inst_names)
    if (length(keep) > 0)
      C[keep, j] <- bj[keep]
  }
  
  # ---------------------------------------------------------------
  # 3. Reduced form Π = C B^{-1}
  # ---------------------------------------------------------------
  B_inv <- solve(B)
  Pi <- C %*% B_inv
  
  # ---------------------------------------------------------------
  # 4. Delta-method SEs (B and C stochastic)
  # ---------------------------------------------------------------
  theta_names <- unlist(lapply(coef_list, names))
  theta_len <- length(theta_names)
  
  # Selection for vec(C)
  SC <- matrix(0, q * K, theta_len)
  row <- 1
  for (j in seq_len(K)) {
    for (i in seq_len(q)) {
      nm <- inst_names[i]
      idx <- which(theta_names == nm)
      if (length(idx) == 1) SC[row, idx] <- 1
      row <- row + 1
    }
  }
  
  # Selection for vec(B)
  SB <- matrix(0, K * K, theta_len)
  row <- 1
  for (j in seq_len(K)) {
    for (i in seq_len(K)) {
      if (i != j) {
        nm <- eq_names[i]
        idx <- which(theta_names == nm)
        if (length(idx) == 1) SB[row, idx] <- -1
      }
      row <- row + 1
    }
  }
  
  vcov_theta <- fit$structural$vcov_ml
  
  J_C <- kronecker(t(B_inv), diag(q))
  J_B <- -kronecker(t(B_inv), Pi)
  
  vcov_Pi <- J_C %*% (SC %*% vcov_theta %*% t(SC)) %*% t(J_C) +
    J_B %*% (SB %*% vcov_theta %*% t(SB)) %*% t(J_B)
  
  se_Pi <- sqrt(diag(vcov_Pi))
  
  # ---------------------------------------------------------------
  # 5. Output table
  # ---------------------------------------------------------------
  Pi_vec <- as.vector(Pi)
  t_Pi <- Pi_vec / se_Pi
  p_Pi <- 2 * pnorm(-abs(t_Pi))
  
  rf_tab <- data.frame(
    Estimate  = round(Pi_vec, digits),
    Std.Error = round(se_Pi, digits),
    t.value   = round(t_Pi, digits + 1),
    p.value   = signif(p_Pi, 3),
    Signif    = stars(p_Pi)
  )
  
  rownames(rf_tab) <- paste(rep(inst_names, K),
                            rep(eq_names, each = q), sep = " → ")
  
  #cat("\nTRUE REDUCED FORM  Π = C B^{-1}\n")
  #print(rf_tab)
  
  # ---------------------------------------------------------------
  # 6. Elasticities at sample means (intercept excluded)
  # ---------------------------------------------------------------
  inst_no_int <- setdiff(inst_names, "(Intercept)")
  
  Zbar <- vapply(inst_no_int, function(z) {
    if (!z %in% names(DF)) stop(sprintf("Instrument '%s' not found in data", z))
    mean(DF[[z]], na.rm = TRUE)
  }, numeric(1))
  
  Ybar <- vapply(eq_names, function(y) {
    if (!y %in% names(DF)) stop(sprintf("Dependent variable '%s' not found in data", y))
    mean(DF[[y]], na.rm = TRUE)
  }, numeric(1))
  
  Elas <- matrix(NA_real_, length(inst_no_int), K,
                 dimnames = list(inst_no_int, eq_names))
  
  for (i in seq_along(inst_no_int)) {
    zi <- inst_no_int[i]
    row_pi <- which(inst_names == zi)
    for (j in seq_len(K))
      Elas[i, j] <- Pi[row_pi, j] * Zbar[i] / Ybar[j]
  }
  
  # Elasticity t-stats are identical to reduced-form t-stats
  t_Elas <- matrix(t_Pi[rep(which(inst_names %in% inst_no_int), K)],
                   nrow = length(inst_no_int), ncol = K)
  
  # ---------------------------------------------------------------
  # Elasticity table with t-stats and stars
  # ---------------------------------------------------------------
  elas_vec <- as.vector(Elas)
  t_elas_vec <- as.vector(t_Elas)
  p_elas_vec <- 2 * pnorm(-abs(t_elas_vec))
  
  elas_tab <- data.frame(
    Elasticity = round(elas_vec, digits),
    t.value    = round(t_elas_vec, digits + 1),
    p.value    = signif(p_elas_vec, 3),
    Signif     = stars(p_elas_vec)
  )
  
  rownames(elas_tab) <- paste(rep(inst_no_int, K),
                              rep(eq_names, each = length(inst_no_int)), sep = " → ")
  
  #cat("Elasticities at sample means (intercept excluded)")
  #print(elas_tab)
  
  invisible(list(B_inv=B_inv,Pi = Pi, vcov = vcov_Pi, table = rf_tab,
                 elasticities = Elas, t_elasticities = t_Elas))
}

