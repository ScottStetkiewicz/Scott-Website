---
title: "Multiple Response Data"
summary: "Analyzing Frequency and Presence/Absence Data"
date: "2018-12-02"
tag: ["R", "Shiny", "Data Wrangling"]
image_preview: "featured.jpg"
output:
  blogdown::html_page:
    toc: false
    fig_width: 6
    dev: "svg"
---

This app is currently being designed for exploring presence/absence and frequency archaeological datasets in the [Atlas of Hillforts Project](https://hillforts.arch.ox.ac.uk/).

## Usage

Upload the data, select the appropriate variables and shift tabs to access the different sections of the app. Functionality includes bar plots and box plots for single, double, multiple response variables at the moment.

## Color Picker

You can customize the color palette by checking the "Custom Colors" box under the plot outputs. This integrated feature is based on Dean Attali's [`colourpicker`](https://github.com/daattali/colourpicker) widget.

