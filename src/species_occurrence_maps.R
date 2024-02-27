# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 September 2023
# Last modified: 15 December 2023 




# ----- ABOUT THE SCRIPT -----

# Generate occurrence maps for:
  # Centris pallida (speciesKey: 1342915)
  # Olneya tesota (speciesKey: 2974564)
  # Parkinsonia florida (speciesKey: 5359949)
  # Parkinsonia microphylla (speciesKey: 5359945)




# ----- LOAD LIBRARIES -----

library(dplyr)
library(ggplot2)
library(leaflet) 
library(mapview)
library(png)
library(grid)
library(cowplot)




# ----- LOAD DATA -----

# Read data set
data <- read.csv("data/GBIF/cleaned_species_with_elevation.csv")

# Separate species for individual plots
cp <- data %>%
  filter(speciesKey == 1342915)
ot <- data %>%
  filter(speciesKey == 2974564)
pf <- data %>%
  filter(speciesKey == 5359949)
pm <- data %>%
  filter(speciesKey == 5359945)




# ----- GENERATE MAPS -----

# C. PALLIDA
cp_plot <- leaflet(cp,
                   options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("Esri.WorldTopoMap") %>%
  addCircleMarkers(color = "#CD1076",
                   radius = 3,
                   fillOpacity = 0.8,
                   stroke = FALSE)

# Save map
mapshot(cp_plot,
        file = "output/occurrence_maps/cp_map.png")

# ---

# O. TESOTA
ot_plot <- leaflet(ot,
                   options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("Esri.WorldTopoMap") %>%
  addCircleMarkers(color = "#4F77DC",
                   radius = 3,
                   fillOpacity = 0.8,
                   stroke = FALSE)

# Save map
mapshot(ot_plot,
        file = "output/occurrence_maps/ot_map.png")

# ---

# P. FLORIDA
pf_plot <- leaflet(pf,
                   options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("Esri.WorldTopoMap") %>%
  addCircleMarkers(color = "#7B68EE",
                   radius = 3,
                   fillOpacity = 0.8,
                   stroke = FALSE)

# Save map
mapshot(pf_plot,
        file = "output/occurrence_maps/pf_map.png")

# ---

# P. MICROPHYLLA
pm_plot <- leaflet(pm,
                   options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("Esri.WorldTopoMap") %>%
  addCircleMarkers(color = "#EE7600",
                   radius = 3,
                   fillOpacity = 0.8,
                   stroke = FALSE)

# Save map
mapshot(pm_plot,
        file = "output/occurrence_maps/pm_map.png")




# ----- PLOT MAPS IN ONE FIGURE -----

# Re-open images for arranging
cp_plot <- readPNG("output/occurrence_maps/cp_map.png")
ot_plot <- readPNG("output/occurrence_maps/ot_map.png")
pf_plot <- readPNG("output/occurrence_maps/pf_map.png")
pm_plot <- readPNG("output/occurrence_maps/pm_map.png")

# Arrange images in one one plot
plots <- plot_grid(rasterGrob(cp_plot), rasterGrob(ot_plot), 
                   rasterGrob(pf_plot), rasterGrob(pm_plot),
                   labels = c("A", "B", "C", "D"),
                   label_size = 20,
                   ncol = 2)

# Save plot
ggsave("output/occurrence_maps/species_occurrence_maps.png", 
       plots,
       width = 20,
       height = 15,
       units = "cm")



