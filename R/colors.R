#' @title MATLAB Parula Color Palette
#' @description MATLAB R2014b Parula colormap as hex codes.
#' @param n Integer. Number of colours.
#' @return Character vector of hex colours.
#' @export
#' @importFrom grDevices colorRampPalette rgb
parula_colors <- function(n = 256) {
  stops <- rbind(
    c(0.2422, 0.1504, 0.6603), c(0.2504, 0.1650, 0.7076),
    c(0.2578, 0.1818, 0.7511), c(0.2647, 0.1978, 0.7952),
    c(0.2706, 0.2147, 0.8364), c(0.2751, 0.2342, 0.8710),
    c(0.2783, 0.2559, 0.8991), c(0.2803, 0.2782, 0.9221),
    c(0.2813, 0.3006, 0.9414), c(0.2810, 0.3228, 0.9579),
    c(0.2795, 0.3447, 0.9717), c(0.2760, 0.3667, 0.9829),
    c(0.2699, 0.3892, 0.9906), c(0.2602, 0.4123, 0.9952),
    c(0.2440, 0.4358, 0.9988), c(0.2206, 0.4603, 0.9973),
    c(0.1963, 0.4847, 0.9892), c(0.1834, 0.5074, 0.9798),
    c(0.1786, 0.5289, 0.9682), c(0.1764, 0.5499, 0.9520),
    c(0.1687, 0.5703, 0.9359), c(0.1540, 0.5902, 0.9218),
    c(0.1460, 0.6091, 0.9079), c(0.1380, 0.6276, 0.8973),
    c(0.1248, 0.6459, 0.8883), c(0.1113, 0.6635, 0.8763),
    c(0.0952, 0.6798, 0.8598), c(0.0689, 0.6948, 0.8394),
    c(0.0297, 0.7082, 0.8163), c(0.0036, 0.7203, 0.7917),
    c(0.0067, 0.7312, 0.7660), c(0.0433, 0.7411, 0.7394),
    c(0.0964, 0.7500, 0.7120), c(0.1408, 0.7584, 0.6842),
    c(0.1717, 0.7670, 0.6554), c(0.1938, 0.7758, 0.6251),
    c(0.2161, 0.7843, 0.5923), c(0.2470, 0.7918, 0.5567),
    c(0.2906, 0.7973, 0.5188), c(0.3406, 0.8008, 0.4789),
    c(0.3909, 0.8029, 0.4354), c(0.4456, 0.8024, 0.3909),
    c(0.5044, 0.7993, 0.3480), c(0.5616, 0.7942, 0.3045),
    c(0.6174, 0.7876, 0.2612), c(0.6720, 0.7793, 0.2227),
    c(0.7242, 0.7698, 0.1910), c(0.7738, 0.7598, 0.1646),
    c(0.8203, 0.7498, 0.1535), c(0.8634, 0.7406, 0.1596),
    c(0.9035, 0.7330, 0.1774), c(0.9393, 0.7288, 0.2100),
    c(0.9728, 0.7298, 0.2394), c(0.9956, 0.7434, 0.2371),
    c(0.9970, 0.7659, 0.2199), c(0.9952, 0.7893, 0.2028),
    c(0.9892, 0.8129, 0.1885), c(0.9786, 0.8360, 0.1766),
    c(0.9676, 0.8587, 0.1643), c(0.9610, 0.8806, 0.1537),
    c(0.9597, 0.9023, 0.1423), c(0.9628, 0.9234, 0.1330),
    c(0.9691, 0.9438, 0.1241), c(0.9769, 0.9839, 0.0805))
  hex <- grDevices::rgb(stops[, 1], stops[, 2], stops[, 3])
  if (n == nrow(stops)) return(hex)
  grDevices::colorRampPalette(hex)(n)
}


#' @title MATLAB Jet palette
#' @param n Integer. Number of colours.
#' @return Character vector of hex colours.
#' @export
matlab_jet_colors <- function(n = 256) {
  grDevices::colorRampPalette(
    c("#000090", "#0000FF", "#00FFFF",
      "#FFFF00", "#FF0000", "#800000"))(n)
}


#' @title Turbo palette
#' @param n Integer.
#' @return Character vector of hex colours.
#' @export
turbo_colors <- function(n = 256) {
  grDevices::colorRampPalette(
    c("#30123B", "#4145AB", "#4675ED", "#39A2FC", "#1BCFD4",
      "#24EAA7", "#61FC6C", "#A4FC3C", "#D1E834", "#F3C63A",
      "#FE9B2D", "#F36315", "#D93806", "#A91201", "#7A0403"))(n)
}


#' @title Blue-Red diverging palette
#' @param n Integer.
#' @return Character vector of hex colours.
#' @export
bluered_colors <- function(n = 256) {
  grDevices::colorRampPalette(
    c("#053061", "#2166AC", "#92C5DE", "#F7F7F7",
      "#F4A582", "#B2182B", "#67001F"))(n)
}


#' @title Sinha red-yellow-black palette
#' @param n Integer.
#' @return Character vector of hex colours.
#' @export
sinha_colors <- function(n = 256) {
  grDevices::colorRampPalette(
    c("#000000", "#4A0E00", "#B22222", "#FF8C00", "#FFFF66"))(n)
}


#' @title Convert R colour vector to a plotly colorscale list
#' @param cols Character vector of hex colours.
#' @param n_breaks Integer.
#' @return List of list(value, hex) pairs.
#' @export
mqqcause_palette <- function(cols, n_breaks = 32) {
  n_breaks <- max(2L, as.integer(n_breaks))
  idx <- round(seq(1, length(cols), length.out = n_breaks))
  vals <- seq(0, 1, length.out = n_breaks)
  lapply(seq_len(n_breaks), function(i) list(vals[i], cols[idx[i]]))
}


#' @title Resolve a colour-scale name to a plotly colorscale
#' @param name Character.
#' @param n_breaks Integer.
#' @return A plotly colorscale (character or list).
#' @export
resolve_colorscale <- function(name = "Parula", n_breaks = 32) {
  if (is.list(name)) return(name)
  if (!is.character(name) || length(name) != 1)
    stop("'name' must be a single string")
  key <- tolower(name)
  native <- c("viridis", "plasma", "cividis", "inferno", "magma",
              "rdbu", "rdylbu", "blues", "greens", "reds", "greys",
              "ylgnbu", "ylorrd", "bluered", "rainbow")
  if (key == "parula")  return(mqqcause_palette(parula_colors(), n_breaks))
  if (key == "jet")     return(mqqcause_palette(matlab_jet_colors(), n_breaks))
  if (key == "turbo")   return(mqqcause_palette(turbo_colors(), n_breaks))
  if (key == "bluered" || key == "blue_red")
    return(mqqcause_palette(bluered_colors(), n_breaks))
  if (key == "sinha" || key == "red_yellow_black")
    return(mqqcause_palette(sinha_colors(), n_breaks))
  if (key %in% native) {
    cap <- function(s) paste0(toupper(substr(s, 1, 1)), substr(s, 2, nchar(s)))
    return(cap(key))
  }
  name
}


#' @title Available colour scales in mqqcause
#' @param show_preview Print descriptions.
#' @return Character vector of scale names.
#' @export
mqqcause_colorscales <- function(show_preview = TRUE) {
  scales <- c("Parula", "Jet", "Turbo", "BlueRed", "Sinha",
              "Viridis", "Plasma", "Cividis", "Inferno", "Magma", "RdBu")
  desc <- c(Parula  = "MATLAB R2014b default (perceptually uniform)",
            Jet     = "Classic MATLAB rainbow",
            Turbo   = "Google Turbo",
            BlueRed = "Diverging (blue low, red high)",
            Sinha   = "Sinha cross-quantile heatmap palette",
            Viridis = "Perceptually uniform",
            Plasma  = "Perceptually uniform, high contrast",
            Cividis = "Optimized for CVD",
            Inferno = "Dark to bright",
            Magma   = "Dark purple to white",
            RdBu    = "Diverging red/blue")
  if (show_preview) {
    cat("\nAvailable mqqcause color scales\n")
    cat("===============================\n")
    for (s in scales) cat(sprintf("  %-8s : %s\n", s, desc[[s]]))
    cat("\n  Default in mqqcause plots: \"Parula\"\n")
  }
  invisible(scales)
}
