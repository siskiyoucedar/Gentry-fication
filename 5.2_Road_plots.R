library(tidyverse)
library(sf)
library(tmap)
library(viridis)
library(wordcloud2)
library(extrafont)
loadfonts(device = "win", quiet = TRUE) 

# read merged London shpS (not necessary if running after 4_Get_London_objects)

london_map_matches <- st_read("_Processed_data/london_map_matches.gpkg")
roads_LBs <- st_read("_Processed_data/LBs_roads_output.gpkg")
roads_london <- st_read("_Processed_data/london_roads_output.gpkg")

# do the same for roads in London

percentages_LDN <- as.data.frame(roads_LBs) |>
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

common_names_LDN <- as.data.frame(roads_LBs) |>
  group_by(Matched_Word) |>
  summarise(
    "Count" = n(),
  ) |>
  arrange(
    desc(Count)
  ) |>
  # remove the NA line
  tail(-1)

# create two new objs to aid plotting

roads_london_matched <- roads_LBs |> filter(
  Match == "Yes"
) |>
  select(
    "Name" = "name_1", "Matched Word" = "Matched_Word"
  )

london_map_matches <- london_map_matches |>
  select(
    "Name" = "NAME",
    "Match Percent" = "Match_percent"
  )

# test map

breaks = c(8, 10, 11, 12, 15, 18, 21, 27)
labels = c("8 to 10%","10 to 11%","11 to 12%", "12 to 14%", "15 to 17%", "18 to 21%", "21 to 27%")

tmap_mode("view")

tm_shape(london_map_matches) +
  tm_polygons(col = "Match Percent", 
              alpha = 0.7, 
              breaks = breaks,
              labels = labels,
              title = "Gentry-fied Roads",
              palette = viridis(n = 7, option = "G", begin = 0.2)) +
  tm_basemap(c(StreetMap = "OpenStreetMap", TopoMap = "OpenTopoMap")) +
  tm_shape(roads_london_matched) +
  tm_lines(col = "black", 
           alpha = 1,
           legend.col.show = FALSE,
           lwd = 2
           ) +
  tm_shape(roads_london_matched) +
  tm_lines(col = "white", 
           alpha = 1,
           legend.col.show = FALSE,
           lwd = 1
  ) 

wordcloud2(data = common_names, 
           fontFamily = "Accidental Presidency", 
           size = 1, 
           rotateRatio = 0,
           color = rep_len(
             viridis(n = 10, option = "G", begin = 0.2, end = 0.8, direction = 1), nrow(common_names_LDN)
             )
           )

wordcloud2(data = common_names_LDN, 
           fontFamily = "Accidental Presidency", 
           size = 1, 
           rotateRatio = 0,
           color = rep_len(
             viridis(n = 10, option = "G", begin = 0.2, end = 0.8, direction = 1), nrow(common_names_LDN)
             )
)
