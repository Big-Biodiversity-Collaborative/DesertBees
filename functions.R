# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 December 2023
# Last modified: 3 January 2024




# -- ABOUT --

# Function for running Maxent (ENMeval)
  # Current SDM
  # Future SDM




# ----- SPECIES DISTRIBUTION MODEL -----

sdm <- function(species, clim, current_or_future_sdm) {
  
  
  
  # -- CONVERT OBSERVATIONS TO SPATIAL OBJECT --
  
  # Note start of process
  print("Preparing occurrence data.")
  
  # Convert species observations to spatial points
  # CRS: Coordinate Reference System
  spp <- SpatialPoints(species,
                       proj4string = CRS("+proj=longlat"))
  
  # Determine extent of species presence data in order to crop the climate data
  # to appropriate values
  geo_extent <- terra::ext(spp)
  
  # Expand that extent by 50% to account for predicted distribution outside of
  # the expected range
  geo_extent_plus <- geo_extent * 1.5
  
  # Note that process is done
  print("Occurrence data has been converted to spatial points.")
  
  
  
  # -- CROP CLIMATE DATA --
  
  # Note start of process
  print("Preparing predictors.")
  
  # Crop climate variables to the 150% extent of species
  clim <- terra::crop(clim, geo_extent_plus)
  
  
  
  # -- CROP ELEVATION DATA --
  
  # Change projection to that of bioclim variables (may take a minute)
  dem <- terra::project(dem, crs(clim))
  
  # Crop to match that of bioclim variables
  dem <- terra::crop(dem, ext(clim))
  
  # Resample DEM so that extent can match that of the climate data
  # (Important for stacking SpatRasters)
  dem <- resample(dem, clim)
  
  # Check extents
  ext(dem)
  ext(clim)
  
  # Note that process is done
  print("Predictors have been cropped.")
  
  
  
  # -- PREPARE OCCURRENCE POINTS --
  
  # Note start of process
  print("Thinning occurrence data.")
  
  # Thin occurrence records so there's only one per raster cell
  occurrences <- dismo::gridSample(spp, clim, n = 1)
  
  # Note that process is done
  print("Occurrence points have been thinned.")
  
  
  
  # -- SET SEED --
  
  # For reproducibility in the remainder of the script
  set.seed(2023)
  
  
  
  #  -- PREPARE BACKGROUND POINTS --
  
  # Note start of process
  print("Preparing background data.")
  
  # Generate random points
  background <- raptr::randomPoints(clim[[1]], n = 10000)
  
  # Apply column names from occurrences to background
  colnames(background) <- colnames(occurrences)
  
  # Note that process is done
  print("Background points have been generated.")
  
  
  
  # -- PARAMETER SETTING AND K-FOLD BLOCKS --
  
  # Note start of process
  print("Preparing parameters for Maxent.")
  
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
  
  # Note that process is done
  print("Parameters have been set.")
  
  
  
  # -- MAXENT --
  
  # Note start of process
  print("Performing Maxent.")
  
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
  
  # Note that process is done
  print("Maxent has been completed.")
  
  
  
  # -- FIND BEST MODEL --
  
  # Note start of process
  print("Finding the optimal model.")
  
  # Look at table with evaluation metrics for each set of tuning parameters
  eval_table <- results@results
  
  # Filter for optimal model
  optimal <- results@results %>%
    filter(cbi.val.avg > 0) %>%
    filter(or.10p.avg == min(or.10p.avg)) %>%
    filter(auc.val.avg == max(auc.val.avg))
  
  # Extract the optimal model
  best <- results@models[[optimal$tune.args]]
  
  # [For initial checks]
  # Find non-zero coefficients and save file
  betas <- as.data.frame(best$betas)
  write.csv(betas, 
            paste("output/", spp_list[i], "/", current_or_future_sdm, "_beta_values.csv", sep = ""))
  
  # Note that process is done
  print("Optimal model extracted.")
  
  
  
  # -- USING OPTIMAL MODEL FOR PREDICTIONS --
  
  # Note start of process
  print("Preparing prediction data.")
  
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
  
  
  
  # -- PREPARE DATA FOR PLOTTING --
  
  # (A) DISTRIBUTION:
  
  pred_spdf <- as(pred_vals, "SpatialPixelsDataFrame")
  
  pred_df <- as.data.frame(pred_spdf)
  
  print("Saving .csv file for predicted distribution.")
  
  write.csv(pred_df, 
            paste("output/", spp_list[i], "/", current_or_future_sdm, "_distribution.csv", sep = ""),
            row.names = FALSE)
  
  # (B) RANGE:
  
  raster_spdf <- as(range, "SpatialPixelsDataFrame")
  
  range_df <- as.data.frame(raster_spdf)
  
  range_df$layer <- as.factor(range_df$layer)
  
  print("Saving .csv file for predicted range.")
  
  write.csv(range_df, 
            paste("output/", spp_list[i], "/", current_or_future_sdm, "_range.csv", sep = ""),
            row.names = FALSE)
  
  # Note that process is done
  print("Predictions have been saved in output folder.")
  
}




