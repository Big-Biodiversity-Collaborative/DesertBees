## Description of R Script Files

This folder contains the code used in data cleaning / analysis, and for figure generation.

-   **get_gbif.R**

    Retrieves data from the [Global Biodiversity Information Facility](https://www.gbif.org/) of four species:

    -   Desert / Digger Bee (*Centris pallida*)

    -   Blue Palo Verde (*Parkinsonia florida*)

    -   Foothill Palo Verde (*Parkinsonia microphylla*)

    -   Desert Ironwood (*Olneya tesota*)

    The data is processed to remove those with no geographic coordinates (latitude and longitude), duplicates, and other characteristics that may contribute to the accuracy and analysis of the data. The cleaning includes consideration of the species' documented range, so a polygon is also drawn around the observations and the outliers are excluded from the analysis. This script creates the following files:

    -   `data/gbif/cleaned_species.csv`

    ------------------------------------------------------------------------

-   **run_maxent.R**

    Runs the Maxent model on each of the four species. Results are stored in the following folders under `output/`:

    -   `centris_pallida`

    -   `olneya_tesota`

    -   `parkinsonia_florida`

    -   `parkinsonia_microphylla`

    ------------------------------------------------------------------------

-   **species_occurrence_maps.R**

    Generates occurrence maps for each of the four species, and makes a composite map as well. This script stores the maps in `output/occurrence_maps`.

    ------------------------------------------------------------------------

-   **species_distribution_maps.R**

    Generates current and future predicted distribution maps for each of the four species, and makes composite maps as well. This script stores the maps in `output/distribution_maps`.

    ------------------------------------------------------------------------

-   **distribution_map_overlap.R**

    Calculates the area for the current/future predicted distribution of each species. Plots are made for the area where distribution overlaps for all four species (also both current and future).

    ------------------------------------------------------------------------

    **Summary Table Calculations**

    The following are scripts used to generate additional tables for the manuscript:

-   `observation_counts.R` (Table 1)

-   `optimal_models.R` (Table 3)

-   `find_avg_elevations.R` (Table 6)
