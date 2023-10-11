# Maxine Cruz
# tmcruz@arizona.edu
# Created: 27 September 2023
# Last modified: 9 October 2023




# ----- ABOUT THE SCRIPT -----

# *** IN PROGRESS ***

# Attempts implementing ENMeval / Maxent based on ENMeval_example.R from Erin.

# Also this vignette: 
  # https://jamiemkass.github.io/ENMeval/articles/ENMeval-2.0-vignette.html

# Hopefully the formatting here will help me format the loop for all species in 
  # another script. So then everything can be consolidated into one script.

# A lot of this will be repeat from ENMeval_example.R, but typing it myself
  # helps me to learn the mechanics and concepts. But this will also include
  # the future distribution predictions from predicted climate changes.

# Changes will need to be made once raster is retired.




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

# DEAL WITH CLIMATE DATA --

# Convert to spatial points (data now represents geographical location)
# CRS: Coordinate Reference System
cp_spatial <- SpatialPoints(cp_data,
                            proj4string = CRS("+proj=longlat"))

# Download climate data from WorldClim (if not done previously)
current_env <- getData("worldclim", 
                       var = "bio", 
                       res = 2.5, 
                       path = "data/") 

# --

# *** TO DO: MOVE TO GEODATA PACKAGE - DOWNLOADING WORLDCLIM DATA ***

# worldclim_country(country = c("US", "MX"),
#                  var = "bio",
#                  res = 2.5,
#                  path = "data/worldclim_2-5")

# --

# Create a list of the files in wc2-5 folder for raster stack
clim_list <- list.files(path = "data/wc2-5/", 
                        pattern = ".bil$",
                        full.names = TRUE)

# Create RasterStack (collection of objects with same spatial extent/resolution)
clim <- raster::stack(clim_list)

# Only keep certain bioclimatic variables since some are just functions of others
# (a.k.a. they are redundant, and this can lead to over fitting)

# Removing bio3, bio7, bio10, bio11, and bio17 
# See https://www.worldclim.org/data/bioclim.html
clim <- dropLayer(clim, c("bio3", "bio7", "bio10", "bio11", "bio17"))

# Determine extent of C. pallida presence data in order to crop the climate data
# to appropriate values
geo_extent <- raster::extent(cp_spatial)

# Expand that extent by 50% to account for predicted distribution outside of
# the expected range
geo_extent_plus <- geo_extent * 1.5

# The class of geo_extent and geo_extent_plus is Extent

# Crop climate variables to the 150% extent of C. pallida
clim_crop <- raster::crop(clim, geo_extent_plus)

# clim_crop results in a RasterBrick, so we convert it back into a RasterStack
clim_crop <- raster::stack(clim_crop)

# Thin occurrence records so there's only one per raster cell
occurrences <- dismo::gridSample(cp_spatial, clim_crop, n = 1)

# Just 178 observations left

# A raster is a matrix of cells / pixels organized in a grid and represents info.
  # The matrix would be the study area.
  # Now there is only one C. pallida occurrence in each of those cells.


# PSEUDO-ABSENCE POINTS --

# Randomly select pseudo-absence points from the cropped raster (one per cell 
# without replacement). 
  # We'll use 100x the number of observations since the pseudo-absenses act as
  # a background of environmental variables.

# Generating random points only requires the raster grid format, so we'll just
# use one layer of clim_crop to do this.
background <- dismo::randomPoints(clim_crop[[1]], n = 17800)

# Use column names from occs df in background df
colnames(background) <- colnames(occurrences)


# PARAMETER SETTINGS --

# Tuning some parameters can control the complexity of the model.

  # Feature classes (fc) - sets relationship of climate variables to the
    # probability of species occurrence. Example: The linear feature class says
    # as the climate values increase, so does the probability of that species
    # occurring. Similarly, the quadratic would suggest that the species is more
    # likely to exist at moderate climate values as opposed to the extremes.

  # Regularization multipliers (rm) - dictates how smooth the model is. Helps
    # avoid over fitting the model and helps to regularize / generalize the
    # predictions.

# Here we first try modeling with fc = L, LQ, H, and LQH, and rm = 1, 2, and 3
tune.args <- list(fc = c("L", "LQ", "H", "LQH"), rm = 1:3)

# ENMevaluate is a cross-validation (CV) function.

  # ENM = Ecological Niche Model

  # Occurrence data is partitioned into validation and training bins (folds).

  # This is a k-fold CV method. Where the data is split into k groups ("folds")
    # of roughly equal size. One of the folds is used to create a model, and
    # this model is tested on the remaining k-1 folds. This is repeated k times
    # with each fold having a turn as model. More folds reduce bias but
    # increase variance, whereas the reverse increases bias but reduces variance.
  
# Here we will use the block method.
  # Splits data into four groups, each having roughly the same number of
  # occurrences. There are two bisections - one latitude and one longitude.

# Set seed for reproducibility purposes
set.seed(8)

# Create blocks with the occurrence and background (pseudo-absence) data
block <- get.block(occs = occurrences,
                   bg = background)

# Table to check number of occurrences in each block
table(block$occs.grp)

# Plot to check number of occurrences in each block
# evalplot.grps(pts = occurrences,
#               pts.grp = block$occs.grp,
#               envs = clim_crop)

# Table to check number of background points in each block
table(block$bg.grp)

# Plot to check number of background points in each block
# evalplot.grps(pts = background,
#               pts.grp = block$bg.grp,
#               envs = clim_crop)

# Create a list to feed these partitions to the ENMevaluate() function
user.grp <- list(occs.grp = block$occs.grp, 
                 bg.grp = block$bg.grp)

# Specify a couple other settings for the Maxent model
  # Default validation.g is "full" - CV is with respsect to full background.
  # The "partition" with respect to the partitioned background only 
    # (i.e. training occurrences are compared to training background, and 
    # validation occurrences compared to validation background). 

# We will use the partition method because it creates a more independent model
# to be tested against the others. There are other options for modifications:
# https://rdocumentation.org/packages/ENMeval/versions/2.0.4/topics/ENMevaluate
other.settings <- list(validation.bg = "partition")

# For parallel processing, use 2 fewer cores than are available
# (Creates less load on the CPU?)
num_cores <- parallel::detectCores() - 2


# MAXENT WITH ENMEVAL --

maxent_results <- ENMevaluate(occs = occurrences,
                              bg = background,
                              envs = clim_crop,
                              algorithm = "maxent", # Maxent model
                              tune.args = tune.args,
                              partitions = "user", # User-defined partitions
                              user.grp = user.grp,
                              other.settings = other.settings,
                              parallel = TRUE, # Allow parallel processing
                              numCores = num_cores)


# PICK "BEST" MODEL FOR INFERENCES --








