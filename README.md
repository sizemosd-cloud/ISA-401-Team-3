# ISA-401-Team-3

---
title: "README.md"
author: "Sarah, Paige, Caroline, Layne"
date: "2026-05-08"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```


# Project Overview: The ROI of MLB Talent

### Research Question
**"Do higher-paid MLB players actually perform better, as measured by W.A.R.?"**

We wanted to test whether WAR is a strong predictor of salary and whether higher-paid players consistently deliver higher on-field performance.

We also wanted to explore whether other factors might influence WAR or salary, such as whether a player is a rookie versus a veteran, their age, or whether they are coming off a particularly strong or weak season. This helps us understand if salary is driven purely by performance, or if additional context and player characteristics play a role in how teams value and compensate players.

---

## Data Sources

* **Performance (W.A.R.):** [FanGraphs](https://www.fangraphs.com/leaders/war?season=2025&team=19&wartype=1) – Primary source for Wins Above Replacement (WAR) metrics.
* **Salary Data:** [Spotrac](https://www.spotrac.com/mlb/rankings/_/year/2025) – Comprehensive player contract and 2025 cash earnings.
* **Player Metadata:** [Baseballr (R-Baseballverse)](https://billpetti.github.io/baseballr/) – Used to pull official active rosters and position abbreviations.
* **Validation & Records:** [Baseball-Reference](https://www.baseball-reference.com/) and [MLB.com](https://www.mlb.com/players) – Used for cross-referencing and manual cleaning of player positions.


## Technical Workflow

### 1. Data Acquisition
Thse methods were helpful in approaching our data:  
* **Scraping:** financial rankings from Spotrac using `rvest`.
* **API Requests:**  JSON fetching from FanGraphs to compile a full-league WAR database.
* **Package Integration:** Used `baseballr` to interface directly with MLB’s internal statistics API.

### 2. Data Cleaning
The most challenging part was overlapping the data across the different sources. We had these problems:

* **Name Discrepancies:** match names containing special characters (accents), suffixes (Jr., III)

* **Duplicate Handling:** Resolved "Identity Collisions" for players with identical names (e.g., Luis García, Max Muncy).
* **Position Imputation:** Manually corrected players marked with an "X" or missing position data by referencing 2025 primary games played.

### 3. Data Merging
We used **Fuzzy Join** to merge the data and to fix the different spellings of player names across sources. This "fuzzy" joined the players across the sources. 

### 4. Statistical Analysis (K-Means Clustering)
To answer our research question, we applied K-Means clustering to the final dataset. This grouped players into four distinct value tiers:
* **Efficient Players:** Low WAR, Low Salary.
* **Veterans/underperforming Players:** Low WAR, Mid Salary.
* **Paid and Productive:** High WAR, High Salary.
* **Elite/Rookie:** High WAR, Low Salary.

---

## Project Conclusion
The final output of this R Markdown workflow is `ISA401_final_table.csv`, which we then uploaded into Tableau to further analyze our data with graphs. We found that there were several extreme outliers, but mostly our data showed a more nuanced conclusion, that W.A.R shouldn't be the only predictor of salary for baseball players. It also depends on their veteran status, years played, team they are on, their position, and more.

---

## Required Libraries
```{r}

library(httr)
library(jsonlite)
library(rvest)
library(baseballr)
library(tidyverse)
library(fuzzyjoin)
library(stringi)
library(openxlsx)

```
