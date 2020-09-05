library(tidyverse)
library(lubridate)
library(viridis)

data <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv",
  na.strings = "", fileEncoding = "UTF-8-BOM"
)

cases <-
  data %>%
  as_tibble() %>%
  select(
    date = dateRep,
    cases,
    deaths,
    country = countriesAndTerritories,
    case_rate = Cumulative_number_for_14_days_of_COVID.19_cases_per_100000
  ) %>%
  mutate(date = as_date(date, format = "%d/%m/%Y"))

cases %>%
  filter(country == "Greece" |
    country == "Italy" |
    country == "Switzerland" |
    country == "United_Kingdom") %>%
  drop_na() %>%
  ggplot(aes(x = date, y = case_rate)) +
  geom_line(aes(colour = country),
    size = 1
  ) +
  geom_line(aes(y = 60), colour = "red", linetype = "dashed") +
  # geom_line(aes(y = 50), colour = "orange", linetype = "dashed") +
  # geom_line(aes(y = 40), colour = "yellow4", linetype = "dashed") +
  scale_color_viridis_d(begin = .1, end = .9, option = "C") +
  labs(
    y = "Cumulative 14 day case count per 100,000 people",
    x = "Date"
  ) +
  theme_minimal() +
  scale_x_date(
    date_breaks = "1 week",
    date_labels = "%d/%m"
  ) +
  scale_y_continuous(breaks = seq(from = 0, to = 1000, by = 5))
