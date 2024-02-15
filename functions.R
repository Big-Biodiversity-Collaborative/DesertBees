# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 December 2023
# Last modified: 14 February 2024




# -- ABOUT --

# Function for running Maxent (ENMeval)
  # Current SDM
  # Future SDM

# Performs the following, among other things:
  # Converts observations to spatial points
  # Allows for predictions that are 200 meters outside of expected range
  # Crops climate data to extent
  # Crops elevation data to extent
  # Matches CRS for predictors
  # Removes values / locations outside expected elevation of bee and host plants
  # Thins occurrence points (one per raster cell)
  # Generates background points
  # Prepares MaxEnt settings
  # (1st run determines which predictor variables contribute most to model)
  # Removes predictor variables with little to no effect on model
  # Runs MaxEnt
  # Evaluates "best" model
  # Saves results for plotting distribution and range maps




# ----- SPECIES DISTRIBUTION MODEL -----

sdm <- function(species, clim_mod, current_or_future_sdm) {
  
  print(paste("Performing", current_or_future_sdm, "analysis."))
  
  
  
  # -- CONVERT OBSERVATIONS TO SPATIAL OBJECT --
  
  # Note start of process
  print("Preparing occurrence data.")
  
  # Convert species observations to spatial points
  # CRS: Coordinate Reference System
  spp <- SpatialPoints(species,
                       proj4string = CRS("+proj=longlat"))
  
  # Determine extent of species presence data in order to crop the climate and
    # elevation data to appropriate values
  
  # Since ext() takes the extent of the observations as a rectangular area,
    # we will create a boundary using the outer points of the observations and
    # then expand that boundary later so it is not so constrained
  
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
  # at most is 200 meters (bee foraging or tree seed)
  geo_extent <- buffer(x = hull, width = 200)
  
  # If we check this using the same method as above, it will look the same but
    # if you zoom in (a lot) to the nodes the buffer is visible
  
  # Save buffer as shapefile
  writeVector(geo_extent,
              filename = paste("data/SHAPEFILES/", spp_list[i],"/ext_buffer.shp",
                               sep = ""))
  
  # Note that process is done
  print("Occurrence data has been converted to spatial points.")
  
  
  
  # -- CROP ELEVATION DATA --
  
  # We are starting with elevation because we are turning extreme elevations to
    # NA values. This will create some "holes" which will need to be applied
    # to the climate data as well.
  
  # Note start of process
  print("Preparing predictors.")
  
  # Crop and mask elevation to the buffer boundaries
  dem_mod <- dem %>%
    terra::crop(geo_extent, snap = "out") %>%
    terra::mask(geo_extent)
  
  # Check: plot(dem_mod)
  
  # Remove extreme elevation values
  # (Accounts for both bee and plant ranges)
  dem_mod[dem_mod < 0] <- NA
  dem_mod[dem_mod > 1250] <- NA
  
  # Check: plot(dem_mod)
  
  
  
  # -- CROP CLIMATE DATA --
  
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
  print("Predictors have been cropped.")
  
  
  
  # -- PREPARE OCCURRENCE POINTS --
  
  # Note start of process
  print("Thinning occurrence data.")
  
  # Thin occurrence records so there's only one per raster cell
  occurrences <- dismo::gridSample(spp, clim_mod[[1]], n = 1)
  
  # Note that process is done
  print("Occurrence points have been thinned.")
  
  
  
  # -- SET SEED --
  
  # For reproducibility in the remainder of the script
  set.seed(2023)
  
  
  
  #  -- PREPARE BACKGROUND POINTS --
  
  # Note start of process
  print("Preparing background data.")
  
  # Generate random points
  background <- terra::spatSample(x = clim_mod[[1]],  
                                  size = 10000,
                                  method = "random",
                                  na.rm = TRUE,
                                  values = FALSE,
                                  xy = TRUE)
  
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
  
  # Check: 
    # clim_mod_r <- raster::stack(clim_mod)
    # evalplot.grps(pts = occurrences, pts.grp = block$occs.grp, envs = clim_mod_r)
  
  # Table to check number of background points in each block
  table(block$bg.grp)
  
  # Check: 
    # evalplot.grps(pts = background, pts.grp = block$bg.grp, envs = clim_mod_r)
  
  # Create a list to feed these partitions to the ENMevaluate() function
  user.grp <- list(occs.grp = block$occs.grp, 
                   bg.grp = block$bg.grp)
  
  # We try modeling with fc = L, LQ, Q, LQH, and H, and rm = 1, 2, and 3
  tune.args <- list(fc = c("L", "LQ", "Q", "LQH", "H"), rm = 1:3)
  
  # Specify we are using both climate and elevation as predictors
  envs <- c(clim_mod, dem_mod)
  
  # [AFTER INITIAL CHECKS] -- OMITTED
  
  # Comment if initial checks (later in code) have not been run first
    # Code below will eliminate insignificant predictor variables
    # For keeping variables that contribute the most to the model
    # (They have a marginal response curve with the predicted probability of presence)
  
  # Open file with significant predictor variables
  #betas <- read.csv(paste("output/", spp_list[i], "/", current_or_future_sdm, "_beta_values.csv", sep = ""))
  
  # Get names for complete set of variables
  #vars <- names(envs)
  
  # Get names of significant variables
  #vars_to_keep <- betas$X
  
  # Get which variables need to be removed
  #vars_to_remove <- setdiff(vars, vars_to_keep)
  
  # Convert to Raster to easily remove variables
  #envs <- raster::stack(envs)
  
  # Drop layers containing insignificant variables
  #envs <- dropLayer(envs, vars_to_remove)
  
  # Convert back to SpatRaster
  #envs <- terra::rast(envs)
  
  # [END] --
  
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
  
  # [START INITIAL CHECKS] -- OMITTED
  
  # 1st pass: Un-comment (code below) to acquire significant predictor variables
    # Will save significant betas as .csv's in respective species' folder
    # That .csv is used in the 2nd pass to remove insignificant predictor variables
    # The 2nd pass uses only the significant predictor variables in the model
  
  # Find non-zero coefficients and save file
  
  #betas <- as.data.frame(best$betas)
  #write.csv(betas, 
  #          paste("output/", spp_list[i], "/", current_or_future_sdm, "_beta_values.csv", sep = ""))
  
  # [END INITIAL CHECKS] --
  
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
  
  # For plotting, remove lowest (near zero) environmental suitability values
    # to be able to layer results on top of Google map
  
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







