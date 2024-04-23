# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 December 2023
# Last modified: 16 April 2024




# ----- ABOUT -----

# Runs Maxent (ENMeval) on four species:

  # Common name (Scientific name) - Taxon key
  # Desert / Digger Bee (Centris pallida) - 1342915
  # Blue Palo Verde (Parkinsonia florida) - 5359949
  # Foothill Palo Verde (Parkinsonia microphylla) - 5359945
  # Desert Ironwood (Olneya tesota) - 2974564

# Generates predictions for current, 2021-2040, and 2041-2060 time periods.

# (SDM = Species Distribution Model)

# Code for sdm() is in functions.R




# ----- LOAD LIBRARIES -----

# For shapefiles
library(sf)
library(rnaturalearth)

# For converting to and working with spatial data
library(sp)
library(raster)
library(dismo)
library(terra)
library(dplyr)

# For maxent
library(ENMeval)

# Function
source("functions.R")



# ----- LOAD DATA -----

# Species occurrence data
data <- read.csv("data/gbif/cleaned_species_with_elevation.csv")

# Elevation data
dem_initial <- rast("data/dem/northamerica_elevation_cec_2023.tif")




# ----- RUN SPECIES DISTRIBUTION MODEL -----

# Climate data for model generation
clim <- terra::rast(list.files(path = "data/worldclim",
                                       pattern = ".tif$",
                                       full.names = TRUE))

# Change projection of dem to that of bioclim variables (may take a minute).
# Needs to be done before function modifications, but we are also doing it here
# so it doesn't have to run every pass using WorldClim (it does take so long).
dem <- terra::project(dem_initial, crs(clim))
  
# Species to loop through
spp_list <- unique(data$species)

# Before running and using sdm():
  # If new shapefiles are needed, 
  # First delete shapefiles in output/shapefiles/ 
  # Then the folllowing loop can be run.

# Function
for (i in 1:4) {
  
  # Get species to work with
  species_data <- data %>%
    filter(species == spp_list[i]) %>%
    filter(elevation > 0 | is.na(elevation)) %>%
    select(longitude, latitude)
  
  # Which species are we on
  message(paste0("Currently analyzing: ", spp_list[i]))
  
  # Run through Maxent
  sdm(species_data = species_data)
  
  # Which species did we finish
  message(paste0("Finished analysis for: ", spp_list[i]))
  message("--------------------------------------------")
  
}



