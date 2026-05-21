\name{parula_colors}
\alias{parula_colors}
\alias{matlab_jet_colors}
\alias{turbo_colors}
\alias{bluered_colors}
\alias{sinha_colors}
\alias{mqqcause_palette}
\alias{resolve_colorscale}
\alias{mqqcause_colorscales}
\title{MATLAB-style colour palettes for mqqcause}
\usage{
parula_colors(n = 256)
matlab_jet_colors(n = 256)
turbo_colors(n = 256)
bluered_colors(n = 256)
sinha_colors(n = 256)
mqqcause_palette(cols, n_breaks = 32)
resolve_colorscale(name = "Parula", n_breaks = 32)
mqqcause_colorscales(show_preview = TRUE)
}
\arguments{
\item{n}{Number of colours.}
\item{cols}{Character vector of hex colours.}
\item{n_breaks}{Stops for the plotly list.}
\item{name}{Scale name (Parula by default).}
\item{show_preview}{Print descriptions.}
}
\value{Character vector or list.}
\description{Colour palettes used by mqqcause plotting functions. The
default scale is MATLAB Parula.}
