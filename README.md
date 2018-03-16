

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

Add metadata directly to objects:


```r
library(metar)

obj <- rnorm(100)
metadata(obj) <- list(title = "Normal draws", description = "Some random normal draws")
metadata(obj)
#> $title
#> [1] "Normal draws"
#> 
#> $description
#> [1] "Some random normal draws"
metadata(obj, "title", "description")
#> $title
#> [1] "Normal draws"
#> 
#> $description
#> [1] "Some random normal draws"
```

You can also use the pipe-friendly `add_metadata`:


```r
obj2 <- runif(100) %>%
  add_metadata(title = "Normal draws") %>%
  # Metadata can be added or overwritten
  add_metadata(author = "RNG", title = "Just kidding, they're uniform draws") %>%
  # Metadata can be any R object
  add_metadata(range = list(min = 0, max = 1))
metadata(obj2)
#> $title
#> [1] "Just kidding, they're uniform draws"
#> 
#> $author
#> [1] "RNG"
#> 
#> $range
#> $range$min
#> [1] 0
#> 
#> $range$max
#> [1] 1
metadata(obj2, "range")
#> $range
#> $range$min
#> [1] 0
#> 
#> $range$max
#> [1] 1
```

Add metadata to each column of the `iris` dataset:


```r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

iris_md <- iris %>%
  as_tibble() %>%
  add_column_metadata(
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
#> [1] "The famous Iris dataset"
attr(iris_md, "author")
#> [1] "Not Alexey Shiklomanov"
attr(iris_md$Sepal.Length, "title")
#> [1] "Sepal length"
attributes(iris_md$Sepal.Width)
#> $title
#> [1] "Sepal width"
#> 
#> $unit
#> [1] "in"
#> 
#> $class
#> [1] "sticky"  "numeric"
```

These attributes are made persistent through many operations by the `sticky` package.


```r
metadata(iris_md)
#> $description
#> [1] "The famous Iris dataset"
#> 
#> $author
#> [1] "Not Alexey Shiklomanov"
metadata(iris_md[1, ], "description")
#> $description
#> [1] "The famous Iris dataset"
metadata(iris_md$Sepal.Length[1:5], "title")
#> $title
#> [1] "Sepal length"
```

The CSVY format is just a CSV file with a YAML header.


```r
system.file("examples/example1.csvy", package = "metar") %>%
  readLines() %>%
  writeLines()
#> #---
#> #name: example-dataset-1
#> #description: An example dataset
#> #resources:
#> #  fields:
#> #  - name: var1
#> #    type: string
#> #    label: First variable
#> #  - name: var2
#> #    type: integer
#> #    label: Second variable
#> #  - name: var3
#> #    type: number
#> #    label: Third variable
#> #  - name: var4
#> #    type: boolean
#> #    label: Fourth variable
#> #  - name: var5
#> #    type: factor
#> #    label: Fifth variable
#> #---
#> var1,var2,var3,var4,var5
#> A,1.0,2.0,0,x
#> B,3.0,4.3,1,y
```

If read in with the `read_csvy` function, all metadata will be automatically applied:


```r
dat <- read_csvy(system.file("examples/example1.csvy", package = "metar"))
#> Warning in read_csvy(system.file("examples/example1.csvy", package =
#> "metar")): Mismatches in column classes between fread and data. Coercing
#> data to desired classes.
dat
#> # A tibble: 2 x 5
#>   var1         var2         var3         var4         var5 
#> * <S3: sticky> <S3: sticky> <S3: sticky> <S3: sticky> <fct>
#> 1 A            1            2.0          FALSE        x    
#> 2 B            3            4.3          TRUE         y
metadata(dat)
#> $name
#> [1] "example-dataset-1"
#> 
#> $description
#> [1] "An example dataset"
lapply(dat, metadata)
#> $var1
#> $var1$label
#> [1] "First variable"
#> 
#> 
#> $var2
#> $var2$label
#> [1] "Second variable"
#> 
#> 
#> $var3
#> $var3$label
#> [1] "Third variable"
#> 
#> 
#> $var4
#> $var4$label
#> [1] "Fourth variable"
#> 
#> 
#> $var5
#> $var5$levels
#> [1] "x" "y"
#> 
#> $var5$label
#> [1] "Fifth variable"
```

Note that because `var2` was specified as an `integer` class, it was also read in as an `integer` rather than a `numeric`.


```r
class(dat$var2)
#> [1] "sticky"  "integer"
```
