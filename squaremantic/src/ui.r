ui <- function() {
  shinyUI(semanticPage(
    title = "Squaremantic",
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/sass.min.css"),
      tags$script(src = "js/main.js")
    ),
    shinyjs::useShinyjs(),
    sidebar_layout(
      sidebar_panel(
        width = 1,        
        vertical_layout(
          h1("squaremantic", style = "text-align: center;"),
          textInput("text_input", "Type your sentence:"),
          p("or", style="text-align: center;"),
          button("random", "Get Random One", icon("cube"), style = "margin: 0; width: 100%;"),
          checkbox_input("frame_visibility", "Show Frame"),
          multiple_radio(
            "text_transform",
            "Text Formatting",
            text_transforms,
            names(text_transforms),
            type = "toggle"
          ),
          sliderInput("font_size", "Set Font Size:", min = 0.2, max = 1, value = 1, step = 0.1),
          selectInput("letter_style", "Select Letters Style:", choices = text_styles),
          actionButton("print", "Save Image", icon("image"), style = "margin: 0; width: 100%;"),
          cell_args = "padding: 10px; width: 100%;"
        )
      ),
      main_panel(
        width = 4,
        uiOutput("letters", class = "letters"),
        class = "main"
      ),
      min_height = "100vh",
      mirrored = FALSE,
      container_style = "background-color: white; gap: 0;",
      area_styles = list(
        sidebar_panel = "
          border-radius: 0;
          box-shadow: none;
          padding: 15px;
        ",
        main_panel = "
          align-items: center;
          border: none;
          border-radius: 0;
          box-shadow: none;
          padding: 100px;
        "
      )
    )
  ))
}