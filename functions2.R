# Maxine Cruz
# tmcruz@arizona.edu
# Created: 10 April 2024
# Last modified: 13 April 2024




# ----- ABOUT -----

# Function for running Maxent and generating suitability predictions
  # SDM - loop for each species
  # Predictions - loop for each time frame




# ----- SPECIES DISTRIBUTION MODEL (MAIN LOOP) -----

sdm <- function(species_data) {
  
  
  
  # Note start of SDM for species
  message(paste0(Sys.time(), " | Processing MaxEnt for: ", spp_list[i]))
  
  # For file names
  file_id <- gsub(" ", "_", tolower(spp_list[i]))
  
  # Create directory in output for that species if it does not exist
  species_folder <- paste0("output/", file_id)
  
  if (!dir.exists(species_folder)) {
    
    dir.create(species_folder)
    
  }
  
  
  
  # --- CONVERT OBSERVATIONS TO SPATIAL OBJECT ---
  
  # Convert species observations to spatial points
  # CRS: Coordinate Reference System
  spp <- SpatialPoints(species_data,
                       proj4string = CRS("+proj=longlat"))
  
  # Note that process is done
  message(paste0(Sys.time(), " | Occurrences have been converted to spatial points."))
  
  # Determine extent of species presence data in order to crop the climate and
    # elevation data to appropriate values
  
  # Since ext() takes the extent of the observations as a rectangular area,
    # we will create a boundary using the outer points of the observations and
    # then expand that boundary later so it's not so constrained
  
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
  # at most is 500 meters (bee foraging or tree seed)
  geo_extent <- buffer(x = hull, width = 500)
  
  # If we check this using the same method as above, it will look the same but
    # if you zoom in (a lot) to the nodes the buffer is visible
  
  # For the next step: If new shapefiles that would differ from the original are
    # created, you need to delete the former files manually (the main folder for
    # each species' shapefiles, e.g. output/shapefiles/centris_pallida)
  
  # Create directory in output for that species if it does not exist
  species_folder <- paste0("output/shapefiles/", file_id)
  
  if (!dir.exists(species_folder)) {
    
    dir.create(species_folder)
    
    # Save buffer as shapefile
    writeVector(geo_extent,
                filename = paste0("output/shapefiles/", file_id,"/ext_buffer.shp"))
    
  }
  
  # Note that process is done
  message(paste0(Sys.time(), " | Shapefile of prediction boundaries generated."))
  
  
  
  # --- CROP ELEVATION DATA ---
  
  # We are starting with elevation because we are turning extreme elevations to
  # NA values. This will create some "holes" which will need to be applied
  # to the climate data as well.
  
  # Crop and mask elevation to the buffer boundaries
  dem_mod <- dem %>%
    terra::crop(geo_extent, snap = "out") %>%
    terra::mask(geo_extent)
  
  # Check: plot(dem_mod)
  
  # Remove extreme elevation values
  # (Accounts for both bee and plant ranges)
  dem_mod[dem_mod < 0] <- NA
  
  # Check: plot(dem_mod)
  
  # Note that process is done
  message(paste0(Sys.time(), " | Elevation data has been cropped."))
  
  
  
  # --- CROP CLIMATE DATA ---
  
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
  
  
  
  # --- PREPARE OCCURRENCE POINTS ---
  
  # Thin occurrence records so there's only one per raster cell
  occurrences <- dismo::gridSample(spp, clim_mod[[1]], n = 1)
  
  # Note that process is done
  message(paste0(Sys.time(), " | Occurrence points have been thinned."))
  
  
  
  # --- SET SEED ---
  
  # For reproducibility in the remainder of the script
  set.seed(2023)
  
  
  
  #  --- PREPARE BACKGROUND POINTS ---
  
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
  message(paste0(Sys.time(), " | Background points have been generated."))
  
  
  
  # --- PARAMETER SETTING AND K-FOLD BLOCKS ---
  
  # Create blocks with the occurrence and background data
  block <- get.block(occs = occurrences,
                     bg = background)
  
  # Table to check number of occurrences in each block
  message("Number of occurrences per block:")
  print(table(block$occs.grp))
  
  # Check: 
    # clim_mod_r <- raster::stack(clim_mod)
    # evalplot.grps(pts = occurrences, pts.grp = block$occs.grp, envs = clim_mod_r)
  
  # Table to check number of background points in each block
  message("Number of background points per block:")
  print(table(block$bg.grp))
  
  # Check: 
    # evalplot.grps(pts = background, pts.grp = block$bg.grp, envs = clim_mod_r)
  
  # Create a list to feed these partitions to the ENMevaluate() function
  user.grp <- list(occs.grp = block$occs.grp, 
                   bg.grp = block$bg.grp)
  
  # We try modeling with fc = L, LQ, LQH, and H, and rm = 1, 2, and 3
  tune.args <- list(fc = c("L", "LQ", "LQH", "H"), rm = 1:3)
  
  # Feature and regularization explanations: 
    # https://nsojournals.onlinelibrary.wiley.com/doi/epdf/10.1111/j.1600-0587.2013.07872.x
    # https://plantarum.ca/notebooks/maxent/
    # https://nsojournals.onlinelibrary.wiley.com/doi/10.1111/j.0906-7590.2008.5203.x
  
  # When we run the model later, it will model each feature (fc) and 
  # regularization (rm) combination above. Then we can pick the one that
  # fit "best".
  
  # Specify we are using both climate and elevation as predictors
  envs <- c(clim_mod, dem_mod)
  
  # We will use the partition method because it creates a more independent model
  # to be tested against the others. There are other options for modifications:
  # https://rdocumentation.org/packages/ENMeval/versions/2.0.4/topics/ENMevaluate
  other.settings <- list(validation.bg = "partition")
  
  # For parallel processing, use 2 fewer cores than are available
  # (Creates less load on the CPU?)
  # Note to self: There are 20 total according to the ENMevaluate messages
  num_cores <- parallel::detectCores() - 2
  
  # Note that process is done
  message(paste0(Sys.time(), " | Parameters have been set."))
  
  
  
  # --- MAXENT ---
  
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
  
  # Note that process is done
  message(paste0(Sys.time(), " | MaxEnt has been completed."))
  
  
  
  # --- FIND THE OPTIMAL MODEL ---
  
  # Look at table with evaluation metrics for each set of tuning parameters
  eval_table <- results@results
  
  # And save file
  write.csv(eval_table, 
            paste0("output/", file_id, "/parameter_results.csv"))
  
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
            paste0("output/", file_id, "/predictor_values.csv"))
  
  # Note that process is done
  message(paste0(Sys.time(), " | Optimal model has been extracted."))
  
  
  
  
  # ----- USING OPTIMAL MODEL FOR PREDICTIONS (SUB-LOOP) -----
  
  # Note start of sub-loop
  message(paste0(Sys.time(), " | Using optimal model for predictions."))
  
  # List of climate scenarios to make predictions for (folder path after data/)
  clim_ids <- c("worldclim",
                "ensemble/ssp370/2021",
                "ensemble/ssp370/2041",
                "ensemble/ssp370/2061",
                "ensemble/ssp370/2081")
  
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
    message(paste0(Sys.time(), " | Prediction started for ", spp_list[i], "."))
    
    
    
    # --- RE-PROJECT ELEVATION DATA FOR THAT CLIMATE SCENARIO ---
    
    # Since each climate data may have a different projection, we will need to
      # make sure to run terra::project() again for each.
    
    # Change projection of elevation for that climate (will take a minute)
    dem <- terra::project(dem_initial, crs(clim))
    
    # Note end of process
    message(paste0(Sys.time(), " | Matched projection of DEM to ", clim_id, " climate."))
    
    
    
    # --- CROP ELEVATION DATA ---
    
    # Crop and mask elevation to the buffer boundaries
    dem_mod <- dem %>%
      terra::crop(geo_extent, snap = "out") %>%
      terra::mask(geo_extent)
    
    # Check: plot(dem_mod)
    
    # Remove extreme elevation values
    # (Accounts for both bee and plant ranges)
    dem_mod[dem_mod < 0] <- NA
    
    # Check: plot(dem_mod)
    
    # Note that process is done
    message(paste0(Sys.time(), " | Elevation data has been cropped."))
    
    
    
    # --- CROP CLIMATE DATA ---
    
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
    
    
    
    # --- GENERATE PREDICTIONS
    
    # Generate raster with predicted suitability values
    pred_vals <- enm.maxnet@predict(best_model, 
                                    envs_r,
                                    list(pred.type = "cloglog",
                                         doClamp = FALSE))
    
    # Note that process is done
    message(paste0(Sys.time(), " | Predicted distribution for ", clim_id, " is done."))
    
    
    
    # --- SAVE PREDICTIONS TO OUTPUT FOLDER ---
    
    # Convert to SpatialPixelsDataFrame
    pred_spdf <- as(pred_vals, "SpatialPixelsDataFrame")
    
    # Convert to data frame
    pred_df <- as.data.frame(pred_spdf)
    
    print("Saving .csv file for predicted distribution.")
    
    write.csv(pred_df, 
              paste0("output/", file_id, "/", gsub("ensemble/ssp370/", "ssp370_", clim_id), "_predicted_distribution.csv"),
              row.names = FALSE)
    
    message(paste0(Sys.time(), " | Predictions saved for ", clim_id, "."))
    
  } 
  
  # ----- END OF SUB-LOOP -----
  
} 

# ----- END OF MAIN LOOP -----



