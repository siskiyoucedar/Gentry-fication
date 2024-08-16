library(tidyverse)
library(sf)
library(tmap)

# Run this code in parts - it is very resource intensive down the line

# read the fancy road file (not necessary if running after 3_Map_Words_to_Roads.R)
 roads_joined <- st_read(
   "_Processed_data/roads_output.gpkg"
 ) |>
   st_transform(27700)

# read the london.shp
# you'll need to get this from the London Data Store: https://data.london.gov.uk/dataset/statistical-gis-boundary-files-london 

london_map <- st_read(
  "_Spatial_data/London_Borough_Excluding_MHW.shp"
) |>
  st_transform(27700)

# simplify: just one polygon
# this is a list obj for some reason: do not use this

london_shape <- st_union(london_map)

# test processing power

options(timeout = max(1000, getOption("timeout")))

# get just the roads in London

roads_LBs <- st_intersection(roads_joined, london_map)

# write that to disk

st_write(roads_LBs, "_Processed_data/LBs_roads_output.gpkg", append = FALSE)

# simplify
london_deets <- as.data.frame(roads_LBs) |>
  mutate(
    'value' = 1
  ) |> select(
    name_1, start_node, end_node, 
    id, Match, NAME, value
  )
attr(london_deets, "sf_column") <- NULL
attr(london_deets, "na.action") <- NULL
attr(london_deets, "agr") <- NULL

# Why has this broken?

ldn_test <- unique(london_deets)

# test groupby
london_table <- ldn_test |>
  pivot_wider(
    names_from = "Match",
    values_from = "value",
    values_fill = 0) |>
  group_by(NAME) |>
  summarise(
    "Road_count" = n(),
    "Match_count" = sum(Yes),
    ) |>
  mutate(
    'Match_percent' = as.numeric(
          Match_count/Road_count*100)
      )

# put that data into the sf

london_map_matches <- london_map |>
  merge(london_table)

st_write(london_map_matches, "_Processed_data/london_map_matches.gpkg", append=FALSE)
