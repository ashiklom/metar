# metar 0.2.0

## Breaking changes

* New API for setting metadata. Setting metadata for any object is now accomplished with `add_metadata(obj, ...)` or via a new assignment operator (`metadata(obj) <- list(...)`). The functions of the old `add_metadata` have been replaced with `add_column_metadata`.

## New features

* Add `list2df` function for converting lists to `data.frames` list columns where appropriate.

## Bugfixes

* An additional type conversion step has been added to `read_csvy`, since `fread` will not actually respect `colClasses` if it thinks doing so will result in data loss. Mismatches in `fread`'s guess and the specified classes will result in a warning that can be suppressed with `verbose = FALSE`.

# metar 0.1.1

* Create basic utilities for adding metadata to data frames and reading and writing metadata-enhanced data frames to disk are functional.
* All CRAN checks are passing.
