conf <- config::get(file = "config.yml")

#' Create divider class div
#' 
#' @param ... Div content.
#' @param class Additional class added to element.
divider <- function(..., class = "") {
  div(class = glue::glue("ui {class} divider"), ...)
}

#' Create column class div
#' 
#' @param ... Div content.
#' @param class Additional class added to element.
column <- function(..., class = "") {
  div(class = glue::glue("{class} column"), ...)
}

#' Create row class div
#' 
#' @param ... Div content.
#' @param class Additional class added to element.
row <- function(..., class = "") {
  div(class = glue::glue("{class} row"), ...)
}

#' Standard page grid template
standard_page_grid <- grid_template(default = list(
  areas = rbind(
    c("title", "title",   "title"),
    c("content", "content", "content"),
    c("prev_page",   "blankc",  "next_page")
  ),
  rows_height = c("10%", "70%", "20%"),
  cols_width = c("30%", "auto", "30%")
))

#' Create link button
#' 
#' @param input_id Button id. Button value accessible at \code{input[[input_id]]}.
#' @param label Button label.
#' @param icon Icon displayed in button.
#' @param class Additional class added to element.
#' @param ... Other elements passed to button object.
click_button <- function(input_id, label, icon = NULL, class = "", ...) {
  tags$a(id = input_id, class = glue::glue("ui {class} button"), 
         icon, " ", label, ...)
}

#' Define standard page UI content
#' 
#' @param id Page id.
#' @param title Page title.
#' @param content Page content.
#' @param prev_page Definition of previous page button.
#' @param next_page Definition of next page button.
#' 
#' @details 
#' \code{prev_page} or \code{next_page} should be list containing:
#' \itemize{
#'   \item id Id of next/prev page
#'   \item title Title of next/prev page (diplayed in the navigation button)
#'   \item icon Icon diplayed in the navigation button
#'   \item js Onclick js code related to the navigation button
#' }
page <- function(id, title, content, prev_page, next_page) {
  if (!is.null(prev_page)) {
    prev_page <-  click_button(
      nav_bttn_id(id, prev_page$id), prev_page$title, class = "orange left labeled icon massive", 
      icon = icon(prev_page$icon), href = route_link(prev_page$id), style = "font-size: 2.5rem;")
  }
  if (!is.null(next_page)) {
    next_page = click_button(
      nav_bttn_id(id, next_page$id), next_page$title, class = "orange right labeled icon massive disabled",
      icon = icon(next_page$icon), href = route_link(next_page$id), style = "font-size: 2.5rem;", onclick = next_page$js)
  }
  
  div(
    grid(
      standard_page_grid,
      container_style = "padding: 5%;",
      blankc = div(""),
      title = div(class = "ui center aligned basic segment", div(class = "ui header", style = "font-size: 4em;", title)),
      content = div(content),
      prev_page = prev_page,
      next_page = next_page
    ) 
  )
}

#' Generate ID of navigation button
#' 
#' @param current_id Current Page ID
#' @param navigation_id target page ID
nav_bttn_id <- function(current_id, navigation_id) {
  glue::glue("{current_id}-{navigation_id}")
}

#' Add or remove element class
#' 
#' @param id ID of element (without \code{#}).
#' @param action 'add' or 'remove'
#' @param class  Which class to add/remove
toggle_class <- function(session, id, action, class) {
  session$sendCustomMessage("toggle-class", list(id = id, action = action, eclass = class))
}

#' Add or remove element class
#' 
#' @param id ID of element (without \code{#}).
#' @param action 'hide' or 'show'
toggle_visibility <- function(session, id, action) {
  session$sendCustomMessage("toggle-view", list(id = id, action = action))
}

#' Clear checkboxes selection
#' 
#' @param id ID of checkbox's parent element (without \code{#}).
clear_checkbox <- function(session, id) {
  session$sendCustomMessage("clear-checkbox", list(id = id))
}

#' Generate temporary user path
#' 
#' Sys.time based to make sure each session created different path.
generate_user_path <- function() {
  as.character(glue::glue("{tempdir()}{round(1000*as.numeric(Sys.time()))}"))
}
