# Recover user-level (no project) files
recovr_user <- function(out_folder) {
  results <- NULL

  # recover sessions for RStudio Desktop
  desktop_folder <- rstudio_desktop_folder()
  if (file.exists(desktop_folder)) {
    results <- recovr_sessions(file.path(desktop_folder, "sources"), out_folder)
  }

  # recover sessions for RStudio Server v1.3. (v1.4 and
  # following use the same folder as desktop so have a more
  # symmetric recovery path)
  server_folder <- path.expand("~/.rstudio")
  if (file.exists(server_folder)) {
    results <- rbind(results, recovr_sessions(
      file.path(server_folder, "sources"),
      out_folder))
  }

  # return results
  results
}
