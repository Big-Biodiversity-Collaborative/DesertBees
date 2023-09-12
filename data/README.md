## Description of Data Files

Excluded (by .gitignore) is gbif_rawdata_full.csv due to excessively large file size. Also excluded are climate data files from WorldClim (wc2-5 files) and the Coupled Model Intercomparison Project 5 (CMIP5) (cmip5 files).

-   **full_map_data.csv**

    Combines data from map_data.csv and map_data2.csv.

-   **gbif_rawdata_otesota.csv**

    Raw GBIF data on *Olneya tesota* (taxonKey: 2974564).

-   **map_data.csv**

    Reduced version of gbif_rawdata_full.csv (not included in repository). Contains data on *Centris pallida* (1342915), *Parkinsonia florida* (5359949), *Parkinsonia microphylla* (5359945), *Parkinsonia aculeata* (5357217), *Larrea tridentata* (7568403), *Olneya tesota* (2974564), and *Cercidium spp.* (NA). Columns include year, month, day, speciesKey, genus, species, latitude, longitude, and countryCode.

-   **map_data2.csv**

    Reduced version of gbif_rawdata_otesota.csv. Contains data on *Olneya tesota* (2974564). Columns include year, month, day, speciesKey, genus, species, latitude, longitude, and countryCode.

-   **NAm_map_data.csv**

    Filters full_map_data.csv to observations where countryCode is equal to "US" (United States) or "MX" (Mexico).

-   **NAm_map_data_final.csv**

    Further filters NAm_map_data.csv based on Dr. Buchmann's border drawings (see [images folder](https://github.com/Big-Biodiversity-Collaborative/DesertBees/tree/d21f59cedcddf721dd1e7b97fd74326fd138b521/images)).
