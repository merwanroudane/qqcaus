\name{plot_qq_causality_3d}
\alias{plot_qq_causality_3d}
\alias{plot_qq_causality_heatmap}
\alias{plot_qq_causality_contour}
\alias{plot_significance_heatmap}
\title{Visualisations for QQ Causality Results}
\usage{
plot_qq_causality_3d(qq_result, value = "t_value",
                     colorscale = "Parula", show_contour = TRUE,
                     x_label = "X Quantile (tau)",
                     y_label = "Y Quantile (theta)", title = NULL)

plot_qq_causality_heatmap(qq_result, value = "t_value",
                          colorscale = "Parula", show_stars = TRUE,
                          x_label = "X Quantile (tau)",
                          y_label = "Y Quantile (theta)", title = NULL)

plot_qq_causality_contour(qq_result, value = "t_value",
                          colorscale = "Parula",
                          x_label = "X Quantile (tau)",
                          y_label = "Y Quantile (theta)", title = NULL)

plot_significance_heatmap(qq_result, colorscale = "Parula")
}
\arguments{
\item{qq_result}{A \code{qq_causality} or \code{mqq_causality} object.}
\item{value}{Column to plot.}
\item{colorscale}{Default \code{"Parula"}.}
\item{show_contour, show_stars, x_label, y_label, title}{Plot options.}
}
\value{A plotly object.}
\description{3D surface, heatmap, contour and significance-only heatmap
visualisations of QQ Granger-causality results, defaulting to MATLAB Parula.}
\examples{
## Small toy example -- auto-tested.
set.seed(1); n <- 80
x <- rnorm(n); y <- 0.3 * c(0, x[-n]) + rnorm(n, sd = 0.4)
fit <- qq_causality(x, y,
                    y_quantiles = c(0.25, 0.5, 0.75),
                    x_quantiles = c(0.25, 0.5, 0.75),
                    n_boot = 10, verbose = FALSE)
p1 <- plot_qq_causality_heatmap(fit, value = "t_value", show_stars = TRUE)
p2 <- plot_qq_causality_3d(fit, value = "t_value")
p3 <- plot_qq_causality_contour(fit, value = "t_value")
p4 <- plot_significance_heatmap(fit)
}
