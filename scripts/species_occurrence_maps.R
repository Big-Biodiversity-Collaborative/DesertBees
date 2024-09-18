# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 September 2023
# Last modified: 22 April 2024




# ----- ABOUT THE SCRIPT -----

# Generate occurrence maps for:
  # Centris pallida (speciesKey: 1342915)
  # Olneya tesota (speciesKey: 2974564)
  # Parkinsonia florida (speciesKey: 5359949)
  # Parkinsonia microphylla (speciesKey: 5359945)




# ----- LOAD LIBRARIES -----

# For organizing data
library(dplyr)

# For plotting
library(ggplot2)
library(leaflet)

# For saving maps
library(mapview)

# For organizing panels
library(png)
library(grid)
library(cowplot)




# ----- LOAD DATA -----

# Read data set
data <- read.csv("data/gbif/cleaned_species_with_elevation.csv")

# Separate species for individual plots
  # Also separate by used observations and omitted from model

cp <- data %>%
  filter(speciesKey == 1342915) #%>%
  #filter(elevation > 0 | is.na(elevation))

#cp_omitted <- data %>%
#  filter(speciesKey == 1342915) %>%
#  filter(elevation <= 0)

# Check:
  # cp_all <- data %>% filter(speciesKey == 1342915)

ot <- data %>%
  filter(speciesKey == 2974564) #%>%
  #filter(elevation > 0 | is.na(elevation))

#ot_omitted <- data %>%
#  filter(speciesKey == 2974564) %>%
#  filter(elevation <= 0)

# Check:
  # ot_all <- data %>% filter(speciesKey == 2974564)

pf <- data %>%
  filter(speciesKey == 5359949) #%>%
  #filter(elevation > 0 | is.na(elevation))

#pf_omitted <- data %>%
#  filter(speciesKey == 5359949) %>%
#  filter(elevation <= 0)

# Check:
  # pf_all <- data %>% filter(speciesKey == 5359949)

pm <- data %>%
  filter(speciesKey == 5359945) #%>%
  #filter(elevation > 0 | is.na(elevation))

#pm_omitted <- data %>%
#  filter(speciesKey == 5359945) %>%
#  filter(elevation <= 0)

# Check:
  # pm_all <- data %>% filter(speciesKey == 5359945)




# ----- GENERATE MAPS -----

# C. PALLIDA ---
cp_plot <- leaflet(options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("OpenStreetMap.Mapnik") %>%
  addCircleMarkers(data = cp,
                   color = "#CD1076",
                   radius = 5,
                   fillOpacity = 0.8,
                   stroke = FALSE) #%>%
  addCircleMarkers(data = cp_omitted,
                   color = "black",
                   radius = 5,
                   fillOpacity = 0.8,
                   stroke = FALSE) %>%
  addScaleBar(position = "bottomleft")

# Check
cp_plot

# Save map
mapshot(cp_plot,
        file = "output/occurrence_maps/cp_map.png")

# O. TESOTA ---
ot_plot <- leaflet(options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("OpenStreetMap.Mapnik") %>%
  addCircleMarkers(data = ot,
                   color = "#EE7600",
                   radius = 5,
                   fillOpacity = 0.8,
                   stroke = FALSE) #%>%
  addCircleMarkers(data = ot_omitted,
                   color = "black",
                   radius = 5,
                   fillOpacity = 0.8,
                   stroke = FALSE) %>%
  addScaleBar(position = "bottomleft")

# Check
ot_plot

# Save map
mapshot(ot_plot,
        file = "output/occurrence_maps/ot_map.png")

# P. FLORIDA ---
pf_plot <- leaflet(options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("OpenStreetMap.Mapnik") %>%
  addCircleMarkers(data = pf,
                   color = "#4F77DC",
                   radius = 5,
                   fillOpacity = 0.8,
                   stroke = FALSE) #%>%
  addCircleMarkers(data = pf_omitted,
                   color = "black",
                   radius = 5,
                   fillOpacity = 0.8,
                   stroke = FALSE) %>%
  addScaleBar(position = "bottomleft")

# Check
pf_plot

# Save map
mapshot(pf_plot,
        file = "output/occurrence_maps/pf_map.png")

# P. MICROPHYLLA ---
pm_plot <- leaflet(options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("OpenStreetMap.Mapnik") %>%
  addCircleMarkers(data = pm,
                   color = "#B452CD",
                   radius = 5,
                   fillOpacity = 0.8,
                   stroke = FALSE) #%>%
  addCircleMarkers(data = pm_omitted,
                   color = "black",
                   radius = 5,
                   fillOpacity = 0.8,
                   stroke = FALSE) %>%
  addScaleBar(position = "bottomleft")

# Check
pm_plot

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
                   labels = "auto",
                   label_size = 20,
                   ncol = 2)

# Check
plots

# Save plot
ggsave("output/occurrence_maps/species_occurrence_maps.png", 
       plots,
       width = 20,
       height = 15,
       units = "cm")



