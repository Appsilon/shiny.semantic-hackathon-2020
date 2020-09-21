#' Tiles page UI content
tiles_page <- page(
  conf$tiles$id,
  conf$tiles$title,
  tagList(
    segment(
      class = "placeholder",
      div(
        class = "ui two column stackable center aligned grid",
        divider("OR", class = "vertical"),
        row(
          class = "middle aligned", 
          column(
            div(class = "ui icon header", icon("mouse pointer"), span(class = "ui large text", "Select ready set")),
            div(
              class = "ui massive form",
              multiple_radio(
                "set", NULL, 
                choices = c("dogs", "cats", "flowers"), position = "inline",
                selected = NULL
              )
            )
          ),
          column(
            div(class = "ui icon header", icon("world"), span(class = "ui large text", "Create your own")),
            div(
              class = "field",
              uiinput(
                `data-tooltip` = "Images sourced from https://api.creativecommons.engineering/v1 API",
                class = "big right labeled left icon", icon("tags"), 
                text_input(input_id = "tags", placeholder = "Enter tag"), 
                button("confirm_tag", "Confirm tag", class = "tag label")
              )
            )
          )
        )
      )
    ),
    uiOutput("progress_message")
  ),
  list(id = conf$home$id, title = conf$home$alt, icon = "angle double left"),
  list(id = conf$picture$id, title =  conf$picture$title, icon = "angle double right")
)

#' Tiles page server callback
#' 
#' @param input Shiny app input object
#' @param output Shiny app output object
#' @param session Shiny app session object 
#' @param tiles_path Reactive value storing chosen tiles path. 
#'   Tiles path points to images set used for mosaic creation.
#' @param user_path User specific path. 
#'   Temporary directory created to store user data (created tiles, uploaded images).
tiles_callback <- function(input, output, session, tiles_path, user_path) {
  
  observeEvent(input$confirm_tag, {
    req(input$confirm_tag)
    req(gsub("[a-z]", "", input$tags) == "") # only lowercase words allowed
    
    toggle_class(session, nav_bttn_id(conf$tiles$id, conf$picture$id), "add", "disabled")
    tiles_path(file.path(user_path, "tiles", input$tags))
    
    output$progress_message <- renderUI({
      with_progress({
        prepare_tiles(isolate(input$tags), user_path, session)
        chosen_tiles_message(isolate(input$tags))
      }, value = 0, message = "Starting creating tiles")
    })
    
    clear_checkbox(session, "set")
  }, ignoreNULL = TRUE)
  
  observeEvent(input$set, {
    req(input$set)
    
    tiles_path(file.path("tiles", input$set))
    
    output$progress_message <- renderUI({
      chosen_tiles_message(isolate(input$set))
    })
    
    toggle_class(session, nav_bttn_id(conf$tiles$id, conf$picture$id), "remove", "disabled")
  }, ignoreNULL = TRUE)
  
}

#' Generate selected tiles message
#' 
#' @param tile_id Id of selected tiles.
chosen_tiles_message <- function(tile_id) {
  div(
    class = "ui massive floating message", 
    sprintf("Selected collection: %s", tile_id), 
    style = "text-align: center;"
  )
}

#' Single tile size
tile_size <- c(20, 20)

#' Images source API
#' 
#' Currently used api.creativecommons.engineering/v1
#' 
#' @param tile_tag Images collection name (tag)
#' @param size Upper limit of downloaded images. 500 maximum and default.
img_source_api <- function(tile_tag, size = 500) {
  if (size > 500) {
    warning("size can be 500 maximum. Decreasing to 500..")
    size <- 500
  }
  glue::glue(
    "https://api.creativecommons.engineering/v1/images/?q={tile_tag}&type=jpg&size=small&page_size={size}&page=1"
  )
}

#' Prepare tiles set
#' 
#' Based on selected tag, downloads images using API to user temporary path.
#' The images are resized and used later as a mosaic image collection.
#' 
#' @param tiles_tag Tag based on which tiles should be created
#' @param user_path Temporary user path in which tiles are created
#' @param session Shiny App session object
prepare_tiles <- function(tiles_tag, user_path, session) {
  
  temp_images_location <- file.path(user_path, "tile", tiles_tag)
  unlink(temp_images_location, recursive = TRUE)
  dir.create(temp_images_location, recursive = TRUE)
  target_images_location <- file.path(user_path, "tiles", tiles_tag)
  unlink(target_images_location, recursive = TRUE)
  dir.create(target_images_location, recursive = TRUE)
  
  set_progress(value = 0.1, message = "Downloading data..", session = session)
  
  api_response <- httr::GET(img_source_api(tiles_tag))
  if (api_response$status != 200) {
    session$sendCustomMessage("app-alert", list(value = "Temporary failure with sourcing the data. Please try again later."))
    req(api_response$status == 200)
  }
  images_meta <- content(api_response)$results
  image_urls <- images_meta %>% purrr::map_chr("url") %>% unique()
  
  tryCatch({
    download.file(image_urls, destfile = file.path(temp_images_location, basename(image_urls)), method = "libcurl", quiet = TRUE)
  },
  error = function(e) {
    session$sendCustomMessage("app-alert", list(value = e$message))
    req(FALSE)
  })
  
  set_progress(value = "0.5", message = "Resizing images..", session = session)
  
  for (img in list.files(temp_images_location, pattern = "jpg")) {
    im <- load.image(file = file.path(temp_images_location, img))
    if (dim(im)[4] != 3) { # real jpg only
      next
    }
    thmb <- resize(im, tile_size[1], tile_size[2])
    imager::save.image(thmb, file = file.path(target_images_location, img))
  }
  
  unlink(temp_images_location, recursive = TRUE)
  set_progress(value = 0.8, message = "Saving images..", session = session)
  
  toggle_class(session, nav_bttn_id(conf$tiles$id, conf$picture$id), "remove", "disabled")
}
