#' A cell used by the generateGrid function. Generates a UI element based on the
#'  semantic placeholder element.
#'
#' @param height The height index of the cell
#' @param width The width index of the cell
#' @param ... Aditional arguments used by the semantic function
#' @return A UI tag that can be used by the generateGrid function.
#'
#' @family gridCell functions
#' @seealso [loaderCell(), ratingCell(), checkboxCell()]
pixelCell <- function(height, width, ...) {
  div(id = paste0('pixel_', height, '_', width), class = "ui placeholder")
}

#' A cell used by the generateGrid function. Generates a UI element based on the
#'  semantic loader element.
#'
#' @param height The height index of the cell
#' @param width The width index of the cell
#' @param ... Aditional arguments used by the semantic function
#' @return A UI tag that can be used by the generateGrid function.
#'
#' @family gridCell functions
#' @seealso [pixelCell(), ratingCell(), checkboxCell()]
loaderCell <- function(height, width, loader = double, ...) {
  div(id = paste0('pixel_', height, '_', width), class = glue::glue("ui mini active inline loader slow {loader}"))
}

#' A cell used by the generateGrid function. Generates a UI element based on the
#'  semantic rating element.
#'
#' @param height The height index of the cell
#' @param width The width index of the cell
#' @param icon The semantic icon to use for the input_rating function
#' @param ... Aditional arguments used by the semantic function
#' @return A UI tag that can be used by the generateGrid function.
#'
#' @family gridCell functions
#' @seealso [pixelCell(), loaderCell(), checkboxCell()]
ratingCell <- function(height, width, icon = "star", ...) {
  icon <- ifelse(icon == "random", sample(icons, 1), icon)
  rating_input(paste0('pixel_', height, '_', width), value = 1, max = 1, color = "black", icon = icon)
}

#' A cell used by the generateGrid function. Generates a UI element based on the
#'  semantic checkboxCell element.
#'
#' @param height The height index of the cell
#' @param width The width index of the cell
#' @param ... Aditional arguments used by the semantic function
#' @return A UI tag that can be used by the generateGrid function.
#'
#' @family gridCell functions
#' @seealso [pixelCell(), loaderCell(), ratingCell()]
checkboxCell <- function(height, width, ...) {
  checkbox_input(paste0('pixel_', height, '_', width), is_marked = FALSE)
}

#' Generates a grid of specified cell units and size
#'
#' @param cellCallback Callback that generates a single grid cell
#' @param size The width and height of the grid to generate
#' @param ... Aditional arguments used by the cell function
#' @return A UI tag that can be used in [shinyUI] functions.
generateGrid <- function(cellCallback, size, ...) {
  gridPanel(
    rows = glue("repeat({size}, 20px)"),
    columns = glue("repeat({size}, 20px)"),
    id = "pixelCellContainer",
    class = "cell-container",
    div(class = "ui placeholder overlay"),

    lapply(c(1:size), function(height) {
      tagList(
        lapply(c(1:size), function(width) {
          tagList(
            cellCallback(height, width, ...)
          )
        })
      )
    })
  )
}
