import("shiny")

export("card")

card <- function(id, hex, ns) {
  card_revealed_id <- ns("card_revealed")

  div(
    id = id,
    class = "ui disabled fade reveal image",
    tags$img(
      src = "assets/blank_hex.png",
      class = "visible content",
      onclick = glue::glue(
        "$('#{id}').removeClass('disabled');
        $('#{id}').addClass('active');
        Shiny.setInputValue('{card_revealed_id}', ['{id}', '{hex}'], {{priority: 'event'}});")
    ),
    tags$img(src = glue::glue("assets/{hex}.png"), class = "hidden content")
  )
}
