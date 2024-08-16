library(tidyverse)
library(sf)

### CONSIDER ADDING BUFFER POINTS FOR E.G CAMBRIDGE TO CONFIGURE IF A ROAD CALLED CAMBRIDGE ROAD IS GOING TO CAMBRIDGE
# (AND COULD DO THE OPPOSITE FOR WEIRDLY NAMED HOUSES E.G HILL)

# pull through the data
full_list <- read.csv(
  "_Processed_data/all_names.csv"
)
road_names <- read.csv(
  "_Processed_data/road_names.csv"
)

# pull this one from OS website noted in readme
G_pre_shape <- (
  "_Spatial_data/oproad_gb.gpkg"
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

# try and eke out the Lowe problem

# lowe_test <- road_names |>
#   mutate(
#     "Test" = ifelse(str_detect(name_1, "Lower"), 1, 0)
#   ) |>
#   filter(
#     Test == 1
#   )

# create a list of the gentry words that excludes Lowe

# no_lowe <- full_list |>
#   filter(
#     !(Word == "Lowe")
#   )

# see if any other roads are getting caught that happen to contain Lower

# lowe_testing <- lowe_test |>
#   mutate(
#     Match = ifelse(str_detect(name_1, paste(no_lowe$Word, collapse = "|")), "Yes", "No")
#   ) |>
#   mutate(
#     Matched_Word = ifelse(Match == "Yes", str_extract(name_1, paste(no_lowe$Word, collapse = "|")), NA)
#   ) |>
#   filter(
#     Match == "Yes"
#   )

# ok, as there are a lot of "Lower Queen's St" etc., I think the best fix is to change "Lowe" for "Lowe " - which should hopefully work

full_list[676, 3] = "Lowe "

# do some brief corrections for surnames
# remove geographical indicators
full_list <- full_list |>
  filter(!(Word %in% c("Beach", "Cave", "Craig", "Cross", "Hall", "Head", "Hill", "Lake", "Law", "Lee", "Long", "Mills", "Munro", "Weir", "Wood", "St")))

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
  "_Processed_data/roads_output.gpkg",
  append = FALSE
  )

# declutter
rm(roads, road_names, names_powered, full_list, G_layers, G_pre_shape)
