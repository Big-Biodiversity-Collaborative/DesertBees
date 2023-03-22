# Maxine Cruz
# tmcruz@arizona.edu
# Created: 13 March 2023
# Last modified: 22 March 2023



### ABOUT THE SCRIPT ---

# Loads dependencies

# Loads, cleans, and exports data

# Maps occurrence of the following organisms

# Organism of interest: 
  # Desert / Digger bee (Centris pallida)

# Host plants: 
  # Palo verde (Parkinsonia florida, Parkinsonia microphylla, P. aculeata)
  # Desert ironweed (Olneya tesota)
  # Some might be listed under Cercidium (former name of Parkinsonia genus)
  # Creosote bush (Larrea tridentata)



### LOAD LIBRARIES ---

library(rgbif)
library(readr)
library(tidyverse)
library(leaflet)



### PULL DATA ---

# Taxon keys from GBIF
  # Centris pallida - 1342915
  # Parkinsonia florida - 5359949
  # Parkinsonia microphylla - 5359945
  # Parkinsonia aculeata - 5357217
  # Larrea tridentata - 7568403
  # Olneya tesota - 2974564
  # Cercidium spp. - NA

# Request full occurrence record of C. pallida and host plants from GBIF
# occ_download requires a setup with GBIF account on a .Renviron file
# See https://docs.ropensci.org/rgbif/articles/gbif_credentials.html
# Download takes at least 15 minutes 
# Following line will retrieve a large dataset,
# since I already have it in my system I have commented it out
# occ_download(pred_in("taxonKey", c(1342915, 5359949, 5359945,
#                                    5357217, 7568403)))

# Retrieve download
# Two following lines retrieves the data from my own account
# full_data <- occ_download_get("0095579-230224095556074") %>%
#   occ_download_import()

# Download gives table with 120454 observations and 259 variables

# To avoid odd complications, the .zip was added to .gitignore

# Save raw download to data folder
# write_csv(full_data, "data/gbif_rawdata_full.csv")

# --- Added 3/19/2023 ---

# Olneya tesota is a late addition
# Since it is only one key, pred() is sufficient
# occ_download(pred("taxonKey", 2974564))

# Retrieve download
# otesota_data <- occ_download_get('0103311-230224095556074') %>%
#   occ_download_import()

# Download gives table with 4562 observations and 259 variables

# Save raw download to data folder
# write_csv(otesota_data, "data/gbif_rawdata_otesota.csv")



### CLEAN FOR PLOTTING ---

# Read csv
map_data <- read_csv("data/gbif_rawdata_full.csv")

# 120454 observations, 259 variables

# Remove duplicate observations
map_data <- distinct(map_data)

# 120454 observations, 259 variables

# Remove observations with NA latitude / longitude
map_data <- map_data[!is.na(map_data$decimalLatitude), ]
map_data <- map_data[!is.na(map_data$decimalLongitude), ]

# 113519 observations, 259 variables

# Reduce columns to what is / might be necessary for mapping
# Numbers correspond to specific columns in the full raw data
map_data <- select(map_data, 107, 108, 109, 240, 203, 207, 138, 139, 125)

# 113519 observations, 9 variables

# Rename columns
colnames(map_data)[6] = "species"
colnames(map_data)[7] = "latitude"
colnames(map_data)[8] = "longitude"

# Save reduced and cleaned data to data folder
write_csv(map_data, "data/map_data.csv")

# --- Added 3/19/2023 ---

# Read csv
map_data2 <- read_csv("data/gbif_rawdata_otesota.csv")

# 4562 observations, 259 columns

# Remove observations with NA latitude / longitude
map_data2 <- map_data2[!is.na(map_data2$decimalLatitude), ]
map_data2 <- map_data2[!is.na(map_data2$decimalLongitude), ]

# 4101 observations, 9 variables

# Since Olneya tesota is a new additon, it will be merged to the initial data
# Columns retained should be the same
map_data2 <- select(map_data2, 107, 108, 109, 240, 203, 207, 138, 139, 125)

# Gives 4562 observations and 9 variables

# Rename columns
colnames(map_data2)[6] = "species"
colnames(map_data2)[7] = "latitude"
colnames(map_data2)[8] = "longitude"

# Save reduced and cleaned data to data folder
write_csv(map_data2, "data/map_data2.csv")

# Combine initial data with Olneya tesota data
full_map_data <- rbind(map_data, map_data2)

# Gives new dataframe with 1117620 observations and 9 variables

# Save complete map data
write_csv(full_map_data, "data/full_map_data.csv")

# Create separate map data limited to North America
# Filter where countryCode is United States (US) or Mexico (MX)
# Plotting full world shows no data in Canada, so that is omitted
NAm_map_data <- full_map_data %>%
  filter(countryCode == "US" | countryCode == "MX")

# Gives new dataframe with 73143 observations and 9 variables

# Save North America map data
write_csv(NAm_map_data, "data/NAm_map_data.csv")

# Save a copy to R Shiny folder for alternative mapping
write_csv(NAm_map_data, "ShinyDesertBees/data/NAm_map_data.csv")



### PLOT OCCURRENCE MAP --

# Open map_data.csv
map_data <- read_csv("data/NAm_map_data.csv")

# Assign each species a different color
map_data <- map_data %>% 
  mutate(point_color = case_when(speciesKey == 1342915 ~ "#FF3E96",
                                 speciesKey == 5359949 ~ "#C0FF3E",
                                 speciesKey == 5359945 ~ "#00FFFF",
                                 speciesKey == 5357217 ~ "#FFA500",
                                 speciesKey == 7568403 ~ "#EED2EE",
                                 speciesKey == 2974564 ~ "#E066FF"))

# Gives 68488 observations and 10 variables

# Number of records for each organism will be included on the map
table(map_data$speciesKey)

# Gives a table with counts of each species records (in North America)
  # Centris pallida (1342915) - 220
  # Parkinsonia florida (5359949) - 3056
  # Parkinsonia microphylla (5359945) - 3659
  # Parkinsonia aculeata (5357217) - 6469
  # Larrea tridentata (7568403) - 51215
  # Olneya tesota (2974564) - 3869

# Generate map
leaflet(map_data) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addProviderTiles("Stamen.TonerLines") %>%
  addCircles(
    color = map_data$point_color,
    fillColor = map_data$point_color,
    fillOpacity = 0.8) %>%
  addLegend(position = "bottomleft",
            colors = c("#FF3E96", "#FFA500", "#C0FF3E", 
                                "#00FFFF", "#EED2EE", "#E066FF"),
            labels = c("Centris pallida (220)", 
                       "Parkinsonia aculeata (6469)",
                       "Parkinsonia florida (3056)", 
                       "Parkinsonia microphylla (3659)",
                       "Larrea tridentata (51215)", 
                       "Olneya tesota (3869)"),
            title = "Legend of Species (# records in North America)",
            opacity = 1) %>%
  setView(lng = -111.362048, lat = 30.462234, zoom = 4.4)


