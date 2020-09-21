import("shiny")
import("shiny.semantic")

export("ui")
export("init_server")

ui <- function(id) {
  ns <- NS(id)

  div(
    class = "ui raised segment",
    h2("Game settings"),
    h3("Board size:"),
    shiny.semantic::dropdown_input(
      input_id = ns("board_size"),
      choices = c("2x3", "3x4", "3x6", "4x6"),
      value = "4x6"
    )
  )
}

init_server <- function(id) {
  callModule(server, id)
}

server <- function(input, output, session) {
  session$userData$board_size <- reactiveVal()

  observeEvent(input$board_size, {
    board_size <- switch(
      input$board_size,
      "2x3" = c(2, 3, 3),
      "3x4" = c(3, 4, 6),
      "3x6" = c(3, 6, 9),
      "4x6" = c(4, 6, 12)
    )
    session$userData$board_size(board_size)
  })
}
