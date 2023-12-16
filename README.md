# Distributions of *Centris pallida* and Host Plants

*\~ IN PROGRESS*

## 🐝 Summary

This repository stores the data and code for generating figures of the current and (predicted) future distributions of the Desert Pallid bee (*Centris pallida*) and some of its host plants (*Olneya tesota*, *Parkinsonia florida*, and *Parkinsonia microphylla*).

The distributions are modeled using Maximum Entropy (MaxEnt) and the most fitting model is determined through cross-validation using the `ENMeval` package.

[Insert more description later]

These figures will help assess possible changes in distribution overlap to happen over as climate change ensues, which can aid in planning conservation efforts.

## 📚 Libraries

The following R packages are used (and scripts will use all, or some, of these):

-   [List all packages used]

## 📂 Folder Contents

***data:*** Contains the raw and cleaned data from the [Global Biodiversity Information Facility](https://www.gbif.org/) (GBIF). The climate data, which have been retrieved and processed by Jeff Oliver, are from [WorldClim (version 2.1)](http://www.worldclim.com/version2) and the [Coupled Model Intercomparison Project, Phase 6](https://wcrp-cmip.org/cmip-phase-6-cmip6/) (CMIP6). Other data used in the modeling may be stored here as well. The data in this folder are used in the Maxent modeling and generation of the figures.

***src:*** Contains code for cleaning the data, running models, and generating figures.

***output:*** Contains figures and model outputs.

***ShinyDesertBees:*** [Pending]

*Last updated: December 15, 2023*
