function(input, output, session) {
  session$userData$players <- players$Players$new()
  game_settings$init_server("game_settings")

  active_player <- c("TRUE", "FALSE")

  output$players_section <- renderUI(
    purrr::map2(session$userData$players$players, active_player, ~player_section$ui(.x$id, .y))
  )

  purrr::walk(session$userData$players$players, ~player_section$init_server(.x$id, .x))

  observeEvent(session$userData$players$active_player(), {
    shinyjs::runjs("$('#players_section .ui.raised.segment').removeClass('active');")
    shinyjs::runjs(glue::glue("$('#Player_{session$userData$players$active_player()}').addClass('active');"))
  }, ignoreInit = TRUE)

  reset <- reactive(input$reset)


  board$init_server("board", reset)
  output$board <- renderUI(
    div(
      class = "board",
      board$ui("board", size = session$userData$board_size()),
      button("reset", "", icon = icon("sync")))
  )

  observeEvent(c(input$reset, session$userData$board_size()), {
    session$userData$players$reset_scores()
    output$board <- renderUI(
      div(class = "board", board$ui("board", size = session$userData$board_size()),
      button("reset", "", icon = icon("sync")))
    )
  }, ignoreInit = TRUE)
}
