library(tidyverse)
library(sf)

# read the fancy road file (not necessary if running after 3_Map_Words_to_Roads.R)
roads_joined <- st_read(
  "_Processed_data/roads_output.gpkg"
) |>
  st_transform(27700)

# percentage of roads associated with each word

percentages <- as.data.frame(roads_joined) |>
  group_by(Match) |>
  summarise(
    "Count" = n(),
  ) |>
  mutate(
    "Percentage" = paste0(
      format(
        round(
          (Count / sum(Count)) * 100, 2
        ), nsmall = 2), "%")
  )

# most common names matched to each road

common_names <- as.data.frame(roads_joined) |>
  group_by(Matched_Word) |>
  summarise(
    "Count" = n(),
  ) |>
  arrange(
    desc(Count)
  ) |>
  # remove the NA line
  tail(-1)