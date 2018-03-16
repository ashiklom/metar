#' Retrieve YAML header from file
#'
#' Note that this assumes only one Yaml header, starting on the first line of 
#' the file.
#'
#' @param file Filename from which to read YAML header
#' @param verbose Logical. If `TRUE`, print warning if no header found.
#' @param ... Additional arguments to [yaml::read_yaml]
#' @return Character vector of lines containing YAML header, or `NULL` if no 
#' YAML header found.
#' @export
read_yaml_header <- function(file, verbose = TRUE, ...) {
  yaml_rxp <- "^#*---[[:space:]]*$"
  con <- file(file, "r")
  on.exit(close(con))
  first_line <- readLines(con, n = 1)
  if (!grepl(yaml_rxp, first_line)) {
    if (verbose) warning("No YAML header found.")
    return(NULL)
  }
  iline <- 2
  closing_tag <- FALSE
  tag_vec <- character()
  while (!closing_tag) {
    curr_line <- readLines(con, n = 1)
    tag_vec[iline - 1] <- curr_line
    closing_tag <- grepl(yaml_rxp, curr_line)
    iline <- iline + 1
  }
  out_raw <- tag_vec[seq_len(iline - 2)]
  if (all(grepl("^#+", out_raw))) {
    out_raw <- gsub("^#+", "", out_raw)
  }
  out <- yaml::read_yaml(text = out_raw, ...)
  structure(out, nlines = iline - 1)
}
