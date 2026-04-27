# Load libraries
library(httr)
library(jsonlite)
library(rvest)
library(readr)
library(robotstxt)


# Ask to scrape: 

# URL 1

url1<- "https://www.spotrac.com/mlb/rankings/player/_/year/2025/sort/cap_total"
paths_allowed(paths="https://www.spotrac.com/mlb/rankings/player/_/year/2025/sort/cap_total")

page2 <- read_html(GET(url1, add_headers(`User-Agent` = "Mozilla/5.0")))

# NOW you can scrape the elements
player_names <- page2 |> 
  html_elements("div.link a") |> 
  html_text(trim = TRUE)

player_salaries <- page2 |> 
  html_elements("span.medium") |> 
  html_text(trim = TRUE)

head(player_names)
head(player_salaries)

# Scrape positions




