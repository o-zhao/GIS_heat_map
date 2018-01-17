# GIS_heat_map
Easily adaptable heat map function that can present ZIP level granularity

Sans access to ArcGIS software, you can still make pretty heat maps in R. Unfortunately, R's map packages (`map_data` likely being the most commonly used) have granularity only down to the county level. This script creates a `zip.heat` function that will work for county/state/country level observations as well, but is most useful for ZIP code level data.

The script goes through an example map that plots the number of ER admissions for Medicaid beneficiaries in New York State in 2014. The data have been normalized to average number of admissions per beneficiary in each ZIP code. 

### Caveats
The map legend is kind of crude, because tinkering with it was a second order concern when I wrote this script.
ZIP shape files were too large to uploaded in the example data folder. I recommend using TIGER/Line shape files published by the U.S. Census Bureau (<https://www.census.gov/geo/maps-data/data/tiger-line.html>)

### Future work
Though this repo is ostensibly about the heat map capabilities, the motivation for this project came from wanting to visualize markers of public health (e.g. levels of smoking, alcoholism, Medicaid recipients, lead poisoning, asthma) and see where clusters of public health problems arose, and whether certain areas whose demographics/characteristics (larger presence of marginalized ethnic groups or lower average socioeconomic status) seemed to be over or underperforming what statistical analyses on these health outcomes would predict for the area.
