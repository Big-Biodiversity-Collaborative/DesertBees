# Maxine Cruz
# tmcruz@arizona.edu
# Created: 27 September 2023
# Last modified: 9 October 2023




# ----- ABOUT THE SCRIPT -----

# *** IN PROGRESS ***

# Attempts implementing ENMeval / Maxent based on ENMeval_example.R from Erin.

# Hopefully the formatting here will help me format the loop for all species in 
  # another script. So then everything can be consolidated into one script.

# A lot of this will be repeat from ENMeval_example.R, but typing it myself
  # helps me to learn the mechanics and concepts. But this will also include
  # the future distribution predictions from predicted climate changes.




# ----- LOAD LIBRARIES -----

library(stringr)
library(ENMeval)
library(raster)
library(dplyr)
library(dismo)
library(ggplot2)

library(geodata)



# ----- LOAD DATA -----

# Full data set
full_set <- read.csv("data/NAm_map_data_final.csv")

# Only C. pallida
cp_data <- full_set %>%
  filter(speciesKey == 1342915) %>%
  dplyr::select(longitude, latitude)




# ----- CURRENT PREDICTED SDM -----

# Convert to spatial points (data now represents geographical location)
# CRS: Coordinate Reference System
cp_spatial <- SpatialPoints(cp_data,
                            proj4string = CRS("+proj=longlat"))

# Download climate data from WorldClim (if not done previously)
current_env <- getData("worldclim", 
                       var = "bio", 
                       res = 2.5, 
                       path = "data/") 

# *** TO DO: MOVE TO GEODATA PACKAGE - WORLDCLIM ***
# worldclim_country(country = c("US", "MX"),
#                  var = "bio",
#                  res = 2.5,
#                  path = "data/worldclim_2pt5")

# Create a list of the files in wc2-5 folder for raster stack
clim_list <- list.files(path = "data/wc2-5/", 
                        pattern = ".bil$",
                        full.names = TRUE)

# Create RasterStack (collection of objects with same spatial extent/resolution)
clim <- raster::stack(clim_list)














