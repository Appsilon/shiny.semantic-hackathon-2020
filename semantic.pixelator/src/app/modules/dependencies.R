#' Generate css rules based on css variables for diferent generated grid elements.
#' Includes rules for changing the colors of semantic loaders, checkboxes, icons and placeholders.
#'
#' @return A UI style tag that can be passed to the [shinyUI] function.
#'
#' @family dependencies functions
#' @seealso [eggs(), appDependencies()]
cssCellRules <- function() {
  tags$style(
    paste(lapply(c(1:thumbnailSize), function(height) {
      paste(lapply(c(1:thumbnailSize), function(width) {
        glue::glue("
          #{paste0('pixel_', height, '_', width)}.ui.loader:after,
          #{paste0('pixel_', height, '_', width)}.ui.rating .active.icon {{
            color: var(--color-{height}-{width}) !important;
          }}
          #{paste0('pixel_', height, '_', width)}.ui.placeholder,
          input#{paste0('pixel_', height, '_', width)}~label:before{{
            background-color: var(--color-{height}-{width}) !important;
          }}
        ")
      }), collapse = "")
    }), collapse = "")
  )
}

#' Generates a list of options for easter eggs in the application, based of the www/assets/eggs folder.
#'
#' @return A UI script tag that can be passed to the [shinyUI] function.
#'
#' @family dependencies functions
#' @seealso [cssCellRules(), appDependencies()]
eggs <- function() {
  tags$script(
    paste(
      "let eggList = [",
        paste(lapply(list.files("www/assets/eggs"), function(egg) {
          glue::glue("{{code: '{strsplit(egg, '.', fixed = TRUE)[[1]][1]}', target: '{egg}'}}")
        }), collapse = ","),
      "]", collapse = "")
  )
}

#' Generates a tag list with all the custom app dependencies required for the application to work.
#'
#' @return A UI tagList that can be passed to the [shinyUI] function.
#'
#' @family dependencies functions
#' @seealso [cssCellRules(), eggs()]
appDependencies <- function() {
  tagList(
    tags$head(includeHTML(("www/google-analytics.html"))),
    tags$script(src = "scripts/ga-events.js"),
    tags$link(rel = "stylesheet", href = "css/sass.min.css"),
    tags$script(src = "scripts/dom-to-image.min.js"),
    tags$script(src = "scripts/filesaver.js"),
    tags$script(src = "scripts/downloader.js"),
    tags$script(src = "scripts/egg.js"),
    tags$script(src = "scripts/palette.js"),
    tags$script(src = "scripts/console.js"),
    tags$script(src = "scripts/responsive.js"),
    pwa("https://demo.appsilon.ai/apps/pixelator", title = "Semantic Pixelator", icon = "www/icon.png"),
    eggs(),
    cssCellRules()
  )
}
