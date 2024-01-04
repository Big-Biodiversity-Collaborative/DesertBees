# Maxine Cruz
# tmcruz@arizona.edu
# Created: 28 November 2023
# Last modified: 4 January 2024




# ----- ABOUT -----

# Code for teaching purposes (Applied Data Science)

# This is the same code used in run_maxent.R and distribution_and_range_maps.R,
# but has been re-formatted so that the following is all in one script:

  # CURRENT species distribution model
  # Generating plots of predictions




# ----- LOAD LIBRARIES -----

# For modeling
library(sp)
library(raster)
library(dismo)
library(terra)
library(raptr)
library(ENMeval)

# For data prep
library(dplyr)

# For plotting
library(ggplot2)




# ----- LOAD SPECIES DATA -----

# Full data set
data <- read.csv("data/ADS_versions/cleaned_species.csv")

# Only need the latitude and longitude for the model
data <- data %>%
  dplyr::select(longitude, latitude)

# Convert to spatial points (data now represents geographical location)
# CRS: Coordinate Reference System
sp_data <- SpatialPoints(data,
                         proj4string = CRS("+proj=longlat"))

# Determine extent of species presence data in order to crop the climate data
# to appropriate values
geo_extent <- ext(sp_data)

# Expand extent by 50% to account for predictions outside of the expected range
geo_extent <- geo_extent * 1.5




# ----- LOAD CLIMATE DATA -----

# Data acquisition from WorldClim 2.1 
# Done by Jeff Oliver, at ~ 21 x 21 km resolution:
# https://github.com/Big-Biodiversity-Collaborative/SwallowtailClimateChange/blob/main/src/data/prep-forecast-data.R

# Open climate data
clim <- terra::rast(list.files(path = "data/WORLDCLIM",
                                      pattern = ".tif$",
                                      full.names = TRUE))

# Crop climate variables to the 150% extent of species
clim <- terra::crop(clim, geo_extent)




# ----- LOAD ELEVATION DATA -----

# DEM: Digital Elevation Model (in meters)

# Elevation data may also help in predicting where else species might occur

# Data from the Commission for Environmental Cooperation (CEC)
# ~ 1 x 1 km resolution
# http://www.cec.org/north-american-environmental-atlas/elevation-2007/

# Access elevation data
dem <- rast(paste0("data/DEM", "/northamerica_elevation_cec_2023.tif"))

# Change projection to that of bioclim variables (may take a minute)
dem <- terra::project(dem, crs(clim))

# Crop to match that of bioclim variables
dem <- terra::crop(dem, ext(clim))

# Resample DEM so that extent can match that of the climate data
# (Important for stacking SpatRasters)
dem <- resample(dem, clim)

# Check extents (if they don't match, we won't be able to use both in the model)
ext(dem)
ext(clim)




# ----- PREPARE OCCURRENCE POINTS -----

# Thin occurrence records so there's only one per raster cell
occurrences <- dismo::gridSample(sp_data, clim, n = 1)




# ----- SET SEED -----

# For reproducibility in the remainder of the script
set.seed(2024)




#  ----- PREPARE BACKGROUND POINTS -----

# Generate random points
# https://besjournals.onlinelibrary.wiley.com/doi/10.1111/j.2041-210X.2011.00172.x
background <- raptr::randomPoints(clim[[1]], n = 10000)

# Apply column names from occurrences to background
colnames(background) <- colnames(occurrences)




# ----- PARAMETER SETTING AND K-FOLD BLOCKS -----

# Helpful guide to Maxent:
# https://nsojournals.onlinelibrary.wiley.com/doi/full/10.1111/j.1600-0587.2013.07872.x

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
envs <- c(clim, dem)

# We will use the partition method because it creates a more independent model
# to be tested against the others. There are other options for modifications:
# https://rdocumentation.org/packages/ENMeval/versions/2.0.4/topics/ENMevaluate
other.settings <- list(validation.bg = "partition")

# For parallel processing, use 2 fewer cores than are available
# (Creates less load on the CPU?)
# Note to self: There are 20 total according to the ENMevaluate messages
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

# Look at table with evaluation metrics for each set of tuning parameters
eval_table <- results@results

# Filter for optimal model
optimal <- results@results %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

# Extract the optimal model
best <- results@models[[optimal$tune.args]]




# ----- USING OPTIMAL MODEL FOR PREDICTIONS -----

# Convert predictors from SpatRaster to RasterStack
# (enm.maxnet only takes raster objects at the moment)
envs_r <- raster::stack(envs)

# (A) DISTRIBUTION:

# Generate raster with predicted suitability values
pred_vals <- enm.maxnet@predict(best, 
                                envs_r,
                                list(pred.type = "cloglog",
                                     doClamp = FALSE))

# (B) RANGE:

# Extract predicted suitability values for occurrence locations
pred_occ <- raster::extract(pred_vals, occurrences)

# Extract predicted suitability values for background locations
pred_bg <- raster::extract(pred_vals, background)

# Evaluate models - gives ModelEvaluation object
eval <- dismo::evaluate(pred_occ, pred_bg)

# Use a max(spec + sens) threshold to convert probabilities into binary values 
# (1 = part of species' predicted range; 0 = outside of range) - gives a Value
threshold <- dismo::threshold(eval, stat = "spec_sens")

# For predicting range, find predicted values greater than the threshold
range <- pred_vals > threshold




# ----- PREPARE DATA FOR PLOTTING -----

# Environmental suitability plots
pred_spdf <- as(pred_vals, "SpatialPixelsDataFrame")

dist_df <- as.data.frame(pred_spdf)

# Range plots
raster_spdf <- as(range, "SpatialPixelsDataFrame")

range_df <- as.data.frame(raster_spdf)

range_df$layer <- as.factor(range_df$layer)




# ----- PLOT MAPS -----

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")

# Set boundaries where map should be focused
xmax <- max(dist_df$x)
xmin <- min(dist_df$x)
ymax <- max(dist_df$y)
ymin <- min(dist_df$y)

# ENVIRONMENTAL SUITABILITY MAP --
ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours=viridis::viridis(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  geom_point(data = data,
             aes(x = longitude, y = latitude)) +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

# Save
ggsave(file = "output/ADS_versions/current_distribution.png",
       width = 25,
       height = 15,
       units = "cm")

# RANGE MAP --
ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/ADS_versions/current_range.png",
       width = 25,
       height = 15,
       units = "cm")
