# Distributions of *Centris pallida* and Host Plants

## 🐝 Summary

This repository stores the data and code for generating figures of the current and (predicted) future distribution of *Centris pallida* and some of its host plants (*Olneya tesota*, *Parkinsonia florida*, and *Parkinsonia microphylla*).

## 📚 Libraries

The following R libraries are used (and scripts will use all, or some, of these):

+---------------+--------------+---------------+
| -   cowplot   | -   maps     | -   rJava     |
|               |              |               |
| -   dismo     | -   maptools | -   spocc     |
|               |              |               |
| -   gridExtra | -   readr    | -   tidyverse |
|               |              |               |
| -   leaflet   | -   rgbif    |               |
+---------------+--------------+---------------+

-   cowplot

-   dismo

-   gridExtra

-   leaflet

-   maps

-   maptools

-   readr

-   rgbif

-   rJava

-   spocc

-   tidyverse

## 📂 Folder Contents

**data:** Contains the original downloads of raw and filtered data from GBIF ([Global Biodiversity Information Facility](https://www.gbif.org/)). Not included due to excessively large size are the climate data used for modeling. The climate data, which have been excluded using gitignore, are from [WorldClim](https://worldclim.org/) (wc2-5 files) and the [Coupled Model Intercomparison Project 5](https://esgf-node.llnl.gov/projects/cmip5/) (CMIP5) (cmip5 files). The data in this folder are used to produce the figures.

**src:** Contains code for filtering the data, running models, and generating figures.

**output:** Contains figures and model outputs.

**images:** Contains reference pictures for filtering the data.

*Last updated: June 27, 2023*
