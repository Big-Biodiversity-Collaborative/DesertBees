# Maxine Cruz
# tmcruz@arizona.edu
# Created: 8 February 2024
# Last modified: 8 February 2024




# ----- ABOUT -----

# Plots occurrence map and saves that as: 
  # output/ADS_versions/occurrence_map.png




# ----- LOAD LIBRARIES -----

# For leaflet version
library(leaflet)
library(mapview)

# For ggplot2 version
library(ggplot2)




# ----- LOAD DATA -----

# Here we'll pull in the data we created in get_species.R
data <- read.csv("data/ADS_versions/cleaned_species.csv")




# ----- PLOT MAP (LEAFLET) -----

# Plot our occurrence map
plot <- leaflet(data,
        options = leafletOptions(zoomControl = FALSE)) %>% # Removes zoom button
  addProviderTiles("Esri.WorldStreetMap") %>% # Adds map layer
  addCircleMarkers( # Adds our species points
    color = "#FF3E96",
    radius = 3,
    fillOpacity = 0.8,
    stroke = FALSE)

# You can choose your own map layer if something looks better to you here:
# https://leaflet-extras.github.io/leaflet-providers/preview/

# Save map
mapshot(plot,
        file = "output/ADS_versions/occurrence_map.png")



# ----- PLOT MAP (GGPLOT) -----

# Get borderlines
wrld <- ggplot2::map_data("world")

# Set boundaries where map should be focused
xmax <- max(data$longitude) + 1
xmin <- min(data$longitude) - 1
ymax <- max(data$latitude) + 1
ymin <- min(data$latitude) - 1

# Plot map
ggplot() +
  borders("world", colour = "black") + # Adds country borders
  borders("state", colour = "black") + # Adds state borders
  coord_fixed(xlim = c(xmin, xmax), # Where to cut-off map (otherwise it will print the full world)
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  geom_point(data = data, # Our species data
             aes(x = longitude, y = latitude),
             color = "cornflowerblue",
             size = 1.5) +
  labs(title = bquote(paste(bold("Occurrence map of"), # Title
                            bolditalic(" Centris pallida"))),
       x = "Longitude", # x-axis label
       y = "Latitude") + # y-axis label
  theme(axis.title.x = element_text(margin = margin(t = 10)), # Miscellaneous adjustments
        axis.title.y = element_text(margin = margin(r = 10)),
        panel.background = element_rect(fill = "grey95"),
        plot.background = element_rect(fill = "white"))

# Save map
ggsave(file = "output/ADS_versions/occurrence_map_2.png",
       width = 25,
       height = 15,
       units = "cm")



