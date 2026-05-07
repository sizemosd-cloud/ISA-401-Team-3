### Data Acquisition
```{r}
# Load libraries
library(httr)
library(jsonlite)
library(rvest)
library(readr)
library(robotstxt)


##### Salaries #####

# Store the website as variable and declare that the script is allowed data from the URL

url1<- "https://www.spotrac.com/mlb/rankings/player/_/year/2025/sort/cap_total"
paths_allowed(paths="https://www.spotrac.com/mlb/rankings/player/_/year/2025/sort/cap_total")

# Pull the webpage content from the URL and load it into R so it can be read and scraped.

page2 <- read_html(GET(url1, add_headers(`User-Agent` = "Mozilla/5.0")))

# Extract data from the webpage by pulling player names and salaries and stores them in seperate variables, and display the first few enteries to ensure results are correct. 

player_names <- page2 |> 
  html_elements("div.link a") |> 
  html_text(trim = TRUE)

player_salaries <- page2 |> 
  html_elements("span.medium") |> 
  html_text(trim = TRUE)

head(player_names)
head(player_salaries)

##### Positions #####

library(baseballr)
library(dplyr)

# This code pulls the hitting and pitching statistics for the 2025 season and storing them in respective dataset 

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

# Combine the hitting and pitching datasets into one dataset, keep only the essential information and then remove duplicate players so each player appears only once.

all_players_2025 <- bind_rows(hitter_data, pitcher_data) %>%
  select(
    player_full_name, 
    position_name, 
    position_abbreviation, 
    team_name
  ) %>%
  distinct(player_full_name, .keep_all = TRUE)

head(all_players_2025)


##### WAR #####

base_url <- "https://www.fangraphs.com/api/leaders/war"

# Define a function that takes a page number and send a web request to an API using specific filters to retrieve a numbered set of data for 2025 MLB stats.

get_page <- function(page_num) {
  res <- GET(base_url, query = list(
    season = 2025,
    team = team,
    wartype = 1,
    position = "all",
    league = "all",
    page = page_num,
    pageSize = 100
  ), 
  add_headers(`User-Agent` = "Mozilla/5.0"))

# Convert the API response into a usable JSON format and extract the main data portion from it, then return that data so it can be used in the dataset.

  data <- fromJSON(content(res, "text", encoding = "UTF-8"))
  return(data$data)
}

# figure out total pages
first <- GET(base_url, query = list(
  season = 2025,
  team = 0,
  wartype = 1,
  position = "all",
  league = "all",
  page = 1,
  pageSize = 100
))

first_data <- fromJSON(content(first, "text", encoding = "UTF-8"))
