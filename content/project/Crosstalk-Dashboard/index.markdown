---
title: "Crosstalk Dashboard"
summary: "Integrated GIS, `DataTable` and `d3scatter` plot for exploratory analysis"
date: "2018-12-02"
tag: ["R", "Shiny", "Crosstalk", "GIS"]
image_preview: "featured.jpg"
output:
  blogdown::html_page:
    toc: false
    fig_width: 6
    dev: "svg"
---



## CrossTalk Archaeology Dashboard 

This `flexdashboard` is desgined for relational/GIS archaeological data to be simultaneously viewed in `leaflet`, `DT` and `d3scatter` for quick and easy exploratory analysis. It uses default synthetic data from <span style="font-variant:small-caps;">Stetkiewicz, S.</span>, (2016). *Iron Age Iron Production in Britain and the Near Continent: Compositional Analyses and Smelting "Systems"*. Unpublished PhD Thesis, University of Edinburgh.

[`Flexdashboards`](https://rmarkdown.rstudio.com/flexdashboard/) are a quick and easy way to get data visualized, and [`crosstalk`](https://rstudio.github.io/crosstalk/index.html)/ `shiny` compatibility allows linked bushing and filtering of data points. For archaeologists, this is particularly useful when assessing the geographic distribution of sample material from an Excel or .CSV file in relation to some kind of statistical analysis (e.g. linear regression, *k*-means clustering, etc.). Due to the simplicity of the `flexdashboard` interface, adding and removing sections of the dashboard to accommodate new code chunks or `htmlwidgets` is a breeze; making it ideal for beginner-level visualizations and data exploration in archaeology.

## Use

There are three ways to reactively select data points with this app:

1. Click the small box below the zoom option on the `leaflet` map to select sites
2. Select rows or columns of data from the `DT` datatable 
3. Click and drag to highlight desired sites on the `d3scatter` scatterplot.

## Updates

This repostory will be updated soon to provide reactive infoBoxes/valueBoxes and gauge elements

{{% alert note %}}
The [CrossTalk Dashboard](https://scottstetkiewicz.shinyapps.io/slagMaps/) is hosted on shinpyapps.io (limited usage), but can be forked [here on Github](https://github.com/ScottStetkiewicz/CrossTalk-Archaeology-Dashboard). 
{{% /alert %}}
