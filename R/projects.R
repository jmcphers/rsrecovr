# Recovers RStudio content from a single project
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
    recovred <- recovr_sessions(file.path(state_folder, context_id, "sources"),
                                out_folder)

    if (!is.null(recovred) && nrow(recovred) > 0) {
      # we found sources in this folder; tag with the session ID
      cbind(data.frame(context = context_id), recovred)
    } else {
      # no sources here
      NULL
    }
  })

  # return summary of results
  do.call(rbind, results)
}
