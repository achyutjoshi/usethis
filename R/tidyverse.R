#' Helpers for the tidyverse
#'
#' These helpers follow tidyverse conventions which are generally a little
#' stricter than the defaults, reflecting the need for greater rigor in
#' commonly used packages
#'
#' @details
#'
#' * `use_tidy_ci()`: sets up travis and codecov, ensuring that the package
#'    works on all version of R starting at 3.1.
#'
#' * `use_tidy_description()`: puts fields in standard order and alphabetises
#'   dependencies.
#'
#' * `use_tidy_eval()`: imports a standard set of helpers to facilitate
#'   programming with the tidy eval toolkit.
#'
#' * `use_tidy_versions()`: pins all dependencies to require at least
#'   the currently installed version.
#'
#' @md
#' @name tidyverse
NULL

#' @export
#' @rdname tidyverse
#' @inheritParams use_travis
use_tidy_ci <- function(browse = interactive()) {
  check_uses_github()

  new <- use_template(
    "tidy-travis.yml",
    ".travis.yml",
    ignore = TRUE
  )
  use_template("codecov.yml", ignore = TRUE)

  use_dependency("R", "Depends", ">= 3.1")
  use_dependency("covr", "Suggests")

  use_travis_badge()
  use_codecov_badge()

  if (new) {
    travis_activate(browse)
  }

  invisible(TRUE)
}


#' @export
#' @rdname tidyverse
use_tidy_description <- function() {
  base_path <- proj_get()

  # Alphabetise dependencies
  deps <- desc::desc_get_deps(base_path)
  deps <- deps[order(deps$type, deps$package), , drop = FALSE]
  desc::desc_del_deps(file = base_path)
  desc::desc_set_deps(deps, file = base_path)

  # Alphabetise remotes
  remotes <- desc::desc_get_remotes(file = base_path)
  if (length(remotes) > 0)
    desc::desc_set_remotes(sort(remotes), file = base_path)

  # Reorder all fields
  desc::desc_reorder_fields(file = base_path)

  invisible(TRUE)
}


#' @export
#' @rdname tidyverse
#' @param overwrite By default (`FALSE`), only dependencies without version
#'   specifications will be modified. Set to `TRUE` to modify all dependencies.
use_tidy_versions <- function(overwrite = FALSE) {
  deps <- desc::desc_get_deps(proj_get())

  to_change <- deps$package != "R"
  if (!overwrite) {
    to_change <- to_change & deps$version == "*"
  }

  deps$version[to_change] <- vapply(deps$package[to_change], dep_version, character(1))
  desc::desc_set_deps(deps, file = proj_get())

  invisible(TRUE)
}

is_installed <- function(x) {
  length(find.package(x, quiet = TRUE)) > 0
}
dep_version <- function(x) {
  if (is_installed(x)) paste0(">= ", utils::packageVersion(x)) else "*"
}


#' @export
#' @rdname tidyverse
use_tidy_eval <- function() {
  if (!uses_roxygen()) {
    stop("`use_tidy_eval()` requires that you use roxygen.", call. = FALSE)
  }

  use_dependency("rlang", "Imports", ">= 0.1.2")
  use_template("tidy-eval.R", "R/utils-tidy-eval.R")

  todo("Run document()")
}
