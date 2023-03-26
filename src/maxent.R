# Maxine Cruz
# tmcruz@arizona.edu
# Created: 25 March 2023
# Last modified: 26 March 2023



### ABOUT THE SCRIPT ---

# Maxent for Centris pallida

# Current and future predictions of C. pallida distribution

# Maximum Entropy modeling:
  # Species niche and distribution model
  # Input environmental data and species occurrence data
  # Model gives probability distribution where each environmental grid
  #  has a predicted suitability of conditions for the species
  # Output is predicted probability of presence or local abundance

# https://biodiversityinformatics.amnh.org/open_source/maxent/



### LOAD LIBRARIES ---

library(tidyverse)
library(dismo)
library(maptools)
library(maps)
library(spocc)
library(rJava)
library(gridExtra)
library(cowplot)



### CURRENT SPECIES DISTRIBUTION MODEL ---

# Read data
cp_data <- read_csv("data/NAm_map_data.csv")

# Isolate C. pallida records and reduce to only lat/long data
cp_data <- cp_data %>%
  filter(speciesKey == 1342915) %>%
  dplyr::select(longitude, latitude)

# 866 observations, 2 variables

# Convert to spatial points (data now represents geographical location)
# CRS: Coordinate Reference System
cp_spatial <- SpatialPoints(cp_data,
                            proj4string = CRS("+proj=longlat"))

# Download climate data from WorldClim
current_env <- getData("worldclim", 
                       var = "bio", 
                       res = 2.5, 
                       path = "data/") 

# Note to use geodata package instead
# getData() will be unavailable in future raster package

# Create a list of the files in wc2-5 folder for raster stack
clim_list <- list.files(path = "data/wc2-5/", 
                        pattern = ".bil$",
                        full.names = T)

# Create RasterStack (collection of objects with same spatial extent/resolution)
clim <- raster::stack(clim_list)

# --- PSEUDO-ABSENCE POINTS ---

# Generate pseudo-absence points and geographic extent of these points
  # Pseudo-absence: artificial absence data
  # It is difficult to obtain confirmed absences, esp. with mobile organisms
  # This also makes it more difficult to ensure reliability
  # Presence-absence models tend to do better than presence-only models
  # So we create absence points for SDM

# Isolate a RasterLayer for defining geographic extent (boundaries)
mask <- raster(clim[[1]])

# Determine extent of C. pallida presence data
# So pseudo-absence points are generated within known range
geo_extent <- extent(cp_spatial)

# Set a seed so the same points are obtained every time code is run
# (For reproducibility purposes)
set.seed(8)

# Generate background (pseudo-absence) points within boundaries
# We have 866 presence points for C. pallida, so we will create
#  an equal number of pseudo-absence points
bg_data <- randomPoints(mask = mask,
                        n = 866,
                        ext = geo_extent,
                        extf = 1.25, 
                        warn = 0) 

# Add column names
colnames(bg_data) <- c("longitude", "latitude")

# Collect climate data for those presence and pseudo-absence points
occ_env <- na.omit(raster::extract(x = clim, y = cp_data))
absence_env <- na.omit(raster::extract(x = clim, y = bg_data))

# Create binary data frame of presence data and background points
# (0 = abs, 1 = pres)
pres_abs <- c(rep(1, nrow(occ_env)), rep(0, nrow(absence_env)))

# Create data frame with climate data for both presence and background
pres_abs_env <- as.data.frame(rbind(occ_env, absence_env)) 

# --- MAXENT MODEL ---

# Run Maxent model
# x = environmental conditions of presence/background points
# p = presence/background points of C.pallida
cp_SDM <- dismo::maxent(x = pres_abs_env,
                        p = pres_abs,
                        path = paste("output/maxent_outputs"), )

# --- PREDICT AREAS ---

# Limit boundaries of prediction
predict_extent <- 1.25 * geo_extent
geo_area <- crop(clim, predict_extent)

# Generate prediction from model over boundaries
# Where else could C. pallida be
cp_pred_plot <- raster::predict(cp_SDM, geo_area)

# Convert prediction to a data frame for plotting
raster_spdf <- as(cp_pred_plot, "SpatialPixelsDataFrame")
cp_pred_df <- as.data.frame(raster_spdf)

# --- PLOT PREDICTIONS ON MAP ---

# Based on the climate conditions and geography that C. pallida is found at,
#  where else could they be

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")

# Set boundaries where map should be focused
xmax <- max(cp_pred_df$x)
xmin <- min(cp_pred_df$x)
ymax <- max(cp_pred_df$y)
ymin <- min(cp_pred_df$y)

# Create ggplot of current SDM
current_SDM <- ggplot() +
  geom_polygon(data = wrld, 
               mapping = aes(x = long, y = lat, group = group),
               fill = "#BFBFBF") +
  geom_raster(data = cp_pred_df, 
              aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colors = terrain.colors(10, rev = T)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = 
         bquote(italic("Centris pallida")~"SDM under Current Climate"),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(legend.box.background = element_rect(),
        legend.box.margin = margin(5, 5, 5, 5))

# Save plot
ggsave(filename = "current_cpallida_sdm.jpg", 
       plot = current_SDM, 
       path = "output", 
       width = 1600, 
       height = 1000, 
       units = "px")



### FUTURE SPECIES DISTRIBUTION MODEL ---

# Has an additional step to create a prediction 70 years into future

# --- PROJECTED CLIMATE DATA ---

# Download predicted climate data from CMIP5
future_env <- raster::getData(name = "CMIP5", 
                              var = "bio", 
                              res = 2.5,
                              rcp = 45, 
                              model = "IP", 
                              year = 70, 
                              path = "data") 

names(future_env) = names(clim)

# --- PREDICT AREAS ---

# Limit boundaries of prediction
geo_area_future <- crop(future_env, predict_extent)

# Generate prediction from model over boundaries
# Where else could C. pallida be (in the future)
cp_pred_plot_future <- raster::predict(cp_SDM, geo_area_future)

# Convert prediction to a data frame for plotting
raster_spdf_future <- as(cp_pred_plot_future, "SpatialPixelsDataFrame")
cp_pred_df_future <- as.data.frame(raster_spdf_future)

# --- PLOT FUTURE PREDICTIONS ON MAP ---

# Set boundaries where map should be focused
xmax_f <- max(cp_pred_df_future$x)
xmin_f <- min(cp_pred_df_future$x)
ymax_f <- max(cp_pred_df_future$y)
ymin_f <- min(cp_pred_df_future$y)

# Create ggplot of future SDM
future_SDM <- ggplot() +
  geom_polygon(data = wrld, 
               mapping = aes(x = long, y = lat, group = group),
               fill = "#BFBFBF") +
  geom_raster(data = cp_pred_df_future, 
              aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colors = terrain.colors(10, rev = T)) +
  coord_fixed(xlim = c(xmin_f, xmax_f), 
              ylim = c(ymin_f, ymax_f), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = 
         bquote(italic("Centris pallida")~"SDM under CMIP5 Climate Predictions"),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(legend.box.background = element_rect(),
        legend.box.margin = margin(5, 5, 5, 5))

# Save plot
ggsave(filename = "future_cpallida_sdm.jpg", 
       plot = future_SDM, 
       path = "output", 
       width = 1600, 
       height = 1000, 
       units = "px")




### PLOT CURRENT AND FUTURE SIDE-BY-SIDE

# Current SDM
current_plot <- ggplot() +
  geom_polygon(data = wrld, 
               mapping = aes(x = long, y = lat, group = group),
               fill = "#BFBFBF") +
  geom_raster(data = cp_pred_df, 
              aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colors = terrain.colors(10, rev = T)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = 
         bquote(bold("under Current Climate Conditions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(legend.box.background = element_rect(),
        legend.position = "bottom")

# Future SDM
future_plot <- ggplot() +
  geom_polygon(data = wrld, 
               mapping = aes(x = long, y = lat, group = group),
               fill = "#BFBFBF") +
  geom_raster(data = cp_pred_df_future, 
              aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colors = terrain.colors(10, rev = T)) +
  coord_fixed(xlim = c(xmin_f, xmax_f), 
              ylim = c(ymin_f, ymax_f), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = 
         bquote(bold("under CMIP5 Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(legend.box.background = element_rect(),
        legend.position = "bottom")

# Combine plots
plot_row <- plot_grid(current_plot, future_plot)

# Generate common plot title
title <- ggdraw() + 
  draw_label(bquote("Species Distribution Model of" ~italic("Centris pallida")),
             fontface = "bold",
             hjust = 0.5,
             size = 20)

# Add title to combined plots
combined_plots <- plot_grid(title,
                            plot_row,
                            ncol = 1,
                            rel_heights = c(0.1, 1))

# Save combined plots
ggsave(filename = "current_future_SDM.jpg",
       plot = combined_plots,
       path = "output",
       width = 2600,
       height = 1791,
       units = "px")




