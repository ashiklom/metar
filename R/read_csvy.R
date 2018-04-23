#' Read a CSVY file
#'
#' @details A CSVY (CSV + YAML) file is just a CSV file prepended with a YAML 
#' header containing relevant metadata. The metadata can be any list or 
#' list-like object, and any fields not specially recognized will be parsed by 
#' [yaml::read_yaml] and stored as named attributes. The following metadata 
#' fields are parsed specially:
#'
#'  - `read_csv` -- contains the arguments to be passed to [readr::read_csv], 
#'  such as the field separator (`sep`) and `NA` strings (`na.strings`). In 
#'  general, this is not necessary because `read_csv` has sensible defaults and 
#'  is clever about figuring such things out, but it may improve performance or 
#'  reliability for particularly large or complex files.
#'
#'  - `resources: fields` (Single item `fields` nested inside root item 
#'  `resources`) -- A list of metadata for the table columns.  These are 
#'  structured generally following the [Table 
#'  Schema](https://frictionlessdata.io/specs/table-schema) of a [Tabular Data 
#'  Package](https://frictionlessdata.io/specs/tabular-data-package) with a few 
#'  R-friendly modifications. All of these fields are optional, though some can 
#'  be deduced automatically during the writing process. Some common fields are 
#'  as follows (fields with `*` following their labels are not in the Table 
#'  Schema):
#'    * `name` -- Name of field, corresponding to column name in data
#'    * `title` -- A human-readable label for the field
#'    * `description` -- A description for the field
#'    * `type` -- String specifying the schema type (see [schema_type_dict])
#'    * `class*` -- String or array specifying the R `class`(es) to which the 
#'    object belongs.
#'    * `constraints` -- A list of constraints on the data (see [Table Schema: 
#'    Constraints](https://frictionlessdata.io/specs/table-schema/#constraints)).  
#'    Eventually, all of these will be actively used by R to verify data.
#'
#'  - `missingValues` -- An array of strings that are used to indicate missing 
#'  values.
#'
#' @param file Name of file to read.
#' @param metadata Path to additional metadata. If `NULL` (default), assume 
#' metadata is in `file`.
#' @inheritParams read_yaml_header
#' @param ... Additional arguments to [readr::read_csv]
#' @export
read_csvy <- function(file,
                      metadata = NULL,
                      verbose = TRUE,
                      ...) {
  if (!is.null(metadata)) {
    stopifnot(file.exists(metadata))
    tryCatch(
      meta_data <- read_yaml_header(metadata, verbose = TRUE),
      warning = function(w) stop(w)
    )
    skip_lines <- 0
  } else {
    meta_data <- read_yaml_header(file, verbose = verbose)
    if (is.null(meta_data)) {
      skip_lines <- 0
    } else {
      skip_lines <- attr(meta_data, "nlines")
    }
  }

  readr_opts <- list(
    file = file,
    skip = skip_lines
  )

  readr_meta <- meta_data[["read_csv"]]

  if (!is.null(readr_meta)) {
    readr_opts <- modifyList(readr_opts, readr_meta)
  }

  classes <- extract_colclasses(meta_data, verbose = verbose)
  if (!is.null(classes)) {
    readr_opts[["col_types"]] <- purrr::map_chr(classes, 1)
  }

  # Function arguments take highest priority
  readr_opts <- modifyList(readr_opts, list(...))

  csv_raw <- do.call(readr::read_csv, readr_opts)

  # Set levels for factor columns
  factor_classes <- purrr::keep(classes, ~. == "factor" && !is.null(attr(., "factor_levels")))
  factor_levels <- purrr::map(factor_classes, ~attr(., "factor_levels"))
  factor_cols <- names(factor_classes)
  csv_raw[factor_cols] <- purrr::map2(
    csv_raw[factor_cols],
    factor_levels,
    factor
  )

  csv_classes <- purrr::map_chr(csv_raw, class)
  class_mismatch <- csv_classes != fread_opts[["colClasses"]]
  if (any(class_mismatch)) {
    if (verbose) {
      warning("Mismatches in column classes between fread and data. ",
              "Coercing data to desired classes.")
    }
    csv_raw[class_mismatch] <- purrr::map2(
      csv_raw[class_mismatch],
      fread_opts[["colClasses"]][class_mismatch],
      convert_class
    )
  }


  meta_attr <- extract_attributes(meta_data)
  csv_md <- do.call(add_column_metadata, c(list(.data = csv_raw), meta_attr))
  csv_md
}

#' Convert object to class, dealing with special cases
convert_class <- function(obj, to) {
  if (to == "Date") return(as.character(obj))
  if (to == "POSIXct") return(as.character(obj))
  if (to == "factor") {
    lvls <- attr(to, "factor_levels")
    if (!is.null(lvls)) {
      return(factor(obj, lvls))
    } else {
      return(factor(obj))
    }
  }
  methods::as(obj, to)
}

#' Extract column classes from metadata
#'
#' @param meta_data Named list of metadata values returned by 
#' [read_yaml_header]
#' @param verbose Logical. If `TRUE`, warn about missing fields.
#' @return Named vector of column classes, suitable for `colClasses` argument 
#' of [data.table::fread].
#' @export
extract_colclasses <- function(meta_data, verbose = TRUE) {
  if (!"resources" %in% names(meta_data)) {
    if (verbose) {
      warning("No resources field found. Returning NULL.")
    }
    return(NULL)
  }
  if (!"fields" %in% names(meta_data[["resources"]])) {
    if (verbose) {
      warning("No fields found in metadata. Returning NULL.")
    }
    return(NULL)
  }
  fields <- meta_data[["resources"]][["fields"]] %>%
    extract_as_name("name")
  purrr::map(fields, field2colclass)
}

#' Convert metadata list to attributes list suitable for [add_metadata]
#'
#' @inheritParams extract_colclasses
#' @export
extract_attributes <- function(meta_data) {
  root_md <- setdiff(names(meta_data), c("resources", "fread"))
  .root <- meta_data[root_md]
  drop_fields <- c("name", "type", "class", "levels")
  field_md <- meta_data[["resources"]][["fields"]] %>%
    extract_as_name("name") %>%
    purrr::map(~.[setdiff(names(.), drop_fields)])
  c(field_md, list(.root = .root))
}

field2colclass <- function(field) {
  if ("class" %in% names(field)) {
    r_class <- field$class
  }
  if ("type" %in% names(field)) {
    schema_type <- field[["type"]]
    r_class <- schema_type_dict[schema_type]
  }
  col_class <- match.fun()
  if (r_class == "factor" && "levels" %in% names(field)) {
    attr(r_class, "factor_levels") <- field$levels
  }
  r_class
}

extract_as_name <- function(l, tag) {
  names(l) <- purrr::map_chr(l, tag)
  purrr::map(l, ~.[setdiff(names(.), tag)])
}
