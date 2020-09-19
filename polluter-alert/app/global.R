library(shiny)
library(shiny.semantic)
library(modules)
library(config)
library(sass)
library(leaflet)
library(leaflet.mapboxgl)
library(highcharter)
library(anytime)
library(dplyr)
library(shinysense)
library(shinyjs)
library(httr)
library(glue)
library(lubridate)

consts <- config::get(file = "constants.yml")

intro <- as.character(consts$intro)
random_comments <- consts$random_comments

options(mapbox.accessToken = consts$mapbox_token)


