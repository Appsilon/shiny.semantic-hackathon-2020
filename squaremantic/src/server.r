server <- function(input, output, session) {

  letters_border <- 1
  letters_padding <- 50
  
  letters_length <- reactive({ nchar(input$text_input) })
  
  letters_x_total <- reactive({
    ifelse(letters_length() == 0, 1, ceiling(sqrt(letters_length())))
  })

  text_letters <- reactive({ as.list(strsplit(input$text_input,'')[[1]]) })

  observeEvent(input$random, {
    updateTextInput(session, "text_input", value = sample(sentences, 1))
  })

  observeEvent(input$print, {
     create_modal(modal(
       id = "modal",
       header = h2("Unfortunately, this feature is not supported yet.."),
       ("Printing to PDF format functionality is still under development! Please, come back soon! In the meantime, we encourage you to visit our"),
       a("website", href="https://appsilon.com/", target = "_blank", rel = "noopener")
     ))
  })

  letter_gap <- reactive({ 1 / letters_x_total() * 30 + 10 })

  font_size <- reactive({
    input$wrapper_width / letters_x_total() * input$font_size
  })

  frame_visibility <- reactive({
    ifelse(input$frame_visibility, "#000", "transparent")
  })

  letter_size <- reactive({
    gaps <- (letters_x_total() - 1) * letter_gap()
    borders <- border_width() * 2
    paddings <- letters_padding * 2
    (input$wrapper_width - gaps - borders - paddings) / letters_x_total() # to improve
  })

  border_width <- reactive({ 1 / letters_x_total() * 5 + 5 })

  letter_styles <- reactive({
    list(
      "Basic" = "",
      "Solid" = "
        background-color: #000;
        color: #fff
      ",
      "Bordered" = glue::glue("
        border: {border_width()}px solid #000;
      ")
    )
  })
  
  output$letters <- renderUI({
    if (letters_length() > 0) {
      do.call(flow_layout, modifyList(text_letters(), list(
        cell_args = list(style = glue::glue("
          align-items: center;
          display: flex;
          color: #000;
          font-size: {font_size()}px;
          height: {letter_size()}px;
          justify-content: center;
          line-height: 1;
          text-transform: {input$text_transform};
          {letter_styles()[input$letter_style]}
        ")),
        column_gap = letter_gap(),
        row_gap = letter_gap(),
        cell_width = letter_size(),
        style = glue::glue("
          align-content: center;
          border: {border_width()}px solid {frame_visibility()};
          height: 100%;
          justify-content: center;
          padding: {letters_padding}px;
        ")
      )))
    } else {
      "Type in some sentence ..."
    }
  })
}
