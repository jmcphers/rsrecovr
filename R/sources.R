
# Recover a single source file. Returns the path to the recovered file, or NA
# if file recovery did not take place.
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

  # recover content
  contents_file <- file.path(folder, paste0(id, "-contents"))
  contents <- if (file.exists(contents_file) && file.info(contents_file)$size > 0) {
    # newer RStudio versions keep the contents alongside the metadata
    readLines(con = contents_file)
  } else if (!is.null(metadata$contents) && nchar(metadata$contents) > 0) {
    # older versions use the "contents" value in the JSON metadata
    metadata$contents
  } else {
    "No contents found"
  }

  # put it in saved/unsaved depending on whether or not the file is dirty
  out_folder <- file.path(out_folder, if (isTRUE(metadata$dirty)) {
    # explicitly marked dirty; we know it's unsaved
    "unsaved"
  } else {
    # the dirty flag when unset doesn't reliably tell us if the contents differ
    # from disk since they could have changed; compare contents here.
    if (is.null(metadata$path)) {
      # no file on disk to compare this to, so consider it to be saved
      # (this is probably not a file buffer at all)
      "saved"
    } else {
      if (file.exists(metadata$path)) {
        old_contents <- readLines(metadata$path)
        if (identical(contents, old_contents)) {
          # the file's contents are the same as the contents on disk
          "saved"
        } else {
          # the file in the source database is not the same; consider it
          # unsaved
          "unsaved"
        }
      } else {
        # the file exists in the source database but not on disk, which should
        # be considered unsaved
        "unsaved"
      }
    }
  })

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

  # save the contents to the file
  writeLines(contents, con = target)

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

