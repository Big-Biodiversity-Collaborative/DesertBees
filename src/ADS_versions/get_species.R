# Maxine Cruz
# tmcruz@arizona.edu
# Created: 5 December 2023
# Last modified: 4 January




# ----- ABOUT -----

# 1) Retrieves data from GBIF for the following species:

# (Replace with your own species below)

# Common name (Scientific name) - Taxon key
# Desert / Digger Bee (Centris pallida) - 1342915

# 2) Cleans data

# 3) Saves cleaned data as: data/ADS_versions/cleaned_species.csv




# ----- LOAD LIBRARIES -----

# For downloading data from GBIF
library(rgbif)

# For cleaning data
library(CoordinateCleaner)
library(dplyr)
library(sf)
library(sp)



# ----- GET DATA -----

# Request full occurrence record of organisms from GBIF

# NOTE: occ_download requires a setup with GBIF account on a .Renviron file
# See https://docs.ropensci.org/rgbif/articles/gbif_credentials.html

# Insert your own species' taxon key in the following line:

occ_download(pred_in("speciesKey", 1342915))

# Prints download and citation info that looks as follows:

# Download Info:
# Username: tmcruz
# E-mail: tmcruz@arizona.edu
# Format: DWCA
# Download key: 0045111-231120084113126
# Created: 2024-01-04T19:06:38.309+00:00

# Citation Info:  
# Please always cite the download DOI when using this data.
# https://www.gbif.org/citation-guidelines
# DOI: 10.15468/dl.sg6wbx

# Citation:
# GBIF Occurrence Download 
# https://doi.org/10.15468/dl.sg6wbx
# Accessed from R via rgbif (https://github.com/ropensci/rgbif) on 2024-01-04

# Retrieve download (replace with your own download key)
raw_data <- 
  occ_download_get(key = "0045111-231120084113126", path = "data/ADS_versions/") %>%
  occ_download_import()

# Below is to help track changes in data while we clean:
# 1093 observations, 212 variables

# Save raw data as csv
# (row.names = FALSE removes the random column that shows up if you don't do this)
write.csv(raw_data, "data/ADS_versions/raw_species.csv", 
          row.names = FALSE)




# ----- CLEAN DATA: FILTERING -----

# If starting here, read in the raw data (downloaded on _ January 2024)
raw_data <- read.csv("data/ADS_versions/raw_species.csv")

# 1093 observations, 212 variables

# Clean data
data <- raw_data %>%
  filter(!is.na(decimalLatitude), # Remove NA latitude / longitude values
         !is.na(decimalLongitude)) %>%
  filter(countryCode %in% c("US", "MX", "CA")) %>% # Keep records in study area of interest
  filter(!basisOfRecord %in% c("FOSSIL_SPECIMEN", "LIVING_SPECIMEN")) %>% # Remove fossil records / specimens (only removed 1 observation)
  cc_sea(lon = "decimalLongitude", # Organisms are land-dwellers, so remove records in the ocean
         lat = "decimalLatitude") %>%
  filter(hasGeospatialIssues == FALSE) %>% # Remove those with issues
  distinct(decimalLongitude, # Remove duplicates
           decimalLatitude, 
           speciesKey, 
           datasetKey, 
           .keep_all = TRUE)

# 298 observations, 212 variables

# Reduce columns to what is / might be necessary for analyses / figures
data <- data %>%
  select(61, 62, 63, 92, 93, 193, 192, 151, 174, 80, 79) %>%
  rename(latitude = decimalLatitude,
         longitude = decimalLongitude) %>%
  arrange(species, kingdom, year, month, day)

# 298 observations, 11 variables

# Column numbers identified using which(colnames(data) == "column_name")
# 61 = year
# 62 = month
# 63 = day
# 79 = countryCode
# 80 = stateProvince
# 92 = decimalLatitude
# 93 = decimalLongitude
# 151 = kingdom
# 174 = elevation
# 192 = speciesKey
# 193 = species




# ----- SAVE DATA -----

# Save as csv
write.csv(data, "data/ADS_versions/cleaned_species.csv", 
          row.names = FALSE)

# ---

# To check cleaning:

# library(leaflet)

# leaflet(cleaned_data) %>%
#   addProviderTiles("Esri.WorldImagery") %>%
#   addTiles(
#     urlTemplate = "https://tiles.stadiamaps.com/tiles/{variant}/{z}/{x}/{y}{r}.png?api_key={apikey}",
#     attribution = paste('&copy; <a href="https://stadiamaps.com/" target="_blank">Stadia Maps</a> ',
#                         '&copy; <a href="https://stamen.com/" target="_blank">Stamen Design</a> ',
#                         '&copy; <a href="https://openmaptiles.org/" target="_blank">OpenMapTiles</a> ',
#                         '&copy; <a href="https://www.openstreetmap.org/about" target="_blank">OpenStreetMap</a> contributors'),
#     options = tileOptions(variant = 'stamen_toner_lines', 
#                           apikey = 'd20cf594-4437-4c63-9cc1-59f58e5a7b89')
#   ) %>%
#   addCircleMarkers(
#     color = "#FF3E96",
#     radius = 3,
#     fillOpacity = 0.8,
#     stroke = FALSE)




