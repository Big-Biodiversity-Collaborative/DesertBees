# Maxine Cruz
# tmcruz@arizona.edu
# Created: 5 September 2024
# Last modified: 5 September 2024




# ----- ABOUT -----

# Generates ggplot maps from test (model_tests.R) Maxent results
  # C. pallida was used for testing




# ----- LOAD LIBRARIES -----

# For plotting
library(ggplot2)

# Function
source("functions.R")

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")




# ----- TEST (A) MAPS -----

# -- CURRENT --

# Data
data <- read.csv("output/tests/worldclim_predicted_distribution_adjusted.csv")

# Zoom box
xmax <- max(data$x) + 1
xmin <- min(data$x) - 1
ymax <- max(data$y) + 1
ymin <- min(data$y) - 1

# Plot
plot <- custom_ggplot1(sdm_data = data, 
                       xmin = xmin, xmax = xmax, 
                       ymin = ymin, ymax = ymax)

# Save plot
ggsave("output/tests/distribution_maps/species_distribution_maps_current.png", 
       plot,
       width = 17,
       height = 16,
       units = "cm")

# -- FUTURE --

# Data
data <- read.csv("output/tests/ssp245_2021_predicted_distribution_adjusted.csv")

# Zoom box
xmax <- max(data$x) + 1
xmin <- min(data$x) - 1
ymax <- max(data$y) + 1
ymin <- min(data$y) - 1

# Plot
plot <- custom_ggplot2(sdm_data = data, 
                       xmin = xmin, xmax = xmax, 
                       ymin = ymin, ymax = ymax)

# Save plot
ggsave("output/tests/distribution_maps/species_distribution_maps_future.png", 
       plot,
       width = 17,
       height = 16,
       units = "cm")




# ----- TEST (B) MAPS -----

# -- CURRENT --

# Data
data <- read.csv("output/tests/worldclim_predicted_distribution_adjusted_2.csv")

# Zoom box
xmax <- max(data$x) + 1
xmin <- min(data$x) - 1
ymax <- max(data$y) + 1
ymin <- min(data$y) - 1

# Plot
plot <- custom_ggplot1(sdm_data = data, 
                       xmin = xmin, xmax = xmax, 
                       ymin = ymin, ymax = ymax)

# Save plot
ggsave("output/tests/distribution_maps/species_distribution_maps_current_2.png", 
       plot,
       width = 17,
       height = 16,
       units = "cm")

# -- FUTURE --

# Data
data <- read.csv("output/tests/ssp245_2021_predicted_distribution_adjusted_2.csv")

# Zoom box
xmax <- max(data$x) + 1
xmin <- min(data$x) - 1
ymax <- max(data$y) + 1
ymin <- min(data$y) - 1

# Plot
plot <- custom_ggplot2(sdm_data = data, 
                       xmin = xmin, xmax = xmax, 
                       ymin = ymin, ymax = ymax)

# Save plot
ggsave("output/tests/distribution_maps/species_distribution_maps_future_2.png", 
       plot,
       width = 17,
       height = 16,
       units = "cm")









