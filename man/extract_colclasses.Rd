% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_csvy.R
\name{extract_colclasses}
\alias{extract_colclasses}
\title{Extract column classes from metadata}
\usage{
extract_colclasses(meta_data, verbose = TRUE)
}
\arguments{
\item{meta_data}{Named list of metadata values returned by
\link{read_yaml_header}}

\item{verbose}{Logical. If \code{TRUE}, warn about missing fields.}
}
\value{
Named vector of column classes, suitable for \code{colClasses} argument
of \link[data.table:fread]{data.table::fread}.
}
\description{
Extract column classes from metadata
}
