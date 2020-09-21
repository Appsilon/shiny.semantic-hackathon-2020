import("shiny")
import("shiny.semantic")
import("purrr")

export("ui")
export("init_server")

card <- use("logic/card.R")

ui <- function(id, size) {
  ns <- NS(id)

  ncol <- size[2]
  nrow <- size[1]

  available_hexes <- c(
    "shiny_semantic",
    "semantic_dashboard",
    "shiny_info",
    "shiny_i18n",
    "shiny_worker",
    "shiny_router",
    "dplyr",
    "purrr",
    "R6",
    "sass",
    "shiny",
    "Appsilon"
  )

  available_hexes <- sample(available_hexes, (ncol*nrow)/2)

  hexes <- sample(rep(available_hexes, times = 2), size = ncol*nrow)

  areas <- cross2(1:ncol, 1:nrow) %>% map(~paste0("card_", .x[[1]], "_", .x[[2]]))

  grid_template <- shiny.semantic::grid_template(
      default = list(
        areas = areas %>% matrix(ncol = ncol),
        cols_width = rep("200px", times = ncol),
        rows_height = rep("205px", times = nrow)
      )
    )

  cards <- purrr::map2(areas, hexes, ~card$card(ns(.x), .y, ns))
  args <- c(grid_template = list(grid_template), cards)
  args <- set_names(args, c("grid_template", areas))

  do.call(shiny.semantic::grid, args)
}

init_server <- function(id, reset) {
  callModule(server, id, reset = reset)
}

server <- function(input, output, session, reset) {
  first_card_hex <- reactiveVal(NULL)
  first_card_id <- reactiveVal(NULL)

  observeEvent(reset(), {
    first_card_hex(NULL)
    first_card_id(NULL)
  })

  observeEvent(input$card_revealed, {
    if (is.null(first_card_hex()) || first_card_id() == input$card_revealed[1]) {
      first_card_id(input$card_revealed[1])
      first_card_hex(input$card_revealed[2])
    } else {
      if (first_card_hex() == input$card_revealed[2]) {
        session$userData$players$give_point()
        Sys.sleep(1)
        shinyjs::runjs(
          glue::glue(
            "$('#{first_card_id()}').css('display', 'none');"
          )
        )
        shinyjs::runjs(
          glue::glue(
            "$('#{input$card_revealed[1]}').css('display', 'none');"
          )
        )
        if (sum(unlist(session$userData$players$get_scores())) == session$userData$board_size()[3]) {
          winner <- session$userData$players$get_winner()
          if (length(winner) == 1) {
            phrase <- glue::glue("The winner is {winner}!")
          } else {
            winner <- paste(unlist(winner), collapse = ", ")
            phrase <- glue::glue("Draw: {winner}")
          }
          create_modal(modal(
            id = "game_finished",
            header = h2("Game finished!"),
            h3(phrase)
          ))
        }
      } else {
        session$userData$players$next_player()
        Sys.sleep(1)
        shinyjs::runjs(
          glue::glue("$('.ui.fade.reveal.image').addClass('disabled');")
        )
        shinyjs::runjs(
          glue::glue("$('.ui.fade.reveal.image').removeClass('active');")
        )
      }
      first_card_hex(NULL)
      first_card_id(NULL)
    }
  })
}
