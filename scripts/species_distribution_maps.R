# Maxine Cruz
# tmcruz@arizona.edu
# Created: 22 March 2024
# Last modified: 8 September 2024




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

# library(ggsn)

# Function
source("functions.R")

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")




# ----- CURRENT MAPS -----

# P. florida seems to have the widest area so we'll match the axes for all maps
  # to that one. This also makes it so plot_grid doesn't come out wonky.

# P. florida zoom box
zoom_data <- read.csv("output/parkinsonia_florida/worldclim/worldclim_predicted_distribution_adjusted.csv")

xmax <- max(zoom_data$x) + 1
xmin <- min(zoom_data$x) - 1
ymax <- max(zoom_data$y) + 1
ymin <- min(zoom_data$y) - 1

# Now all maps should have the same axes

# C. pallida

data <- read.csv("output/centris_pallida/worldclim/worldclim_predicted_distribution_adjusted.csv")
plot_a <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# O. tesota

data <- read.csv("output/olneya_tesota/worldclim/worldclim_predicted_distribution_adjusted.csv")
plot_b <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# P. florida

data <- read.csv("output/parkinsonia_florida/worldclim/worldclim_predicted_distribution_adjusted.csv")
plot_c <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# P. microphylla

data <- read.csv("output/parkinsonia_microphylla/worldclim/worldclim_predicted_distribution_adjusted.csv")
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
zoom_data <- read.csv("output/centris_pallida/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.csv")

xmax <- max(zoom_data$x) + 1
xmin <- min(zoom_data$x) - 1
ymax <- max(zoom_data$y) + 1
ymin <- min(zoom_data$y) - 1

# Now all maps should have the same axes

# C. pallida

data <- read.csv("output/centris_pallida/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.csv")
plot_a <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# O. tesota

data <- read.csv("output/olneya_tesota/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.csv")
plot_b <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# P. florida

data <- read.csv("output/parkinsonia_florida/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.csv")
plot_c <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# P. microphylla

data <- read.csv("output/parkinsonia_microphylla/ssp245_2021/ssp245_2021_predicted_distribution_adjusted.csv")
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





