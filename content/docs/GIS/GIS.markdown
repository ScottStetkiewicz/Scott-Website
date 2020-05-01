---
title: "GIS with Leaflet"

draft: false
toc: true
toc_float: true
type: docs

linktitle: Leaflet Choropleth
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
```


```r
m <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng = -87.597241, lat = 41.789829,
             popup = "Saieh Hall of Economics")
m %>%
  frameWidget()
```

<!--html_preserve--><div id="htmlwidget-9503130667a27ed47493" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-9503130667a27ed47493">{"x":{"url":"/docs/GIS/GIS_files/figure-html//widgets/widget_unnamed-chunk-2.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

## Under development
