#' Recover RStudio Files
#'
#' Recovers unsaved changes or abandoned auto-save copies of files
#' previously opened in RStudio.
#'
#' @param project_path The project directory from which to recover files.
#'   Typically a path on disk to the directory. Use the special value
#'   `NULL` to recover files from sessions not associated with projects,
#'   and `"all"` to recover files from every recently used project and
#'   session.
#' @param out_folder The path to which recovered files should be written.
#' @param force Whether `out_folder` should be overwritten if it already exists.
#'
#' @return A data frame listing the recovered files.
#'
#' @examples
#' \dontrun{
#' # Recover files in the current project to the temporary directory
#' recovr()
#'
#' # Recover all recent projects/files to a custom folder
#' recovr(project_path = "all", out_folder = "~/scratch/rstudio")
#'
#' }
#'
#' @export

recovr <- function(project_path,
                   out_folder = file.path(tempdir(), "rsrecovr"),
                   force = FALSE) {
  if (missing(project_path)) {
    # user has not specified a project path; try to infer from working dir
    tryCatch({
      project_path <- rprojroot::find_root(rprojroot::is_rstudio_project)
    }, error = function(e) {
      warning("The current path (", getwd(), ") does not appear to be inside ",
              "an RStudio project. Files not open in a project will be ",
              "recovered. Suppress this warning with project_path = NULL ",
              "to explicitly restore files not open in a project.")
      project_path <<- NULL
    })
  }

  # establish output folder
  if (file.exists(out_folder)) {
    if (!isTRUE(force)) {
      stop("The output folder ", out_folder, " already exists. Remove it and ",
           "try again, or use force = TRUE to overwrite it.")
    }

    # get old output folder out of the way
    unlink(out_folder, recursive = TRUE)
  }

  # create the output folder
  dir.create(out_folder, recursive = TRUE)

  # recover requested content
  results <- if (is.null(project_path)) {
    # explicitly specifying null recovers user content
    recovr_user(out_folder)
  } else if (identical(project_path, "all")) {
    # explicitly specifying all recovers *everything*
    recovr_all(out_folder)
  } else {
    # otherwise, recover just the project specified
    recovr_project(project_path, out_folder)
  }

  # sum the results which have a restored file; many of the restored buffers
  # wind up not being files (e.g. data viewers)
  total <- length(which(!is.na(results["restored"])))

  message("Recovery complete; recovered ", total, " files to ", out_folder)

  invisible(results)
}
