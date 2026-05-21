## Test environments

* local Windows 11, R 4.5.2
* win-builder (devel and release) — pending
* R-hub (Linux, macOS, Windows) — pending

## R CMD check results

0 errors | 0 warnings | 0 notes

## Submission notes

This is the first CRAN release of `mqqcause`.

Maintainer: Dr Merwan Roudane <merwanroudane920@gmail.com>
Source repository: https://github.com/merwanroudane/qqcaus

The package implements bivariate and multivariate (conditional)
Quantile-on-Quantile Granger-causality tests with a Sup-Wald summary
across the (theta, tau) grid. It complements my existing
`QuantileOnQuantile` CRAN package and shares the same MATLAB Parula
default colour scale used by my new `mqqr` and `qqkrls` companion
packages.

Slow examples (the full grid with bootstrap standard errors) are
wrapped in `\donttest{}`. Tests cover the lightweight code paths.
