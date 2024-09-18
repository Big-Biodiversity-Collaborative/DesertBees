# Maxine Cruz
# tmcruz@arizona.edu
# Created: 14 May 2024
# Last modified: 8 September 2024




# ----- ABOUT -----

# Finds average elevation for current and future distributions
  # Test / template script containing comments is at the bottom




# ----- LOAD LIBRARIES -----

library(dplyr)
library(terra)




# ----- LOAD DATA -----

# Species occurrence data
data <- read.csv("data/gbif/cleaned_species_with_elevation.csv")

# Elevation data
dem <- rast("data/dem/northamerica_elevation_cec_2023.tif")

# Climate data
clim <- terra::rast(list.files(path = "data/worldclim",
                               pattern = ".tif$",
                               full.names = TRUE))

# Change projection of dem to that of bioclim variables (may take a minute)
dem_mod <- terra::project(dem, crs(clim))




# ----- FIND AVERAGE ELEVATION ACROSS CURRENT AND FUTURE DISTRIBUTIONS -----

# Species to loop through
spp_list <- unique(data$species)

# Empty table
averages <- data.frame()

# Loop for finding averages and adding them to a table
for (i in 1:4) {
  
  # i) Access file names
  file_id <- gsub(" ", "_", tolower(spp_list[i]))
  
  # ii) Current distribution
  current <- read.csv(paste0("output/", file_id, "/worldclim/worldclim_predicted_distribution_adjusted.csv"))
  
  coords <- current %>%
    select(x, y)
  
  spp <- SpatialPoints(coords,
                       proj4string = CRS("+proj=longlat"))
  
  occs <- vect(spp)
  
  elevocc1 <- terra::extract(dem_mod, occs, ID = TRUE) %>%
    cbind(geom(occs))
  
  elevocc1 <- elevocc1 %>%
    select(5, 6, 2) %>%
    rename(latitude = y,
           longitude = x,
           elevation = northamerica_elevation_cec_2023)
  
  # iii) Future distribution
  future <- read.csv(paste0("output/", file_id, "/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.csv"))
  
  coords <- future %>%
    select(x, y)
  
  spp <- SpatialPoints(coords,
                       proj4string = CRS("+proj=longlat"))
  
  occs <- vect(spp)
  
  elevocc2 <- terra::extract(dem_mod, occs, ID = TRUE) %>%
    cbind(geom(occs))
  
  elevocc2 <- elevocc2 %>%
    select(5, 6, 2) %>%
    rename(latitude = y,
           longitude = x,
           elevation = northamerica_elevation_cec_2023)
  
  # iv) Calculate averages for this species and append to full data frame
  new_df <- data.frame(species = file_id,
                       current.m = mean(elevocc1$elevation),
                       future.m = mean(elevocc2$elevation))
  
  averages <- rbind(averages, new_df)
  
}

# End of main loop

# Save table
write.csv(averages,
          file = "output/average_elevations.csv",
          row.names = FALSE)




# ----- TESTING / TEMPLATE FOR ABOVE CODE -----

# a) C. pallida ---

# i) Current distribution
current <- read.csv("output/centris_pallida/worldclim/worldclim_predicted_distribution_adjusted.csv")

# Isolate lat/long
coords <- current %>%
  select(x, y)

# Convert to spatial points
spp <- SpatialPoints(coords,
                     proj4string = CRS("+proj=longlat"))

# Convert to SpatVector
occs <- vect(spp)

# Extract elevation values for occurrence points
elevocc <- terra::extract(dem_mod, occs, ID = TRUE) %>%
  cbind(geom(occs))

# Isolate lat/long and elevation
elevocc <- elevocc %>%
  select(5, 6, 2) %>%
  rename(latitude = y,
         longitude = x,
         elevation = northamerica_elevation_cec_2023)

# Average elevation
message(paste0("Average elevation for current distribution of C. pallida: "),
        mean(elevocc$elevation))

# ii) Future distribution
future <- read.csv("output/centris_pallida/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.csv")

# Isolate lat/long
coords <- future %>%
  select(x, y)

# Convert to spatial points
spp <- SpatialPoints(coords,
                     proj4string = CRS("+proj=longlat"))

# Convert to SpatVector
occs <- vect(spp)

# Extract elevation values for occurrence points
elevocc <- terra::extract(dem_mod, occs, ID = TRUE) %>%
  cbind(geom(occs))

# Isolate lat/long and elevation
elevocc <- elevocc %>%
  select(5, 6, 2) %>%
  rename(latitude = y,
         longitude = x,
         elevation = northamerica_elevation_cec_2023)

# Average elevation
message(paste0("Average elevation for future distribution of C. pallida: "),
        mean(elevocc$elevation))

