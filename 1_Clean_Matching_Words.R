library(tidyverse)

# ideal file structure
ideal <- tibble(
  "Name" = c("Smith", "Sussex", "Earl", "Victoria"),
  "Type" = c("Surname", "House", "Title", "First Name"),
  "Status" = c("extant", "extinct", "extinct", "extant"), # < needs encoding ordinal, 0 = extinct 1 = extant
  "Location_Match" = c("No", "Yes", "No", "No"), # < needs encoding ordinal, 0 = yes 1 = no
  "Power" = c(1, 0.25, 0.5, 1) # < function of status * location_match (where a 0 = 0.5)
)

# # # SURNAMES; PLACES

# read in the duchies, marquesses, earldoms, viscounts
full_list <- read.csv(
  "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\words_input\\aristocracy.csv"
)

# cleaning
full_list <- full_list |>
  
  # use grepl to check for "extinct xyz" in rows and turn it into "extinct" or keep it as is
  mutate(
    Status = ifelse(grepl("extinct", Status), "extinct", Status)
  ) |>
  
  # just fixing cases
  mutate(
    Status = tolower(Status)
  ) |>
  
  # use grepl to split up double barreled names; "^[^-]+-" means "the thing before and including the hyphen"
  # look for a hyphen. don't find a hyphen - keep things the same.
  mutate(
    Surname2 = ifelse(grepl("-", Surname), gsub("^[^-]+-", "", Surname), "")
  ) |>
  
  # and another one that does the same but for the third hyphen
  mutate(
    Surname3 = ifelse(grepl("-", Surname2), gsub("^[^-]+-", "", Surname2), "")
  ) |>
  
  # then make the original column just have the first half; "-.*$" means "the thing after and including the hyphen"
  # so everything after the hyphen gets gone.
  mutate(
    Surname1 = ifelse(grepl("-", Surname), gsub("-.*$", "", Surname), Surname)
  ) |>
  
  # and do the same with any extras left in surname 2
  mutate(
    Surname2 = ifelse(grepl("-", Surname2), gsub("-.*$", "", Surname2), Surname2)
  ) |>
  
  # finally, extract the placenames from the Title column
  # \\S+ matches one or more non-whitespace characters
  # $ asserts the end of the string
  mutate(
    Place = str_extract(Title, "\\S+$")
  ) |>
  
  # "\\[\\d+\\]" looks at the things inside the brackets, including the brackets themselves
  # and it gets replaced with white space
  mutate(
    Place = gsub("\\[\\d+\\]", "", Place)
  ) |>
  select(
    Surname1, Surname2, Surname3, Place, Status
  ) |>   
  group_by (
    Surname3
  ) |>
  
# move the surnames from width to length
  pivot_longer(
    cols = starts_with("Surname"),
    names_to = "Number",
    values_to = "Surname"
  ) |>

# don't need this for now
  select(
    -Number
    ) |>
    
# Time to pivot so that we get types of words!
  pivot_longer(
    cols = c(Surname, Place),
    names_to = "Type",
    values_to = "Word"
  ) |>
    
# Remove dupes
  unique() |>
    
# Remove empties
    filter(
      Word != ""
    ) |>
  arrange(
    Word, Type, Status,  
  )

# # # LOCATION MATCHES

# read in the county towns .csv
county_names <- read.csv(
  "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\words_input\\county_towns.csv"
) |>
  # fix format so we have one column of words to look for
  pivot_longer(
    cols = c(County, County_town),
    names_to = "Type",
    values_to = "C_Word"
  )

# # POWER CALCULATION

# create an artificial uncertainty indicator related to both geographical names and whether or not a house is extinct
powers <- full_list |>
  select(
    Word, Status
  ) |>
  unique(
  ) |>
  mutate(
    Location_Match = ifelse(str_detect(Word, paste(county_names$C_Word, collapse = "|")), "Yes", "No")
  ) |>
  # the 0.01 means that an extinct house will always render extinct, even if it has multiple extinct branches
  # but even one cross of extant and extinct will flag as a mixed status and reset to 1 max
  mutate(
    Power = ifelse((Status == "extant"), 1, 0.01)
  ) |>
  group_by(
    Word
  ) |>
  summarise(
    Power = ifelse((sum(Power) < 1), 0.5, 1)
  )

# merge; remove duplicate values
full_list <- full_list |>
  merge(
    powers
  ) |>
  filter(
    Status == "extant" | Status == "extinct" & Power == 0.5
  ) |>
  
  # check for county towns and counties
  mutate(
    Location_Match = ifelse(str_detect(Word, paste(county_names$C_Word, collapse = "|")), "Yes", "No")
  ) |>

  # change power in response to this
  mutate(
    "Power" = ifelse(Status == "extant", (ifelse(Location_Match == "No", 1, 0.5)), ifelse(Location_Match == "No", 0.5, 0.25))
  ) |>
  arrange(
    Type, Word, Status, Location_Match, Power
  )
  
# # # FIRST NAMES
  
# read in the monarch .csv
monarch_names <- read.csv(
  "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\words_input\\monarchs.csv"
) |>
    
  # add powers
  mutate(
    "Power" = ifelse(Status == "Monarch", 1, 0.5),
  
    # add location_match for consistency
    "Location_Match" = "No",
    "Type" = "First Name"
  ) |>
  rename(
    "Word" = "monarch_name"
  ) |>
  arrange(
    Type, Word, Status, Location_Match, Power
  )

# # # NOUNS

# read in the nouns .csv

noun_names <- read.csv(
  "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\words_input\\nouns.csv"
) |>
  
  # add powers
  mutate(
    "Power" = 1,
    
    # add location_match for consistency
    "Location_Match" = "No",
    "Type" = "Noun",
    "Status" = "Constant"
  ) |>
  rename(
    "Word" = "noun"
  ) |>
  arrange(
    Type, Word, Status, Location_Match, Power
  )

# # # ALL TOGETHER NOW

# smash the tables together
full_list <- as.data.frame(rbind(
  full_list, monarch_names, noun_names 
  ) |> 
  group_by(
    Word
  )
)

# write to disk
write.csv(full_list, 
          file = "C:\\Users\\siski\\OneDrive - University College London\\Projects\\Mapping\\Gentry-fication\\.words_output\\all_names.csv", 
          row.names = FALSE
)

# clear up
rm(county_names, full_list, ideal, monarch_names, noun_names, powers)
