---
title: "Normality Tests"
summary: "Statistical Tests of Distribution Normality"
date: "2018-12-02"
tag: ["R", "Shiny", "Statistics"]
image_preview: "featured.jpg"
output:
  blogdown::html_page:
    toc: false
    fig_width: 6
    dev: "svg"
---

This Shiny app is designed to provide a quick, reactive means of uploading any dataset and exploring several popular methods of assessing distribution normality.

## Usage

Simply upload your data, select the variable you wish to test, and the app will provide:

* The *p*-value of the Shaprio-Wilk test
* The *p*-value of the Anderson-Darling test
* A visualization of the distribution density (`statdensity`)
* A normal quantile-quantile plot (`qqnorm`) with a reference line (`qqline`)

If there are known groups in your dataset that may be impacting the overall distribution of the tested variable, you can use the **Select Grouping Variable** option to view individual color-coded subset distributions.    

## Transformations

If your data does not appear to be normally distributed, you can see how applying square, cube, and logarithmic transformations impact the tests/visualizations. 

{{% alert note %}}
The [Normal Test App](https://scottstetkiewicz.shinyapps.io/NormalTest/) is hosted on shinpyapps.io (limited usage), but can be forked [here on Github](https://github.com/ScottStetkiewicz/NormalDistributionTests).
{{% /alert %}}
