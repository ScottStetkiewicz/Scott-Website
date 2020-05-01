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




```r
library(tidyverse)
library(leaflet)
library(stringr)
library(sf)
library(here)
library(widgetframe)
options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())
```

[Leaflet](https://leafletjs.com/) is an open-source JavaScript library for creating interactive maps. Unlike static visualization packages such as `ggplot2` or `ggmap`, Leaflet maps are fully interactive and can include features such as:

* Interactive panning/zooming
* Pop-up tooltips and labels
* Highlighting/selecting regions

## Basic usage

Leaflet maps are built using layers, similar to `ggplot2`.

1. Create a map widget by calling `leaflet()`
1. Add **layers** to the map using one or more of the layer functions (e.g. `addTiles()`, `addMarkers()`, `addPolygons()`)
1. Repeat step 2 as many times as necessary to incorporate the necessary information
1. Display the map widget

A basic example is:


```r
library(leaflet)
library(widgetframe)
library(raster)
library(leaflet)
library(tidyverse)

# Get UK polygon data
UK <- getData("GADM", country = "GB", level = 2)

### Create dummy data
set.seed(111)
mydf <- data.frame(place = unique(UK$NAME_2),
                   value = sample.int(n = 1000000, size = n_distinct(UK$NAME_2), replace = TRUE))

### Create five colors for fill
mypal <- colorQuantile(palette = "RdYlBu", domain = mydf$value, n = 5, reverse = TRUE)

l <- leaflet() %>% 
addProviderTiles("OpenStreetMap.Mapnik") %>%
setView(lat = 55, lng = -3, zoom = 6) %>%
addPolygons(data = UK,
            stroke = FALSE, smoothFactor = 0.2, fillOpacity = 0.3,
            fillColor = ~mypal(mydf$value),
            popup = paste("Region: ", UK$NAME_2, "<br>",
                          "Value: ", mydf$value, "<br>")) %>%
addLegend(position = "bottomright", pal = mypal, values = mydf$value,
          title = "UK value",
          opacity = 1)

htmlwidgets::saveWidget(frameableWidget(l),'leaflet.html')
```

<iframe seamless src="../leaflet.html" width="100%" height="500"></iframe>
