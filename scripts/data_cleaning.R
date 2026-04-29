##### Salaries Cleaned #####

[insert]



##### Position Cleaned #####

[insert]



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
  select(playerName, totalWAR) %>%
  mutate(totalWAR = round(totalWAR,2))

nrow(df)
