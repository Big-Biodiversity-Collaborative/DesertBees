# Maxine Cruz
# tmcruz@arizona.edu
# Created: 27 September 2023
# Last modified: 2 October 2023




# ----- ABOUT THE SCRIPT -----

# Maxent for Parkinsonia florida

# Current and future predictions of P. florida distribution

# Same but reduced script of maxent_Cpallida.R, but using a different speciesKey




# ----- LOAD LIBRARIES -----

library(tidyverse)
library(dismo)
library(maptools)
library(maps)
library(spocc)
library(rJava)
library(gridExtra)
library(cowplot)




# ----- GET DATA -----

# Read data
species_data <- read_csv("data/NAm_map_data_final.csv")

# Isolate species records and reduce to only lat/long data
species_data <- species_data %>%
  filter(speciesKey == 5359945) %>%
  dplyr::select(longitude, latitude)

# 3784 obsversations

# Convert to spatial points (data now represents geographical location)
# CRS: Coordinate Reference System
species_spatial <- SpatialPoints(species_data,
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




# ----- CURRENT SPECIES DISTRIBUTION MODEL -----

# -- PSEUDO-ABSENCE POINTS --

# Isolate a RasterLayer for defining geographic extent (boundaries)
mask <- raster(clim[[1]])

# Determine extent of C. pallida presence data
# So pseudo-absence points are generated within known range
geo_extent <- extent(species_spatial)

# Set a seed so the same points are obtained every time code is run
# (For reproducibility purposes)
set.seed(8)

# Generate background (pseudo-absence) points within boundaries
bg_data <- randomPoints(mask = mask,
                        n = 45408, # 3784 x 12 = 45408
                        ext = geo_extent,
                        extf = 1.25, 
                        warn = 0) 

# Add column names
colnames(bg_data) <- c("longitude", "latitude")

# Collect climate data for those presence and pseudo-absence points
occ_env <- na.omit(raster::extract(x = clim, y = species_data))
absence_env <- na.omit(raster::extract(x = clim, y = bg_data))

# Create binary data frame of presence data and background points
# (0 = abs, 1 = pres)
pres_abs <- c(rep(1, nrow(occ_env)), rep(0, nrow(absence_env)))

# Create data frame with climate data for both presence and background
pres_abs_env <- as.data.frame(rbind(occ_env, absence_env)) 

# -- MAXENT MODEL --

# Run Maxent model
# x = environmental conditions of presence/background points
# p = presence/background points of species
species_SDM <- dismo::maxent(x = pres_abs_env,
                             p = pres_abs,
                             path = paste("output/maxent_Pmicrophylla_outputs"), )

# -- PREDICT AREAS --

# Limit boundaries of prediction
predict_extent <- 1.25 * geo_extent
geo_area <- crop(clim, predict_extent)

# Generate prediction from model over boundaries
# Where else could species be
species_pred_plot <- raster::predict(species_SDM, geo_area)

# Convert prediction to a data frame for plotting
raster_spdf <- as(species_pred_plot, "SpatialPixelsDataFrame")
species_pred_df <- as.data.frame(raster_spdf)




# ----- FUTURE SPECIES DISTRIBUTION MODEL -----

# -- PROJECTED CLIMATE DATA --

# Download predicted climate data from CMIP5
future_env_50 <- raster::getData(name = "CMIP5", 
                                 var = "bio", 
                                 res = 2.5,
                                 rcp = 45, 
                                 model = "IP", 
                                 year = 50, 
                                 path = "data") 

names(future_env_50) = names(clim)

# -- PREDICT AREAS --

# Limit boundaries of prediction
geo_area_future_50 <- crop(future_env_50, predict_extent)

# Generate prediction from model over boundaries
# Where else could C. pallida be (in the future)
species_pred_plot_future_50 <- raster::predict(species_SDM, geo_area_future_50)

# Convert prediction to a data frame for plotting
raster_spdf_future_50 <- as(species_pred_plot_future_50, 
                            "SpatialPixelsDataFrame")
species_pred_df_future_50 <- as.data.frame(raster_spdf_future_50)




# ----- PLOT CURRENT AND PREDICTED PLOTS -----

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")

# Set boundaries where current map should be focused
xmax <- max(species_pred_df$x)
xmin <- min(species_pred_df$x)
ymax <- max(species_pred_df$y)
ymin <- min(species_pred_df$y)

# Current SDM
current_plot <- ggplot() +
  geom_polygon(data = wrld, 
               mapping = aes(x = long, y = lat, group = group),
               fill = "#BFBFBF") +
  geom_raster(data = species_pred_df, 
              aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colours=viridis::viridis(99)) +
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

# Set boundaries where future map should be focused
xmax_f <- max(species_pred_df_future_50$x)
xmin_f <- min(species_pred_df_future_50$x)
ymax_f <- max(species_pred_df_future_50$y)
ymin_f <- min(species_pred_df_future_50$y)

# Future SDM (50 years)
future_plot_50 <- ggplot() +
  geom_polygon(data = wrld, 
               mapping = aes(x = long, y = lat, group = group),
               fill = "#BFBFBF") +
  geom_raster(data = species_pred_df_future_50, 
              aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colours=viridis::viridis(99)) +
  coord_fixed(xlim = c(xmin_f, xmax_f), 
              ylim = c(ymin_f, ymax_f), 
              expand = F) +
  scale_size_area() +
  borders("state") +
  labs(title = 
         bquote(bold("under CMIP5 Climate Predictions (50 yrs)")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(legend.box.background = element_rect(),
        legend.position = "bottom")




# ----- PLOT CURRENT AND FUTURE SIDE-BY-SIDE -----

# Combine plots for current and 50 years
plot_row <- plot_grid(current_plot, future_plot_50)

# Generate common plot title
title <- ggdraw() + 
  draw_label(bquote("Species Distribution Model of" ~italic("Parkinsonia microphylla")),
             fontface = "bold",
             hjust = 0.5,
             size = 20)

# Add title to combined plots
combined_plots <- plot_grid(title,
                            plot_row,
                            ncol = 1,
                            rel_heights = c(0.1, 1))

# Save combined plots
ggsave(filename = "current_future_SDM_pmicrophylla.jpg",
       plot = combined_plots,
       path = "output/SDM_first_attempt",
       width = 3000,
       height = 1791,
       units = "px")
