library(shiny)
library(sass)
library(htmltools)
library(glue)
library(shiny.semantic)
library(imager)
library(stringi)
library(shiny.grid) # devtools::install_github("pedrocoutinhosilva/shiny.grid")
library(shiny.pwa) # devtools::install_github('pedrocoutinhosilva/shiny.pwa')

# Source required scrips
source("modules/dependencies.R")
source("modules/options.R")
source("modules/tracker.R")

source("modules/pixel-grid.R")
source("modules/color-palette.R")
source("modules/ui-fragments.R")
source("modules/about-section.R")

# Preprocess required css
sass(
  sass::sass_file("styles/main.scss"),
  cache_options = sass_cache_options(FALSE),
  options = sass_options(output_style = "compressed"),
  output = "www/css/sass.min.css"
)
