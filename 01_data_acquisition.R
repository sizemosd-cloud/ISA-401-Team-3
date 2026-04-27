# Load libraries
library(httr)
library(jsonlite)
library(rvest)
library(readr)
library(robotstxt)


# Salaries

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

# Positions
library(baseballr)
library(dplyr)

hitter_data <- mlb_stats(
  stat_type = "season",
  stat_group = "hitting",
  season = 2025,
  player_pool = "All"
)

pitcher_data <- mlb_stats(
  stat_type = "season",
  stat_group = "pitching",
  season = 2025,
  player_pool = "All"
)

all_players_2025 <- bind_rows(hitter_data, pitcher_data) %>%
  select(
    player_full_name, 
    position_name, 
    position_abbreviation, 
    team_name
  ) %>%
  distinct(player_full_name, .keep_all = TRUE)

head(all_players_2025)
