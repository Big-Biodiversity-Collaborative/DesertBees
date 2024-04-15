# Maxine Cruz
# tmcruz@arizona.edu
# Created: 22 March 2024
# Last modified: 25 March 2024




# ----- ABOUT -----

# Generates ggplot maps from Maxent results

# 1) Creates strips of current, SSP 245, SSP 370, and SSP 585 for each species
# 2) Arranges species strips so the final plot is a panel of scenarios




# ----- LOAD LIBRARIES -----

library(ggplot2)
library(cowplot)

# Function
source("functions.R")

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")




# ----- MAKE STRIPS -----

# Strips are structured as:
  # Current predictions
  # Predictions under SSP 245
  # Predictions under SSP 370
  # Predictions under SSP 585

# -- Centris pallida --

# Current
data <- read.csv("output/centris_pallida/current_distribution.csv")
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2041
data <- read.csv("output/centris_pallida/future370_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2041-2070")

# 2071
data <- read.csv("output/centris_pallida/future370_2071_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2071-2100")

# Strip
cp_strip <- plot_grid(plot_a, plot_b, plot_c,
                      labels = "auto",
                      label_size = 20,
                      ncol = 3)

# Save
ggsave2(file = "output/centris_pallida/distribution_strip.png",
       plot = last_plot(),
       width = 35,
       height = 20,
       units = "cm")




# -- Olneya tesota --

# Current
data <- read.csv("output/Olneya tesota/current_distribution.csv")
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2041
data <- read.csv("output/Olneya tesota/future370_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2041-2070")

# 2071
data <- read.csv("output/Olneya tesota/future370_2071_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2071-2100")

# Strip
cp_strip <- plot_grid(plot_a, plot_b, plot_c,
                      labels = "auto",
                      label_size = 20,
                      ncol = 3)

# Save
ggsave2(file = "output/Olneya tesota/distribution_strip.png",
        plot = last_plot(),
        width = 35,
        height = 20,
        units = "cm")




# -- Parkinsonia florida --

# Current
data <- read.csv("output/Parkinsonia florida/current_distribution.csv")
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2041
data <- read.csv("output/Parkinsonia florida/future370_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2041-2070")

# 2071
data <- read.csv("output/Parkinsonia florida/future370_2071_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2071-2100")

# Strip
cp_strip <- plot_grid(plot_a, plot_b, plot_c,
                      labels = "auto",
                      label_size = 20,
                      ncol = 3)

# Save
ggsave2(file = "output/Parkinsonia florida/distribution_strip.png",
        plot = last_plot(),
        width = 35,
        height = 20,
        units = "cm")




# -- Parkinsonia microphylla --

# Current
data <- read.csv("output/Parkinsonia microphylla/current_distribution.csv")
plot_a <- custom_ggplot(sdm_data = data, sdm_type = "2000-2021")

# 2041
data <- read.csv("output/Parkinsonia microphylla/future370_distribution.csv")
plot_b <- custom_ggplot(sdm_data = data, sdm_type = "2041-2070")

# 2071
data <- read.csv("output/Parkinsonia microphylla/future370_2071_distribution.csv")
plot_c <- custom_ggplot(sdm_data = data, sdm_type = "2071-2100")

# Strip
cp_strip <- plot_grid(plot_a, plot_b, plot_c,
                      labels = "auto",
                      label_size = 20,
                      ncol = 3)

# Save
ggsave2(file = "output/Parkinsonia microphylla/distribution_strip.png",
        plot = last_plot(),
        width = 35,
        height = 20,
        units = "cm")




# ----- MAKE PANEL -----



