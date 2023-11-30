# Maxine Cruz
# tmcruz@arizona.edu
# Created: 18 September 2023
# Last modified: 28 November 2023 




# ----- ABOUT THE SCRIPT -----

# Generate occurrence maps for:
    # Centris pallida (speciesKey: 1342915)
    # Olneya tesota (speciesKey: 2974564)
    # Parkinsonia florida (speciesKey: 5359949)
    # Parkinsonia microphylla (speciesKey: 5359945)




# ----- LOAD LIBRARIES -----

library(readr)
library(leaflet)
library(mapview) 
library(png)
library(grid)
library(gridExtra)
library(ggmap)




# ----- LOAD DATA -----

# Read data set
full_data <- read_csv("data/NAm_map_data_final.csv")

# Separate species into subsets
cp <- full_data %>%
  filter(speciesKey == 1342915) # 861 observations
ot <- full_data %>%
  filter(speciesKey == 2974564) # 4090 observations
pf <- full_data %>%
  filter(speciesKey == 5359949) # 3172 observations
pm <- full_data %>%
  filter(speciesKey == 5359945) # 3770 observations




# ----- GENERATE MAPS -----

# Centris pallida
cp_plot <- leaflet(cp,
                   options = leafletOptions(zoomControl = FALSE,
                                            attributionControl = FALSE)) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addTiles(
    urlTemplate = "https://tiles.stadiamaps.com/tiles/{variant}/{z}/{x}/{y}{r}.png?api_key={apikey}",
    attribution = paste('&copy; <a href="https://stadiamaps.com/" target="_blank">Stadia Maps</a> ',
                        '&copy; <a href="https://stamen.com/" target="_blank">Stamen Design</a> ',
                        '&copy; <a href="https://openmaptiles.org/" target="_blank">OpenMapTiles</a> ',
                        '&copy; <a href="https://www.openstreetmap.org/about" target="_blank">OpenStreetMap</a> contributors'),
    options = tileOptions(variant = 'stamen_toner_lines', 
                          apikey = 'd20cf594-4437-4c63-9cc1-59f58e5a7b89')
    ) %>%
  addCircleMarkers(
    color = "#FF3E96",
    radius = 3,
    fillOpacity = 0.8,
    stroke = FALSE
  )

# Save map - leaflet maps require a different method since they show in the
  # Viewer pane
mapshot(cp_plot,
        file = "output/occurrence_maps/cp_map.png")

# Olneya tesota
ot_plot <- leaflet(ot) %>% 
  addProviderTiles("Esri.WorldImagery") %>%
  addProviderTiles("Stamen.TonerLines") %>%
  addCircleMarkers(
    color = "#E066FF",
    radius = 3.5,
    fillOpacity = 0.8,
    stroke = FALSE
  )

# Parkinsonia florida
pf_plot <- leaflet(pf) %>% 
  addProviderTiles("Esri.WorldImagery") %>%
  addProviderTiles("Stamen.TonerLines") %>%
  addCircleMarkers(
    color = "#FFA500",
    radius = 3.5,
    fillOpacity = 0.8,
    stroke = FALSE
  )

# Parkinsonia microphylla
pm_plot <- leaflet(pm) %>% 
  addProviderTiles("Esri.WorldImagery") %>%
  addProviderTiles("Stamen.TonerLines") %>%
  addCircleMarkers(
    color = "#00FFFF",
    radius = 3.5,
    fillOpacity = 0.8,
    stroke = FALSE
  )




# ----- PLOT MAPS IN ONE FIGURE -----

# Save maps as .png files
mapshot(cp_plot, file = "output/cp_occ_map.png")
mapshot(ot_plot, file = "output/ot_occ_map.png")
mapshot(pf_plot, file = "output/pf_occ_map.png")
mapshot(pm_plot, file = "output/pm_occ_map.png")

# Re-open images
cp_plot <- readPNG("output/occurence_maps/cp_occ_map.png")
ot_plot <- readPNG("output/occurence_maps/ot_occ_map.png")
pf_plot <- readPNG("output/occurence_maps/pf_occ_map.png")
pm_plot <- readPNG("output/occurence_maps/pm_occ_map.png")

# Arrange images in one one plot
plots <- arrangeGrob(
  rasterGrob(cp_plot), rasterGrob(ot_plot), 
  rasterGrob(pf_plot), rasterGrob(pm_plot),
  ncol = 2,
  padding = 1
)

# Save plot
ggsave2("output/occurence_maps/spp_occ_maps.png", plots)

# Note: Needed to import to Microsoft Powerpoint to add letters to figure



