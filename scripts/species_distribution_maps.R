# Maxine Cruz
# tmcruz@arizona.edu
# Created: 22 March 2024
# Last modified: 22 April 2024




# ----- ABOUT -----

# Generates ggplot maps from Maxent results

# 1) Creates strips of 2000-2021, 2021-40, and 2041-60 predictions for each species
# 2) Arranges species strips so the final plot is a panel of scenarios




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




# ----- MAKE STRIPS -----

# Strips are structured as:
  # Current predictions (2000-2021)
  # Predictions under SSP 370 for 20-year increments

# -- Centris pallida --

# Current
data <- read.csv("output/centris_pallida/worldclim_predicted_distribution.csv")
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/centris_pallida/ssp370_2021_predicted_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2021-2040")

# 2041
data <- read.csv("output/centris_pallida/ssp370_2041_predicted_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2041-2060")

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
data <- read.csv("output/olneya_tesota/ssp370_2021_predicted_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2021-2040")

# 2041
data <- read.csv("output/olneya_tesota/ssp370_2041_predicted_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2041-2060")

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
data <- read.csv("output/parkinsonia_florida/ssp370_2021_predicted_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2021-2040")

# 2041
data <- read.csv("output/parkinsonia_florida/ssp370_2041_predicted_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2041-2060")

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
data <- read.csv("output/parkinsonia_microphylla/ssp370_2021_predicted_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2021-2040")

# 2041
data <- read.csv("output/parkinsonia_microphylla/ssp370_2041_predicted_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2041-2060")

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
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/centris_pallida/ssp370_2021_predicted_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2021-2040")

# 2041
data <- read.csv("output/centris_pallida/ssp370_2041_predicted_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2041-2060")

# -- Olneya tesota --

# Current
data <- read.csv("output/olneya_tesota/worldclim_predicted_distribution.csv")
plot_d <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/olneya_tesota/ssp370_2021_predicted_distribution.csv")
plot_e <- custom_ggplot(sdm_data = data, sdm_type = "2021-2040")

# 2041
data <- read.csv("output/olneya_tesota/ssp370_2041_predicted_distribution.csv")
plot_f <- custom_ggplot(sdm_data = data, sdm_type = "2041-2060")

# -- Parkinsonia florida --

# Current
data <- read.csv("output/parkinsonia_florida/worldclim_predicted_distribution.csv")
plot_g <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/parkinsonia_florida/ssp370_2021_predicted_distribution.csv")
plot_h <- custom_ggplot(sdm_data = data, sdm_type = "2021-2040")

# 2041
data <- read.csv("output/parkinsonia_florida/ssp370_2041_predicted_distribution.csv")
plot_i <- custom_ggplot(sdm_data = data, sdm_type = "2041-2060")

# -- Parkinsonia microphylla --

# Current
data <- read.csv("output/parkinsonia_microphylla/worldclim_predicted_distribution.csv")
plot_j <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2021
data <- read.csv("output/parkinsonia_microphylla/ssp370_2021_predicted_distribution.csv")
plot_k <- custom_ggplot(sdm_data = data, sdm_type = "2021-2040")

# 2041
data <- read.csv("output/parkinsonia_microphylla/ssp370_2041_predicted_distribution.csv")
plot_l <- custom_ggplot(sdm_data = data, sdm_type = "2041-2060")

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
       width = 30,
       height = 55,
       units = "cm")

