#' Mosaic page UI content
mosaic_page <- page(
  conf$mosaic$id,
  conf$mosaic$title, 
  div(
    style = "text-align: center;",
    action_button("confirm_settings", "Run mosaic generator!", style = "width: 40%;  margin-top: 10%;", class = "red massive"), 
    imageOutput("mosaied", width = "100%", height = "auto"),
    uiOutput("download_image")
  ), 
  list(id = conf$picture$id, title =  conf$picture$title, icon = "angle double left"),
  list(id = conf$home$id, title = "Try again!", icon = "undo", js = "setTimeout(location.reload.bind(location), 1);")
)

#' Mosaic page server callback
#' 
#' @param input Shiny app input object
#' @param output Shiny app output object
#' @param session Shiny app session object 
#' @param tiles_path Reactive value storing chosen tiles path. 
#'   Tiles path points to images set used for mosaic creation.
#' @param user_path User specific path. 
#'   Temporary directory created to store user data (created tiles, uploaded images).
mosaic_callback <- function(input, output, session, tiles_path, user_path) {
  trigger_save <- reactiveVal(NULL)
  trigger_download <- reactiveVal(NULL)
  
  file_path_jpg <- file.path(user_path, "cam.jpg")
  orig_file_out <- file.path(user_path, "final.jpg")
  
  observeEvent(input$confirm_settings, {
    toggle_class(session, "confirm_settings", "add", "disabled")
    with_progress({
      composeMosaicFromImageRandom(file_path_jpg, orig_file_out, tiles_path(), removeTiles=FALSE)  
    }, message = "Generating image. This can take ~ 30 seconds..", value = 0.3)
    trigger_save(runif(1))
  })
  
  output$mosaied <- renderImage({
    req(trigger_save())
    toggle_visibility(session, "confirm_settings", action = "hide")
    trigger_download(runif(1))
    list(src = orig_file_out)
  }, deleteFile = FALSE)
  
  output$download_image <- renderUI({
    req(trigger_download())
    toggle_class(session, nav_bttn_id(conf$mosaic$id, conf$home$id), "remove", "disabled")
    tags$a(
      id = "download_img", "Download image", style = "width: 40%;", download = NA, target = "_blank", href = "",
      class = "ui red massive button shiny-download-link", icon("download")
    )
  })
  
  output$download_img <- downloadHandler(
    filename = "mosaic.jpg",
    contentType = "image/jpeg",
    content = function(file) {
      file.copy(orig_file_out, file)
    }
  )
  
}
