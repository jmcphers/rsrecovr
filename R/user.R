# Recover user-level (no project) files
recovr_user <- function(out_folder) {
  results <- NULL

  # recover sessions for RStudio Desktop
  desktop_folder <- rstudio_desktop_folder()
  if (file.exists(desktop_folder)) {
    results <- recovr_sessions(file.path(desktop_folder, "sources"))
  }

  # recover sessions for RStudio Server
  server_folder <- path.expand("~/.rstudio")
  if (file.exists(server_folder)) {
    results <- rbind(results, recovr_sessions(
      file.path(server_folder, "sources"),
      out_folder))
  }

  # return results
  results
}
