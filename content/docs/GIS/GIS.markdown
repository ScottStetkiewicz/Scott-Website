---
title: "GIS with Leaflet"

draft: false
toc: true
toc_float: true
type: docs

linktitle: Leaflet
menu:
  docs:
    parent: GIS
    weight: 1
---



While software platforms like ArcGIS and QGIS are the industry standard for complex geopspatial analysis, they're a bit cumbersome for basic visualization purposes. [Leaflet](https://leafletjs.com/) is an open-source JavaScript library that enables rapid production of interactive maps that are easily embedded in a variety of contexts. Leaflet maps are dynamic and include features such as:

* Interactive panning/zooming
* Choropleth capabilities
* Pop-up tooltips and labels
* Highlighting/selecting regions
* Custom map icons

## Usage

A basic usage example employing `leaflet` and the `acs` package to visualize U.S. Census data is demonstrated below.

In this particular tutorial, I'll be using the [2011 Nativity And Citizenship Status In The United States](https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes/2011/1-year.html) dataframe, which provides data on the citizenship of U.S. residents. The aim here is to produce GIS output that can map where the highest proportion of individuals not born in the U.S. reside in the state of Rhode Island.

### Fetching `acs` Data


```r
library(tidyverse)
library(tigris)
library(acs)
library(leaflet)
library(htmltools)
library(widgetframe)
```

Our first step is to initialize a `tracts` vector that defines the state of interest for `acs` calls. We can then make a basic `acs.fetch` call using the relevant table number for our dataset of interest (in this case, B05001). The finall line here allows us to see what the column names are in the dataframe:


```r
# Select Rhode Island for tracts
tracts <- tracts(state = 'RI', cb=TRUE)
```

```
## 
  |                                                                            
  |                                                                      |   0%
  |                                                                            
  |===========                                                           |  15%
  |                                                                            
  |======================                                                |  31%
  |                                                                            
  |========================                                              |  35%
  |                                                                            
  |===================================                                   |  51%
  |                                                                            
  |============================================                          |  62%
  |                                                                            
  |=======================================================               |  78%
  |                                                                            
  |==================================================================    |  94%
  |                                                                            
  |======================================================================| 100%
```

```r
# Fetch ACS data 
ri <- acs.fetch(
  geography = geo.make(state = "RI", county="*", tract = "*"),
  endyear = 2011, span = 5, 
  table.number = "B05001", 
  col.names = "pretty")    

# View column names
attr(ri, "acs.colnames") 
```

```
## [1] "Nativity and Citizenship Status in the United States: Total:"                                                
## [2] "Nativity and Citizenship Status in the United States: U.S. citizen, born in the United States"               
## [3] "Nativity and Citizenship Status in the United States: U.S. citizen, born in Puerto Rico or U.S. Island Areas"
## [4] "Nativity and Citizenship Status in the United States: U.S. citizen, born abroad of American parent(s)"       
## [5] "Nativity and Citizenship Status in the United States: U.S. citizen by naturalization"                        
## [6] "Nativity and Citizenship Status in the United States: Not a U.S. citizen"
```

### Dataframe Construction

With our initial data fetched, we can create a new structure to hold geolocation variables and our main data of 1) overall population in the state of RI and 2) the total number of non-citizens:


```r
# Create new dataframe including geolocation data and estimates
ri_df <- data.frame(
  paste0(
    str_pad(ri@geography$state,  2, "left", pad="0"),
    str_pad(ri@geography$county, 3, "left", pad="0"),
    str_pad(ri@geography$tract,  6, "left", pad="0")),
  ri@estimate[,c("Nativity and Citizenship Status in the United States: Total:", "Nativity and Citizenship Status in the United States: Not a U.S. citizen")],
  stringsAsFactors = FALSE)

# Select subset of initial dataframe
ri_df <- dplyr::select(ri_df, 1:3) %>% tbl_df()

# Rename rows
names(ri_df) <- c("GEOID", "total", "non_citizen")

# Calculate percentage of non-U.S. citizens
ri_df$percent <- 100*(ri_df$non_citizen/ri_df$total)
```

### Perform spatial join

We can now spatially join our initial `tracts` vector with our new dataframe:


```r
# Spatial join
df_merged <- geo_join(tracts, ri_df, "GEOID", "GEOID")

# Remove any tracts with no land area
df_merged <- df_merged[df_merged$ALAND>0,]
```

### Plot Output


```r
# Set popup labels
popup <- paste0("GEOID: ", df_merged$GEOID, "<br>", "Percent of non-U.S. Citizens: ", round(df_merged$percent,2))

# Set color palette
pal <- colorNumeric(
  palette = "plasma",
  domain = df_merged$percent
)

RI<-leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = df_merged,
              fillColor = ~pal(percent),
              color = "#b2aeae", # you need to use hex colors
              fillOpacity = 0.7,
              weight = 1,
              smoothFactor = 0.2,
              popup = popup) %>%
  addLegend(pal = pal,
            values = df_merged$percent,
            position = "bottomright",
            title = "Percent of non-U.S.<br>Citizens",
            labFormat = labelFormat(suffix = "%"))

htmlwidgets::saveWidget(frameableWidget(RI),'RI.html')
```
