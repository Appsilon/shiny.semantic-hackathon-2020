semanticPage(
  appDependencies(),
  pageBackground(),

  gridPanel(
    id = "main-page",
    columns = "350px 1fr",
    rows = "75px 1fr",
    areas = c(
      "header main",
      "side main"
    ),
    gap = "15px",

    header = div(
      class = "ui raised segment inverted",
      div(class = "background-gradient"),
      h2(class = "title", "Semantic Pixelator")
    ),

    side = div(
      class = "sidebar-wrapper",
      gridPanel(class = "ui raised segment inverted sidebar-container",
        gap = "15px",
        rows = "35px 322px 1fr 40px 100px",

        div(
          id = "image-picker-buttons",
          darkify(fileInput, "upload", label = "", buttonLabel = "Upload image", type = "file", accept = "image/png, image/jpeg"),
          darkify(action_button, "reload", "Random image")
        ),
        imageOutput("image"),

        div(
          class = "sidebar-options",

          darkify(
            selectInput,
            "gridSize",
            "Grid size",
            gridSizes
          ),
          darkify(
            selectInput,
            "gridType",
            "Grid type",
            pixelTypes
          ),
          uiOutput("pixelType"),
          uiOutput("loaderType"),
          uiOutput("pixelRandomize")
        ),

        gridPanel(
          class = "grid-side ui raised segment inverted",
          rows = "repeat(1, 10px)",
          columns = "100%",

          div(class = "image-setting", darkify(toggle, "grayScale", "Gray scale", is_marked = FALSE))
        ),

        gridPanel(
          class = "grid-side ui raised segment inverted",
          rows = "repeat(3, 20px)",
          columns = "100%",
          gap = "5px",

          div(class = "image-setting", darkify(toggle, "toggleRed", "Red channel")),
          div(class = "image-setting", darkify(toggle, "toggleGreen", "Green channel")),
          div(class = "image-setting", darkify(toggle, "toggleBlue", "Blue channel"))
        )
      )
    ),

    main = gridPanel(class = "ui raised segment pixel-grid inverted",
      columns = "1fr",
      rows = "1fr 100px",
      gap = "15px",

      helpModal(),

      div(class = "background-gradient-main"),

      div(
        class = "grid-wrapper",
        uiOutput("grid"),
        uiOutput("gridCells"),
        uiOutput("paletteColors")
      ),

      gridPanel(
        class = "grid-side ui raised segment inverted",
        rows = "1fr",
        columns = "100px 50px auto 50px 100px 100px",
        gap = "15px",

        darkify(action_button, "generatePalette", "New Palette"),

        div(class = "spacer"),

        gridPanel(
          id = "generatedPalette",
          columns = "repeat(5, 1fr)",
          gap = "5px",

          lapply(1:5, function(index) {paletteCell(index)})
        ),

        div(class = "spacer"),

        div(id = "download-message"),

        darkify(action_button, "downloadPalette", "Download Palette"),
        darkify(action_button, "downloadImage", "Download Image")
      )
    )
  )
)
