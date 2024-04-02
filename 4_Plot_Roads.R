library(tidyverse)
library(sf)
library(tmap)

# read the region .shp
# regions <- st_read(
#   "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\Regions\\RGN_DEC_2023_EN_BFC.shp"
# )

# read the fancy road file
roads_joined <- st_read(
  "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\roads_output.gpkg"
) |>
  st_transform(27700)

# read the london.shp
london_map <- st_read(
  "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\LBs\\London_Borough_Excluding_MHW.shp"
) |>
  st_transform(27700)

# how about some nice summary outputs?
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

common_names <- as.data.frame(roads_joined) |>
  group_by(Matched_Word) |>
  summarise(
    "Count" = n(),
  ) |>
  arrange(desc(Count))

# the ruthven_check: all of the Ruthvens pulled out from the data should have a "yes" for "match"
ruthven_check <- roads_joined |> filter(
  str_detect(name_1, "Ruthven")
)

# simplify road data
# which pieces of data do I actually need? 
# id (for merging back in)
# start_node, end_node (for geometry)
# Match
roads_easy <- roads_joined |>
  select(
    id, 
    # name_1,
    start_node, end_node, 
    Match 
    #, Power, 
    # Matched_Word
  ) 
rm(roads_joined)
#test join
roads_london <- st_join(roads_easy,london_map)
rm(roads_easy)
save.image("~/.RData")
# simplify
london_deets <- as.data.frame(roads_london) |>
  mutate(
    'value' = 1
  ) |> select(
    id, name_1, start_node, end_node, Match, Power, Matched_Word, NAME
  )
attr(london_deets, "sf_column") <- NULL
attr(london_deets, "na.action") <- NULL
attr(london_deets, "agr") <- NULL

london_deets <- london_deets 
temp <- london_deets |> select(
  id,NAME) |>
  na.omit()
london_deets <- london_deets |>
  merge(
    temp,
    id,
    id
  )


# test groupby
london_deets <- london_deets |>
  pivot_wider(
    names_from = 'Match',
    values_from = 'value',
    values_fill = 0) |>
  group_by(NAME) |>
  summarise(
    "Road_count" = n(),
    "Match_count" = sum(Yes),
    'Match %' = paste0(
      format(
      round(
        Match_count/Road_count),
      nsmall = 0), "%")
    )


# test region map
# qtm(regions)
# test subset data
# a test map
tm_shape(london_map) +
  tm_polygons(col = NA, alpha = 0.5) +
  tm_shape(RoadsSub) +
  tm_lines(col = "Match")
