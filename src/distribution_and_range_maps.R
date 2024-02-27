# Maxine Cruz
# tmcruz@arizona.edu
# Created: 21 December 2023
# Last modified: 27 February 2024




# ----- ABOUT -----

# Generates maps from Maxent results




# ----- LOAD LIBRARIES -----

library(ggplot2)
library(cowplot)

# Collect data for map borderlines
wrld <- ggplot2::map_data("world")



# ----- LOAD DATA -----

# Species occurence data
data <- read.csv("data/GBIF/cleaned_species_with_elevation.csv")




# ---------------------------------------------------------------------

# A.1) CENTRIS PALLIDA (CURRENT) -----

# Data for maps
dist_df <- read.csv("output/Centris pallida/current_distribution.csv")
range_df <- read.csv("output/Centris pallida/current_range.csv")

# Set boundaries where map should be focused
xmax <- max(dist_df$x) + 1
xmin <- min(dist_df$x) - 1
ymax <- max(dist_df$y) + 1
ymin <- min(dist_df$y) - 1

# Occurrence points
occ_points <- data %>%
  dplyr::filter(speciesKey == 1342915) %>%
  dplyr::select(4, 5)

# ENVIRONMENTAL SUITABILITY ---

p1 <- ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours = viridis::plasma(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  geom_point(data = occ_points,
             aes(x = longitude, y = latitude),
             color = "cornflowerblue",
             size = 1) +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

p1

# Save
ggsave(file = "output/Centris pallida/current_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


# RANGE ---

range_df$layer <- as.factor(range_df$layer)

ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/Centris pallida/current_range.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# A.2) CENTRIS PALLIDA (FUTURE) -----

# Data for maps
dist_df <- read.csv("output/Centris pallida/future_distribution.csv")
range_df <- read.csv("output/Centris pallida/future_range.csv")

# Set boundaries where map should be focused
xmax <- max(dist_df$x) + 1
xmin <- min(dist_df$x) - 1
ymax <- max(dist_df$y) + 1
ymin <- min(dist_df$y) - 1


# ENVIRONMENTAL SUITABILITY ---

p2 <- ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours = viridis::plasma(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
     x = "Longitude",
     y = "Latitude",
     fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

p2

# Save
ggsave(file = "output/Centris pallida/future_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


# RANGE ---

range_df$layer <- as.factor(range_df$layer)

ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/Centris pallida/future_range.png",
       width = 25,
       height = 15,
       units = "cm")


# ---------------------------------------------------------------------

# A.3) SIDE-BY-SIDE

plot_grid(p1, p2, labels = c('A', 'B'), label_size = 20)

# Save
ggsave(file = "output/Centris pallida/both_climate_distribution.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# B.1) OLNEYA TESOTA (CURRENT) -----

# Data for maps
dist_df <- read.csv("output/Olneya tesota/current_distribution.csv")
range_df <- read.csv("output/Olneya tesota/current_range.csv")

# Set boundaries where map should be focused
xmax <- max(dist_df$x) + 1
xmin <- min(dist_df$x) - 1
ymax <- max(dist_df$y) + 1
ymin <- min(dist_df$y) - 1


# ENVIRONMENTAL SUITABILITY ---

q1 <- ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours = viridis::plasma(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

q1

# Save
ggsave(file = "output/Olneya tesota/current_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


# RANGE ---

range_df$layer <- as.factor(range_df$layer)

ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/Olneya tesota/current_range.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# B.2) OLNEYA TESOTA (FUTURE) -----

# Data for maps
dist_df <- read.csv("output/Olneya tesota/future_distribution.csv")
range_df <- read.csv("output/Olneya tesota/future_range.csv")

# Set boundaries where map should be focused
xmax <- max(dist_df$x) + 1
xmin <- min(dist_df$x) - 1
ymax <- max(dist_df$y) + 1
ymin <- min(dist_df$y) - 1


# ENVIRONMENTAL SUITABILITY ---

q2 <- ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours = viridis::plasma(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

q2

# Save
ggsave(file = "output/Olneya tesota/future_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


# RANGE ---

range_df$layer <- as.factor(range_df$layer)

ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/Olneya tesota/future_range.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# B.3) SIDE-BY-SIDE

plot_grid(q1, q2, labels = c('A', 'B'), label_size = 20)

# Save
ggsave(file = "output/Olneya tesota/both_climate_distribution.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# C.1) PARKINSONIA FLORIDA (CURRENT) -----

# Data for maps
dist_df <- read.csv("output/Parkinsonia florida/current_distribution.csv")
range_df <- read.csv("output/Parkinsonia florida/current_range.csv")

# Set boundaries where map should be focused
xmax <- max(dist_df$x) + 1
xmin <- min(dist_df$x) - 1
ymax <- max(dist_df$y) + 1
ymin <- min(dist_df$y) - 1


# ENVIRONMENTAL SUITABILITY ---

r1 <- ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours = viridis::plasma(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

r1

# Save
ggsave(file = "output/Parkinsonia florida/current_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


# RANGE ---

range_df$layer <- as.factor(range_df$layer)

ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/Parkinsonia florida/current_range.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# C.2) PARKINSONIA FLORIDA (FUTURE) -----

# Data for maps
dist_df <- read.csv("output/Parkinsonia florida/future_distribution.csv")
range_df <- read.csv("output/Parkinsonia florida/future_range.csv")

# Set boundaries where map should be focused
xmax <- max(dist_df$x) + 1
xmin <- min(dist_df$x) - 1
ymax <- max(dist_df$y) + 1
ymin <- min(dist_df$y) - 1


# ENVIRONMENTAL SUITABILITY ---

r2 <- ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours = viridis::plasma(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

r2

# Save
ggsave(file = "output/Parkinsonia florida/future_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


# RANGE ---

range_df$layer <- as.factor(range_df$layer)

ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/Parkinsonia florida/future_range.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# C.3) SIDE-BY-SIDE

plot_grid(r1, r2, labels = c('A', 'B'), label_size = 20)

# Save
ggsave(file = "output/Parkinsonia florida/both_climate_distribution.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# D.1) PARKINSONIA MICROPHYLLA (CURRENT) -----

# Data for maps
dist_df <- read.csv("output/Parkinsonia microphylla/current_distribution.csv")
range_df <- read.csv("output/Parkinsonia microphylla/current_range.csv")

# Set boundaries where map should be focused
xmax <- max(dist_df$x) + 1
xmin <- min(dist_df$x) - 1
ymax <- max(dist_df$y) + 1
ymin <- min(dist_df$y) - 1


# ENVIRONMENTAL SUITABILITY ---

s1 <- ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours = viridis::plasma(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

s1

# Save
ggsave(file = "output/Parkinsonia microphylla/current_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


# RANGE ---

range_df$layer <- as.factor(range_df$layer)

ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("Current Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/Parkinsonia microphylla/current_range.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# D.2) PARKINSONIA MICROPHYLLA (FUTURE) -----

# Data for maps
dist_df <- read.csv("output/Parkinsonia microphylla/future_distribution.csv")
range_df <- read.csv("output/Parkinsonia microphylla/future_range.csv")

# Set boundaries where map should be focused
xmax <- max(dist_df$x) + 1
xmin <- min(dist_df$x) - 1
ymax <- max(dist_df$y) + 1
ymin <- min(dist_df$y) - 1


# ENVIRONMENTAL SUITABILITY ---

s2 <- ggplot() +
  geom_raster(data = dist_df, 
              aes(x = x, y = y, fill = layer))  + 
  scale_fill_gradientn(colours = viridis::plasma(99)) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
       x = "Longitude",
       y = "Latitude",
       fill = "Environmental \nSuitability") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.box.background = element_rect(color = NA),
        legend.position = "bottom",
        panel.background = element_rect(fill = "grey95"))

s2

# Save
ggsave(file = "output/Parkinsonia florida/future_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


# RANGE ---

range_df$layer <- as.factor(range_df$layer)

ggplot() +
  geom_raster(data = range_df, 
              aes(x = x, y = y, fill = layer)) +
  scale_fill_manual(values = c("orangered3", "mediumturquoise")) +
  coord_fixed(xlim = c(xmin, xmax), 
              ylim = c(ymin, ymax), 
              expand = F) +
  scale_size_area() +
  borders("world") +
  borders("state") +
  labs(title = bquote(bold("CMIP6 Climate Predictions")),
       x = "Longitude",
       y = "Latitude") + 
  theme(axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        legend.position = "none")

# Save
ggsave(file = "output/Parkinsonia microphylla/future_range.png",
       width = 25,
       height = 15,
       units = "cm")

# ---------------------------------------------------------------------

# D.3) SIDE-BY-SIDE

plot_grid(s1, s2, labels = c('A', 'B'), label_size = 20)

# Save
ggsave(file = "output/Parkinsonia microphylla/both_climate_distribution.png",
       width = 25,
       height = 15,
       units = "cm")


