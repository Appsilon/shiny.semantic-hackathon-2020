import("R6")
import("shiny")
import("magrittr")

export("Players")

Player <- R6::R6Class(
    "Player",
    public = list(
      name = "string",
      id = "string",
      score = "int",
      initialize = function(name) {
        self$name <- reactiveVal(name)
        self$score <- reactiveVal(0)
        self$id <- name
      },
      give_point = function() {
        self$score(self$score() + 1)
      },
      change_name = function(new_name) {
        self$name(new_name)
      },
      reset_score = function() {
        self$score(0)
      }
    )
  )

Players <- R6::R6Class(
  "Players",
  public = list(
    players = "list",
    active_player = "reactiveVal",
    initialize = function() {
      self$players <- list(
        Player_1 = Player$new("Player_1"),
        Player_2 = Player$new("Player_2")
      )
      self$active_player <- reactiveVal(1)
    },
    add_player = function() {
    },
    give_point = function() {
      self$players[[self$active_player()]]$give_point()
    },
    remove_player = function() {
    },
    next_player = function() {
      if (length(self$players) > self$active_player()) {
        self$active_player(self$active_player() + 1)
      } else {
        self$active_player(1)
      }
    },
    get_scores = function() {
      scores <- purrr::map(self$players, ~.x$score())
      names <- purrr::map(self$players, ~.x$name())

      stats::setNames(scores, names)
    },
    get_winner = function() {
      winning_score <- max(unlist(self$get_scores()))
      self$get_scores() %>%
        purrr::keep(function(x) x == winning_score) %>%
        names()
    },
    reset_scores = function() {
      purrr::walk(self$players, ~.x$reset_score())
    }
  )
)
