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

While software platforms like ArcGIS and QGIS are the industry standard for complex geopspatial analysis, they're a bit cumbersome for basic visualization purposes. [Leaflet](https://leafletjs.com/) is an open-source JavaScript library that enables rapid production of interactive maps that are easily embedded in a variety of contexts. Leaflet maps are dynamic and include features such as:

* Interactive panning/zooming
* Choropleth capabilities
* Pop-up tooltips and labels
* Highlighting/selecting regions
* Custom map icons

## Usage

A basic usage example is:
