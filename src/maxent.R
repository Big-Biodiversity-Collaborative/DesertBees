# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 December 2023
# Last modified: 18 December 2023




# -- ABOUT --

# Runs Maxent (ENMeval)
  # Current SDM
  # Future SDM

# Function for maxent code is in functions.R




# ----- LOAD DATA -----

# Species occurence
data <- read.csv("data/GBIF/cleaned_species.csv")

# Elevation
dem <- rast(paste0("data/DEM", "/northamerica_elevation_cec_2023.tif"))




# ----- CURRENT SDM -----

# Climate data
clim <- terra::rast(list.files(path = "data/WORLDCLIM",
                                       pattern = ".tif$",
                                       full.names = TRUE))
  
# Function




# ----- FUTURE SDM -----

# Climate data
clim <- terra::rast(list.files(path = "data/CMIP6",
                               pattern = ".tif$",
                               full.names = TRUE))

# Function
  
  
  
  
  
