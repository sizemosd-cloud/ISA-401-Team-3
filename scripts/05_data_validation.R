---
title: "Completed Project R Markdown"
author: "Sarah, Paige, Caroline, Layne"
date: "2026-05-04"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```


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
    team = 19,
    wartype = 1,
    position = "all",
    league = "all",
    page = page_num,
    pageSize = 100
  ))

# Convert the API response into a usable JSON format and extract the main data portion from it, then return that data so it can be used in the dataset.

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

```

### Data Cleaning
```{r}
##### Salaries Cleaned #####

# Load libraries
library(httr)
library(jsonlite)
library(rvest)
library(readr)
library(robotstxt)

url1 <- "https://www.spotrac.com/mlb/rankings/player/_/year/2025/sort/cap_total"
paths_allowed(paths = "https://www.spotrac.com/mlb/rankings/player/_/year/2025/sort/cap_total")

page2 <- read_html(GET(url1, add_headers(`User-Agent` = "Mozilla/5.0")))

# scrape elements
player_names <- page2 |> 
  html_elements("div.link a") |> 
  html_text(trim = TRUE)

player_salaries <- page2 |> 
  html_elements("span.medium") |> 
  html_text(trim = TRUE)

# cut down salary list to match player names
player_salaries <- player_salaries[1:1514]

# look for duplicated names
player_names[duplicated(player_names)]

player_names[c(115, 1278, 271, 1015, 1077, 1078, 1103)]
# fix duplicated names
player_names[c(115, 1278, 271, 1015, 1077, 1078, 1103)] <- c("Max Muncy (LAD)", "Max Muncy (ATH)", "Luis García Jr.", "Luis F. Castillo", 
                                                             "José Fermín", "José Fermin", "Luis García")
# confirm names are fixed
player_names[c(115, 1278, 271, 1015, 1077, 1078, 1103)]


head(player_names)
head(player_salaries)

# clean result
salary_table <- data.frame(
  Player = player_names,
  Salary = player_salaries,
  stringsAsFactors = FALSE
)

# check that there are no other duplicated names
salary_table$Player[duplicated(salary_table$Player)]

salary_table <- salary_table |> 
  distinct(Player, .keep_all = TRUE)

head(salary_table)
```


```{r}
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
# look for duplicated names in each dataset
hitter_data$player_full_name[duplicated(hitter_data$player_full_name)]
pitcher_data$player_full_name[duplicated(pitcher_data$player_full_name)]

# fix duplicated name
which(hitter_data$player_full_name == "Max Muncy")
hitter_data[c(253, 427), 43] <- c("Max Muncy (LAD)", "Max Muncy (ATH)")
hitter_data$player_full_name[duplicated(hitter_data$player_full_name)]

all_players_2025 <- bind_rows(hitter_data, pitcher_data) %>%
  select(player_full_name, position_name, position_abbreviation, team_name) |> 
  distinct(player_full_name, .keep_all = TRUE) 

# Check that all players have a position
unique(all_players_2025$position_abbreviation)

# Look for players without a position
all_players_2025 |> 
  filter(position_abbreviation == "X")

# find the rows that correspond to that player
which(all_players_2025$position_abbreviation == "X")

# fill in missing positions
all_players_2025[c(211, 243, 376, 503, 519, 531, 543,
                   561, 593, 640, 649, 714, 747), 3]

all_players_2025[c(211, 243, 376, 503, 519, 531, 543,
                   561, 593, 640, 649, 714, 747), 3] <- c(
                  "2B", "OF", "DH", "OF/3B", "RF", "OF/1B",
                  "SS", "OF", "1B", "OF", "CF/2B", "OF", "C")
all_players_2025 |> 
  filter(position_abbreviation == "X")

all_players_2025$player_full_name[duplicated(all_players_2025$player_full_name)]
  
```

```{r}
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

# first request (for total rows)
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

# clean WAR values
first_data$totalWAR <- round(first_data$totalWAR, 2)
first_data[c(125, 1224), 2]
first_data[c(125, 1224), 2] <- c("Max Muncy (LAD)", "Max Muncy (ATH)")
first_data[c(125, 1224), 2]

war_data <- first_data |> 
  select(playerName, totalWAR) |> 
  distinct(playerName, .keep_all = TRUE)

nrow(war_data)
```

```{r}
##### Additional Cleaning (Special Characters & Name Corrections)#####
library(stringr)
library(stringi)
library(tidyr)

spec_char <- all_players_2025 |>
  filter(str_detect(player_full_name, "[^\\x00-\\x7F]"))

non_spec_char <- spec_char |> 
  mutate(player_full_name = stri_trans_general(player_full_name, "Latin-ASCII"))

spec_char_list <- spec_char$player_full_name
non_spec_char_list <- non_spec_char$player_full_name

salary_table <- salary_table |>
  mutate(Player  = if_else(Player %in% non_spec_char_list,
                   spec_char_list[match(Player, non_spec_char_list)],Player))

salary_table$Player[duplicated(salary_table$Player)]
salary_table[406, 1] <- "Luis Garcia"

# Names that appeared within the all_players_2025 dataset and salary_table but were written differently

salary_table[c(943, 753, 1000, 1061, 1068, 443,1125, 1151, 
               272, 1269, 689, 1337,1378, 749, 800, 1447,
               693, 797, 825, 1021, 1167, 1348), 1]

salary_table[c(943, 753, 1000, 1061, 1068, 443,1125, 1151, 
               272, 1269, 689, 1337,1378, 749, 800, 1447,
               693, 797, 825, 1021, 1167, 1348), 1] <- c(
                 "Sam Aldegheri", "Nacho Alvarez Jr.", "Mike Burrows", "Carl Edwards Jr.", "Jose Espada", "Yuli Gurriel",
                 "Dom Hamel", "Andrew Hoffmann", "Jakob Junis", "Patrick Monteverde", "Richie Palacios", "Leo Rivas", 
                 "Bob Seymour", "Michael Siani", "Louis Varland", "Donovan Walton", "Ji Hwan Bae", "Simeon Woods Richardson", "Jose A. Ferrer", "Zach Cole", "Leo Jiménez", "Carlos Rodriguez")

salary_table[c(693, 797, 825, 1021, 1167, 1348), 1]

salary_table$Player[duplicated(salary_table$Player)]

### Players with Jr in the name that appeared in all_players_2025 but without Jr in the salary_table

salary_table[c(83, 236, 917, 1087), 1]
salary_table[c(83, 236, 917, 1087), 1] <- c(
                 "Lance McCullers Jr.", "Jazz Chisholm Jr.", "DaShawn Keirsey Jr.", "Rafael Flores Jr.")
```


### Data Merging ###
```{r}
# The code merge the WAR dataset with player position data and salary data. The left join keeps all WAR players and adds matching position and salary info when available, while the inner join keeps only players who appear in all datasets.

# USED CHAT ISA BY FADEL TO HELP :)
# need to install.packages("fuzzyjoin") and install.packages("stringr")

# Helper function to clean names
clean_names <- function(name_vec) {
  name_vec |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[[:punct:]]", "") |> 
    stringr::str_replace_all("\\b(sr|ii|iii|iv)\\b", "") |>
    stringr::str_squish()
}

# Apply cleaning to all three tables
salary_table <- salary_table |> 
  dplyr::mutate(clean_name = clean_names(Player))

salary_table$clean_name[duplicated(salary_table$clean_name)]

all_players_2025 <- all_players_2025 |> 
  dplyr::mutate(clean_name = clean_names(player_full_name))

war_data <- war_data |> 
  dplyr::mutate(clean_name = clean_names(playerName))

# Step 1: Fuzzy join salary with positions (INNER JOIN)
salary_position <- salary_table |>
  fuzzyjoin::stringdist_inner_join(
    all_players_2025, 
    by = "clean_name", 
    max_dist = 0.001, 
    method = "jw"
  )

# Step 2: Fuzzy join result with WAR (INNER JOIN)
final_table <- salary_position |>
  fuzzyjoin::stringdist_inner_join(
    war_data, 
    by = c("clean_name.x" = "clean_name"), 
    max_dist = 0.05, 
    method = "jw"
  ) |>
  dplyr::select(
    Player = Player, 
    Position = position_abbreviation, 
    Team = team_name, 
    Salary = Salary, 
    WAR = totalWAR
  )

head(final_table)
nrow(final_table)

# Optional: Check how many players you kept
cat("Players in salary table:", nrow(salary_table), "\n")
cat("Players in position table:", nrow(all_players_2025), "\n")
cat("Players in WAR table:", nrow(war_data), "\n")
cat("Players in final merged table:", nrow(final_table), "\n")
```



```{r}
Inactive_Players <- salary_table |>
  fuzzyjoin::stringdist_anti_join(
    all_players_2025, 
    by = "clean_name", 
    max_dist = 0.001, 
    method = "jw"
  )

library(stringr)
library(stringi)
library(tidyr)

list_inactive <- Inactive_Players$Player
list_inactive


Inactivename_split <- Inactive_Players |>
  separate(Player, into = c("first_name", "last_name"), sep = " ", extra = "merge")


WARname_split <- war_data |>
  separate(playerName, into = c("first_name", "last_name"), sep = " ", extra = "merge")


inactive_check <- Inactivename_split |>
  filter(last_name %in% WARname_split$last_name)


overlap_last_names <- intersect(
  WARname_split$last_name,
  Inactivename_split$last_name
)

war_subset <- WARname_split |>
  filter(last_name %in% overlap_last_names) |> 
  select(clean_name, last_name, totalWAR)

inactive_subset <- Inactivename_split |>
  filter(last_name %in% overlap_last_names) |> 
  select(clean_name, last_name)


```

## Data Validation
```{r}
library(openxlsx)
final_table |> 
  filter(Position == "X")


duplicate_rows <- final_table |>
  dplyr::group_by(Player) |>
  dplyr::filter(n() > 1) |>
  dplyr::ungroup()

duplicate_names <- final_table$Player[duplicated(final_table$Player)]

dupe_names <- as.list(unique(duplicate_names))

new_final_table <- final_table |>
  filter(!Player %in% dupe_names)
write.xlsx(final_table, "ISA401_final_table.xlsx")
```
