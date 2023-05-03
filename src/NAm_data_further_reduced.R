# Maxine Cruz
# tmcruz@arizona.edu
# Created: 30 April 2023
# Last modified: 3 May 2023



### ABOUT THE SCRIPT ---

# Further filters data per Dr. Buchanan's request (see other_files folder)

# Reduces data to:
  # Centris pallida - 1342915
  # Olneya tesota - 2974564
  # Parkinsonia florida - 5359949
  # Parkinsonia microphylla - 5359945

# And removes unlikely observations

# Draws desired boundary on map and removes points outside lines



### LOAD LIBRARIES ---

library(tidyverse)
library(leaflet)



### FILTER DATA ---

# Load NAm_map_data.csv
og_data <- read_csv("data/NAm_map_data.csv")

# Filter for desired organisms
og_data <- filter(og_data,
                  speciesKey == c(1342915,
                                  2974564,
                                  5359949,
                                  5359945))

# Filter C. pallida observations ---
cp_done <- og_data %>%
  filter(speciesKey == 1342915) 

# Make sure correct points were removed
leaflet(cp_done) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addProviderTiles("Stamen.TonerLines") %>%
  addCircles(fillOpacity = 0.8)




# Filter O. tesota observations ---





# Filter P. florida observations





# Filter P. microphylla observations




