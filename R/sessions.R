
recovr_sessions <- function(sources_folder, out_folder) {
  folders <- list.files(sources_folder)
  session_ids <- files[grepl("^s-[a-zA-Z0-9]{8}$", folders, perl = TRUE)]

  results <- lapply(session_ids, function(session_id) {
    recovred <- recovr_sources(file.path(sources_folder, session_id),
                               out_folder)
  })
}
