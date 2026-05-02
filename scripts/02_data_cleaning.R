##### Salaries Cleaned #####

# Load libraries
library(httr)
library(jsonlite)
library(rvest)
library(readr)
library(robotstxt)


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

player_salaries <- player_salaries[1:1512]

head(player_names)
head(player_salaries)

# clean result

salary_table <- data.frame(
  Player = player_names,
  Salary = player_salaries,
  stringsAsFactors = FALSE
)

head(salary_table)


##### Position Cleaned #####

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


##### WAR Cleaned #####

library(httr)
library(jsonlite)
library(dplyr)

base_url <- "https://www.fangraphs.com/api/leaders/war"

get_page <- function(page_num) {
  res <- GET(base_url, query = list(
    season = 2025,
    team = 19,
    wartype = 1,
    position = "all",
    league = "all",
    page = page_num,
    pageSize = 100
  ))
  
  data <- fromJSON(content(res, "text", encoding = "UTF-8"))
  return(data$data)
}

# figure out total pages
first <- GET(base_url, query = list(
  season = 2025,
  team = 19,
  wartype = 1,
  position = "all",
  league = "all",
  page = 1,
  pageSize = 100
))

first_data <- fromJSON(content(first, "text", encoding = "UTF-8"))

total_rows <- first_data$total
page_size <- 100
total_pages <- ceiling(total_rows / page_size)

# loop through all pages
all_data <- lapply(1:total_pages, get_page) |> bind_rows()

first_data$totalWAR <- round(first_data$totalWAR, 2)

# clean result
df <- first_data %>%
  select(playerName, totalWAR)

nrow(df)
