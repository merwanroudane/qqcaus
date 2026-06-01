# mqqcause — Multivariate Quantile-on-Quantile Granger Causality

[![CRAN status](https://www.r-pkg.org/badges/version/mqqcause)](https://CRAN.R-project.org/package=mqqcause)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/mqqcause)](https://cran.r-project.org/package=mqqcause)
[![CRAN downloads total](https://cranlogs.r-pkg.org/badges/grand-total/mqqcause)](https://cran.r-project.org/package=mqqcause)
[![License: GPL-3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

> **Author / maintainer:** Dr Merwan Roudane &nbsp;&middot;&nbsp;
> <merwanroudane920@gmail.com> &nbsp;&middot;&nbsp;
> Repo: <https://github.com/merwanroudane/qqcaus>

`mqqcause` implements both bivariate and multivariate (conditional)
Quantile-on-Quantile Granger causality tests. For each pair of quantile
levels (theta, tau), the slope `beta1(theta, tau)` from the
locally-weighted quantile regression of `y_t` on `x_{t-1}` is tested
against zero with a paired bootstrap. The multivariate variant
additionally conditions on a set of moderators `Z` (and optional
`x * Z` interactions). A Sup-Wald summary across the grid is also
provided (Troster 2018).

All 3D surfaces, heatmaps and contour plots default to MATLAB Parula.

## Installation

```r
# from CRAN (once accepted)
install.packages("mqqcause")

# development version
# install.packages("remotes")
remotes::install_github("merwanroudane/qqcaus")

# from a local source tarball
install.packages("mqqcause_1.0.0.tar.gz", repos = NULL, type = "source")
```

## Quick start

```r
library(mqqcause)

set.seed(1)
n <- 200
x <- rnorm(n)
z <- rnorm(n)
y <- 0.3 * c(0, x[-n]) + 0.2 * c(0, z[-n]) + rnorm(n, sd = 0.4)

# Bivariate
fit1 <- qq_causality(x, y, n_boot = 100)
print(fit1); sup_wald(fit1)

# Conditional (multivariate)
fit2 <- mqq_causality(x, y, moderators = list(Z = z), n_boot = 100)
print(fit2)

# Heatmap with significance stars (MATLAB Parula)
plot_qq_causality_heatmap(fit2, value = "t_value", show_stars = TRUE)

# Significance-only heatmap
plot_significance_heatmap(fit2)
```

## References

* Sim, N., Zhou, H. (2015). Oil Prices, US Stock Return, and the
  Dependence Between Their Quantiles.
  *Journal of Banking and Finance*, 55, 1-12.
* Troster, V. (2018). Testing for Granger-causality in Quantiles.
  *Econometric Reviews*, 37(8), 850-866.

## License

GPL-3
