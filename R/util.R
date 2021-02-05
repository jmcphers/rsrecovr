
rstudio_desktop_folder <- function() {
  # Check for folders specified by an environment variable.
  # This is not common but is a possibility for custom
  # installations of RStudio Server.
  rstudioDataHome <- Sys.getenv("RSTUDIO_DATA_HOME")
  if (nzchar(rstudioDataHome)){
    return(rstudioDataHome)
  }
  xdgDataHome <- Sys.getenv("XDG_DATA_HOME")
  if (nzchar(xdgDataHome)) {
    return(file.path(xdgDataHome, "rstudio"))
  }

  # Check for RStudio 1.4 folders
  v14_folder <- if (identical(.Platform$OS.type, "windows")) {
    file.path(Sys.getenv("LOCALAPPDATA"), "RStudio")
  } else {
    path.expand("~/.local/share/rstudio")
  }
  if (file.exists(v14_folder)) {
    return(v14_folder)
  }

  # Check for RStudio 1.3 and prior folders
  if (identical(.Platform$OS.type, "windows")) {
    file.path(Sys.getenv("LOCALAPPDATA"), "RStudio-Desktop")
  } else {
    path.expand("~/.rstudio-desktop")
  }
}
