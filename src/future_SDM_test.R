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
library(raster)
library(dismo)
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

# Resample DEM so that extent can match that of the climate data
# (Important for stacking SpatRasters)
dem <- resample(dem, future_clim)

# Check extents
ext(dem)
ext(future_clim)




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

# Save this table
write.csv(eval_table, "output/enmeval_futurepred_results.csv")

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

pred_df <- as.data.frame(pred_spdf)

# Range plots
raster_spdf <- as(range, "SpatialPixelsDataFrame")

range_df <- as.data.frame(raster_spdf)

range_df$layer <- as.factor(range_df$layer)




# ----- PLOT DISTRIBUTION MAPS -----

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")

# Set boundaries where map should be focused
xmax <- max(pred_df$x)
xmin <- min(pred_df$x)
ymax <- max(pred_df$y)
ymin <- min(pred_df$y)

# Environmental suitability prediction map
ggplot() +
  geom_raster(data = future_pred_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours=viridis::viridis(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

# Save
ggsave(file = "output/enmeval_future_distribution.png",
       width = 25,
       height = 15,
       units = "cm")

# Range prediction map
ggplot() +
  geom_raster(data = future_range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin2, xmax2), 
              ylim = c(ymin2, ymax2), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = bquote(bold("50 Years into the Future")),
       x = "Longitude",
       y = "Latitude") + 
  theme(legend.position = "none")

# Save
ggsave(file = "output/enmeval_test_future_range.png",
       width = 25,
       height = 15,
       units = "cm")


