# Maxine Cruz
# tmcruz@arizona.edu
# Created: 22 March 2024
# Last modified: 14 May 2024




# ----- ABOUT -----

# Generates ggplot maps from Maxent results
  # 1) Creates a grid of current distributions (4 panels)
  # 2) Creates a grid of future distributions (4 panels)



# ----- LOAD LIBRARIES -----

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

# Function
source("functions.R")

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")

# Major cities
city_coords <- data.frame(city = c("Phoenix", "Tucson", "Las Vegas", 
                                   "Los Angeles", "San Diego", "Hermosillo"),
                          latitude = c(33.6055497, 32.1560939, 36.1251645,
                                       34.0206085, 32.8246976, 29.0834732),
                          longitude = c(-112.4547019, -111.0486154, -115.3398097,
                                        -118.7413831, -117.4386299, -111.0707154))




# ----- CURRENT MAPS -----

# P. florida seems to have the widest area so we'll match the axes for all maps
  # to that one. This also makes it so plot_grid doesn't come out wonky.

# P. florida zoom box
zoom_data <- read.csv("output/parkinsonia_florida/worldclim_predicted_distribution_adjusted.csv")

xmax <- max(zoom_data$x) + 1
xmin <- min(zoom_data$x) - 1
ymax <- max(zoom_data$y) + 1
ymin <- min(zoom_data$y) - 1

# Now all maps should have the same axes

# C. pallida

data <- read.csv("output/centris_pallida/worldclim_predicted_distribution_adjusted.csv")
plot_a <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# O. tesota

data <- read.csv("output/olneya_tesota/worldclim_predicted_distribution_adjusted.csv")
plot_b <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# P. florida

data <- read.csv("output/parkinsonia_florida/worldclim_predicted_distribution_adjusted.csv")
plot_c <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# P. microphylla

data <- read.csv("output/parkinsonia_microphylla/worldclim_predicted_distribution_adjusted.csv")
plot_d <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# Plot as a grid
current_grid <- plot_grid(plot_a + theme(legend.position = "none"), 
                          plot_b + theme(legend.position = "none"), 
                          plot_c + theme(legend.position = "none"), 
                          plot_d + theme(legend.position = "none"),
                          labels = "auto",
                          label_size = 20,
                          ncol = 2)

# Get legend from one plot to use for all plots
legend <- get_legend(plot_a)

# Plot grid with legend
current_grid2 <- plot_grid(current_grid, legend, rel_widths = c(3, 0.6))

# Check grid
current_grid2

# Save plot
ggsave("output/distribution_maps/species_distribution_maps_current.png", 
       current_grid2,
       width = 17.33,
       height = 17.445,
       units = "cm")




# ----- FUTURE MAPS -----

# C. pallida seems to have the widest area so we'll match the axes for all maps
  # to that one. This also makes it so plot_grid doesn't come out wonky.

# C. pallida zoom box
zoom_data <- read.csv("output/centris_pallida/ssp245_2021_predicted_distribution_adjusted.csv")

xmax <- max(zoom_data$x) + 1
xmin <- min(zoom_data$x) - 1
ymax <- max(zoom_data$y) + 1
ymin <- min(zoom_data$y) - 1

# Now all maps should have the same axes

# C. pallida

data <- read.csv("output/centris_pallida/ssp245_2021_predicted_distribution_adjusted.csv")
plot_a <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# O. tesota

data <- read.csv("output/olneya_tesota/ssp245_2021_predicted_distribution_adjusted.csv")
plot_b <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# P. florida

data <- read.csv("output/parkinsonia_florida/ssp245_2021_predicted_distribution_adjusted.csv")
plot_c <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# P. microphylla

data <- read.csv("output/parkinsonia_microphylla/ssp245_2021_predicted_distribution_adjusted.csv")
plot_d <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# Plot as a grid
current_grid <- plot_grid(plot_a + theme(legend.position = "none"), 
                          plot_b + theme(legend.position = "none"), 
                          plot_c + theme(legend.position = "none"), 
                          plot_d + theme(legend.position = "none"),
                          labels = "auto",
                          label_size = 20,
                          ncol = 2)

# Get legend from one plot to use for all plots
legend <- get_legend(plot_a)

# Plot grid with legend
current_grid2 <- plot_grid(current_grid, legend, rel_widths = c(3, 0.6))

# Check grid
current_grid2

# Save plot
ggsave("output/distribution_maps/species_distribution_maps_future.png", 
       current_grid2,
       width = 18,
       height = 14.779,
       units = "cm")










# ----- MAKE STRIPS -----

# Strips are structured as:
  # Current predictions (2000-2021)
  # Predictions under SSP 370 for 20-year increments

# -- Centris pallida --

# Current
data <- read.csv("output/centris_pallida/worldclim_predicted_distribution.csv")
plot_a <- custom_ggplot1(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/centris_pallida/ssp245_2021_predicted_distribution.csv")
plot_b <- custom_ggplot1(sdm_data = data, sdm_type = "SSP2-4.5 2021-2040")

# 2041
data <- read.csv("output/centris_pallida/ssp245_2041_predicted_distribution.csv")
plot_c <- custom_ggplot1(sdm_data = data, sdm_type = "SSP2-4.5 2041-2060")

# Strip
cp_strip <- plot_grid(plot_a, plot_b, plot_c,
                      labels = "auto",
                      label_size = 20,
                      ncol = 3)

# Check
cp_strip

# Save
ggsave2(file = "output/centris_pallida/distribution_strip.png",
       plot = last_plot(),
       width = 44,
       height = 20,
       units = "cm")

# -- Olneya tesota --

# Current
data <- read.csv("output/olneya_tesota/worldclim_predicted_distribution.csv")
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/olneya_tesota/ssp245_2021_predicted_distribution.csv")
plot_b <- custom_ggplot1(sdm_data = data, sdm_type = "SSP2-4.5 2021-2040")

# 2041
data <- read.csv("output/olneya_tesota/ssp245_2041_predicted_distribution.csv")
plot_c <- custom_ggplot1(sdm_data = data, sdm_type = "SSP2-4.5 2041-2060")

# Strip
ot_strip <- plot_grid(plot_a, plot_b, plot_c,
                      labels = "auto",
                      label_size = 20,
                      ncol = 3)

# Check
ot_strip

# Save
ggsave2(file = "output/olneya_tesota/distribution_strip.png",
        plot = last_plot(),
        width = 46,
        height = 20,
        units = "cm")

# -- Parkinsonia florida --

# Current
data <- read.csv("output/parkinsonia_florida/worldclim_predicted_distribution.csv")
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/parkinsonia_florida/ssp245_2021_predicted_distribution.csv")
plot_b <- custom_ggplot1(sdm_data = data, sdm_type = "SSP2-4.5 2021-2040")

# 2041
data <- read.csv("output/parkinsonia_florida/ssp245_2041_predicted_distribution.csv")
plot_c <- custom_ggplot1(sdm_data = data, sdm_type = "SSP2-4.5 2041-2060")

# Strip
pf_strip <- plot_grid(plot_a, plot_b, plot_c,
                      labels = "auto",
                      label_size = 20,
                      ncol = 3)

# Check
pf_strip

# Save
ggsave2(file = "output/parkinsonia_florida/distribution_strip.png",
        plot = last_plot(),
        width = 47,
        height = 20,
        units = "cm")

# -- Parkinsonia microphylla --

# Current
data <- read.csv("output/parkinsonia_microphylla/worldclim_predicted_distribution.csv")
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/parkinsonia_microphylla/ssp245_2021_predicted_distribution.csv")
plot_b <- custom_ggplot1(sdm_data = data, sdm_type = "SSP2-4.5 2021-2040")

# 2041
data <- read.csv("output/parkinsonia_microphylla/ssp245_2041_predicted_distribution.csv")
plot_c <- custom_ggplot1(sdm_data = data, sdm_type = "SSP2-4.5 2041-2060")

# Strip
pm_strip <- plot_grid(plot_a, plot_b, plot_c,
                      labels = "auto",
                      label_size = 20,
                      ncol = 3)

# Check
pm_strip

# Save
ggsave2(file = "output/parkinsonia_microphylla/distribution_strip.png",
        plot = last_plot(),
        width = 38,
        height = 20,
        units = "cm")




# ----- MAKE PANEL -----

# Re-open images for arranging
cp_plot <- readPNG("output/centris_pallida/distribution_strip.png")
ot_plot <- readPNG("output/olneya_tesota/distribution_strip.png")
pf_plot <- readPNG("output/parkinsonia_florida/distribution_strip.png")
pm_plot <- readPNG("output/parkinsonia_microphylla/distribution_strip.png")

# Arrange images in one one plot
plots <- plot_grid(rasterGrob(cp_plot), rasterGrob(ot_plot), 
                   rasterGrob(pf_plot), rasterGrob(pm_plot),
                   labels = "auto",
                   label_size = 20,
                   ncol = 1)

# Check
plots

# Save plot
ggsave("output/species_distribution_maps.png", 
       plots,
       width = 20,
       height = 65,
       units = "cm")




# ----- ALTERNATE METHOD -----

# -- Centris pallida --

# Current
data <- read.csv("output/centris_pallida/worldclim_predicted_distribution.csv")
plot_a <- custom_ggplot1(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/centris_pallida/ssp245_2021_predicted_distribution.csv")
plot_b <- custom_ggplot2(sdm_data = data, sdm_type = "SSP2-4.5 2021-2040")

# 2041
data <- read.csv("output/centris_pallida/ssp245_2041_predicted_distribution.csv")
plot_c <- custom_ggplot2(sdm_data = data, sdm_type = "SSP2-4.5 2041-2060")

# -- Olneya tesota --

# Current
data <- read.csv("output/olneya_tesota/worldclim_predicted_distribution.csv")
plot_d <- custom_ggplot1(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/olneya_tesota/ssp245_2021_predicted_distribution.csv")
plot_e <- custom_ggplot2(sdm_data = data, sdm_type = "SSP2-4.5 2021-2040")

# 2041
data <- read.csv("output/olneya_tesota/ssp245_2041_predicted_distribution.csv")
plot_f <- custom_ggplot2(sdm_data = data, sdm_type = "SSP2-4.5 2041-2060")

# -- Parkinsonia florida --

# Current
data <- read.csv("output/parkinsonia_florida/worldclim_predicted_distribution.csv")
plot_g <- custom_ggplot1(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/parkinsonia_florida/ssp245_2021_predicted_distribution.csv")
plot_h <- custom_ggplot2(sdm_data = data, sdm_type = "SSP2-4.5 2021-2040")

# 2041
data <- read.csv("output/parkinsonia_florida/ssp245_2041_predicted_distribution.csv")
plot_i <- custom_ggplot2(sdm_data = data, sdm_type = "SSP2-4.5 2041-2060")

# -- Parkinsonia microphylla --

# Current
data <- read.csv("output/parkinsonia_microphylla/worldclim_predicted_distribution.csv")
plot_j <- custom_ggplot1(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/parkinsonia_microphylla/ssp245_2021_predicted_distribution.csv")
plot_k <- custom_ggplot2(sdm_data = data, sdm_type = "SSP2-4.5 2021-2040")

# 2041
data <- read.csv("output/parkinsonia_microphylla/ssp245_2041_predicted_distribution.csv")
plot_l <- custom_ggplot2(sdm_data = data, sdm_type = "SSP2-4.5 2041-2060")

# Full panel
panel <- plot_grid(plot_a, plot_b, plot_c,
                   plot_d, plot_e, plot_f,
                   plot_g, plot_h, plot_i,
                   plot_j, plot_k, plot_l,
                   labels = "auto",
                   align = "hv",
                   label_size = 20,
                   ncol = 3)

# Check
panel

# Save plot
ggsave("output/species_distribution_maps.png", 
       panel,
       width = 25.2,
       height = 55,
       units = "cm")

