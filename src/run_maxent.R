# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 December 2023
# Last modified: 18 December 2023




# -- ABOUT --

# Runs Maxent (ENMeval)
  # Current SDM
  # Future SDM

# Function for maxent code is in functions.R




# ----- LOAD LIBRARIES -----

# For converting to and working with spatial data
library(sp)
library(raster)
library(dismo)
library(terra)
library(raptr)
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
  print(paste("Finished Maxent for:", spp_list[i]))
  
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
  
  # Number of observations (for generating number of background points)
  num_obs <- nrow(species)
  
  # Run through Maxent
  sdm(species = species, clim = clim, current_or_future_sdm = "future")
  
  # Which species did we finish
  print(paste("Finished Maxent for:", spp_list[i]))
  
}  
  
  
  
  
