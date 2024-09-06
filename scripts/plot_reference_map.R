# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 December 2023
# Last modified: 16 April 2024




# ----- ABOUT -----

# Plot maps for context




# ----- LOAD LIBRARIES -----

# For managing data
library(dplyr)
library(terra)
library(raster)

# For plotting
library(ggplot2)

# For organizing panel arrangement
library(cowplot)
library(png)
library(grid)

# Using archived packages

# 1) ggsn (adds symbols and scale bars to ggplot)

# install.packages("https://cran.r-project.org/src/contrib/Archive/ggsn/ggsn_0.5.0.tar.gz", 
#                  type = "source", 
#                  repos = NULL)

library(ggsn)




# ----- LOAD DATA -----

# Collect data for map borderlines
borderlines <- map_data("world")

borderlines <- borderlines %>%
  filter(region == "USA")

# Climate
clim <- terra::rast(list.files(path = "data/worldclim",
                               pattern = ".tif$",
                               full.names = TRUE))

# Elevation
dem <- rast("data/dem/northamerica_elevation_cec_2023.tif")

dem <- terra::project(dem, crs(clim))

dem_raster <- raster(dem)

dem_plot <- as(dem_raster, "SpatialPixelsDataFrame")

dem_plot <- as.data.frame(dem_plot)




# ----- PLOT MAP -----

# Bounding box
ymax <- 39.522431
ymin <- 21.888022
xmax <- -105.455389
xmin <- -124.806799

# Only keep data in bounding box
dem_plot_reduced <- dem_plot %>%
  filter(x < xmax) %>%
  filter(x > xmin) %>%
  filter(y < ymax) %>%
  filter(y > ymin)

# Major cities
city_coords <- data.frame(city = c("Phoenix", "Tucson", "Las Vegas", 
                                   "Los Angeles", "Hermosillo",
                                   "Culiacan", "Mexicali"),
                          latitude = c(33.448376, 32.25346, 36.18811,
                                       34.0544, 29.1026,
                                       24.79032, 32.663334),
                          longitude = c(-112.074036, -110.911789, -115.176468,
                                        -118.2439, -110.97732,
                                        -107.38782, -115.467781))

# Plot map
ggplot() +
  geom_raster(data = dem_plot_reduced, 
              aes(x = x, 
                  y = y, 
                  fill = northamerica_elevation_cec_2023)) + 
  scale_fill_gradientn(colours = viridis::viridis(100)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world", colour = "black", fill = "white") +
  borders("state") +
  geom_point(data = city_coords,
             aes(x = longitude, y = latitude)) +
  geom_label(data = city_coords,
            aes(x = longitude, y = latitude, label = city),
            vjust = -0.3) +
  labs(x = "Longitude",
       y = "Latitude",
       fill = "Elevation") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        panel.background = element_rect(fill = "grey95")) +
  ggsn::scalebar(data = borderlines,
           location = "bottomleft",
           dist = 1000,
           dist_unit = "km",
           transform = TRUE,
           model = "WGS84",
           st.size = 3,
           border.size = 0.5)






