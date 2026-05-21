test_that("parula returns hex colours", {
  expect_match(parula_colors(5), "^#[0-9A-Fa-f]{6}$")
})

test_that("qq_causality returns expected structure", {
  set.seed(1); n <- 100
  x <- rnorm(n); y <- 0.3 * c(0, x[-n]) + rnorm(n, sd = 0.5)
  fit <- qq_causality(x, y,
                      y_quantiles = c(0.25, 0.5, 0.75),
                      x_quantiles = c(0.25, 0.5, 0.75),
                      n_boot = 20, verbose = FALSE)
  expect_s3_class(fit, "qq_causality")
  expect_equal(nrow(fit$results), 9)
  M <- qq_causality_to_matrix(fit, "beta1")
  expect_equal(dim(M), c(3, 3))
  sw <- sup_wald(fit)
  expect_true(is.list(sw) && "sup_statistic" %in% names(sw))
})

test_that("mqq_causality conditions on Z", {
  set.seed(1); n <- 120
  x <- rnorm(n); z <- rnorm(n)
  y <- 0.3 * c(0, x[-n]) + 0.2 * c(0, z[-n]) + rnorm(n, sd = 0.4)
  fit <- mqq_causality(x, y, list(Z = z),
                       y_quantiles = c(0.25, 0.5, 0.75),
                       x_quantiles = c(0.25, 0.5, 0.75),
                       n_boot = 20, verbose = FALSE)
  expect_s3_class(fit, "mqq_causality")
  expect_true("Z" %in% fit$moderator_names)
})
