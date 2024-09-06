# Maxine Cruz
# tmcruz@arizona.edu
# Created: 2 September 2024
# Last modified: 2 September 2024




# ----- ABOUT -----

# THIS IS A TEST TO CHECK MODEL OUTPUTS

# (1) What happens if we don't remove observations per Steve's requests?
  # Plot current/future maxent maps with ALL observations included
    # e.g. No removal of observations "outside" of expected areas and
    # no removal of those recorded below sea level (0 m)

  # The results for (1) were attained by running the script before adding the 
    # "re-scale elevation" section.

# (2) What happens if we re-scale the elevation raster?
  # Plot current/future maxent maps with ALL observations included 
  # Distributions were estimated using a re-scaled elevation raster 
    # e.g. Lowest elevation x becomes 0m, and scale from there
    # All points become +x

  # Results for (2) were attained after adding the re-scale elevation section.

# (3) Make a plot showing current maps, results from (1), and results from (2)




# ----- OBSERVATIONS WITHOUT REMOVAL -----

# Here we make a new set of data that is cleaned, but no polygons remove points
  # "outside" what is expected. Nor will points with certain elevations be
  # omitted.

# This section only needs to be done once, I just needed un-cropped data.


# -- LIBRARIES --

library(CoordinateCleaner)
library(dplyr)
library(terra)


# -- CLEAN DATA --

# Read in the raw data (downloaded on 7 December 2023)
raw_data <- read.csv("data/gbif/raw_species.csv")

# Number of observations (nrow(filter(raw_data, speciesKey == ___))):
# C. pallida = 1089
# O. tesota = 5453
# P. florida = 4747
# P. microphylla = 5191

# 16480 observations, 223 variables

# Clean data
data <- raw_data %>%
  # Remove NA latitude / longitude values (14686, removes 1794)
  filter(!is.na(decimalLatitude), 
         !is.na(decimalLongitude)) %>%
  # Keep records in study area of interest (14682, removes 4)
  filter(countryCode %in% c("US", "MX", "CA")) %>% 
  # Remove fossil records / specimens (14681, removes 1)
  filter(!basisOfRecord %in% "LIVING_SPECIMEN") %>% 
  # Organisms are land-dwellers, so remove records in the ocean (14237, removes 444)
  cc_sea(lon = "decimalLongitude", 
         lat = "decimalLatitude") %>%
  # Remove those with issues (14236, removes 1)
  filter(hasGeospatialIssues == FALSE) %>% 
  # Remove duplicates (13228, removes 988)
  distinct(decimalLongitude, 
           decimalLatitude, 
           year,
           month,
           day,
           speciesKey, 
           datasetKey, 
           .keep_all = TRUE)

# 13228 observations, 223 variables

# Number of observations:
# C. pallida = 317
# O. tesota = 4605
# P. florida = 3781
# P. microphylla = 4525

# Reduce columns to what is / might be necessary for analyses / figures
data <- data %>%
  select(67, 68, 69, 98, 99, 202, 201, 157, 183, 86, 85) %>%
  rename(latitude = decimalLatitude,
         longitude = decimalLongitude) %>%
  arrange(species, kingdom, year, month, day)

# 13228 observations, 11 variables

# Save as csv
write.csv(data, "data/gbif/cleaned_species_keep_all.csv", row.names = FALSE)


# -- FIND MISSING ELEVATIONS --

# Species occurence data
data <- read.csv("data/gbif/cleaned_species_keep_all.csv")

# Elevation data
dem <- rast("data/dem/northamerica_elevation_cec_2023.tif")

# Climate data
clim <- terra::rast(list.files(path = "data/worldclim",
                               pattern = ".tif$",
                               full.names = TRUE))

# Change projection of dem to that of bioclim variables (may take a minute)
dem <- terra::project(dem, crs(clim))

# Isolate lat/long
coords <- data %>%
  select(longitude, latitude)

# Convert to spatial points
spp <- SpatialPoints(coords,
                     proj4string = CRS("+proj=longlat"))

# Convert to SpatVector
occs <- vect(spp)

# Extract elevation values for occurrence points
elevocc <- terra::extract(dem, occs, ID = TRUE) %>%
  cbind(geom(occs))

# Isolate lat/long and elevation
elevocc <- elevocc %>%
  select(6, 5, 2) %>%
  rename(latitude = y,
         longitude = x,
         elevation = northamerica_elevation_cec_2023)

# Merge newly acquired elevations to original data frame
data <- cbind(elevocc, data)

# Check merge!!!

# Make vector of matching coordinates for checking
check <- ifelse(data[1] == data[7] & data[2] == data[8], 1, 0)

# Check that all are matching
length(unique(check)) == 1 

# If all TRUE, proceed

# Remove columns
data <- data %>%
  select(4, 5, 6, 7, 8, 9, 10, 11, 3, 13, 14)

# Save new data
write.csv(data, "data/gbif/cleaned_species_keep_all_with_elevation.csv", 
          row.names = FALSE)




# ----- [TEST A]: KEEP ALL OBSERVATIONS -----

# ----- MODEL PREP -----

# -- LIBRARIES --

# For converting to and working with spatial data
library(sp)
library(raster)
library(dismo)
library(terra)
library(dplyr)

# For maxent
library(ENMeval)


# -- PREP SPECIES DATA --

# Load species data
data <- read.csv("data/gbif/cleaned_species_keep_all_with_elevation.csv")

# Species list
spp_list <- unique(data$species)

# Species we'll be testing with is C. pallida
species_data <- data %>%
  filter(species == spp_list[1]) %>%
  select(longitude, latitude)

# Convert species observations to spatial points
spp <- SpatialPoints(species_data,
                     proj4string = CRS("+proj=longlat"))


# -- CREATE BUFFER --

# So we're not predicting over the entire continent
  # Just enough to account for dispersal over time

# Create vector of the spatial points
vec <- vect(spp)

# Create minimum bounding polygon (takes outermost points to create polygon)
hull <- convHull(vec)

# To check polygon:
# hull_s <- as(hull, "Spatial")
# mapview(spp) + mapview(hull_s)

# If points are not showing on mapview():
# mapviewOptions(fgb = FALSE)

# The "width = " is in meters, and we'll assume dispersal for any species
# at most is 150000 meters (bee foraging or tree seed).
# Also accounting for shifts in range.
geo_extent <- buffer(x = hull, width = 150000)


# -- PREP CLIMATE AND ELEVATION DATA --

# Load elevation data
dem_initial <- rast("data/dem/northamerica_elevation_cec_2023.tif")

# Climate data
clim <- terra::rast(list.files(path = "data/worldclim",
                               pattern = ".tif$",
                               full.names = TRUE))

# Change projection of DEM so we can do the next steps
dem_mod <- terra::project(dem_initial, crs(clim))

# Crop and mask elevation to the buffer boundaries
dem_mod <- dem_mod %>%
  terra::crop(geo_extent, snap = "out") %>%
  terra::mask(geo_extent)

# Crop and mask climate to the buffer boundaries
clim_mod <- clim %>%
  terra::crop(geo_extent, snap = "out") %>%
  terra::mask(geo_extent)

# Resample dem_mod so that extent can match that of the climate data
# (Important for stacking SpatRasters)
dem_mod <- resample(dem_mod, clim)

# Crop and mask climate to match DEM
clim_mod <- clim %>%
  terra::crop(dem_mod, snap = "out") %>%
  terra::mask(dem_mod)

# Plotting clim_mod and dem_mod will show them on the same scale now
  # plot(clim_mod[[1]])
  # plot(dem_mod)


# -- THIN OCCURRENCES --

# Thin occurrence records so there's only one per raster cell
occurrences <- dismo::gridSample(spp, clim_mod[[1]], n = 1)


# -- REPRODUCIBILITY PURPOSES --

# For reproducibility in the remainder of the script
set.seed(2023)


# -- BACKGROUND POINTS --

# Generate random points
background <- terra::spatSample(x = clim_mod[[1]],  
                                size = 10000,
                                method = "random",
                                na.rm = TRUE,
                                values = FALSE,
                                xy = TRUE)

# Apply column names from occurrences to background
colnames(background) <- colnames(occurrences)


# -- K-FOLD BLOCKS --

# Create blocks with the occurrence and background data
block <- get.block(occs = occurrences,
                   bg = background)

# Table to check number of occurrences in each block
message("Number of occurrences per block:")
print(table(block$occs.grp))

# Table to check number of background points in each block
message("Number of background points per block:")
print(table(block$bg.grp))

# Check: 
  # clim_mod_r <- raster::stack(clim_mod)
  # evalplot.grps(pts = occurrences, pts.grp = block$occs.grp, envs = clim_mod_r)
  # evalplot.grps(pts = background, pts.grp = block$bg.grp, envs = clim_mod_r)


# -- MODEL PARAMETERS --

# Create a list to feed these partitions to the ENMevaluate() function
user.grp <- list(occs.grp = block$occs.grp, 
                 bg.grp = block$bg.grp)

# We try modeling with fc = L, LQ, LQH, and H, and rm = 1, 2, and 3
tune.args <- list(fc = c("L", "LQ", "LQH", "H"), rm = 1:3)

# Specify we are using both climate and elevation as predictors
envs <- c(clim_mod, dem_mod)

# Names for complete set of variables
vars_to_remove <- c("bio3", "bio7")

# Convert to Raster to easily remove variables
envs <- raster::stack(envs)

# Drop layers containing unwanted variables
envs <- dropLayer(envs, vars_to_remove)

# Convert back to SpatRaster
envs <- terra::rast(envs)

# We will use the partition method because it creates a more independent model
# to be tested against the others. There are other options for modifications:
# https://rdocumentation.org/packages/ENMeval/versions/2.0.4/topics/ENMevaluate
other.settings <- list(validation.bg = "partition")

# For parallel processing, use 2 fewer cores than are available
# (Creates less load on the CPU?)
# Note to self: There are 20 total according to the ENMevaluate messages
num_cores <- parallel::detectCores() - 2




# ----- RUN MAXENT -----

# Run SDM
results <- ENMevaluate(occs = occurrences,
                       bg = background,
                       envs = envs,
                       algorithm = "maxnet", 
                       tune.args = tune.args,
                       partitions = "user", 
                       user.grp = user.grp,
                       other.settings = other.settings,
                       parallel = TRUE, # Allow parallel processing
                       numCores = num_cores)




# ----- FIND THE OPTIMAL MODEL -----

# Look at table with evaluation metrics for each set of tuning parameters
eval_table <- results@results

# And save file
write.csv(eval_table, 
          paste0("output/tests/parameter_results.csv"),
          row.names = FALSE)

# Filter for optimal model
optimal <- results@results %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

# Extract the optimal model
best_model <- results@models[[optimal$tune.args]]

# Find non-zero coefficients 
betas <- as.data.frame(best_model$betas)

# Rename silly column
names(betas)[names(betas) == "best_model$betas"] <- "predictor_value"

# Arrange relation value (probably not the right term) in decreasing fashion
betas <- betas %>% 
  arrange(desc(predictor_value))

# And save file
write.csv(betas, 
          paste0("output/tests/predictor_values.csv"))




# ----- FORECAST MODEL -----

# List of climate scenarios to make predictions for (folder path after data/)
clim_ids <- c("worldclim",
              "ensemble/ssp245/2021")

# Loop through each climate period and generate predictions for each
for (clim_id in clim_ids) {
  
  
  
  # --- GET CLIMATE SCENARIO TO MAKE PREDICTIONS FOR ---
  
  # Get climate data path
  clim_file <- paste0("data/", clim_id)
  
  # Load data
  clim <- terra::rast(list.files(path = clim_file,
                                 pattern = ".tif$",
                                 full.names = TRUE))
  
  # Note start of prediction for this climate scenario
  message(paste0(Sys.time(), " | Prediction started for ", clim_id, "."))
  
  
  
  # --- RE-PROJECT ELEVATION DATA FOR THAT CLIMATE SCENARIO ---
  
  # Since each climate data may have a different projection, we will need to
  # make sure to run terra::project() again for each.
  
  # Change projection of elevation for that climate (will take a minute)
  dem_mod <- terra::project(dem_initial, crs(clim))
  
  # Note end of process
  message(paste0(Sys.time(), " | Matched projection of DEM to ", clim_id, " climate."))
  
  
  
  # --- PREPARE ELEVATION AND CLIMATE PREDICTORS ---
  
  # Crop and mask elevation to the buffer boundaries
  dem_mod <- dem_mod %>%
    terra::crop(geo_extent, snap = "out") %>%
    terra::mask(geo_extent)
  
  # Crop and mask climate to the buffer boundaries
  clim_mod <- clim %>%
    terra::crop(geo_extent, snap = "out") %>%
    terra::mask(geo_extent)
  
  # Resample dem_mod so that extent can match that of the climate data
  # (Important for stacking SpatRasters)
  dem_mod <- resample(dem_mod, clim_mod)
  
  # Crop and mask climate to dem_mod (removes extreme elevation areas)
  clim_mod <- clim_mod %>%
    terra::crop(dem_mod, snap = "out") %>%
    terra::mask(dem_mod)
  
  # Check: plot(clim_mod[[1]])
  
  # Check extents: ext(dem_mod) and ext(clim_mod)
  
  # Note that process is done
  message(paste0(Sys.time(), " | Climate data has been cropped."))
  
  
  
  # --- COMBINE PREDICTORS FOR THIS CLIMATE SCENARIO ---
  
  # Combine to one object
  envs <- c(clim_mod, dem_mod)
  
  # Convert predictors from SpatRaster to RasterStack
  # (enm.maxnet only takes raster objects at the moment)
  envs_r <- raster::stack(envs)
  
  # Note that process is done
  message(paste0(Sys.time(), " | Predictors prepared."))
  
  
  
  # --- GENERATE PREDICTIONS ---
  
  # Generate raster with predicted suitability values
  pred_vals <- enm.maxnet@predict(best_model, 
                                  envs_r,
                                  list(pred.type = "cloglog",
                                       doClamp = FALSE))
  
  # Make a copy of the raster for visualizations
  pred_vals_plotting <- pred_vals
  
  # Set any values below 0.5 to missing so audience is just aware of the "more suitable" areas
  pred_vals_plotting[pred_vals_plotting < 0.50] <- NA
  
  # Note that process is done
  message(paste0(Sys.time(), " | Predicted distribution for ", clim_id, " is done."))
  
  
  
  # --- SAVE PREDICTIONS TO OUTPUT FOLDER ---
  
  # (A.1) ORIGINAL VALUES ---
  
  # As raster
  writeRaster(pred_vals,
              paste0("output/tests/", gsub("/", "_", gsub("ensemble/", "", clim_id)), "_predicted_distribution.tif"))
  
  # Convert to SpatialPixelsDataFrame
  pred_spdf <- as(pred_vals, "SpatialPixelsDataFrame")
  
  # Convert to data frame
  pred_df <- as.data.frame(pred_spdf)
  
  # Save file
  write.csv(pred_df, 
            paste0("output/tests/", gsub("/", "_", gsub("ensemble/", "", clim_id)), "_predicted_distribution.csv"),
            row.names = FALSE)
  
  # (A.2) ONLY >50% CHANCE SUITABLE VALUES ---
  
  # As raster
  writeRaster(pred_vals_plotting,
              paste0("output/tests/", gsub("/", "_", gsub("ensemble/", "", clim_id)), "_predicted_distribution_adjusted.tif"))
  
  # Convert to SpatialPixelsDataFrame
  pred_spdf <- as(pred_vals_plotting, "SpatialPixelsDataFrame")
  
  # Convert to data frame
  pred_df <- as.data.frame(pred_spdf)
  
  # Save file
  write.csv(pred_df, 
            paste0("output/tests/", gsub("/", "_", gsub("ensemble/", "", clim_id)), "_predicted_distribution_adjusted.csv"),
            row.names = FALSE)
  
  # Note that process is done
  message(paste0(Sys.time(), " | Predicted distribution saved for ", clim_id, "."))
  
} 




# ----- [TEST B]: KEEP ALL OBSERVATIONS + MAKE LOWEST ELEVATION THE NEW 0M -----

# ----- MODEL PREP -----

# -- PREP SPECIES DATA --

# Load species data
data <- read.csv("data/gbif/cleaned_species_keep_all_with_elevation.csv")

# Species list
spp_list <- unique(data$species)

# Species we'll be testing with is C. pallida
species_data <- data %>%
  filter(species == spp_list[1]) %>%
  select(longitude, latitude)

# Convert species observations to spatial points
spp <- SpatialPoints(species_data,
                     proj4string = CRS("+proj=longlat"))


# -- CREATE BUFFER --

# So we're not predicting over the entire continent
# Just enough to account for dispersal over time

# Create vector of the spatial points
vec <- vect(spp)

# Create minimum bounding polygon (takes outermost points to create polygon)
hull <- convHull(vec)

# To check polygon:
# hull_s <- as(hull, "Spatial")
# mapview(spp) + mapview(hull_s)

# If points are not showing on mapview():
# mapviewOptions(fgb = FALSE)

# The "width = " is in meters, and we'll assume dispersal for any species
# at most is 150000 meters (bee foraging or tree seed).
# Also accounting for shifts in range.
geo_extent <- buffer(x = hull, width = 150000)


# -- PREP CLIMATE AND ELEVATION DATA --

# Load elevation data
dem_initial <- rast("data/dem/northamerica_elevation_cec_2023.tif")

# Climate data
clim <- terra::rast(list.files(path = "data/worldclim",
                               pattern = ".tif$",
                               full.names = TRUE))

# Change projection of DEM so we can do the next steps
dem_mod <- terra::project(dem_initial, crs(clim))

# Crop and mask elevation to the buffer boundaries
dem_mod <- dem_mod %>%
  terra::crop(geo_extent, snap = "out") %>%
  terra::mask(geo_extent)

# Crop and mask climate to the buffer boundaries
clim_mod <- clim %>%
  terra::crop(geo_extent, snap = "out") %>%
  terra::mask(geo_extent)

# Resample dem_mod so that extent can match that of the climate data
# (Important for stacking SpatRasters)
dem_mod <- resample(dem_mod, clim)

# Crop and mask climate to match DEM
clim_mod <- clim %>%
  terra::crop(dem_mod, snap = "out") %>%
  terra::mask(dem_mod)

# Plotting clim_mod and dem_mod will show them on the same scale now
# plot(clim_mod[[1]])
# plot(dem_mod)


# -- RE-SCALE ELEVATION DATA --

# Notice that the scale bar has zero showing, 
  # and there are negative elevation values.

# plot(dem_mod)

# Find minimum and maximum cell values
mnm <- minmax(dem_mod)

dem_min <- mnm[1]
dem_max <- mnm[2]

# Value to adjust the minimum elevation to the new 0m
scale_val <- abs(dem_min)

# Define a function that adds the scale value to non-NA values
add_val <- function(x) {
  x[!is.na(x)] <- x[!is.na(x)] + scale_val
  return(x)
}

# Convert to RasterStack for the next line to work
dem_mod_r <- raster::stack(dem_mod)

# Apply the function to the RasterStack
dem_mod_r <- calc(dem_mod_r, fun = add_val)

# Convert back to SpatRaster
dem_mod <- terra::rast(dem_mod_r)

# Check new min and max
  # The old min and max should have the absolute value of the min added on

new_mnm <- minmax(dem_mod)
print(paste0("Old minimum: ", mnm[1], " | New minimum: ", new_mnm[1]))
print(paste0("Old maximum: ", mnm[2], " | New maximum: ", new_mnm[2]))

# plot(dem_mod)

# The old plot would show 0 on the scale bar, 
  # now it does not since it is the new lowest value.


# -- THIN OCCURRENCES --

# Thin occurrence records so there's only one per raster cell
occurrences <- dismo::gridSample(spp, clim_mod[[1]], n = 1)


# -- REPRODUCIBILITY PURPOSES --

# For reproducibility in the remainder of the script
set.seed(2023)


# -- BACKGROUND POINTS --

# Generate random points
background <- terra::spatSample(x = clim_mod[[1]],  
                                size = 10000,
                                method = "random",
                                na.rm = TRUE,
                                values = FALSE,
                                xy = TRUE)

# Apply column names from occurrences to background
colnames(background) <- colnames(occurrences)


# -- K-FOLD BLOCKS --

# Create blocks with the occurrence and background data
block <- get.block(occs = occurrences,
                   bg = background)

# Table to check number of occurrences in each block
message("Number of occurrences per block:")
print(table(block$occs.grp))

# Table to check number of background points in each block
message("Number of background points per block:")
print(table(block$bg.grp))

# Check: 
# clim_mod_r <- raster::stack(clim_mod)
# evalplot.grps(pts = occurrences, pts.grp = block$occs.grp, envs = clim_mod_r)
# evalplot.grps(pts = background, pts.grp = block$bg.grp, envs = clim_mod_r)


# -- MODEL PARAMETERS --

# Create a list to feed these partitions to the ENMevaluate() function
user.grp <- list(occs.grp = block$occs.grp, 
                 bg.grp = block$bg.grp)

# We try modeling with fc = L, LQ, LQH, and H, and rm = 1, 2, and 3
tune.args <- list(fc = c("L", "LQ", "LQH", "H"), rm = 1:3)

# Specify we are using both climate and elevation as predictors
envs <- c(clim_mod, dem_mod)

# Names for complete set of variables
vars_to_remove <- c("bio3", "bio7")

# Convert to Raster to easily remove variables
envs <- raster::stack(envs)

# Drop layers containing unwanted variables
envs <- dropLayer(envs, vars_to_remove)

# Convert back to SpatRaster
envs <- terra::rast(envs)

# We will use the partition method because it creates a more independent model
# to be tested against the others. There are other options for modifications:
# https://rdocumentation.org/packages/ENMeval/versions/2.0.4/topics/ENMevaluate
other.settings <- list(validation.bg = "partition")

# For parallel processing, use 2 fewer cores than are available
# (Creates less load on the CPU?)
# Note to self: There are 20 total according to the ENMevaluate messages
num_cores <- parallel::detectCores() - 2




# ----- RUN MAXENT -----

# Run SDM
results <- ENMevaluate(occs = occurrences,
                       bg = background,
                       envs = envs,
                       algorithm = "maxnet", 
                       tune.args = tune.args,
                       partitions = "user", 
                       user.grp = user.grp,
                       other.settings = other.settings,
                       parallel = TRUE, # Allow parallel processing
                       numCores = num_cores)




# ----- FIND THE OPTIMAL MODEL -----

# Look at table with evaluation metrics for each set of tuning parameters
eval_table <- results@results

# And save file
write.csv(eval_table, 
          paste0("output/tests/parameter_results_2.csv"),
          row.names = FALSE)

# Filter for optimal model
optimal <- results@results %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

# Extract the optimal model
best_model <- results@models[[optimal$tune.args]]

# Find non-zero coefficients 
betas <- as.data.frame(best_model$betas)

# Rename silly column
names(betas)[names(betas) == "best_model$betas"] <- "predictor_value"

# Arrange relation value (probably not the right term) in decreasing fashion
betas <- betas %>% 
  arrange(desc(predictor_value))

# And save file
write.csv(betas, 
          paste0("output/tests/predictor_values_2.csv"))




# ----- FORECAST MODEL -----

# List of climate scenarios to make predictions for (folder path after data/)
clim_ids <- c("worldclim",
              "ensemble/ssp245/2021")

# Loop through each climate period and generate predictions for each
for (clim_id in clim_ids) {
  
  
  
  # --- GET CLIMATE SCENARIO TO MAKE PREDICTIONS FOR ---
  
  # Get climate data path
  clim_file <- paste0("data/", clim_id)
  
  # Load data
  clim <- terra::rast(list.files(path = clim_file,
                                 pattern = ".tif$",
                                 full.names = TRUE))
  
  # Note start of prediction for this climate scenario
  message(paste0(Sys.time(), " | Prediction started for ", clim_id, "."))
  
  
  
  # --- RE-PROJECT ELEVATION DATA FOR THAT CLIMATE SCENARIO ---
  
  # Since each climate data may have a different projection, we will need to
  # make sure to run terra::project() again for each.
  
  # Change projection of elevation for that climate (will take a minute)
  dem_mod <- terra::project(dem_initial, crs(clim))
  
  # Note end of process
  message(paste0(Sys.time(), " | Matched projection of DEM to ", clim_id, " climate."))
  
  
  
  # --- PREPARE ELEVATION AND CLIMATE PREDICTORS ---
  
  # Crop and mask elevation to the buffer boundaries
  dem_mod <- dem_mod %>%
    terra::crop(geo_extent, snap = "out") %>%
    terra::mask(geo_extent)
  
  # Crop and mask climate to the buffer boundaries
  clim_mod <- clim %>%
    terra::crop(geo_extent, snap = "out") %>%
    terra::mask(geo_extent)
  
  # Resample dem_mod so that extent can match that of the climate data
  # (Important for stacking SpatRasters)
  dem_mod <- resample(dem_mod, clim_mod)
  
  # Crop and mask climate to dem_mod (removes extreme elevation areas)
  clim_mod <- clim_mod %>%
    terra::crop(dem_mod, snap = "out") %>%
    terra::mask(dem_mod)
  
  # Check: plot(clim_mod[[1]])
  
  # Check extents: ext(dem_mod) and ext(clim_mod)
  
  # Note that process is done
  message(paste0(Sys.time(), " | Climate data has been cropped."))
  
  
  
  # -- RE-SCALE ELEVATION DATA --
  
  # Find minimum and maximum cell values
  mnm <- minmax(dem_mod)
  
  dem_min <- mnm[1]
  dem_max <- mnm[2]
  
  # Value to adjust the minimum elevation to the new 0m
  scale_val <- abs(dem_min)
  
  # Convert to RasterStack for the next line to work
  dem_mod_r <- raster::stack(dem_mod)
  
  # Apply the function to the RasterStack
  dem_mod_r <- calc(dem_mod_r, fun = add_val)
  
  # Convert back to SpatRaster
  dem_mod <- terra::rast(dem_mod_r)
  
  # Check new min and max
  # The old min and max should have the absolute value of the min added on
  
  new_mnm <- minmax(dem_mod)
  print(paste0("Old minimum: ", mnm[1], " | New minimum: ", new_mnm[1]))
  print(paste0("Old maximum: ", mnm[2], " | New maximum: ", new_mnm[2]))
  
  # Note that process is done
  message(paste0(Sys.time(), " | DEM has been re-scaled."))

  
  
  # --- COMBINE PREDICTORS FOR THIS CLIMATE SCENARIO ---
  
  # Combine to one object
  envs <- c(clim_mod, dem_mod)
  
  # Convert predictors from SpatRaster to RasterStack
  # (enm.maxnet only takes raster objects at the moment)
  envs_r <- raster::stack(envs)
  
  # Note that process is done
  message(paste0(Sys.time(), " | Predictors prepared."))
  
  
  
  # --- GENERATE PREDICTIONS ---
  
  # Generate raster with predicted suitability values
  pred_vals <- enm.maxnet@predict(best_model, 
                                  envs_r,
                                  list(pred.type = "cloglog",
                                       doClamp = FALSE))
  
  # Make a copy of the raster for visualizations
  pred_vals_plotting <- pred_vals
  
  # Set any values below 0.5 to missing so audience is just aware of the "more suitable" areas
  pred_vals_plotting[pred_vals_plotting < 0.50] <- NA
  
  # Note that process is done
  message(paste0(Sys.time(), " | Predicted distribution for ", clim_id, " is done."))
  
  
  
  # --- SAVE PREDICTIONS TO OUTPUT FOLDER ---
  
  # (A.1) ORIGINAL VALUES ---
  
  # As raster
  writeRaster(pred_vals,
              paste0("output/tests/", gsub("/", "_", gsub("ensemble/", "", clim_id)), "_predicted_distribution_2.tif"))
  
  # Convert to SpatialPixelsDataFrame
  pred_spdf <- as(pred_vals, "SpatialPixelsDataFrame")
  
  # Convert to data frame
  pred_df <- as.data.frame(pred_spdf)
  
  # Save file
  write.csv(pred_df, 
            paste0("output/tests/", gsub("/", "_", gsub("ensemble/", "", clim_id)), "_predicted_distribution_2.csv"),
            row.names = FALSE)
  
  # (A.2) ONLY >50% CHANCE SUITABLE VALUES ---
  
  # As raster
  writeRaster(pred_vals_plotting,
              paste0("output/tests/", gsub("/", "_", gsub("ensemble/", "", clim_id)), "_predicted_distribution_adjusted_2.tif"))
  
  # Convert to SpatialPixelsDataFrame
  pred_spdf <- as(pred_vals_plotting, "SpatialPixelsDataFrame")
  
  # Convert to data frame
  pred_df <- as.data.frame(pred_spdf)
  
  # Save file
  write.csv(pred_df, 
            paste0("output/tests/", gsub("/", "_", gsub("ensemble/", "", clim_id)), "_predicted_distribution_adjusted_2.csv"),
            row.names = FALSE)
  
  # Note that process is done
  message(paste0(Sys.time(), " | Predicted distribution saved for ", clim_id, "."))
  
}





