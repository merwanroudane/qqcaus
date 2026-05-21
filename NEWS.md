# mqqcause 1.0.0

* Initial CRAN release.
* `qq_causality()` for bivariate Quantile-on-Quantile Granger causality
  (Sim and Zhou 2015 framework) and `mqq_causality()` for the
  conditional version that adds a vector of moderators and optional
  `x * Z` interaction terms (Sinha et al. 2024).
* `sup_wald()` summary across (theta, tau) with Bonferroni adjustment
  (Troster 2018).
* 3D surface, heatmap, contour and significance-only heatmap
  visualisations (`plot_qq_causality_3d`, `plot_qq_causality_heatmap`,
  `plot_qq_causality_contour`, `plot_significance_heatmap`).
* MATLAB Parula default colour scale, plus Jet, Turbo, BlueRed and
  the Sinha red-yellow-black palette.
