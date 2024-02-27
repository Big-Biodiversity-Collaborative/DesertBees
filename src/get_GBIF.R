# Maxine Cruz
# tmcruz@arizona.edu
# Created: 5 December 2023
# Last modified: 8 December 2023




# ----- ABOUT -----

# 1) Retrieves data from GBIF for the following species:

  # Common name (Scientific name) - Taxon key
  # Desert / Digger Bee (Centris pallida) - 1342915
  # Blue Palo Verde (Parkinsonia florida) - 5359949
  # Foothill Palo Verde (Parkinsonia microphylla) - 5359945
  # Desert Ironwood (Olneya tesota) - 2974564

# 2) Cleans data

# 3) Further cleans by removing points outside expected range
  # Achieved by drawing polygon and eliminating points outside of boundary

# 4) Saves cleaned data as: data/GBIF/cleaned_species.csv




# ----- LOAD LIBRARIES -----

library(rgbif)
library(CoordinateCleaner)
library(dplyr)
library(sf)
library(sp)
library(mapview)



# ----- GET DATA -----

# Request full occurrence record of orgnanisms from GBIF

# NOTE: occ_download requires a setup with GBIF account on a .Renviron file
  # See https://docs.ropensci.org/rgbif/articles/gbif_credentials.html

occ_download(pred_in("speciesKey", c(1342915, 5359949, 5359945, 2974564)))

# Prints download and citation info as follows:

# Download Info:
  # Username: tmcruz
  # E-mail: tmcruz@arizona.edu
  # Format: DWCA
  # Download key: 0022014-231120084113126
  # Created: 2023-12-07T16:56:19.767+00:00

# Citation Info:  
  # Please always cite the download DOI when using this data.
  # https://www.gbif.org/citation-guidelines
  # DOI: 10.15468/dl.wzea7y

# Citation:
  # GBIF Occurrence Download 
  # https://doi.org/10.15468/dl.wzea7y
  # Accessed from R via rgbif 

# Retrieve download
raw_data <- 
  occ_download_get(key = "0022014-231120084113126", path = "data/GBIF/") %>%
  occ_download_import()

# 15329 observations, 212 variables

# Save raw data as csv
write.csv(raw_data, "data/GBIF/raw_species.csv", row.names = FALSE)




# ----- CLEAN DATA: FILTERING -----

# If starting here, read in the raw data (downloaded on 7 December 2023)
raw_data <- read.csv("data/GBIF/raw_species.csv")

# Number of observations (nrow(filter(data, speciesKey == ___))):
  # C. pallida = 1089
  # O. tesota = 5039
  # P. florida = 4535
  # P. microphylla = 4666

# 15329 observations, 212 variables

# Clean data
data <- raw_data %>%
  filter(!is.na(decimalLatitude), # Remove NA latitude / longitude values
         !is.na(decimalLongitude)) %>%
  filter(countryCode %in% c("US", "MX", "CA")) %>% # Keep records in study area of interest
  filter(!basisOfRecord %in% c("FOSSIL_SPECIMEN", "LIVING_SPECIMEN")) %>% # Remove fossil records / specimens (only removed 1 observation)
  cc_sea(lon = "decimalLongitude", # Organisms are land-dwellers, so remove records in the ocean
         lat = "decimalLatitude") %>%
  filter(hasGeospatialIssues == FALSE) %>% # Remove those with issues
  distinct(decimalLongitude, # Remove duplicates
           decimalLatitude, 
           year,
           month,
           day,
           speciesKey, 
           datasetKey, 
           .keep_all = TRUE)

# 12138 observations, 212 variables

# Number of observations:
  # C. pallida = 315
  # O. tesota = 4219
  # P. florida = 3586
  # P. microphylla = 4018

# Reduce columns to what is / might be necessary for analyses / figures
data <- data %>%
  select(61, 62, 63, 92, 93, 193, 192, 151, 174, 80, 79) %>%
  rename(latitude = decimalLatitude,
         longitude = decimalLongitude) %>%
  arrange(species, kingdom, year, month, day)

# 11998 observations, 10 variables

# Columns identified using which(colnames(data) == "column_name")
  # 61 = year
  # 62 = month
  # 63 = day
  # 79 = countryCode
  # 80 = stateProvince
  # 92 = decimalLatitude
  # 93 = decimalLongitude
  # 151 = kingdom
  # 174 = elevation
  # 192 = speciesKey
  # 193 = species




# ----- CLEAN DATA: REMOVE OUTSIDE EXPECTED RANGE -----

# 1) CONVERT SPECIES COORDINATES TO SPATIALPOINTS -----

# Species data prefixes
spp_prefix <- c("cp", "ot", "pf", "pm")

# Species names to loop through
spp <- unique(data$species)

# The loop
for (i in 1:4) {
  
  # Species to focus on
  species_i <- spp[i]
  
  # Filter for that species data
  coords <- data %>%
    filter(species == species_i) %>%
    select(5, 4)
  
  # Convert coordinates to SpatialPoints
  sp_coords <- SpatialPoints(coords,
                             proj4string = CRS("+proj=longlat +datum=WGS84"))
  
  # Name for species spatial coordinates object
  df_name <- paste(spp_prefix[i], "coords", sep = "_")
  
  # New object for the spatial coordinates
  assign(df_name, sp_coords)
  
}

# ---

# 2) SET UP POLYGONS FOR EACH SPECIES -----

# Coordinates of vertices determined by rolling over plotted map in Viewer
# (Latitude/longitude will show at top of Viewer)
# *: First and last points should be the same to close the polygon

# A) CENTRIS PALLIDA --

# Vertices:
  # (34.16182, -120.84961) *
  # (40.38003, -113.99414)
  # (31.87756, -104.42383)
  # (18.14585, -109.42383)
  # (34.16182, -120.84961) *

# Data frame for polygon coordinates
cp_poly_coords <- data.frame(longitude = c(-120.84961, -113.99414, -104.42383, 
                                           -109.42383, -120.84961),
                             latitude = c(34.16182, 40.38003, 31.87756, 
                                          18.14585, 34.16182),
                             species = "Centris pallida")

# B) OLNEYA TESOTA --

# Vertices:
  # (22.89768, -109.86328) *
  # (26.01730, -115.26855)
  # (33.88866, -118.16895)
  # (35.69299, -111.40137)
  # (33.22950, -108.28125)
  # (22.69512, -107.84180)
  # (22.89768, -109.86328) *

# Data frame for polygon coordinates
ot_poly_coords <- data.frame(longitude = c(-109.86328, -115.26855, -118.16895, 
                                           -111.40137, -108.28125, -107.84180, 
                                           -109.86328),
                             latitude = c(22.89768, 26.01730, 33.88866, 
                                          35.69299, 33.22950, 22.69512, 
                                          22.89768),
                             species = "Olneya tesota")

# C) PARKINSONIA FLORIDA --

# Vertices:
  # (33.02709, -119.44336) * CHECK
  # (37.33522, -116.10352)
  # (33.79741, -107.92969)
  # (22.06528, -108.14941)
  # (22.06528, -110.96191)
  # (24.07656, -111.36841)
  # (24.07656, -112.15942)
  # (25.61181, -112.35718)
  # (25.78011, -114.23584)
  # (33.02709, -119.44336) *

# Data frame for polygon coordinates
pf_poly_coords <- data.frame(longitude = c(-119.75098, -116.1035, -107.92969, 
                                           -108.14941, -110.96191, -111.36841, 
                                           -112.15942, -112.35718, -114.23584, 
                                           -119.75098),
                             latitude = c(33.66950, 37.33522, 33.79741, 
                                          22.06528, 22.06528, 24.07656, 
                                          24.07656, 25.61181, 25.78011, 
                                          33.66950),
                             species = "Parkinsonia florida")

# D) PARKINSONIA MICROPHYLLA --

# Vertices:
  # (26.56888, -114.32373) *
  # (31.52236, -118.58643)
  # (37.38762, -115.24658)
  # (31.29733, -106.76514)
  # (27.00041, -110.45654)
  # (22.53285, -108.69873)
  # (22.53285, -111.81885)
  # (26.56888, -114.32373) *

# Data frame for polygon coordinates
pm_poly_coords <- data.frame(longitude = c(-114.32373, -118.58643, -115.24658, 
                                           -106.76514, -110.45654, -108.69873, 
                                           -111.81885, -114.32373),
                             latitude = c(26.56888, 31.52236, 37.38762, 
                                          31.29733, 27.00041, 22.53285, 
                                          22.53285, 26.56888),
                             species = "Parkinsonia microphylla")

# E) COMBINE ALL IN ONE DATA FRAME

poly_coords <- rbind(cp_poly_coords, ot_poly_coords,
                     pf_poly_coords, pm_poly_coords)

# F) LOOP FOR CREATING SPATIAL POLYGONS FOR EACH SPECIES

for (i in 1:4) {
  
  # Species to focus on
  species_i <- spp[i]
  
  # Filter for that species data
  coords <- poly_coords %>%
    filter(species == species_i) %>%
    select(1, 2)
  
  # Convert coordinates to SpatialPoints
  sp_coords <- SpatialPoints(coords,
                             proj4string = CRS("+proj=longlat +datum=WGS84"))
  
  # Generate polygon using matrix of vertices
  poly <- Polygon(sp_coords)
  
  # Convert polygon into Polygon class
  poly <- Polygons(list(poly), ID = "A")
  
  # Convert Polygon to SpatialPolygon
  sp_poly <- SpatialPolygons(list(poly), 
                             proj4string = CRS("+proj=longlat +datum=WGS84"))
  
  # Name for species spatial coordinates object
  df_name <- paste(spp_prefix[i], "poly", sep = "_")
  
  # New object for the spatial coordinates
  assign(df_name, sp_poly)
  
}

# ---

# 3) FILTER BY POLYGON -----

# To check boundaries of polygon
# mapview(cp_coords) + mapview(cp_poly)

# New data frame of coordinates
cleaned_coords <- data.frame()

# The loop
for (i in 1:4) {
  
  # Name of coordinate object to use
  sp_coords <- paste(spp_prefix[i], "coords", sep = "_")
  
  # Get that object
  sp_coords <- get(sp_coords)
  
  # Name of polygon for filtering
  sp_poly <- paste(spp_prefix[i], "poly", sep = "_")
  
  # Get that object
  sp_poly <- get(sp_poly)
  
  # Isolate points within the polygon
  sp_coords <- sp_coords[sp_poly, ]
  
  # Convert SpatialPoints back to normal points for new data frame later
  sp_coords <- as.data.frame(sp_coords)
  
  # Also add column specifying respective species and species key
  sp_coords <- cbind(species = spp[i],
                     sp_coords)
  
  # Add to new data frame
  cleaned_coords <- rbind(cleaned_coords, sp_coords)
  
}

# To check filtering:
  # 1) Omit last three comment lines in loop and run
  # 2) Plot mapview(sp_coords) + mapview(sp_poly)




# ----- SAVE DATA -----

# Filter full data to the new filtered species coordinates
cleaned_data <- semi_join(data, cleaned_coords)

# 12102 observations, 11 variables

# Number of observations:
  # C. pallida = 309
  # O. tesota = 4213
  # P. florida = 3570
  # P. microphylla = 4010

# Save as csv
write.csv(cleaned_data, "data/GBIF/cleaned_species.csv", row.names = FALSE)

# ---

# To check cleaning:

# library(leaflet)

# leaflet(cleaned_data) %>%
#   addProviderTiles("Esri.WorldImagery") %>%
#   addTiles(
#     urlTemplate = "https://tiles.stadiamaps.com/tiles/{variant}/{z}/{x}/{y}{r}.png?api_key={apikey}",
#     attribution = paste('&copy; <a href="https://stadiamaps.com/" target="_blank">Stadia Maps</a> ',
#                         '&copy; <a href="https://stamen.com/" target="_blank">Stamen Design</a> ',
#                         '&copy; <a href="https://openmaptiles.org/" target="_blank">OpenMapTiles</a> ',
#                         '&copy; <a href="https://www.openstreetmap.org/about" target="_blank">OpenStreetMap</a> contributors'),
#     options = tileOptions(variant = 'stamen_toner_lines', 
#                           apikey = 'd20cf594-4437-4c63-9cc1-59f58e5a7b89')
#   ) %>%
#   addCircleMarkers(
#     color = "#FF3E96",
#     radius = 3,
#     fillOpacity = 0.8,
#     stroke = FALSE)


