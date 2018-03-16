context("Adding and accessing metadata")

import::from("tibble", "as_tibble", "tribble")
import::from("magrittr", "%>%")

test_that(
  "Adding metadata works as expected",
  {
    iris_tbl <- as_tibble(iris)
    species_description <- tribble(
      ~Species, ~description,
      "setosa", "pretty",
      "virginica", "pure",
      "versicolor", "purple"
    )
    iris_md <- iris_tbl %>%
      add_metadata(
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
