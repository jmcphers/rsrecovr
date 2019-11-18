
recovr_all <- function(out_folder) {
  # start with an empty list of projects
  projects <- c()

  # look for a project MRU to examine
  for (folder in c(rstudio_desktop_folder(), path.expand("~/.rstudio"))) {
    mru <- file.path(folder, "monitored", "lists", "project_mru")
    if (file.exists(mru)) {
      projects <- c(projects, readLines(mru))
    }
  }

  results <- NULL

  # restore all the projects in the MRU
  project_results <- lapply(projects, function(mru_entry) {
    # mru_entry points to an rproj file; move up one level
    mru_entry <- dirname(mru_entry)

    # recover files from the project
    results <- recovr_project(path.expand(mru_entry), out_folder)
    if (!is.null(results) && nrow(results) > 0) {
      # found files to recover
      cbind(project = basename(mru_entry), results)
    } else {
      NULL
    }
  })

  # combine all project results
  results <- do.call(rbind, project_results)

  # combine user results
  user_results <- recovr_user(out_folder)
  if (!is.null(user_results) && nrow(user_results) > 0) {
    results <- rbind(results, cbind(project = NA, context = NA, user_results))
  }

  # return everything
  results
}


