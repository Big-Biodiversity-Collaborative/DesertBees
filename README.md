# Distributions of *Centris pallida* and Host Plants

*\~ IN PROGRESS*

## 🐝 Summary

This repository stores the data and code for generating figures of the current and (predicted) future distributions of the Desert Pallid bee (*Centris pallida*) and some of its host plants (*Olneya tesota*, *Parkinsonia florida*, and *Parkinsonia microphylla*).

The distributions are modeled using Maximum Entropy (MaxEnt) and the most fitting model is determined through cross-validation using the ENMeval package.

[Insert more description later]

These figures will help assess possible changes in distribution overlap to happen over the next 70 years, which can aid in planning conservation .

## 📚 Libraries

The following R packages are used (and scripts will use all, or some, of these):

-   [List all packages used]

## 📂 Folder Contents

***data*****:** Contains the original downloads of raw and filtered data from GBIF ([Global Biodiversity Information Facility](https://www.gbif.org/)). Not included due to excessively large size are the climate data used for modeling. The climate data, which have been excluded using gitignore, are from [WorldClim](https://worldclim.org/) (wc2-5 files) and the [Coupled Model Intercomparison Project 5](https://esgf-node.llnl.gov/projects/cmip5/) (CMIP5) (cmip5 files). The data in this folder are used to produce the figures.

***src*****:** Contains code for filtering the data, running models, and generating figures.

***output*****:** Contains figures and model outputs.

***images*****:** Contains reference pictures for filtering the data.

*Last updated: October 9, 2023*
