\name{qq_causality}
\alias{qq_causality}
\alias{mqq_causality}
\alias{sup_wald}
\alias{qq_causality_to_matrix}
\title{Quantile-on-Quantile Granger Causality (Bivariate and Multivariate)}
\usage{
qq_causality(x, y,
             y_quantiles = seq(0.05, 0.95, by = 0.05),
             x_quantiles = seq(0.05, 0.95, by = 0.05),
             bandwidth = 0.05, n_boot = 200,
             cdf_based_kernel = TRUE,
             cause_name = "X", effect_name = "Y",
             verbose = TRUE, seed = 42)

mqq_causality(x, y, moderators = list(),
              y_quantiles = seq(0.05, 0.95, by = 0.05),
              x_quantiles = seq(0.05, 0.95, by = 0.05),
              bandwidth = 0.05, n_boot = 200, interactions = TRUE,
              cdf_based_kernel = TRUE,
              cause_name = "X", effect_name = "Y",
              verbose = TRUE, seed = 42)

sup_wald(qq_result, alpha = 0.05)
qq_causality_to_matrix(qq_result, value = "t_value")
}
\arguments{
\item{x, y}{Numeric vectors (cause and effect).}
\item{moderators}{Named list of numeric vectors (the conditioning set Z).}
\item{y_quantiles, x_quantiles}{Numeric vectors of quantile levels in (0, 1).}
\item{bandwidth}{Kernel bandwidth on the empirical-CDF scale.}
\item{n_boot}{Bootstrap replicates.}
\item{interactions}{Include x*Z cross-terms (mqq_causality).}
\item{cdf_based_kernel}{Use CDF-distance kernel.}
\item{cause_name, effect_name}{Variable names for printing.}
\item{verbose}{Print progress.}
\item{seed}{RNG seed.}
\item{qq_result}{A \code{qq_causality} / \code{mqq_causality} object.}
\item{value}{Column to pivot.}
\item{alpha}{Significance threshold.}
}
\value{For \code{qq_causality} and \code{mqq_causality}, an object of class
\code{"qq_causality"} or \code{"mqq_causality"}. \code{sup_wald} returns a
list; \code{qq_causality_to_matrix} returns a numeric matrix.}
\description{Tests whether the tau-quantile of \eqn{x_{t-1}} Granger-causes
the theta-quantile of \eqn{y_t}. The multivariate variant conditions on a
set of moderators \eqn{Z} and optional \eqn{x \cdot Z} interaction terms
(the conditional-causality test that under-pins Sinha et al., 2024).}
\references{
Sim, N., Zhou, H. (2015). \emph{Journal of Banking and Finance}, 55, 1-12.

Troster, V. (2018). Testing for Granger-causality in Quantiles.
\emph{Econometric Reviews}, 37(8), 850-866.
}
\examples{
set.seed(1); n <- 200
x <- rnorm(n); z <- rnorm(n)
y <- 0.3 * c(0, x[-n]) + 0.2 * c(0, z[-n]) + rnorm(n, sd = 0.4)
fit <- mqq_causality(x, y, list(Z = z),
                     y_quantiles = c(0.25, 0.5, 0.75),
                     x_quantiles = c(0.25, 0.5, 0.75),
                     n_boot = 30, verbose = FALSE)
print(fit)
sup_wald(fit)
}
