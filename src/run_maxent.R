# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 December 2023
# Last modified: 14 February 2024




# -- ABOUT --

# Runs Maxent (ENMeval) on four species:

  # Common name (Scientific name) - Taxon key
  # Desert / Digger Bee (Centris pallida) - 1342915
  # Blue Palo Verde (Parkinsonia florida) - 5359949
  # Foothill Palo Verde (Parkinsonia microphylla) - 5359945
  # Desert Ironwood (Olneya tesota) - 2974564

# There is script for a:
  # Current SDM
  # Future SDM

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

# Species occurence data
data <- read.csv("data/GBIF/cleaned_species.csv")

# Elevation data
dem <- rast(paste0("data/DEM", "/northamerica_elevation_cec_2023.tif"))




# ----- CURRENT SDM -----

# Climate data
clim <- terra::rast(list.files(path = "data/WORLDCLIM",
                                       pattern = ".tif$",
                                       full.names = TRUE))

# Change projection of dem to that of bioclim variables (may take a minute).
# Needs to be done before function modifications, but we are also doing it here
# so it doesn't have to run every pass (since it does take so long).
dem <- terra::project(dem, crs(clim))
  
# Species to loop through
spp_list <- unique(data$species)

# Function
for (i in 1:4) {
  
  # Get species to work with
  species <- data %>%
    filter(species == spp_list[i]) %>%
    dplyr::select(longitude, latitude)
  
  # Which species are we on
  print(paste("Currently processing data for:", spp_list[i]))
  
  # Run through Maxent
  sdm(species = species, clim = clim, current_or_future_sdm = "current")
  
  # Which species did we finish
  print(paste("Finished CURRENT Maxent for:", spp_list[i]))
  print("-------------------------")
  
}



# ----- FUTURE SDM -----

# Climate data
clim <- terra::rast(list.files(path = "data/CMIP6",
                               pattern = ".tif$",
                               full.names = TRUE))

# Function
for (i in 1:4) {
  
  # Get species to work with
  species <- data %>%
    filter(species == spp_list[i]) %>%
    dplyr::select(longitude, latitude)
  
  # Which species are we on
  print(paste("Currently processing data for:", spp_list[i]))
  
  # Run through Maxent
  sdm(species = species, clim = clim, current_or_future_sdm = "future")
  
  # Which species did we finish
  print(paste("Finished FUTURE Maxent for:", spp_list[i]))
  print("-------------------------")
  
}  
  
  
  
  
