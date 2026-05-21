#' @title Bivariate Quantile-on-Quantile Granger Causality
#'
#' @description
#' Tests whether the \eqn{\tau}-quantile of \eqn{x_{t-1}} Granger-causes
#' the \eqn{\theta}-quantile of \eqn{y_t} by inspecting the slope
#' \eqn{\beta_1(\theta,\tau)} in
#' \deqn{y_t = \beta_0(\theta,\tau) + \beta_1(\theta,\tau)(x_{t-1} - x^\tau)
#'        + \alpha(\theta) y_{t-1} + v_t^\theta,}
#' fitted by weighted quantile regression with Gaussian kernel weights.
#' Standard errors are computed by paired bootstrap. The function returns
#' a 2-D (theta, tau) surface of bootstrap t-statistics and p-values that
#' is ideal for a heatmap with significance stars (the standard
#' presentation used in Sinha et al. articles).
#'
#' @param x Numeric vector. Cause variable.
#' @param y Numeric vector. Effect variable.
#' @param y_quantiles Numeric vector of \eqn{\theta} in (0, 1).
#' @param x_quantiles Numeric vector of \eqn{\tau} in (0, 1).
#' @param bandwidth Kernel bandwidth on the empirical-CDF scale.
#' @param n_boot Bootstrap replicates. Default 200.
#' @param cdf_based_kernel Use CDF-distance kernel.
#' @param cause_name,effect_name Variable names.
#' @param verbose Print progress.
#' @param seed RNG seed.
#'
#' @return Object of class \code{"qq_causality"}.
#' @references
#' Sim, N., Zhou, H. (2015). \emph{J. Banking & Finance}, 55, 1-12.
#'
#' Troster, V. (2018). Testing for Granger-causality in Quantiles.
#' \emph{Econometric Reviews}, 37(8), 850-866.
#'
#' @examples
#' set.seed(1); n <- 200
#' x <- rnorm(n); y <- 0.3 * c(0, x[-n]) + rnorm(n, sd = 0.5)
#' fit <- qq_causality(x, y,
#'                     y_quantiles = c(0.25, 0.5, 0.75),
#'                     x_quantiles = c(0.25, 0.5, 0.75),
#'                     n_boot = 30, verbose = FALSE)
#' print(fit)
#'
#' @export
#' @importFrom stats quantile pt
qq_causality <- function(x, y,
                         y_quantiles = seq(0.05, 0.95, by = 0.05),
                         x_quantiles = seq(0.05, 0.95, by = 0.05),
                         bandwidth = 0.05,
                         n_boot = 200,
                         cdf_based_kernel = TRUE,
                         cause_name = "X",
                         effect_name = "Y",
                         verbose = TRUE,
                         seed = 42) {
  x <- as.numeric(x); y <- as.numeric(y)
  if (length(x) != length(y)) stop("x and y must have equal length")
  ok <- is.finite(x) & is.finite(y)
  x <- x[ok]; y <- y[ok]; n <- length(y)
  if (n < 30) stop("need at least 30 observations after NA-removal")

  y_resp <- y[-1]; x_lag <- x[-n]; y_lag <- y[-n]
  n_eff <- length(y_resp)

  if (verbose) {
    message("QQ Granger Causality   ", cause_name, " ==> ", effect_name)
    message("  n = ", n_eff,
            ", Y q-grid = ", length(y_quantiles),
            ", X q-grid = ", length(x_quantiles),
            ", h = ", bandwidth)
  }

  records <- list()
  total <- length(y_quantiles) * length(x_quantiles)
  done <- 0; pct_marker <- max(1L, total %/% 10L)

  for (tau in x_quantiles) {
    x_tau <- as.numeric(stats::quantile(x_lag, tau, na.rm = TRUE))
    z_x <- x_lag - x_tau
    w <- qq_weights(x_lag, tau, h = bandwidth, cdf_based = cdf_based_kernel)
    X_mat <- cbind(1, z_x, y_lag)

    for (theta in y_quantiles) {
      done <- done + 1L
      rec <- list(y_quantile = round(theta, 4),
                  x_quantile = round(tau, 4),
                  beta1 = NA_real_, se = NA_real_,
                  t_value = NA_real_, p_value = NA_real_)
      fit <- weighted_qr(y_resp, X_mat, theta, w)
      if (fit$success) {
        rec$beta1 <- fit$coef[2]
        bs <- boot_wqr_se(y_resp, X_mat, theta, w, n_boot,
                          if (!is.null(seed)) seed + done else NULL)
        sb1 <- bs$se[2]
        if (is.finite(sb1) && sb1 > 0) {
          rec$se <- sb1
          rec$t_value <- rec$beta1 / sb1
          df_r <- max(1, n_eff - ncol(X_mat))
          rec$p_value <- 2 * stats::pt(-abs(rec$t_value), df = df_r)
        }
      }
      records[[length(records) + 1]] <- rec
      if (verbose && done %% pct_marker == 0)
        message("  Progress: ", round(100 * done / total), "%")
    }
  }
  if (verbose) message("  done.")
  df <- do.call(rbind, lapply(records, as.data.frame,
                              stringsAsFactors = FALSE))
  df <- df[order(df$y_quantile, df$x_quantile), ]
  rownames(df) <- NULL

  res <- list(results = df,
              y_quantiles = y_quantiles,
              x_quantiles = x_quantiles,
              n_obs = n_eff, bandwidth = bandwidth,
              cause_name = cause_name, effect_name = effect_name,
              direction = paste(cause_name, "->", effect_name),
              call = match.call(),
              method = "QQ Granger Causality")
  class(res) <- "qq_causality"
  res
}


#' @title Multivariate (Conditional) QQ Granger Causality
#'
#' @description
#' Conditional QQ Granger-causality test from \code{x} to \code{y}
#' controlling for a set of moderators / controls \code{Z}. Same null as
#' \code{\link{qq_causality}} but the regression also includes
#' \eqn{Z_{j,t-1}} (and optionally \eqn{x_{t-1} \cdot Z_{j,t-1}}
#' interactions).
#'
#' @inheritParams qq_causality
#' @param moderators Named list of numeric vectors (the conditioning set Z).
#' @param interactions Logical. Include x*Z cross-terms.
#'
#' @return Object of class \code{"mqq_causality"}.
#'
#' @examples
#' set.seed(1); n <- 200
#' x <- rnorm(n); z <- rnorm(n)
#' y <- 0.3 * c(0, x[-n]) + 0.2 * c(0, z[-n]) + rnorm(n, sd = 0.4)
#' fit <- mqq_causality(x, y, list(Z = z),
#'                      y_quantiles = c(0.25, 0.5, 0.75),
#'                      x_quantiles = c(0.25, 0.5, 0.75),
#'                      n_boot = 30, verbose = FALSE)
#' print(fit)
#'
#' @export
mqq_causality <- function(x, y,
                          moderators = list(),
                          y_quantiles = seq(0.05, 0.95, by = 0.05),
                          x_quantiles = seq(0.05, 0.95, by = 0.05),
                          bandwidth = 0.05,
                          n_boot = 200,
                          interactions = TRUE,
                          cdf_based_kernel = TRUE,
                          cause_name = "X",
                          effect_name = "Y",
                          verbose = TRUE,
                          seed = 42) {
  x <- as.numeric(x); y <- as.numeric(y)
  if (length(x) != length(y)) stop("x and y must have equal length")
  if (!is.list(moderators) || (length(moderators) > 0 && is.null(names(moderators))))
    stop("'moderators' must be a named list of numeric vectors")

  Z_names <- names(moderators)
  if (length(Z_names) > 0) {
    Z <- do.call(cbind, lapply(seq_along(moderators), function(j) {
      a <- as.numeric(moderators[[j]])
      if (length(a) != length(y))
        stop("moderator '", Z_names[j], "' length mismatch")
      a
    }))
  } else {
    Z <- matrix(numeric(0), length(y), 0)
  }

  ok <- is.finite(x) & is.finite(y)
  if (ncol(Z) > 0) ok <- ok & apply(Z, 1, function(r) all(is.finite(r)))
  x <- x[ok]; y <- y[ok]; Z <- Z[ok, , drop = FALSE]
  n <- length(y)
  if (n < 40) stop("need at least 40 observations after NA-removal")

  y_resp <- y[-1]; x_lag <- x[-n]; y_lag <- y[-n]
  Z_lag <- Z[-n, , drop = FALSE]
  n_eff <- length(y_resp); p <- ncol(Z_lag)

  if (verbose) {
    message("Multivariate QQ Granger Causality   ",
            cause_name, " ==> ", effect_name, "  |  ",
            if (length(Z_names)) paste(Z_names, collapse = ",") else "none")
    message("  n = ", n_eff,
            ", Y q-grid = ", length(y_quantiles),
            ", X q-grid = ", length(x_quantiles),
            ", h = ", bandwidth,
            ", interactions = ", interactions)
  }

  records <- list()
  total <- length(y_quantiles) * length(x_quantiles)
  done <- 0; pct_marker <- max(1L, total %/% 10L)

  for (tau in x_quantiles) {
    x_tau <- as.numeric(stats::quantile(x_lag, tau, na.rm = TRUE))
    z_x <- x_lag - x_tau
    w <- qq_weights(x_lag, tau, h = bandwidth, cdf_based = cdf_based_kernel)

    Z_tau <- if (p > 0)
      vapply(seq_len(p),
             function(j) as.numeric(stats::quantile(Z_lag[, j], tau, na.rm = TRUE)),
             numeric(1))
      else numeric(0)
    z_Z <- if (p > 0) sweep(Z_lag, 2, Z_tau, "-") else matrix(numeric(0), n_eff, 0)
    inter <- if (interactions && p > 0)
      x_lag * Z_lag - matrix(rep(x_tau * Z_tau, each = n_eff), nrow = n_eff)
      else matrix(numeric(0), n_eff, 0)

    blocks <- list(rep(1, n_eff), z_x, y_lag)
    if (p > 0)           blocks[[length(blocks) + 1]] <- z_Z
    if (ncol(inter) > 0) blocks[[length(blocks) + 1]] <- inter
    X_mat <- do.call(cbind, blocks)

    for (theta in y_quantiles) {
      done <- done + 1L
      rec <- list(y_quantile = round(theta, 4),
                  x_quantile = round(tau, 4),
                  beta1 = NA_real_, se = NA_real_,
                  t_value = NA_real_, p_value = NA_real_)
      fit <- weighted_qr(y_resp, X_mat, theta, w)
      if (fit$success) {
        rec$beta1 <- fit$coef[2]
        bs <- boot_wqr_se(y_resp, X_mat, theta, w, n_boot,
                          if (!is.null(seed)) seed + done else NULL)
        sb1 <- bs$se[2]
        if (is.finite(sb1) && sb1 > 0) {
          rec$se <- sb1
          rec$t_value <- rec$beta1 / sb1
          df_r <- max(1, n_eff - ncol(X_mat))
          rec$p_value <- 2 * stats::pt(-abs(rec$t_value), df = df_r)
        }
      }
      records[[length(records) + 1]] <- rec
      if (verbose && done %% pct_marker == 0)
        message("  Progress: ", round(100 * done / total), "%")
    }
  }
  if (verbose) message("  done.")
  df <- do.call(rbind, lapply(records, as.data.frame,
                              stringsAsFactors = FALSE))
  df <- df[order(df$y_quantile, df$x_quantile), ]
  rownames(df) <- NULL

  res <- list(results = df,
              y_quantiles = y_quantiles,
              x_quantiles = x_quantiles,
              n_obs = n_eff, bandwidth = bandwidth,
              cause_name = cause_name, effect_name = effect_name,
              direction = paste(cause_name, "->", effect_name),
              moderator_names = Z_names,
              interactions = interactions,
              call = match.call(),
              method = "Multivariate QQ Granger Causality (conditional)")
  class(res) <- c("mqq_causality", "qq_causality")
  res
}


#' @title Sup-Wald Summary (Troster 2018)
#'
#' @description Reports \eqn{S = \sup_{(\theta,\tau)} |t(\theta,\tau)|}
#'   from a QQ causality result with a Bonferroni-adjusted p-value over
#'   the (theta, tau) grid.
#' @param qq_result A \code{qq_causality} or \code{mqq_causality} object.
#' @param alpha Significance level. Default 0.05.
#' @return A list with sup statistic, argmax and Bonferroni p-value.
#' @export
#' @importFrom stats pnorm
sup_wald <- function(qq_result, alpha = 0.05) {
  if (!inherits(qq_result, "qq_causality"))
    stop("'qq_result' must be a qq_causality / mqq_causality object")
  r <- qq_result$results
  r <- r[is.finite(r$t_value), ]
  if (!nrow(r))
    return(list(sup_statistic = NA, argmax_y_quantile = NA,
                argmax_x_quantile = NA, bonferroni_p_value = NA,
                reject_H0_at_alpha = NA))
  i_max <- which.max(abs(r$t_value))
  sup <- abs(r$t_value[i_max])
  pg <- 2 * stats::pnorm(-sup)
  adj <- min(1, pg * nrow(r))
  list(sup_statistic = sup,
       argmax_y_quantile = r$y_quantile[i_max],
       argmax_x_quantile = r$x_quantile[i_max],
       bonferroni_p_value = adj,
       reject_H0_at_alpha = adj < alpha)
}


#' @title Print method for qq_causality
#' @param x A qq_causality object.
#' @param ... Ignored.
#' @return Invisibly returns \code{x}.
#' @export
print.qq_causality <- function(x, ...) {
  cat("\n", x$method, "\n", sep = "")
  cat(strrep("=", 60), "\n", sep = "")
  cat("  Direction : ", x$direction, "\n", sep = "")
  cat("  N         : ", x$n_obs, "  h = ", x$bandwidth, "\n", sep = "")
  cat("  Q-grids   : Y = ", length(x$y_quantiles),
      "   X = ", length(x$x_quantiles), "\n", sep = "")
  r <- x$results
  rok <- r[is.finite(r$t_value), ]
  if (nrow(rok) > 0) {
    p <- rok$p_value
    cat(sprintf("\n  Cells tested : %d\n", nrow(rok)))
    cat(sprintf("    p<0.10 : %d (%0.1f%%)\n",
                sum(p < 0.10, na.rm = TRUE),
                100 * sum(p < 0.10, na.rm = TRUE) / nrow(rok)))
    cat(sprintf("    p<0.05 : %d (%0.1f%%)\n",
                sum(p < 0.05, na.rm = TRUE),
                100 * sum(p < 0.05, na.rm = TRUE) / nrow(rok)))
    cat(sprintf("    p<0.01 : %d (%0.1f%%)\n",
                sum(p < 0.01, na.rm = TRUE),
                100 * sum(p < 0.01, na.rm = TRUE) / nrow(rok)))
    sw <- sup_wald(x)
    cat(sprintf("\n  Sup-Wald (Troster 2018)\n"))
    cat(sprintf("    sup|t| = %0.4f  at (theta=%0.2f, tau=%0.2f)\n",
                sw$sup_statistic, sw$argmax_y_quantile,
                sw$argmax_x_quantile))
    cat(sprintf("    Bonferroni p = %0.4g    reject H0 at 5%% : %s\n",
                sw$bonferroni_p_value, sw$reject_H0_at_alpha))
  }
  invisible(x)
}


#' @title Print method for mqq_causality
#' @param x An mqq_causality object.
#' @param ... Ignored.
#' @return Invisibly returns \code{x}.
#' @export
print.mqq_causality <- function(x, ...) {
  NextMethod()
  if (length(x$moderator_names))
    cat("  Conditioning set : ",
        paste(x$moderator_names, collapse = ", "),
        " (interactions = ", x$interactions, ")\n", sep = "")
  invisible(x)
}


#' @title Summary methods
#' @param object A qq_causality / mqq_causality object.
#' @param ... Ignored.
#' @return Invisibly returns \code{object}.
#' @export
summary.qq_causality <- function(object, ...) { print(object); invisible(object) }

#' @rdname summary.qq_causality
#' @export
summary.mqq_causality <- function(object, ...) { print(object); invisible(object) }


#' @title Convert QQ-causality result to matrix
#' @param qq_result A qq_causality / mqq_causality object.
#' @param value Column to pivot: \code{"t_value"} (default),
#'   \code{"p_value"}, \code{"beta1"}, \code{"se"}.
#' @return Numeric matrix.
#' @export
qq_causality_to_matrix <- function(qq_result, value = "t_value") {
  if (!inherits(qq_result, "qq_causality"))
    stop("'qq_result' must be a qq_causality / mqq_causality object")
  df <- qq_result$results
  if (!value %in% names(df)) stop("value '", value, "' not in results")
  ys <- sort(unique(df$y_quantile))
  xs <- sort(unique(df$x_quantile))
  M <- matrix(NA_real_, length(ys), length(xs),
              dimnames = list(as.character(ys), as.character(xs)))
  for (i in seq_along(ys)) for (j in seq_along(xs)) {
    k <- which(df$y_quantile == ys[i] & df$x_quantile == xs[j])
    if (length(k)) M[i, j] <- df[[value]][k[1]]
  }
  M
}
