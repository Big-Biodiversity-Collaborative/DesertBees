# Maxine Cruz
# tmcruz@arizona.edu
# Created: 21 February 2024
# Last modified: 21 February 2024




# -- ABOUT --

# Find elevations of occurrences
  # Since GBIF data has NA values


# We need to find which points are below 0 meters
  # And above 1250 meters



# ----- LOAD LIBRARIES -----

# For:

# Data wrangling
library(dplyr)

# Spatial matters
library(terra)

# Plots
library(ggplot2)




# ----- LOAD DATA -----

# Species occurence data
data <- read.csv("data/GBIF/cleaned_species.csv")

# Elevation data
dem <- rast(paste0("data/DEM", "/northamerica_elevation_cec_2023.tif"))

# Climate data
clim <- terra::rast(list.files(path = "data/WORLDCLIM",
                               pattern = ".tif$",
                               full.names = TRUE))

# Change projection of dem to that of bioclim variables (may take a minute)
dem <- terra::project(dem, crs(clim))




# ----- MATCH DEM ELEVATION TO GBIF DATA -----

# Add identifier column to data (for re-combining later)

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

# -- FOR CHECKING MERGE --

# Make vector of matching coordinates for checking
check <- ifelse(data[1] == data[7] & data[2] == data[8], 1, 0)

# Check that all are matching
length(unique(check)) == 1 

# -- END --

# Remove columns
data <- data %>%
  select(4, 5, 6, 7, 8, 9, 10, 11, 3, 13, 14)

# Save new data
write.csv(data, "data/GBIF/cleaned_species_with_elevation.csv", 
          row.names = FALSE)




# ----- CHECK ELEVATIONS AND MAKE PLOTS -----

# List of species
spp_list <- unique(data$species)

# -- A) C. PALLIDA --------------------------

# Get species
org <- data %>%
  filter(species == spp_list[1])

# Find 10 lowest elevations
low <- org %>%
  arrange(elevation) %>%
  head(n = 10)

# Find 10 highest elevations
high <- org %>%
  arrange(desc(elevation)) %>%
  head(n = 10)

# Get species
latlon <- org %>%
  select(longitude, latitude)

# Convert to spatial points
spp <- SpatialPoints(latlon,
                     proj4string = CRS("+proj=longlat"))

# Convert to SpatVector
occs <- vect(spp)

# Create minimum bounding polygon (takes outermost points to create polygon)
hull <- convHull(occs)

# To check polygon:
# hull_s <- as(hull, "Spatial")
# mapview(spp) + mapview(hull_s)

# If points are not showing on mapview():
# mapviewOptions(fgb = FALSE)

# The "width = " is in meters, and we'll assume dispersal for any species
# at most is 200 meters (bee foraging or tree seed)
geo_extent <- buffer(x = hull, width = 200)

# Crop and mask elevation to the buffer boundaries
dem_mod <- dem %>%
  terra::crop(geo_extent, snap = "out") %>%
  terra::mask(geo_extent)

# Check if existing
below_cutoff <- filter(org, elevation < 0)
above_cutoff <- filter(org, elevation > 1250)

# Plot the elevation map
plot(dem_mod)

# Add all occurrences
points(occs, col = "gray", pch = 19)

# Highlight those below 0 meters
points(occs[which(org$elevation < 0)], col = "red", pch = 19)

# Highlight those above 1250 meters
points(occs[which(org$elevation > 1250)], col = "blue", pch =19)

# Save plot using Export - goes to output/Centris pallida/id_elevation.png




# -- B) O. TESOTA ---------------------------

# Get species
org <- data %>%
  filter(species == spp_list[2])

# Find 10 lowest elevations
low <- org %>%
  arrange(elevation) %>%
  head(n = 10)

# Find 10 highest elevations
high <- org %>%
  arrange(desc(elevation)) %>%
  head(n = 10)

# Get species
latlon <- org %>%
  select(longitude, latitude)

# Convert to spatial points
spp <- SpatialPoints(latlon,
                     proj4string = CRS("+proj=longlat"))

# Convert to SpatVector
occs <- vect(spp)

# Create minimum bounding polygon (takes outermost points to create polygon)
hull <- convHull(occs)

# Assume dispersal
geo_extent <- buffer(x = hull, width = 200)

# Crop and mask elevation to the buffer boundaries
dem_mod <- dem %>%
  terra::crop(geo_extent, snap = "out") %>%
  terra::mask(geo_extent)

# Check if existing
below_cutoff <- filter(org, elevation < 0)
above_cutoff <- filter(org, elevation > 1250)

# Plot the elevation map
plot(dem_mod)

# Add all occurrences
points(occs, col = "gray", pch = 19)

# Highlight those below 0 meters
points(occs[which(data$elevation < 0)], col = "red", pch = 19)

# Highlight those above 1250 meters
points(occs[which(data$elevation > 1250)], col = "blue", pch =19)

# Save plot using Export
  # output/Olneya tesota/id_elevation.png




# -- C) P. FLORIDA --------------------------

# Get species
org <- data %>%
  filter(species == spp_list[3])

# Find 10 lowest elevations
low <- org %>%
  arrange(elevation) %>%
  head(n = 10)

# Find 10 highest elevations
high <- org %>%
  arrange(desc(elevation)) %>%
  head(n = 10)

# Get species
latlon <- org %>%
  select(longitude, latitude)

# Convert to spatial points
spp <- SpatialPoints(latlon,
                     proj4string = CRS("+proj=longlat"))

# Convert to SpatVector
occs <- vect(spp)

# Create minimum bounding polygon (takes outermost points to create polygon)
hull <- convHull(occs)

# Assume dispersal
geo_extent <- buffer(x = hull, width = 200)

# Crop and mask elevation to the buffer boundaries
dem_mod <- dem %>%
  terra::crop(geo_extent, snap = "out") %>%
  terra::mask(geo_extent)

# Check if existing
below_cutoff <- filter(org, elevation < 0)
above_cutoff <- filter(org, elevation > 1250)

# Plot the elevation map
plot(dem_mod)

# Add all occurrences
points(occs, col = "gray", pch = 19)

# Highlight those below 0 meters
points(occs[which(data$elevation < 0)], col = "red", pch = 19)

# Highlight those above 1250 meters
points(occs[which(data$elevation > 1250)], col = "blue", pch =19)

# Save plot using Export
  # output/Parkinsonia florida/id_elevation.png




# -- D) P. MICROPHYLLA ----------------------

# Get species
org <- data %>%
  filter(species == spp_list[4])

# Find 10 lowest elevations
low <- org %>%
  arrange(elevation) %>%
  head(n = 10)

# Find 10 highest elevations
high <- org %>%
  arrange(desc(elevation)) %>%
  head(n = 10)

# Get species
latlon <- org %>%
  select(longitude, latitude)

# Convert to spatial points
spp <- SpatialPoints(latlon,
                     proj4string = CRS("+proj=longlat"))

# Convert to SpatVector
occs <- vect(spp)

# Create minimum bounding polygon (takes outermost points to create polygon)
hull <- convHull(occs)

# Assume dispersal
geo_extent <- buffer(x = hull, width = 200)

# Crop and mask elevation to the buffer boundaries
dem_mod <- dem %>%
  terra::crop(geo_extent, snap = "out") %>%
  terra::mask(geo_extent)

# Check if existing
below_cutoff <- filter(org, elevation < 0)
above_cutoff <- filter(org, elevation > 1250)

# Plot the elevation map
plot(dem_mod)

# Add all occurrences
points(occs, col = "gray", pch = 19)

# Highlight those below 0 meters
points(occs[which(data$elevation < 0)], col = "red", pch = 19)

# Highlight those above 1250 meters
points(occs[which(data$elevation > 1250)], col = "blue", pch =19)

# Save plot using Export
  # output/Parkinsonia microphylla/id_elevation.png



