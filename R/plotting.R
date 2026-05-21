#' @title 3D Surface Plot of QQ Causality
#' @param qq_result A \code{qq_causality} / \code{mqq_causality} object.
#' @param value Column to plot. Default \code{"t_value"}.
#' @param colorscale Default \code{"Parula"}.
#' @param show_contour Show gridlines on the surface.
#' @param x_label,y_label,title Labels.
#' @return A plotly object.
#' @export
#' @importFrom plotly plot_ly layout "%>%"
plot_qq_causality_3d <- function(qq_result, value = "t_value",
                                 colorscale = "Parula", show_contour = TRUE,
                                 x_label = "X Quantile (tau)",
                                 y_label = "Y Quantile (theta)",
                                 title = NULL) {
  M <- qq_causality_to_matrix(qq_result, value)
  xs <- as.numeric(colnames(M)); ys <- as.numeric(rownames(M))
  zlab <- switch(value, t_value = "t-statistic",
                 p_value = "p-value",
                 beta1 = "beta1",
                 se = "SE", value)
  if (is.null(title))
    title <- paste(qq_result$direction, "- QQ Causality (", zlab, ")")
  cs <- resolve_colorscale(colorscale)
  step_x <- if (length(xs) > 1) diff(xs)[1] else 0.05
  step_y <- if (length(ys) > 1) diff(ys)[1] else 0.05
  plotly::plot_ly(
    x = xs, y = ys, z = M, type = "surface",
    colorscale = cs, showscale = TRUE,
    colorbar = list(title = zlab, tickformat = ".3f"),
    contours = list(
      x = list(show = show_contour, color = "black",
               start = min(xs), end = max(xs), size = step_x),
      y = list(show = show_contour, color = "black",
               start = min(ys), end = max(ys), size = step_y),
      z = list(show = FALSE)),
    lighting = list(ambient = 0.55, diffuse = 0.8,
                    specular = 0.15, roughness = 0.9)
  ) %>%
    plotly::layout(title = title,
                   paper_bgcolor = "white", plot_bgcolor = "white",
                   scene = list(
                     xaxis = list(title = x_label, tickformat = ".2f",
                                  showgrid = TRUE, gridcolor = "#E6E6E6"),
                     yaxis = list(title = y_label, tickformat = ".2f",
                                  showgrid = TRUE, gridcolor = "#E6E6E6"),
                     zaxis = list(title = zlab, showgrid = TRUE,
                                  gridcolor = "#F0F0F0"),
                     aspectratio = list(x = 1, y = 1, z = 0.7),
                     camera = list(eye = list(x = 1.4, y = 1.7, z = 1.2))))
}


#' @title Heatmap of QQ Causality with Significance Stars
#' @param qq_result A \code{qq_causality} / \code{mqq_causality} object.
#' @param value Column to plot. Default \code{"t_value"}.
#' @param colorscale Default \code{"Parula"}.
#' @param show_stars Overlay ***, **, * markers (p-value thresholds).
#' @param x_label,y_label,title Labels.
#' @return A plotly object.
#' @export
plot_qq_causality_heatmap <- function(qq_result, value = "t_value",
                                      colorscale = "Parula",
                                      show_stars = TRUE,
                                      x_label = "X Quantile (tau)",
                                      y_label = "Y Quantile (theta)",
                                      title = NULL) {
  M <- qq_causality_to_matrix(qq_result, value)
  xs <- as.numeric(colnames(M)); ys <- as.numeric(rownames(M))
  zlab <- switch(value, t_value = "t-statistic",
                 p_value = "p-value", beta1 = "beta1",
                 se = "SE", value)
  if (is.null(title))
    title <- paste(qq_result$direction, "- QQ Causality (", zlab, ")")
  cs <- resolve_colorscale(colorscale)
  p <- plotly::plot_ly(x = xs, y = ys, z = M, type = "heatmap",
                       colorscale = cs, showscale = TRUE,
                       hovertemplate = paste0("tau: %{x:.2f}<br>theta: %{y:.2f}<br>",
                                              zlab, ": %{z:.4f}<extra></extra>")) %>%
    plotly::layout(title = title,
                   xaxis = list(title = x_label),
                   yaxis = list(title = y_label))
  if (show_stars) {
    pmat <- qq_causality_to_matrix(qq_result, "p_value")
    stars <- matrix("", nrow = nrow(pmat), ncol = ncol(pmat))
    stars[pmat < 0.10] <- "*"; stars[pmat < 0.05] <- "**"; stars[pmat < 0.01] <- "***"
    anns <- list()
    for (i in seq_len(nrow(M))) for (j in seq_len(ncol(M))) {
      if (nzchar(stars[i, j])) {
        anns[[length(anns) + 1]] <- list(
          x = xs[j], y = ys[i], text = stars[i, j],
          xref = "x", yref = "y", showarrow = FALSE,
          font = list(size = 10, color = "white"))
      }
    }
    p <- p %>% plotly::layout(annotations = anns)
  }
  p
}


#' @title Contour Plot of QQ Causality
#' @param qq_result A \code{qq_causality} / \code{mqq_causality} object.
#' @param value,colorscale,x_label,y_label,title See
#'   \code{\link{plot_qq_causality_3d}}.
#' @return A plotly object.
#' @export
plot_qq_causality_contour <- function(qq_result, value = "t_value",
                                      colorscale = "Parula",
                                      x_label = "X Quantile (tau)",
                                      y_label = "Y Quantile (theta)",
                                      title = NULL) {
  M <- qq_causality_to_matrix(qq_result, value)
  xs <- as.numeric(colnames(M)); ys <- as.numeric(rownames(M))
  zlab <- switch(value, t_value = "t-statistic",
                 p_value = "p-value", beta1 = "beta1", se = "SE", value)
  if (is.null(title))
    title <- paste(qq_result$direction, "- QQ Causality (", zlab, ")")
  cs <- resolve_colorscale(colorscale)
  plotly::plot_ly(x = xs, y = ys, z = M, type = "contour",
                  colorscale = cs, showscale = TRUE,
                  contours = list(showlabels = TRUE)) %>%
    plotly::layout(title = title,
                   xaxis = list(title = x_label),
                   yaxis = list(title = y_label))
}


#' @title Significance-only heatmap (categorical)
#' @description Renders only the p-value significance categories
#'   (>=0.10, <0.10, <0.05, <0.01) so the causality region stands out.
#' @param qq_result A \code{qq_causality} / \code{mqq_causality} object.
#' @param colorscale Default \code{"Parula"}.
#' @return A plotly object.
#' @export
plot_significance_heatmap <- function(qq_result, colorscale = "Parula") {
  pmat <- qq_causality_to_matrix(qq_result, "p_value")
  sig <- matrix(0, nrow(pmat), ncol(pmat))
  sig[pmat < 0.10] <- 1; sig[pmat < 0.05] <- 2; sig[pmat < 0.01] <- 3
  xs <- as.numeric(colnames(pmat)); ys <- as.numeric(rownames(pmat))
  cs <- resolve_colorscale(colorscale)
  plotly::plot_ly(x = xs, y = ys, z = sig, type = "heatmap",
                  colorscale = cs, showscale = TRUE,
                  zmin = 0, zmax = 3,
                  colorbar = list(
                    title = "sig",
                    tickvals = c(0, 1, 2, 3),
                    ticktext = c("n.s.", "*", "**", "***"))) %>%
    plotly::layout(title = paste(qq_result$direction,
                                 "- significance (p < 0.10/0.05/0.01)"),
                   xaxis = list(title = "X Quantile (tau)"),
                   yaxis = list(title = "Y Quantile (theta)"))
}


#' @title S3 plot method for qq_causality
#' @param x A qq_causality / mqq_causality object.
#' @param value Column to plot.
#' @param colorscale Default \code{"Parula"}.
#' @param kind \code{"heatmap"}, \code{"3d"}, \code{"contour"}, or
#'   \code{"significance"}.
#' @param ... Passed to the underlying plot function.
#' @return A plotly object.
#' @export
plot.qq_causality <- function(x, value = "t_value", colorscale = "Parula",
                              kind = c("heatmap", "3d", "contour",
                                       "significance"), ...) {
  kind <- match.arg(kind)
  fn <- switch(kind,
               heatmap = plot_qq_causality_heatmap,
               "3d" = plot_qq_causality_3d,
               contour = plot_qq_causality_contour,
               significance = function(r, value, colorscale, ...)
                 plot_significance_heatmap(r, colorscale))
  fn(x, value = value, colorscale = colorscale, ...)
}


#' @title S3 plot method for mqq_causality
#' @param x An mqq_causality object.
#' @param value,colorscale,kind,... See \code{\link{plot.qq_causality}}.
#' @return A plotly object.
#' @export
plot.mqq_causality <- function(x, value = "t_value", colorscale = "Parula",
                               kind = c("heatmap", "3d", "contour",
                                        "significance"), ...) {
  NextMethod()
}
