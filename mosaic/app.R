library(shiny)
library(shiny.semantic)
library(shiny.router)
library(httr)
library(magrittr)
library(imager)
library(RsimMosaic)

options(scipen = 999) 
source("modules/utils.R")
source("modules/home.R")
source("modules/picture.R")
source("modules/tiles.R")
source("modules/mosaic.R")

router <- make_router(
  route("home", hello_page),
  route("tiles", tiles_page, tiles_callback),
  route("picture", picture_page, picture_callback),
  route("mosaic", mosaic_page, mosaic_callback)
)

ui <- semanticPage(
  tags$head(
    tags$link(rel = "stylesheet", href = "style.css"),
    tags$script(glue::glue("var consts = {jsonlite::toJSON(conf, auto_unbox = TRUE)}")),
    tags$script(src = "app.js")
  ),
  router$ui,
  margin = 0
)

server <- function(input, output, session) {
  tiles_path <- reactiveVal(NULL)
  user_path <- generate_user_path()
  dir.create(user_path, recursive = TRUE)
  
  router$server(input, output, session, tiles_path = tiles_path, user_path = user_path)
  
  onStop(function() {
    unlink(user_path, recursive = TRUE)
  })
}

shinyApp(ui, server)
  