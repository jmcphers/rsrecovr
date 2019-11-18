
recovr_project <- function(project_folder, out_folder) {

  state_folder <- file.path(normalizePath(project_folder), ".Rproj.user")
  if (!file.exists(state_folder)) {
    stop("The folder ", project_folder, " does not appear to contain an ",
         "RStudio project.")
  }

  # list all the context IDs
  contexts <- list.files(state_folder, pattern = "^[a-zA-Z0-9]{8}$")

  # recover the sources from each context
  results <- lapply(contexts, function(context_id) {
    # recover the sources from this session
    recovred <- recovr_sessions(file.path(state_folder, context_id),
                                out_folder)

    if (nrow(recovred) > 0) {
      # we found sources in this folder; tag with the session ID
      cbind(data.frame(session = session_id), recovred)
    } else {
      # no sources here
      NULL
    }
  })
}
