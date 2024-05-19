# Maxine Cruz
# tmcruz@arizona.edu
# Created: 17 May 2024
# Last modified: 18 May 2024




# ----- ABOUT -----

# Identify which states each species' observations are located



# ----- LOAD LIBRARIES -----

# For counting
library(dplyr)

# For checking
library(leaflet)




# ----- LOAD DATA -----

# Species occurrence data
data <- read.csv("data/gbif/cleaned_species_with_elevation.csv")




# ----- COUNT OBSERVATIONS -----

# Check countries to look at
unique(data$countryCode)

# MX, US

# States to count observations for
states_list <- unique(data$stateProvince)

# Species to loop through
spp_list <- unique(data$species)

# Empty data frame to store counts
counts <- data.frame()

# Loop

for (i in 1:length(spp_list)) {
  
  # Species i
  species_name <- spp_list[i]
  
  # Get data for species i
  species_data <- data %>%
    filter(species == species_name)
  
  # Data frame to store this species' counts in
  species_counts <- data.frame(Species = species_name,
                               Total_count = nrow(species_data))
  
  for (j in 1:length(states_list)) {
    
    # Get state
    state_name <- states_list[j]
    
    # Filter
    state <- species_data %>%
      filter(stateProvince == state_name)
    
    # Store value to append
    state_counts <- data.frame(name = nrow(state))
    
    # Change column name
    colnames(state_counts)[1] <- state_name
    
    # Append count to species data frame
    species_counts <- cbind(species_counts, state_counts)
    
  }
  
  # Append to full data frame
  counts <- rbind(counts, species_counts)
  
}




# ----- FOR IDENTIFYING COORDINATES WITHOUT STATE/COUNTRY -----

# It seems like only the plants have the issue of observations with
  # coordinates lacking a stateProvince

# Because I'm a bit lazy at this point, I'll just be plotting the points on a
  # leaflet map, and then making sure all the points within a country add up.
  # And then make sure that the total is consistent with the number of points
  # I've assigned a stateProvince.

# There's only a few anyway:
  # O. tesota: 19
  # P. florida: 15
  # P. microphylla: 29

# The total for each country is:
  # O. tesota: 3934 (US) + 681 (MX) = 4615 (total)
  # P. florida: 3339 (US) + 427 (MX) = 3769 (total)
  # P. microphylla: 3999 (US) + 521 (MX) = 4520 (total)

# Separate species into their own data frames
ot <- data %>% 
  filter(species == "Olneya tesota") %>% 
  filter(stateProvince == "")

pf <- data %>% 
  filter(species == "Parkinsonia florida") %>% 
  filter(stateProvince == "")

pm <- data %>% 
  filter(species == "Parkinsonia microphylla") %>% 
  filter(stateProvince == "")

# Plot on leaflet
leaflet() %>% 
  addTiles() %>% 
  addCircleMarkers(data = ot, color = "red", radius = 2) %>% 
  addCircleMarkers(data = pf, color = "green", radius = 2) %>% 
  addCircleMarkers(data = pm, color = "blue", radius = 2)
