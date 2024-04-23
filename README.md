# Distributions of *Centris pallida* and Host Plants

*\~ IN PROGRESS*

## 🐝 Summary

This repository stores the data and code for generating figures of the predicted current (2000-2021) and forecasted (2021-2040 and 2041-2060) distributions of the Desert Pallid bee (*Centris pallida*) and some of its major nectar plants (*Olneya tesota*, *Parkinsonia florida*, and *Parkinsonia microphylla*).

The distributions are modeled using Maximum Entropy (MaxEnt) and the most fitting model is determined through cross-validation using the `ENMeval` package. Predictions are made using `terra::predict()` over the time periods 2000-2021, 2021-2040, and 2041-2060. Climate data from 2000-2021 is from WorldClim version 2.1, and forecasted climate data is from the Coupled Model Intercomparison Project Phase 6 with the ensemble from AdaptWest.

These figures will help assess possible changes in distribution overlap to happen over as climate change ensues, which can aid in planning conservation efforts.

## 📚 Libraries

The following R packages are used (and scripts will use all, or some, of these): [attach .csv of libraries used]

## 📂 Folder Contents

***data:*** Contains the raw and cleaned data from the [Global Biodiversity Information Facility](https://www.gbif.org/) (GBIF). The climate data are from [WorldClim (version 2.1)](http://www.worldclim.com/version2), the [Coupled Model Intercomparison Project, Phase 6](https://wcrp-cmip.org/cmip-phase-6-cmip6/) (CMIP6), and [AdaptWest](https://adaptwest.databasin.org/). Other data used in the modeling may be stored here as well. The data in this folder are used in the MaxEnt modeling and generation of the figures.

***src:*** Contains code for cleaning the data, running models, and generating figures.

***output:*** Contains figures, shapefiles, and model outputs.

## 📑 Order of Script Use

1.  ***get_gbif.R***
    -   About
2.  ***combine_elevation_and_gbif.R***
    -   About
3.  ***species_occurrence_maps.R***
    -   About
4.  ***prep_forecast_data.R***
    -   About
5.  ***run_maxent.R***
    -   About
6.  ***species_distribution_maps.R***
    -   About
7.  [Maybe] ***range_map_overlap.R***
    -   About

*Last updated: April 23, 2024*
