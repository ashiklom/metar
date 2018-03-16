# Overview

`metar` combines several utilities, including
many packages of the core [tidyverse](https://www.tidyverse.org/),
the [sticky](https://cran.r-project.org/web/packages/sticky/index.html) package for persistent attributes,
and the [data.table](https://cran.r-project.org/web/packages/data.table/) package for fast I/O,
to provide a comprehensive interface for working with data and its metadata.
Currently the package provides utilities for:

- Reading from CSVY files, which provide a convenient way of storing tabular data and its metadata together while still being readable by common CSV-reading utilities.
- Adding metadata to in-memory `data.frame`s with a `dplyr`-like syntax

# Installation

This package is not on CRAN (yet!), but is easy enough to install from GitHub:


```r
devtools::install_github("ashiklom/metar")
```

# Usage

Add metadata to the `iris` dataset:


```r
library(metar)
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
iris_md <- iris %>%
  as_tibble() %>%
  add_metadata(
    # Metadata for individual columns
    Sepal.Length = list(title = "Sepal length", unit = "cm"),
    Sepal.Width = list(title = "Sepal width", unit = "in"),
    # .root sets metadata for the data frame as a whole
    .root = list(description = "The famous Iris dataset", author = "Not Alexey Shiklomanov")
  )
```

Metadata are stored as `attributes`.


```r
attr(iris_md, "description")
```

```
## [1] "The famous Iris dataset"
```

```r
attr(iris_md, "author")
```

```
## [1] "Not Alexey Shiklomanov"
```

```r
attr(iris_md$Sepal.Length, "title")
```

```
## [1] "Sepal length"
```

```r
attributes(iris_md$Sepal.Width)
```

```
## $title
## [1] "Sepal width"
## 
## $unit
## [1] "in"
## 
## $class
## [1] "sticky"  "numeric"
```

These attributes are made persistent through many operations by the `sticky` package.


```r
attr(iris_md[1, ], "description")
```

```
## [1] "The famous Iris dataset"
```

```r
attr(iris_md$Sepal.Length[1:5], "title")
```

```
## [1] "Sepal length"
```

The CSVY format is just a CSV file with a YAML header.


```r
system.file("examples/example1.csvy", package = "metar") %>%
  readLines() %>%
  writeLines()
```

```
## #---
## #name: example-dataset-1
## #description: An example dataset
## #resources:
## #  fields:
## #  - name: var1
## #    type: string
## #    label: First variable
## #  - name: var2
## #    type: integer
## #    label: Second variable
## #  - name: var3
## #    type: number
## #    label: Third variable
## #---
## var1,var2,var3
## A,1,2.0
## B,3,4.3
```

If read in with the `read_csvy` function, all metadata will be automatically applied:


```r
dat <- read_csvy(system.file("examples/example1.csvy", package = "metar"))
dat
```

```
## sticky tbl_df tbl data.frame
```

```
## # A tibble: 2 x 3
##   var1         var2         var3        
## * <S3: sticky> <S3: sticky> <S3: sticky>
## 1 A            1            2.0         
## 2 B            3            4.3
```

```r
attr(dat, "description")
```

```
## [1] "An example dataset"
```

```r
attr(dat$var1, "label")
```

```
## [1] "First variable"
```

Note that because `var2` was specified as an `integer` class, it was also read in as an `integer` rather than a `numeric`.


```r
class(dat$var2)
```

```
## [1] "sticky"  "integer"
```
