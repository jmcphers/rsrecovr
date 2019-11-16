
# Recover a single source file. Returns the path to the
recovr_source_file <- function(folder, id, out_folder) {
  metadata <- jsonlite::fromJSON(file.path(folder, id))

  # recover filename
  filename <- if (is.null(metadata$path)) {
    if (is.null(metadata$properties) ||
        is.null(metadata$properties$tempName))
    {
      if (identical(metadata$type, "r_dataframe")) {
        # data viewer object; no filename
        paste0("Data", "-", id)
      } else {
        # no way to infer a name, bail out and use the raw ID
        id
      }
    } else {
      # use the temporary name; e.g. "Untitled1"
      metadata$properties$tempName
    }
  } else {
    # we have a real path; use the base filename
    basename(metadata$path)
  }

  # ascertain target
  target <- file.path(out_folder, filename)

  # ensure target doesn't exist already; could happen if e.g. user had two
  # different foo.R files open in two different directories. in this case,
  # make the filename unique: foo-0123456.R
  if (file.exists(target)) {
    target <- file.path(out_folder, paste0(
      tools::file_path_sans_ext(filename),
        "-",
        id, ".", tools::file_ext(filename)))
  }

  # recover content
  contents_file <- file.path(folder, paste0(id, "-contents"))
  if (file.exists(contents_file)) {
    # newer RStudio versions keep the contents alongside the metadata
    file.copy(from = contents_file, to = target)
  } else if (!is.null(metadata$contents) && nchar(metadata$contents) > 0) {
    # older versions use the "contents" value in the JSON metadata
    writeLines(metadata$contents, con = target)
  } else {
    return(NA)
  }

  # return the file we created
  target
}

recovr_sources <- function(folder, out_folder) {
  # list all the files in the sources folder
  files <- list.files(folder)

  # narrow to those that look like IDs
  ids <- files[grepl("^[a-zA-Z0-9]{8}$", files, perl = TRUE)]

  # attempt to recover each id/file
  recovred <- vapply(ids, function(id) {
    recovr_source_file(folder, id, out_folder)
  }, "")

  # return data frame with results
  data.frame(
    filename = basename(recovred),
    id = ids,
    origin = file.path(folder, ids),
    restored = recovred
  )
}
