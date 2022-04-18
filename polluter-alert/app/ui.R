semanticPage(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css"),
  ),
  uiOutput("welcomeModal"),
  grid(
    grid_template = grid_template(
      default = list(
        areas = rbind(
          c("title", "map"),
          c("info", "map"),
          c("user", "map")
        ),
        cols_width = c("400px", "1fr"),
        rows_height = c("50px", "auto", "200px")
      ),
      mobile = list(
        areas = rbind(
          "title",
          "map",
          "info",
          "user"
        ),
        rows_height = c("70px", "400px", "auto", "200px"),
        cols_width = c("100%")
      )
    ),
    area_styles = list(title = "margin: 20px;", info = "margin: 20px;", user = "margin: 20px;"),
    title = h2(class = "ui header", icon("industry"), div(class = "content", "Polluter Alert")),
    info = uiOutput("sidebar"),
    user = card(
      style = "border-radius: 0; width: 100%; background: #efefef",
      div(class = "content", 
          div(class = "header", style = "margin-bottom: 10px", 
              tags$img(src = "images/elliot.jpg", 
                       class = "ui avatar image"), 
              "Paweł Przytuła ", 
              span(style = "color: #0099f9; font-size: 13px;", 
                   icon("twitter"), 
                   tags$a(href = "https://twitter.com/pawel_appsilon", style = "text-decoration: underline", "@pawel_appsilon"))),
          div(class = "meta", span(style = "color: #ffb266", icon("star")), "42 polluters found"),
          div(class = "meta", span(style = "color: #66cc00", icon("trophy")), "10. place (out of 538 spotters)"),
          div(class = "description", style = "margin-top: 10px", 
              div(id = "add-polluter-modal-button", class = "ui huge red button", style = "width: 100%", 
                  span(style = "margin-right: 10px", icon("camera")), "Add new polluter")),
          modal(
            grid(
              grid_template = grid_template(
                default = list(
                  areas = rbind(
                    c("photo", "coordinates"),
                    c("photo", "comment"),
                    c("photo", "info")
                  ),
                  cols_width = c("50%", "50%"),
                  rows_height = c("300px", "150px", "100px")
                ),
                mobile = list(
                  areas = rbind(
                    c("photo"),
                    c("coordinates"),
                    c("comment"),
                    c("info")
                  ),
                  cols_width = c("100%"),
                  rows_height = c("300px", "300px", "150px", "100px")
                )
              ),
              container_style = "grid-gap: 20px",
              area_styles = list(
                info = "align-self: end"
              ),
              photo = div(class = "ui raised segment", style = "height: 100%",
                          a(class="ui green ribbon label", "Photo"), 
                          uiOutput("shinyviewr")
              ),
              coordinates = div(class = "ui raised segment", style = "height: 100%",
                a(class="ui green ribbon label", "Location", style = "margin-bottom: 10px"),
                leafletOutput("selection_map", height = 200)
              ),
              comment = div(class = "ui raised segment", style = "height: 100%",
                a(class="ui green ribbon label", "Optional comment", style = "margin-bottom: 10px"), 
                textAreaInput("comment", "", width = "450px")
              ),
              info = message_box(class = "info", header = "Info", 
                                 content = "This functionality is mocked. Click OK to close the modal.")
            ),
            header = "Add new polluter",
            class = "basic large",
            id = "add-polluter-modal",
            target = "add-polluter-modal-button",
            settings = list(c("closable", "true"))
          )
      )
    ),
    map = leafletOutput("polluters_map")
  )
)
