library(tidyverse)
library(sf)

## Separate road names from spatial data

# read in the roads (available here: https://www.ordnancesurvey.co.uk/products/os-mastermap-highways-network-roads#get)
G_pre_shape <- (
  "roads_map\\oproad_gb.gpkg"
)
G_layers <- st_layers(
  G_pre_shape
)

# get the specific layer from the gpkg
roads <- st_read(
  G_pre_shape, "road_link"
)

# We'll keep the "roads" object as is for our records.
rm(G_layers,G_pre_shape)

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
          file = ".words_output\\road_names.csv", 
          row.names = FALSE
)