context("Adding and processing metadata")

test_that(
  "Low level metadata functions work",
  {
    obj <- 1:10 %>%
      add_metadata(title = "Insect counts") %>%
      add_metadata(scale = "1000") %>%
      add_metadata(scale = 2000)
    expect_equal(attr(obj, "title"), "Insect counts")
    expect_equal(attr(obj, "scale"), 2000)
    expect_equal(attr(obj[1:5], "title"), "Insect counts")

    obj2 <- obj[7] * 3
    expect_equal(attr(obj2, "scale"), 2000)
    expect_equal(attr(obj2, "scale"), 2000)

    obj3 <- letters[1:5]
    metadata(obj3) <- list(title = "Some letters", purpose = "For testing")
    expect_equal(attr(obj3, "title"), "Some letters")
    expect_equal(attr(obj3, "purpose"), "For testing")
  }
)

test_that(
  "Adding basic metadata works as expected",
  {
    iris_tbl <- tibble::as_tibble(iris)
    species_description <- tibble::tribble(
      ~Species, ~description,
      "setosa", "pretty",
      "virginica", "pure",
      "versicolor", "purple"
    )
    iris_md <- iris_tbl %>%
      add_column_metadata(
        Sepal.Length = list(title = "Sepal length", unit = "cm"),
        Sepal.Width = list(title = "Sepal width", unit = "in"),
        Species = list(description = species_description),
        .root = list(author = "Alexey Shiklomanov")
      )

    expect_true(all(c("title", "unit") %in% names(attributes(iris_md$Sepal.Length))))
    expect_true(all(c("title", "unit") %in% names(attributes(iris_md$Sepal.Width))))
    expect_equal(attr(iris_md$Sepal.Length, "title"), "Sepal length")
    expect_equal(attr(iris_md$Sepal.Length, "unit"), "cm")
    expect_equal(attr(iris_md$Sepal.Width, "title"), "Sepal width")
    expect_equal(attr(iris_md$Sepal.Width, "unit"), "in")
    expect_equal(attr(iris_md$Species, "description"), species_description)
    expect_equal(attr(iris_md, "author"), "Alexey Shiklomanov")
  }
)

test_that(
  "Metadata is processed correctly",
  {
    meta_data <- list(resources = list(fields = list(
      list(name = "col1", type = "string", label = "one"),
      list(name = "col2", class = "character", type = "string", label = "two"),
      list(name = "col3", type = "number", label = "three"),
      list(name = "col4", type = "datetime", label = "four")
      ))
    )

    classes <- extract_colclasses(meta_data)
    col_names <- purrr::map_chr(meta_data$resources$fields, "name")
    expect_named(classes$cols, col_names)
    expect_equal(
      classes,
      readr::cols(
        col1 = readr::col_character(),
        col2 = readr::col_character(),
        col3 = readr::col_number(),
        col4 = readr::col_datetime()
      )
    )

    attrs <- extract_attributes(meta_data)
    expect_named(attrs, c(col_names, ".root"))
    expect_equivalent(
      attrs,
      list(col1 = list(label = "one"), col2 = list(label = "two"),
           col3 = list(label = "three"), col4 = list(label = "four"),
           .root = list())
    )
  }
)
