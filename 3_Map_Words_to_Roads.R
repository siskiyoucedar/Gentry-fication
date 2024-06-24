library(tidyverse)
library(sf)

# pull through the data
full_list <- read.csv(
  ".words_output\\all_names.csv"
)
road_names <- read.csv(
  ".words_output\\road_names.csv"
)

# pull this one from OS website noted in readme
G_pre_shape <- (
  "roads_map\\oproad_gb.gpkg"
)
G_layers <- st_layers(
  G_pre_shape
)
# get the specific layers from the gpkg
roads <- st_read(
  G_pre_shape, "road_link"
)
# don't need the nodes for now
# nodes <- st_read(
#  G_pre_shape, "road_node"
#)

# do some brief corrections for surnames
# remove geographical indicators
full_list <- full_list |>
  filter(!(Word %in% c("Beach", "Cave", "Craig", "Cross", "Hall", "Head", "Hill", "Lake", "Lee", "Long", "Mills", "Munro", "Weir", "Wood", "St")))

# add a way of incorporating power into the search
names_powered <- full_list |>
  filter(Power == 1)

# detect matching strings from titles in the roadnames and add a new column for it
road_names <- road_names |>
  mutate(
    Match = ifelse(str_detect(name_1, paste(full_list$Word, collapse = "|")), "Yes", "No")
  ) |>
  # based on the match, we can do a check that also captures power
  mutate(
    Power = ifelse((Match == "Yes"), ifelse((str_detect(name_1, paste(names_powered$Word, collapse = "|"))), 1, 0.5), 0)
  ) |>
  mutate(
    Matched_Word = ifelse(Match == "Yes", str_extract(name_1, paste(full_list$Word, collapse = "|")), NA)
  )

matched_roads <- road_names |>
  filter(Match == "Yes")

# check things are working; all the rows should read "Yes" under "Match"
Ruthven_check_1 <- road_names |>
  filter(str_detect(name_1, "Ruthven"))

# join roadnames (matched for aristocrats) with roads
roads_joined <- roads |>
  
  # save memory #1:
  
  select(
    id, name_1, start_node, end_node, geometry
  ) |> 
  merge(
    road_names,
    
    # make sure we keep all the roads:
    
    all.x = TRUE
    ) |>
  
  # assign necessary characteristics to those with none
  mutate(
    Match = replace_na(Match, "No"),
    Power = replace_na(Power, 0)
    ) |>
  
  # save memory #2:
  select(
    id, name_1,start_node, end_node, Match, Power, Matched_Word, geometry
  )

# check it worked for e.g. low powers
roads_joined |> filter(
  Match == "Yes"
  ) |>
  head()
roads_joined |> filter(
  Match == "No"
) |>
  head()

# great. now they need spatial characteristics...
# write a geopackage that contains the roads. let's hope this works!

st_write(
  roads_joined, 
  "roads_output.gpkg",
  append = TRUE
  )

# declutter
rm(roads, road_names, names_powered, full_list, G_layers, G_pre_shape)
