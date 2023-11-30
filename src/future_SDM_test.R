# Maxine Cruz
# tmcruz@arizona.edu
# Created: 28 November 2023
# Last modified: 29 November 2023




# ----- ABOUT THE SCRIPT -----

# Introducing CMIP6 and DEM data involved transitioning to terra packages too.

# So, this script rewrites the future predictions using those.

# Workflow:
  # Load GBIF bee data
  # Load CMIP6 climate projection data
  # Load DEM data
  # 




# ----- LOAD DEPENDENCIES -----

library(sp)
library(terra)
library(raptr)
library(dplyr)
library(ENMeval)




# ----- LOAD BEE DATA -----

# Full data set
full_set <- read.csv("data/NAm_map_data_final.csv")

# Only C. pallida
cp_data <- full_set %>%
  filter(speciesKey == 1342915) %>%
  dplyr::select(longitude, latitude)

# Number of observations
num_obs <- nrow(cp_data)

# Convert to spatial points (data now represents geographical location)
# CRS: Coordinate Reference System
cp_data <- SpatialPoints(cp_data,
                         proj4string = CRS("+proj=longlat"))

# Determine extent of C. pallida presence data in order to crop the climate data
# to appropriate values
geo_extent <- ext(cp_data)

# Expand extent by 50% to account for predictions outside of the expected range
geo_extent_plus <- geo_extent * 1.5




# ----- LOAD CLIMATE DATA -----

# Using projected climate for 2041-2070 from an ensemble of CMIP6 GCMs 
  # under the SSP370 emissions scenario 

# Data acquisition from Jeff Oliver, at ~ 4 x 4 km resolution:
  # https://github.com/Big-Biodiversity-Collaborative/SwallowtailClimateChange/blob/main/src/data/prep-forecast-data.R

# Open climate data from CMIP6 ensemble
future_clim <- terra::rast(list.files(path = "data/biovars_ssp370_2041",
                                      pattern = ".tif$",
                                      full.names = TRUE))

# Crop climate variables to the 150% extent of C. pallida
future_clim <- terra::crop(future_clim, geo_extent_plus)




# ----- LOAD ELEVATION DATA -----

# DEM: Digital Elevation Model (in meters)

# Data from the Commission for Environmental Cooperation (CEC)
  # ~ 1 x 1 km resolution
  # http://www.cec.org/north-american-environmental-atlas/elevation-2007/

# Access elevation data
dem <- rast(paste0("data/dem_1km", "/na_elevation.tif"))

# Change projection to that of bioclim variables (may take a minute)
dem <- terra::project(dem, crs(future_clim))

# Crop to match that of bioclim variables
dem <- terra::crop(dem, ext(future_clim))

# The following is important so that both the climate and elevation can be used
  # in ENMevaluate() later. For both to be used, the CRS and the elevation
  # should be matching.

# Check that the CRS are matching
crs(future_clim)
crs(dem)

# Check that extents are matching
ext(future_clim)
ext(dem)

# 




# ----- PREPARE OCCURRENCE POINTS -----

# Thin occurrence records so there's only one per raster cell
occurrences <- dismo::gridSample(cp_data, future_clim, n = 1)




# ----- SET SEED -----

# For reproducibility in the remainder of the script
set.seed(2023)




#  ----- PREPARE BACKGROUND POINTS -----

# Generate random points
background <- raptr::randomPoints(future_clim[[1]], n = num_obs * 15)

# Apply column names from occurrences to background
colnames(background) <- colnames(occurrences)




# ----- PARAMETER SETTING AND K-FOLD BLOCKS -----

# Create blocks with the occurrence and background data
block <- get.block(occs = occurrences,
                   bg = background)

# Table to check number of occurrences in each block
table(block$occs.grp)

# Table to check number of background points in each block
table(block$bg.grp)

# Create a list to feed these partitions to the ENMevaluate() function
user.grp <- list(occs.grp = block$occs.grp, 
                 bg.grp = block$bg.grp)

# We try modeling with fc = L, LQ, H, and LQH, and rm = 1, 2, and 3
tune.args <- list(fc = c("L", "LQ", "H", "LQH"), rm = 1:3)

# Specify we are using both climate and elevation as predictors
envs <- c(future_clim, dem)

# We will use the partition method because it creates a more independent model
# to be tested against the others. There are other options for modifications:
# https://rdocumentation.org/packages/ENMeval/versions/2.0.4/topics/ENMevaluate
other.settings <- list(validation.bg = "partition")

# For parallel processing, use 2 fewer cores than are available
# (Creates less load on the CPU?)
num_cores <- parallel::detectCores() - 2




# ----- MAXENT -----

results <- ENMevaluate(occs = occurrences,
                       bg = background,
                       envs = envs,
                       algorithm = "maxnet", # Maxent model
                       tune.args = tune.args,
                       partitions = "user", # User-defined partitions
                       user.grp = user.grp,
                       other.settings = other.settings,
                       parallel = TRUE, # Allow parallel processing
                       numCores = num_cores)




# ----- FIND BEST MODEL -----






