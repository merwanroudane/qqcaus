#' @title Empirical CDF (mid-rank)
#' @keywords internal
empirical_cdf <- function(x) {
  ranks <- rank(as.numeric(x), ties.method = "average")
  ranks / (length(x) + 1)
}


#' @title Standard Gaussian Kernel
#' @param u Numeric vector.
#' @return Numeric vector of kernel weights.
#' @export
#' @importFrom stats dnorm
gaussian_kernel <- function(u) stats::dnorm(u)


#' @title QQ Kernel Weights on the Empirical-CDF Scale
#' @param x Numeric vector.
#' @param tau Numeric quantile in (0, 1).
#' @param h Numeric bandwidth.
#' @param cdf_based Logical. Use CDF-distance kernel.
#' @return Numeric vector of weights summing to \code{length(x)}.
#' @export
#' @importFrom stats sd
qq_weights <- function(x, tau, h = 0.05, cdf_based = TRUE) {
  x <- as.numeric(x)
  if (cdf_based) {
    Fn <- empirical_cdf(x); u <- (Fn - tau) / h
  } else {
    x_tau <- stats::quantile(x, tau, names = FALSE, na.rm = TRUE)
    s <- stats::sd(x, na.rm = TRUE)
    u <- (x - x_tau) / (if (s > 0) h * s else h)
  }
  w <- gaussian_kernel(u)
  if (sum(w) > 0) w <- w * (length(x) / sum(w))
  w
}


#' @title Weighted Quantile Regression
#' @param y Numeric vector.
#' @param X Numeric design matrix (intercept included).
#' @param tau Numeric quantile in (0, 1).
#' @param weights Numeric weights or NULL.
#' @return A list with \code{coef}, \code{residuals}, \code{fitted},
#'   \code{success}.
#' @export
#' @importFrom quantreg rq.wfit
weighted_qr <- function(y, X, tau, weights = NULL) {
  y <- as.numeric(y); X <- as.matrix(X); n <- nrow(X)
  if (is.null(weights)) weights <- rep(1, n)
  weights <- pmax(as.numeric(weights), 0)
  out <- tryCatch(
    quantreg::rq.wfit(X, y, tau = tau, weights = weights, method = "br"),
    error = function(e) NULL)
  if (is.null(out) || any(!is.finite(out$coefficients))) {
    return(list(coef = rep(NA_real_, ncol(X)),
                residuals = rep(NA_real_, n),
                fitted = rep(NA_real_, n),
                success = FALSE))
  }
  fitted <- as.numeric(X %*% out$coefficients)
  list(coef = unname(out$coefficients),
       residuals = as.numeric(y - fitted),
       fitted = fitted, success = TRUE)
}


#' @title Bootstrap SE for Weighted QR
#' @keywords internal
boot_wqr_se <- function(y, X, tau, weights, n_boot = 200, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  n <- length(y); k <- ncol(X)
  coefs <- matrix(NA_real_, n_boot, k)
  for (b in seq_len(n_boot)) {
    idx <- sample.int(n, n, replace = TRUE)
    fit <- weighted_qr(y[idx], X[idx, , drop = FALSE], tau, weights[idx])
    if (fit$success) coefs[b, ] <- fit$coef
  }
  se <- apply(coefs, 2, function(z) {
    z <- z[is.finite(z)]
    if (length(z) > 1) stats::sd(z) else NA_real_
  })
  list(se = se, boot = coefs)
}
