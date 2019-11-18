
rstudio_desktop_folder <- function() {
  if (identical(.Platform$OS.type, "windows")) {
    file.path(Sys.getenv("LOCALAPPDATA"), "RStudio-Desktop")
  } else {
    path.expand("~/.rstudio-desktop")
  }
}
