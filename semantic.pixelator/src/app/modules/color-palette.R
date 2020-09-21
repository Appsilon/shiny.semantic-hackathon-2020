#' creates a set of css variables that represent a color palette extracted from the given image
#'   These variables can be used to color UI elements that use these css variables.
#'
#' @param image The image to extract colors from
#' @param numbercolors The number of colors to generate.
#' @return A fragment of css valid code that can be added to a css style string.
paletteValues <- function(image, numberColors) {
  paste0(lapply(c(1:numberColors), function(index) {
      color <- color.at(image, sample(width(image), 1), sample(height(image), 1))

      if(length(color) == 1) {
        redValue <- color[1]
        greenValue <- color[1]
        blueValue <- color[1]
      } else {
        redValue <- color[1]
        greenValue <- color[2]
        blueValue <- color[3]
      }

      glue("--palette-{index}: rgb({redValue * 256}, {greenValue * 256}, {blueValue * 256});")
  }), collapse = "")
}

#' Generates a UI element with a background color bound to a specific css variable.
#'   The generated UI will also contain a container to add text, usually updated using javascript.
#'
#' @param index The bound index for the element. The background color will be bound to a named
#'   css variable based on this number.
#' @return A UI tag that can be used in [shinyUI] functions.
paletteCell <- function(index) {
  div(
    id = glue("paletteColor{index}"),
    class = "palette-cell",
    `data-index` = index,
    style = glue("background-color: var(--palette-{index})"),
    div(class = "value")
  )
}
