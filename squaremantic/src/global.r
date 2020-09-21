library(shiny)
library(shiny.semantic)
library(dplyr)
library(sass)
library(glue)

sass(
  sass::sass_file("styles/main.scss"),
  cache_options = sass_cache_options(FALSE),
  options = sass_options(output_style = "compressed"),
  output = "www/css/sass.min.css"
)

text_transforms <- c(
  "initial" = "Original",
  "uppercase" = "All Caps",
  "lowercase" = "All Small"
)

text_styles <- c("Basic", "Solid", "Bordered")

sentences <- list(
  "We love Appsilon",
  "shiny.semantic rulez",
  "I'm not lazy, I'm just very relaxed",
  "Friends are chocolate chips in the cookie of life",
  "You're born free, then you're taxed to death",
  "Smile today, tomorrow could be worse",
  "When nothing is going right, go left",
  "If I'm not back in five minutes, just wait longer",
  "Want to hear a construction joke? Sorry, I'm still working on it",
  "A balanced diet means a cupcake in each hand",
  "Doing nothing is hard, you never know when you're done",
  "Don’t drink while driving – you might spill the beer",
  "Life is short, smile while you still have teeth"
)