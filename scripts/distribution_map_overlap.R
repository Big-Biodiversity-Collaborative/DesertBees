# Maxine Cruz
# tmcruz@arizona.edu
# Created: 21 December 2023
# Last modified: 8 September 2024




# ----- ABOUT -----

# Finds area of current/future distributions

# Finds area that bee and plants overlap
  # Plots overlapped area on map for visualization




# ----- LOAD LIBRARIES -----

# For finding areas
library(terra)
library(raster)

# For mapping
library(ggplot2)
library(cowplot)

# Custom function
source("functions.R")

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")




# ----- LOAD DATA -----

# Species occurrence data
data <- read.csv("data/gbif/cleaned_species_with_elevation.csv")




# ----- CALCULATE AREAS COVERED BY CURRENT / FUTURE DISTRIBUTIONS -----

# Species to loop through
spp_list <- unique(data$species)

# Empty table
areas <- data.frame()

# Loop for finding averages and adding them to a table
for (i in 1:4) {
  
  # i) Access file names
  file_id <- gsub(" ", "_", tolower(spp_list[i]))
  
  # ii) Current distribution
  current <- rast(paste0("output/", file_id, "/worldclim/worldclim_predicted_distribution_adjusted.tif"))
  area1 <- expanse(current, unit = "km")
  
  # iii) Future distribution
  future <- rast(paste0("output/", file_id, "/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.tif"))
  area2 <- expanse(future, unit = "km")
  
  # iv) Calculate averages for this species and append to full data frame
  new_df <- data.frame(species = file_id,
                       current.km = area1$area,
                       future.km = area2$area,
                       percent_change = round(((area2$area - area1$area) / area1$area) * 100, digits = 4))
  
  areas <- rbind(areas, new_df)
  
}

# End of main loop

# Save table
write.csv(areas,
          file = "output/predicted_areas.csv",
          row.names = FALSE)




# ----- FIND AREA OVERLAP BY BEE AND PLANTS -----

# (A) Current --

# Starting raster to find intersection with
current_intersects <- raster("output/centris_pallida/worldclim/worldclim_predicted_distribution_adjusted.tif")

# Find intersection of all distributions
for (i in 2:4) {
  
  # i) Access file names
  file_id <- gsub(" ", "_", tolower(spp_list[i]))
  
  # ii) Access file y
  area_y <- raster(paste0("output/", file_id, "/worldclim/worldclim_predicted_distribution_adjusted.tif"))
  
  # See where the intersection between x and y is
  current_intersects <- raster::intersect(current_intersects, area_y)
  
}

# Convert to SpatRaster so we can find the area
intersects_spat <- rast(current_intersects)

current_intersect_area <- expanse(intersects_spat, unit = "km")

# Convert to data frame so we can plot it
current_intersect <- as(current_intersects, "SpatialPixelsDataFrame")

current_intersect <- as.data.frame(current_intersect)

colnames(current_intersect)[1] = "layer"

# Bounding box
xmax <- max(current_intersect$x) + 1
xmin <- min(current_intersect$x) - 1
ymax <- max(current_intersect$y) + 1
ymin <- min(current_intersect$y) - 1

# Plot
current_area_plot <- custom_ggplot4(sdm_data = current_intersect, 
                                    xmin = xmin, xmax = xmax, 
                                    ymin = ymin, ymax = ymax)


# (B) Future --

# Starting raster to find intersection with
future_intersects <- raster("output/centris_pallida/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.tif")

# Find intersection of all distributions
for (i in 2:4) {
  
  # i) Access file names
  file_id <- gsub(" ", "_", tolower(spp_list[i]))
  
  # ii) Access file y
  area_y <- raster(paste0("output/", file_id, "/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.tif"))
  
  # See where the intersection between x and y is
  future_intersects <- raster::intersect(future_intersects, area_y)
  
}

# Convert to SpatRaster so we can find the area
intersects_spat <- rast(future_intersects)

future_intersect_area <- expanse(intersects_spat, unit = "km")

# Convert to data frame so we can plot it
future_intersect <- as(future_intersects, "SpatialPixelsDataFrame")

future_intersect <- as.data.frame(future_intersect)

colnames(future_intersect)[1] = "layer"

# Bounding box
xmax <- max(current_intersect$x) + 1
xmin <- min(current_intersect$x) - 1
ymax <- max(current_intersect$y) + 1
ymin <- min(current_intersect$y) - 1

# Plot
future_area_plot <- custom_ggplot5(sdm_data = future_intersect, 
                                   xmin = xmin, xmax = xmax, 
                                   ymin = ymin, ymax = ymax)




# (C) Plot together --

both_plots <- plot_grid(current_area_plot + theme(legend.position = "bottom"), 
                        future_area_plot + theme(legend.position = "bottom"),
                        labels = "auto",
                        label_size = 20,
                        ncol = 2)

# Check
both_plots

# Save plot
ggsave("output/distribution_maps/species_distribution_overlap.png", 
       both_plots,
       width = 22,
       height = 15,
       units = "cm")

