library(terra)
library(ENMeval)

# Spatial data --------------------------------------------------------------- #
# Unzip folders with spatial data before running and change directories (dirs)
# below to reflect your folder structure

# Bioclimatic variables: projected climate for 2041-2070 from an ensemble of 
  # CMIP6 GCMs under a SSP370 emissions scenario
  # Data from Jeff Oliver, at ~ 4 x 4 km resolution. Created here:
  # https://github.com/Big-Biodiversity-Collaborative/SwallowtailClimateChange/blob/main/src/data/prep-forecast-data.R
  bioc_dir <- ".../biovars_ssp370_2041"
  bioc <- terra::rast(list.files(path = bioc_dir,
                                 pattern = ".tif$",
                                 full.names = TRUE))

# DEM: digital elevation model (in meters)
  # Data from the CEC, at ~ 1 x 1 km resolution. Found here:
  # http://www.cec.org/north-american-environmental-atlas/elevation-2007/
  dem_dir <- ".../dem_1km"
  dem <- rast(paste0(dem_dir, "/na_elevation.tif"))
  # Change projection to that of bioclim variables and crop (takes a few seconds)
  dem <- terra::project(dem, crs(bioc))
  dem <- terra::crop(dem, ext(bioc))
  
  # If you wanted to create other topographic variables based on this DEM (eg,
  # slope, aspect), you can do that pretty easily with terra::terrain()
  # slope <- terra::terrain(dem, v = "slope", unit = "degrees")
  
# ENMevaluate----------------------------------------------------------------- #  
# Run ENMevaluate() and save the object (here, calling that "mods")
  
  # Pick "best" model based on evaluation metrics
  mods@results
  optimal <- mods@results %>%
    filter(cbi.val.avg > 0) %>%
    filter(or.10p.avg == min(or.10p.avg)) %>%
    filter(auc.val.avg == max(auc.val.avg))
  best <- mods@models[[optimal$tune.args]]
  
  # Here are the non-zero coefficients in our model.
  best$betas
  
  # And here are the marginal response curves for the predictor variables with 
  # non-zero coefficients in our model. y-axis is the cloglog transformation of
  # response, which is an approximation of occurrence probability (with 
  # assumptions) bounded by 0 and 1
  plot(best, type = "cloglog")
  
  # It's not so simple to get measures of "variable importance" with the maxnet
  # algorithm. See: https://groups.google.com/g/Maxent/c/UvEMnIUTl8M
  # So maybe not worth worrying about right now.
  