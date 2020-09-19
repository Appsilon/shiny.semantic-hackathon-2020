server <- function(input, output, session) {
  
  warsaw <- list(lon = 21.0122, lat = 52.2297)
  
  airly_api_url <- glue("https://airapi.airly.eu/v2/measurements/point?lat={warsaw$lat}&lng={warsaw$lon}")
  r <- GET(airly_api_url, add_headers(Accept = "application/json", apikey = consts$airly_api_key))
  
  # Optimistic response parsing (hackathon mode)
  airly_data <- content(r)
  
  air_status <- airly_data$current$indexes[[1]]$description
  pm25_perc <- airly_data$current$standards[[1]]$percent %>% round
  pm10_perc <- airly_data$current$standards[[2]]$percent %>% round
  
  pollution_history <- data.frame(pollutant = c(), measurement = c(), time = c())

  for (i in 1:length(airly_data$history)) {
    data <- airly_data$history[[i]]
    date <- anytime(data$fromDateTime)
    x_date <- glue("{day(date)} ({hour(date)}:00)")
    new_slice <- data.frame(
      pollutant = c(data$values[[2]]$name, data$values[[3]]$name), 
      measurement = c(data$values[[2]]$value, data$values[[3]]$value), 
      time = c(x_date, x_date)
    )
    pollution_history <- rbind(pollution_history, new_slice)
  }
  
  selected_point <- reactiveValues(id = NULL)

  output$welcomeModal <- renderUI({
    create_modal(modal(
      id = "simple-modal",
      title = "Important message",
      header = h2(class = "ui header", icon("industry"), div(class = "content", "Polluter Alert")),
      content = grid(
        grid_template = grid_template(default = list(
          areas = rbind(c("photo", "text")),
          cols_width = c("50%", "50%")
        )),
        container_style = "grid-gap: 20px",
        area_styles = list(text = "padding-right: 20px"),
        photo = tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Warszawski_smog_%2822798350941%29.jpg/800px-Warszawski_smog_%2822798350941%29.jpg", style = "width: 100%", alt = "Source: Radek Kołakowski from Warsaw, Poland, Creative Commons / https://commons.wikimedia.org/wiki/File:Warszawski_smog_(22798350941).jpg"),
        text = HTML(
          sprintf(
            intro,
            tags$a(href = "https://polskialarmsmogowy.pl/polski-alarm-smogowy/smog/szczegoly,skad-sie-bierze-smog,18.html", "heating stoves and boilers"),
            tags$a(href = "https://play.google.com/store/apps/details?id=pl.tajchert.canary&hl=en", "KanarekApp"),
            tags$a(href = "https://github.com/Appsilon/shiny.semantic", "shiny.semantic"),
            tags$a(href = "https://developer.airly.eu/", "Airly API")
          )
        )
      )
    ))
  })
  
  output$time <- renderText({
    paste("Measurements time:", anytime(airly_data$current$fromDateTime))
    #paste("Measurements time:", anytime("2020-09-12T09:56:50.962Z"))
  })
  
  output$polluters_map <- renderLeaflet({
    points_n <- 100
    
    smokeIcon <- makeIcon(
      iconUrl = "images/smoke.gif",
      iconWidth = 60, iconHeight = 60,
      iconAnchorX = 22, iconAnchorY = 94
    )
    
    random_points <- list(
      longitudes = warsaw$lon + rnorm(points_n, sd = 0.1),
      latitudes = warsaw$lat + rnorm(points_n, sd = 0.1)
    )
    
    leaflet() %>% addTiles() %>%
      addMapboxGL(style = "mapbox://styles/mapbox/streets-v9") %>%
      setView(lng = warsaw$lon, lat = warsaw$lat, zoom = 12) %>%
      addEasyButton(easyButton(
        icon="fa-globe", title="Zoom to Level 1",
        onClick=JS("function(btn, map){ map.setZoom(1); }"))) %>%
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="Locate Me",
        onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
      addMarkers(
        data = cbind(random_points$longitudes, random_points$latitudes), 
        layerId = 1:points_n, # marker unique ID numbers
        icon = smokeIcon
      )
  })
  
  observe({
    click <- input$polluters_map_marker_click
    if (is.null(click)) return() # Unwanted event during map initialization
    selected_point$id <- click$id
    print(paste("Selected point", selected_point$id))
    
    circleIcon <- makeIcon(
      iconUrl = "images/red-loading-circle.gif",
      iconWidth = 30, iconHeight = 30,
      iconAnchorX = 7, iconAnchorY = 50
    )
    
    leafletProxy("polluters_map") %>% 
      removeMarker(layerId = "selected") %>%
      addMarkers(
        data = cbind(c(click$lng), c(click$lat)), 
        layerId = "selected",
        icon = circleIcon
      )
  })
  
  output$pollution_stats <- renderUI({
    grid(
      grid_template = grid_template(default = list(
        areas = rbind(
          c("status", "status"),
          c("gauge1", "gauge2"),
          c("plot", "plot")
        ),
        cols_width = c("50%", "50%"),
        rows_height = c("80px", "160px", "auto")
      )),
      area_styles = list(gauge1 = "padding-right: 5px", gauge2 = "padding-left: 5px"),
      status = div(class = "ui message success",
                   #div(class = "header", "Great air here today!"), 
                   div(class = "header", air_status), 
                   textOutput("time")),
      gauge1 = card(
        style = "border-radius: 0; width: 100%; height: 150px; background: #efefef",
        div(class = "content",
            div(class = "header", style = "margin-bottom: 10px", "PM 2.5μm"),
            div(class = "description", highchartOutput("gaugePM25"))
        )
      ),
      gauge2 = card(
        style = "border-radius: 0; width: 100%; height: 150px; background: #efefef",
        div(class = "content",
            div(class = "header", style = "margin-bottom: 10px", "PM 10μm"),
            div(class = "description", highchartOutput("gaugePM10"))
        )
      ),
      plot = card(
        style = "border-radius: 0; width: 100%; background: #efefef",
        div(class = "content",
            div(class = "header", style = "margin-bottom: 10px", "Pollution over time"),
            div(class = "meta", "Measurements from last 24h"),
            div(class = "description", style = "margin-top: 10px", highchartOutput("pollution", height = "200px"))
        )
      )
    )
  })
  
  output$polluter_info <- renderUI({
    id <- selected_point$id
    mock_photos_n <- 11
    mock_comments_n <- sample(1:3, 1)
    mock_alerts_n <- sample(1:50, 1)
    
    comment_row <- function(comment) {
      div(class = "extra content", 
        div(class = "ui large transparent left icon input", icon("user"), 
            div(style = "padding-left: 20px; font-size: 10px", comment))
      )
    }
    
    div(class = "ui card", style = "border-radius: 0; width: 100%; background: #efefef",
      div(class = "content", 
        div(class = "right floated meta", "Added: 2020-12-24"), paste0("Chimney #", id)), 
      div(class = "image", img(src = paste0("images/", id %% mock_photos_n + 1, ".jpg"), style = "height: 250px")), 
      div(class = "content", 
        span(class = "right floated", icon("warning"), paste(mock_alerts_n, "alerts")), 
        icon("comment"), paste(mock_comments_n, "comments")), 
        tagList(lapply(sample(random_comments, mock_comments_n), comment_row)),
        div(class = "extra content", 
          div(class = "ui large transparent left icon input", 
            icon("comment"), tags$input(type = "text", placeholder = "Add Comment...")
          )
        )
    )
  })
  
  output$sidebar <- renderUI({
    if (is.null(selected_point$id)) {
      uiOutput("pollution_stats")
    } else {
      uiOutput("polluter_info")
    }
  })
  
  gauge <- function(value) {
    col_stops <- data.frame(
      q = c(0.15, 0.4, .8),
      c = c('#55BF3B', '#DDDF0D', '#DF5353'),
      stringsAsFactors = FALSE
    )
    
    highchart() %>%
      hc_chart(type = "solidgauge") %>%
      hc_pane(
        startAngle = -90,
        endAngle = 90,
        background = list(
          outerRadius = '100%',
          innerRadius = '60%',
          shape = "arc"
        )
      ) %>%
      hc_tooltip(enabled = FALSE) %>% 
      hc_yAxis(
        stops = list_parse2(col_stops),
        lineWidth = 0,
        minorTickWidth = 0,
        tickAmount = 2,
        min = 0,
        max = 100,
        labels = list(y = 26, style = list(fontSize = "12px")),
        showFirstLabel = FALSE,
        showLastLabel = FALSE
      ) %>%
      hc_add_series(
        data = value,
        dataLabels = list(
          y = -20,
          borderWidth = 0,
          useHTML = TRUE,
          style = list(fontSize = "15px"),
          formatter = JS(paste0("function () { return '", value, "%'; }"))
        )
      ) %>% 
      hc_size(height = 150)
  }
  
  output$gaugePM25 <- renderHighchart({ gauge(pm25_perc) })
  
  output$gaugePM10 <- renderHighchart({ gauge(pm10_perc) })
  
  output$pollution <- renderHighchart({
    pollution_history %>% 
      hchart('areaspline', hcaes(x = 'time', y = 'measurement', group = "pollutant"))
  })
  
  
  camera_snapshot <- callModule(
    shinyviewr,
    'my_camera',
    output_width = 250,
    output_height = 250
  )
  
  output$snapshot <- renderPlot({
    req(camera_snapshot())
    plot(camera_snapshot(), main = 'Your photo')
  }, height = 250)
  
  output$shinyviewr <- renderUI({
    tagList(
      shinyviewr_UI("my_camera", height = 300),
      # Ugly hack for not so pretty button
      runjs("setTimeout(function() { var sr = $('#my_camera-shinyviewr')[0].shadowRoot; var el = $(sr).find('button'); el.css('all','unset'); el.css('background', '#2185d0'); el.css('color', '#ffffff'); el.css('padding', '.78571429em 1.5em .78571429em'); el.css('cursor', 'pointer'); }, 1000)"),
      imageOutput("snapshot")
    )  
  })
  
  output$selection_map <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      addMapboxGL(style = "mapbox://styles/mapbox/streets-v9") %>%
      setView(lng = warsaw$lon, lat = warsaw$lat, zoom = 12)
  })
  
}
