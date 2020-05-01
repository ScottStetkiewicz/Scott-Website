---
title: "GIS with Leaflet"

draft: false
toc: true
toc_float: true
type: docs

linktitle: Choropleth
menu:
  docs:
    parent: Geospatial visualization
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
l <- leaflet() %>% addTiles()
htmlwidgets::saveWidget(frameableWidget(l),'leaflet.html')
```

<iframe seamless src="/leaflet.html" width="100%" height="500"></iframe>
