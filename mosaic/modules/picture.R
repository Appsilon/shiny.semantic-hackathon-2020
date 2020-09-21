#' Semantic file input
#' 
#' Simple hack using shiny::fileInput, due to lack of such component in fomantic library
#' 
#' @param input_id File input id
#' @param label File input button label
file_input <- function(input_id, label) {
  hidden_file_input <- fileInput(input_id, NULL, accept = c(".jpg", ".jpeg", ".png"))
  hidden_file_input$attribs$style <- "display:none;"
  
  file_input_button <- tags$button(
    class = "ui button", onclick = glue::glue("$('#{input_id}').click()"), 
    style = "width: 100%; max-width: 100%;", icon("upload"), label
  )
  
  tagList(
    hidden_file_input,
    file_input_button
  )
}

#' Picture page UI content
picture_page <- page(
  conf$picture$id,
  conf$picture$title,
  segment(
    class = "placeholder",
    div(
      class = "ui two column stackable center aligned grid",
      divider(class = "vertical"),
      row(
        class = "middle aligned", 
        column(
          file_input("image_upload", "Upload your image"),
          divider(class = "horizontal", "OR"),
          actionButton("take_photo", "Use webcam", icon = icon("video"), style = "width: 100%; max-width: 100%;")
        ),
        column(
          div(id = conf$picture$view_ids$image_message, class = "center aligned", "Select one of two options to choose your photo"),
          htmltools::htmlTemplate(filename = "modules/pic_input_template.html", view_ids = conf$picture$view_ids)
        )
      )
    )
  ),
  list(id = conf$tiles$id, title = conf$tiles$title, icon = "angle double left"),
  list(id = conf$mosaic$id, title =  conf$mosaic$title, icon = "angle double right")
)

#' Picture page server callback
#' 
#' @param input Shiny app input object
#' @param output Shiny app output object
#' @param session Shiny app session object 
#' @param user_path User specific path. 
#'   Temporary directory created to store user data (created tiles, uploaded images).
picture_callback <- function(input, output, session, user_path) {
  trigger <- reactiveVal(NULL)
  
  file_path_jpg <- file.path(user_path, "cam.jpg")
  file_path_png <- file.path(user_path, "cam.png")

  observeEvent(input$take_photo, {
    take_photo(session)
  })
  
  observeEvent(input$data_url, {
    base64_to_jpg(input$data_url, file_path_png, file_path_jpg)
    toggle_class(session, nav_bttn_id(conf$picture$id, conf$mosaic$id), "remove", "disabled")
  })
  
  observeEvent(input$image_upload, {
    show_upload(session)
    uploaded_to_jpg(input$image_upload$datapath, file_path_jpg)
    toggle_class(session, nav_bttn_id(conf$picture$id, conf$mosaic$id), "remove", "disabled")
    trigger(input$image_upload)
  })
  
  output[[conf$picture$view_ids$upload_image_output]] <- renderImage({
    req(trigger())
    list(src = file_path_jpg)
  }, deleteFile = FALSE)
  outputOptions(output, conf$picture$view_ids$upload_image_output, suspendWhenHidden = FALSE)
  
  output[[conf$picture$view_ids$upload_image_path]] <- renderText({
    req(trigger())
    trigger()$name
  })
  outputOptions(output, conf$picture$view_ids$upload_image_path, suspendWhenHidden = FALSE)
  
}

#' Send browser message to run webcam
take_photo <- function(session) {
  session$sendCustomMessage("take-photo", list(value = "run"))
}

#' Show uploaded file content
show_upload <- function(session) {
  session$sendCustomMessage("show-upload", list(value = "run"))
}

#' Save base64 string as jpg
#' 
#' @param base64string Base64 string
#' @param png_file_path Temporary path where base64 png form is stored
#' @param jpg_file_path Target jpg file path
#' @param output_width Width of target image
base64_to_jpg <- function(base64string, png_file_path, jpg_file_path, output_width = 200) {
  sent_image <- base64string %>% 
    gsub("data:image/png;base64,", "", ., fixed = TRUE) %>% 
    gsub(" ", "+", ., fixed = TRUE)
  outconn <- file(png_file_path, "wb", blocking = FALSE)
  base64enc::base64decode(what=sent_image, output=outconn)
  close(outconn)
  im <- load.image(png_file_path)
  output_height <- floor(output_width / dim(im)[1] * dim(im)[2])
  im_input <- resize(im, output_width, output_height)
  imager::save.image(im_input, file = jpg_file_path)
}

#' Save uploaded image to jpg
#' 
#' @param file Uploaded file path
#' @param jpg_file_path Target jpg file path
#' @param output_width Width of target image
uploaded_to_jpg <- function(file, jpg_file_path, output_width = 200) {
  im <- load.image(file)
  output_height <- floor(output_width / dim(im)[1] * dim(im)[2])
  im_input <- resize(im, output_width, output_height)
  imager::save.image(im_input, file = jpg_file_path)
}
