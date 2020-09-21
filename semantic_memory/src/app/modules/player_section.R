import("shiny")
import("shiny.semantic")

export("ui")
export("init_server")

ui <- function(id, active = FALSE) {
  ns <- NS(id)
  class <- "ui raised segment"

  if (active) {
    class <- paste0(class, " active")
  }

  div(id = id, class = class,
    div(
      div(
        class = "ui teal ribbon label",
        textOutput(ns("name"), inline = TRUE),
        span(id = ns("edit_name"), shiny.semantic::icon("pen link"))
      ),
      h2("Score:"),
      h3(
        textOutput(ns("score"))
      )
    )
  )
}

init_server <- function(id, player) {
  callModule(server, id, player = player)
}

server <- function(input, output, session, player) {
  ns <- session$ns
  output$name <- renderText(paste0(player$name(), " "))

  output$score <- renderText(player$score())

  shinyjs::onclick(
    id = "edit_name",
    create_modal(
      modal(
        id = ns("name_modal"),
        class = "tiny",
        shiny.semantic::text_input(
          input_id = ns("change_name"),
          value = player$name()
        )
      )
    )
  )

  observeEvent(input$change_name, {
    player$change_name(input$change_name)
  })


}
