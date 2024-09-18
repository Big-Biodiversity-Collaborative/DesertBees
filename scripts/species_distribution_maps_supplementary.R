# Maxine Cruz
# tmcruz@arizona.edu
# Created: 22 March 2024
# Last modified: 27 August 2024




# ----- ABOUT -----

# Generates supplementary material ggplot maps from Maxent results
  # Maps for 2041-2060, 2061-2070, and 2081-2100
  # under SSP 2-4.5 and SSP 3-7.0

# Supplementary Figure 1: C. pallida

# Supplementary Figure 2: For the plants,
  # Rows 1-2, O. tesota
  # 3-4, P. florida
  # 5-6, P. microphylla




# ----- LOAD LIBRARIES -----

# For plotting
library(ggplot2)

# For organizing panel arrangement
library(cowplot)
library(png)
library(grid)

# Function
source("functions.R")

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")




# ----- C. PALLIDA 2041-2100 -----

# C. pallida zoom box
zoom_data <- read.csv("output/centris_pallida/ssp245_2041/ssp245_2041_predicted_distribution_adjusted.csv")

xmax <- max(zoom_data$x) + 1
xmin <- min(zoom_data$x) - 1
ymax <- max(zoom_data$y) + 1
ymin <- min(zoom_data$y) - 1

# Now all maps should have the same axes

# 245 - 2041
data <- read.csv("output/centris_pallida/ssp245_2041/ssp245_2041_predicted_distribution_adjusted.csv")
plot_a <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 245 - 2061
data <- read.csv("output/centris_pallida/ssp245_2061/ssp245_2061_predicted_distribution_adjusted.csv")
plot_b <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 245 - 2081
data <- read.csv("output/centris_pallida/ssp245_2081/ssp245_2081_predicted_distribution_adjusted.csv")
plot_c <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2041
data <- read.csv("output/centris_pallida/ssp370_2041/ssp370_2041_predicted_distribution_adjusted.csv")
plot_d <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2061
data <- read.csv("output/centris_pallida/ssp370_2061/ssp370_2061_predicted_distribution_adjusted.csv")
plot_e <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2081
data <- read.csv("output/centris_pallida/ssp370_2081/ssp370_2081_predicted_distribution_adjusted.csv")
plot_f <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# Plot as grid
grid <- plot_grid(plot_a + theme(legend.position = "none"), 
                  plot_b + theme(legend.position = "none"), 
                  plot_c + theme(legend.position = "none"),
                  plot_d + theme(legend.position = "none"), 
                  plot_e + theme(legend.position = "none"), 
                  plot_f + theme(legend.position = "none"),
                  labels = "auto",
                  label_size = 20,
                  ncol = 3)

# Save plot
ggsave("output/distribution_maps/species_distribution_maps_supplementary.png", 
       grid,
       width = 20,
       height = 13,
       units = "cm")




# ----- HOSTPLANTS 2061-2100 -----

# C. pallida zoom box
zoom_data <- read.csv("output/centris_pallida/ssp245_2041/ssp245_2041_predicted_distribution_adjusted.csv")

xmax <- max(zoom_data$x) + 1
xmin <- min(zoom_data$x) - 1
ymax <- max(zoom_data$y) + 1
ymin <- min(zoom_data$y) - 1

# Now all maps should have the same axes as C. pallida maps

# -- O. tesota --

# 245 - 2041
data <- read.csv("output/olneya_tesota/ssp245_2041/ssp245_2041_predicted_distribution_adjusted.csv")
plot_a <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 245 - 2061
data <- read.csv("output/olneya_tesota/ssp245_2061/ssp245_2061_predicted_distribution_adjusted.csv")
plot_b <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 245 - 2081
data <- read.csv("output/olneya_tesota/ssp245_2081/ssp245_2081_predicted_distribution_adjusted.csv")
plot_c <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2041
data <- read.csv("output/olneya_tesota/ssp370_2041/ssp370_2041_predicted_distribution_adjusted.csv")
plot_d <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2061
data <- read.csv("output/olneya_tesota/ssp370_2061/ssp370_2061_predicted_distribution_adjusted.csv")
plot_e <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2081
data <- read.csv("output/olneya_tesota/ssp370_2081/ssp370_2081_predicted_distribution_adjusted.csv")
plot_f <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# -- P. florida --

# 245 - 2041
data <- read.csv("output/parkinsonia_florida/ssp245_2041/ssp245_2041_predicted_distribution_adjusted.csv")
plot_a1 <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 245 - 2061
data <- read.csv("output/parkinsonia_florida/ssp245_2061/ssp245_2061_predicted_distribution_adjusted.csv")
plot_b1 <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 245 - 2081
data <- read.csv("output/parkinsonia_florida/ssp245_2081/ssp245_2081_predicted_distribution_adjusted.csv")
plot_c1 <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2041
data <- read.csv("output/parkinsonia_florida/ssp370_2041/ssp370_2041_predicted_distribution_adjusted.csv")
plot_d1 <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2061
data <- read.csv("output/parkinsonia_florida/ssp370_2061/ssp370_2061_predicted_distribution_adjusted.csv")
plot_e1 <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2081
data <- read.csv("output/parkinsonia_florida/ssp370_2081/ssp370_2081_predicted_distribution_adjusted.csv")
plot_f1 <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# -- P. microphylla --

# 245 - 2041
data <- read.csv("output/parkinsonia_microphylla/ssp245_2041/ssp245_2041_predicted_distribution_adjusted.csv")
plot_a2 <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 245 - 2061
data <- read.csv("output/parkinsonia_microphylla/ssp245_2061/ssp245_2061_predicted_distribution_adjusted.csv")
plot_b2 <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 245 - 2081
data <- read.csv("output/parkinsonia_microphylla/ssp245_2081/ssp245_2081_predicted_distribution_adjusted.csv")
plot_c2 <- custom_ggplot1(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2041
data <- read.csv("output/parkinsonia_microphylla/ssp370_2041/ssp370_2041_predicted_distribution_adjusted.csv")
plot_d2 <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2061
data <- read.csv("output/parkinsonia_microphylla/ssp370_2061/ssp370_2061_predicted_distribution_adjusted.csv")
plot_e2 <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)

# 370 - 2081
data <- read.csv("output/parkinsonia_microphylla/ssp370_2081/ssp370_2081_predicted_distribution_adjusted.csv")
plot_f2 <- custom_ggplot2(sdm_data = data, 
                         xmin = xmin, xmax = xmax, 
                         ymin = ymin, ymax = ymax)




# ----- PLOT ALL HOSTPLANTS MAPS -----

# Plot as grid
grid <- plot_grid(plot_a + theme(legend.position = "none"), 
                  plot_b + theme(legend.position = "none"), 
                  plot_c + theme(legend.position = "none"),
                  plot_d + theme(legend.position = "none"), 
                  plot_e + theme(legend.position = "none"), 
                  plot_f + theme(legend.position = "none"),
                  
                  plot_a1 + theme(legend.position = "none"), 
                  plot_b1 + theme(legend.position = "none"), 
                  plot_c1 + theme(legend.position = "none"),
                  plot_d1 + theme(legend.position = "none"), 
                  plot_e1 + theme(legend.position = "none"), 
                  plot_f1 + theme(legend.position = "none"),
                  
                  plot_a2 + theme(legend.position = "none"), 
                  plot_b2 + theme(legend.position = "none"), 
                  plot_c2 + theme(legend.position = "none"),
                  plot_d2 + theme(legend.position = "none"), 
                  plot_e2 + theme(legend.position = "none"), 
                  plot_f2 + theme(legend.position = "none"),
                  
                  labels = "auto",
                  label_size = 20,
                  ncol = 3)

# Save plot
ggsave("output/distribution_maps/species_distribution_maps_supplementary_2.png", 
       grid,
       width = 20,
       height = 40,
       units = "cm")



