
recovr_sessions <- function(sources_folder, out_folder) {
  # extract all of the session folders from the sources folder
  folders <- list.files(sources_folder)
  session_ids <- folders[grepl("^s-[a-zA-Z0-9]{8}$", folders, perl = TRUE)]

  # recover the sources from each session
  results <- lapply(session_ids, function(session_id) {

    # recover the sources from this session
    recovred <- recovr_sources(file.path(sources_folder, session_id),
                               out_folder)

    if (nrow(recovred) > 0) {
      # we found sources in this folder; tag with the session ID
      cbind(data.frame(session = session_id), recovred)
    } else {
      # no sources here
      NULL
    }
  })

  # combine all the results into a single data frame
  do.call(rbind, results)
}
