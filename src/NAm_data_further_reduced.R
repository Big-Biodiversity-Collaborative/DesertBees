# Maxine Cruz
# tmcruz@arizona.edu
# Created: 30 April 2023
# Last modified: 12 September 2023


# ----- ABOUT THE SCRIPT -----

# Further filters data per Dr. Buchmann's request (see images folder)

# Reduces data to:
  # Centris pallida - 1342915
  # Olneya tesota - 2974564
  # Parkinsonia florida - 5359949
  # Parkinsonia microphylla - 5359945

# And removes unlikely observations by drawing boundary around desired points'

# Creates new data frame with the further reduced data (NAm_map_data_final.csv)

# mapview() have been commented out so this can be run altogether, but
#  if you want to see the map and polygons in process run this line-by-line
#  and include the mapview()

# (Could have probably been made with a loop and having images generate)
# (but I like seeing everything broken down so... yeah)
# (Also helps me understand what I am doing)




# ----- LOAD LIBRARIES -----

library(tidyverse)
library(sf)
library(sp)
library(mapview)




# ----- LOAD DATA ---
og_data <- read_csv("data/NAm_map_data.csv")

# 73143 observations 
# (includes Parkinsonia aculeata, which is no longer part of the project)




# ----- FILTER CENTRIS PALLIDA (KEY: 1342915) -----

# Filter for C. pallida
cp_data <- filter(og_data,
                  speciesKey == 1342915)

# 866 observations

# C_pallida_bounds.png shows that about 5 observations need to be removed
# (some points may be near overlain on each other or didn't show on image)

# Isolate lat/long columns to generate points for map
coords <- select(cp_data, 8, 7)

# Convert coordinates to a spatial object (SpatialPoints)
sp_coords <- SpatialPoints(coords,
                           proj4string = CRS("+proj=longlat"))

# Plot points on a map
# Map will show in Viewer of RStudio
# mapview(sp_coords)

# Create polygon around desired points
# Got coordinates of corners from rolling over map in Viewer
# (Lat/long will show at top of Viewer)
# First and last points should be the same to close the polygon (*)

# (34.16182, -120.84961) *
# (40.38003, -113.99414)
# (31.87756, -104.42383)
# (18.14585, -109.42383)
# (34.16182, -120.84961) *

latitude <- c(34.16182, 40.38003, 31.87756, 18.14585, 34.16182)
longitude <- c(-120.84961, -113.99414, -104.42383, -109.42383, -120.84961)

poly_coords <- tbl_df(cbind(longitude, latitude))

# Convert coordinates to a spatial object (SpatialPoints)
sp_poly_coords <- SpatialPoints(poly_coords,
                                proj4string = CRS("+proj=longlat"))

# Generate polygon using matrix of vertices
poly1 <- Polygon(sp_poly_coords)

# Convert polygon into Polygon class
cp_poly <- Polygons(list(poly1), ID = "A")

# Convert Polygon to SpatialPolygon (spatial object)
sp_cp_poly <- SpatialPolygons(list(cp_poly),
                              proj4string = CRS("+proj=longlat"))

# Plot polygon on map to check boundaries
# The "+" adds SpatialPolygon on top of SpatialPoints
# mapview(sp_coords) + 
#   mapview(sp_cp_poly)

# Isolate points within boundary
cp_coords <- sp_coords[sp_cp_poly, ]

# NOTE TO SELF INTERMISSION:

  # Would get "Error in over(x, geometry(i)) : identicalCRS(x, y) is not TRUE".
  # Was stuck on this for months 
  # Turns out it was because the CRS (Coordinate Reference System)
  # of the SpatialPoints and SpatialPolygon were not the same.
  # Both needed the proj4string = CRS("+proj=longlat") argument.
  # And I only had that argument in SpatialPoints, which caused the error.
  # ANYWAY, back to the code.

# Make sure points are correct
# mapview(cp_coords) + 
#  mapview(sp_cp_poly)

# Convert SpatialPoints back to normal points for new dataframe later
# Also add column specifying respective species
# AND also column for species key
cp_coords <- as.data.frame(cp_coords)
cp_coords <- cbind(speciesKey = 1342915,
                   cp_coords)

# 861 observations

# Make sure to clear the Viewer before next point cleaning!
# I dunno what the function for that is right now
  



# ----- FILTER OLNEYA TESOTA (KEY: 2974564) -----

# Filter for O. tesota
ot_data <- filter(og_data,
                  speciesKey == 2974564)

# 4101 observations

# O_tesota_bounds.png shows that about 6 observations need to be removed

# Isolate lat/long columns to generate points for map
coords <- select(ot_data, 8, 7)

# Convert coordinates to a spatial object (SpatialPoints)
sp_coords <- SpatialPoints(coords,
                           proj4string = CRS("+proj=longlat"))

# Plot points on a map
# mapview(sp_coords)

# Create polygon around desired points

# (22.89768, -109.86328) *
# (26.01730, -115.26855)
# (33.88866, -118.16895)
# (35.69299, -111.40137)
# (33.22950, -108.28125)
# (22.69512, -107.84180)
# (22.89768, -109.86328) *

latitude <- c(22.89768, 26.01730, 33.88866, 35.69299,
              33.22950, 22.69512, 22.89768)
longitude <- c(-109.86328, -115.26855, -118.16895, -111.40137,
               -108.28125, -107.84180, -109.86328)

poly_coords <- tbl_df(cbind(longitude, latitude))

# Convert coordinates to a spatial object (SpatialPoints)
sp_poly_coords <- SpatialPoints(poly_coords,
                                proj4string = CRS("+proj=longlat"))

# Generate polygon using matrix of vertices
poly1 <- Polygon(sp_poly_coords)

# Convert polygon into Polygon class
ot_poly <- Polygons(list(poly1), ID = "A")

# Convert Polygon to SpatialPolygon (spatial object)
sp_ot_poly <- SpatialPolygons(list(ot_poly),
                              proj4string = CRS("+proj=longlat"))

# Plot polygon on map to check boundaries
# mapview(sp_coords) + 
#  mapview(sp_ot_poly)

# Isolate points within boundary
ot_coords <- sp_coords[sp_ot_poly, ]

# Make sure points are correct
# mapview(ot_coords) + 
#  mapview(sp_ot_poly)

# Convert SpatialPoints back to normal points for new dataframe later
# Also add column specifying respective species
ot_coords <- as.data.frame(ot_coords)
ot_coords <- cbind(speciesKey = 2974564,
                   ot_coords)

# 4090 observations

# Make sure to clear Viewer before proceeding




# ----- FILTER PARKINSONIA FLORIDA (KEY: 5359949) -----

# Filter for P. florida
pf_data <- filter(og_data,
                  speciesKey == 5359949)

# 3194 observations

# P_florida_bounds.png shows that about 16 observations need to be removed

# Isolate lat/long columns to generate points for map
coords <- select(pf_data, 8, 7)

# Convert coordinates to a spatial object (SpatialPoints)
sp_coords <- SpatialPoints(coords,
                           proj4string = CRS("+proj=longlat"))

# Plot points on a map
# mapview(sp_coords)

# Create polygon around desired points

# (33.02709, -119.44336) *
# (37.33522, -116.10352)
# (33.79741, -107.92969)
# (22.06528, -108.14941)
# (22.06528, -110.96191)
# (24.07656, -111.36841)
# (24.07656, -112.15942)
# (25.61181, -112.35718)
# (25.78011, -114.23584)
# (33.02709, -119.44336) *

latitude <- c(33.66950, 37.33522, 33.79741, 22.06528, 22.06528,
              24.07656, 24.07656, 25.61181, 25.78011, 33.66950)
longitude <- c(-119.75098, -116.1035, -107.92969, -108.14941, -110.96191,
               -111.36841, -112.15942, -112.35718, -114.23584, -119.75098)

poly_coords <- tbl_df(cbind(longitude, latitude))

# Convert coordinates to a spatial object (SpatialPoints)
sp_poly_coords <- SpatialPoints(poly_coords,
                                proj4string = CRS("+proj=longlat"))

# Generate polygon using matrix of vertices
poly1 <- Polygon(sp_poly_coords)

# Convert polygon into Polygon class
pf_poly <- Polygons(list(poly1), ID = "A")

# Convert Polygon to SpatialPolygon (spatial object)
sp_pf_poly <- SpatialPolygons(list(pf_poly),
                              proj4string = CRS("+proj=longlat"))

# Plot polygon on map to check boundaries
# mapview(sp_coords) + 
#  mapview(sp_pf_poly)

# Isolate points within boundary
pf_coords <- sp_coords[sp_pf_poly, ]

# Make sure points are correct
# mapview(pf_coords) + 
#  mapview(sp_pf_poly)

# Convert SpatialPoints back to normal points for new dataframe later
# Also add column specifying respective species
pf_coords <- as.data.frame(pf_coords)
pf_coords <- cbind(speciesKey = 5359949,
                   pf_coords)

# 3172 observations

# Make sure to clear Viewer before proceeding



# ----- FILTER PARKINSONIA MICROPHYLLA (KEY: 5359945) -----

# Filter for P. microphylla
pm_data <- filter(og_data,
                  speciesKey == 5359945)

# 3784 obsversations

# P_microphylla_bounds.png shows that about 8 observations need to be removed

# Isolate lat/long columns to generate points for map
coords <- select(pm_data, 8, 7)

# Convert coordinates to a spatial object (SpatialPoints)
sp_coords <- SpatialPoints(coords,
                           proj4string = CRS("+proj=longlat"))

# Plot points on a map
# mapview(sp_coords)

# Create polygon around desired points

# (26.56888, -114.32373) *
# (31.52236, -118.58643)
# (37.38762, -115.24658)
# (31.29733, -106.76514)
# (27.00041, -110.45654)
# (22.53285, -108.69873)
# (22.53285, -111.81885)
# (26.56888, -114.32373) *

latitude <- c(26.56888, 31.52236, 37.38762, 31.29733,
              27.00041, 22.53285, 22.53285, 26.56888)
longitude <- c(-114.32373, -118.58643, -115.24658, -106.76514,
               -110.45654, -108.69873, -111.81885, -114.32373)

poly_coords <- tbl_df(cbind(longitude, latitude))

# Convert coordinates to a spatial object (SpatialPoints)
sp_poly_coords <- SpatialPoints(poly_coords,
                                proj4string = CRS("+proj=longlat"))

# Generate polygon using matrix of vertices
poly1 <- Polygon(sp_poly_coords)

# Convert polygon into Polygon class
pm_poly <- Polygons(list(poly1), ID = "A")

# Convert Polygon to SpatialPolygon (spatial object)
sp_pm_poly <- SpatialPolygons(list(pm_poly),
                              proj4string = CRS("+proj=longlat"))

# Plot polygon on map to check boundaries
# mapview(sp_coords) + 
#  mapview(sp_pm_poly)

# Isolate points within boundary
pm_coords <- sp_coords[sp_pm_poly, ]

# Make sure points are correct
# mapview(pm_coords) + 
#  mapview(sp_pm_poly)

# Convert SpatialPoints back to normal points for new dataframe later
# Also add column specifying respective species
pm_coords <- as.data.frame(pm_coords)
pm_coords <- cbind(speciesKey = 5359945,
                   pm_coords)

# 3784 observations




# ----- SAVE NEWLY FILTERED DATA AS A NEW .CSV FILE -----

# Combine all ~_coords data into one table
species_coords <- rbind(cp_coords, ot_coords, pf_coords, pm_coords)

# 11893 observations

# Filter original NAm_map_data.csv to the new species coordinates
species_coords <- semi_join(og_data, species_coords)

# 11893 observations

# Save as .csv file to data folder
write_csv(species_coords, "data/NAm_map_data_final.csv")



