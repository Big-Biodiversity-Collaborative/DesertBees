# Maxine Cruz
# tmcruz@arizona.edu
# Created: 20 May 2024
# Last modified: 20 May 2024




# ----- ABOUT -----

# Show optimal model for each species in one table

# Should've included this in the function for Maxent but alas
  # Should probably still do so later, but in the meantime this is here




# ----- LOAD LIBRARIES -----

# For managing data
library(dplyr)




# ----- ARRANGE TABLE -----

# This is definitely not the most efficient way but ya know
  # I just need to make this table quickly

cp <- read.csv("output/centris_pallida/parameter_results.csv")
ot <- read.csv("output/olneya_tesota/parameter_results.csv")
pf <- read.csv("output/parkinsonia_florida/parameter_results.csv")
pm <- read.csv("output/parkinsonia_microphylla/parameter_results.csv")

df <- data.frame()

optimal_cp <- cp %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

optimal_cp <- cbind(optimal_cp, data.frame(species = "Centris pallida")) %>%
  select(20, 1:19)

optimal_ot <- ot %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

optimal_ot <- cbind(optimal_ot, data.frame(species = "Olneya tesota")) %>%
  select(20, 1:19)

optimal_pf <- pf %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

optimal_pf <- cbind(optimal_pf, data.frame(species = "Parkinsonia florida")) %>%
  select(20, 1:19)

optimal_pm <- pm %>%
  filter(cbi.val.avg > 0) %>%
  filter(or.10p.avg == min(or.10p.avg)) %>%
  filter(auc.val.avg == max(auc.val.avg))

optimal_pm <- cbind(optimal_pm, data.frame(species = "Parkinsonia microphylla")) %>%
  select(20, 1:19)

df <- optimal_cp %>%
  rbind(optimal_ot) %>%
  rbind(optimal_pf) %>%
  rbind(optimal_pm)

write.csv(df, 
          "output/optimal_models.csv",
          row.names = FALSE)





