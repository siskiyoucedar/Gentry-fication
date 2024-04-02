library(tidyverse)
library(sf)

# read in the roads
G_pre_shape <- (
  "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\roads_map\\oproad_gb.gpkg"
)
G_layers <- st_layers(
  G_pre_shape
)

# get the specific layer from the gpkg
roads <- st_read(
  G_pre_shape, "road_link"
)

# clear off the roads with no names
road_names <- as.data.frame(roads)|> 
  select(
    "id", "name_1"
  ) |>
  na.omit()

# remove needless attributes
attr(road_names, "sf_column") <- NULL
attr(road_names, "na.action") <- NULL
attr(road_names, "agr") <- NULL

# keen to reduce load, let's save that to .csv
write.csv(road_names, 
          file = "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\.words_output\\road_names.csv", 
          row.names = FALSE
)
