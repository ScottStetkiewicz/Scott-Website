---
title: "Network Analysis Shiny App"
summary: "`visNetwork` app for Neural Network Analysis"
date: "2019-10-22"
tag: ["R", "Shiny", "Statistics", "Network Analysis"]
header:
  image: "featured.png"
output:
  blogdown::html_page:
    toc: false
    fig_width: 6
    dev: "svg"
---

This app provides an interactive interface for Neural Network Analysis (NNA) using the `visNetwork` package, allowing [D3](https://d3js.org) interaction with data, nodes and edges.

## Background

The visualization of complex networks can reveal unexpected insights into relationships between people and groups in a variety of social, business and academic settings. For instance, if a university was looking to improve collaboration between departments, they might produce a tag list associated with each faculty member and (as an example) data science techniques in use across the school. The resulting dataframe might look something like this: 

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> Department </th>
   <th style="text-align:left;"> Tags </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Professor 1 </td>
   <td style="text-align:left;"> Anthropology </td>
   <td style="text-align:left;"> GIS, Survey </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 2 </td>
   <td style="text-align:left;"> Anthropology </td>
   <td style="text-align:left;"> GIS, Machine Learning </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 3 </td>
   <td style="text-align:left;"> Art </td>
   <td style="text-align:left;"> Qualitative, Survey </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 4 </td>
   <td style="text-align:left;"> Art </td>
   <td style="text-align:left;"> GIS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 5 </td>
   <td style="text-align:left;"> English </td>
   <td style="text-align:left;"> Qualitative </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 6 </td>
   <td style="text-align:left;"> English </td>
   <td style="text-align:left;"> GIS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 7 </td>
   <td style="text-align:left;"> English </td>
   <td style="text-align:left;"> Survey, GIS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 8 </td>
   <td style="text-align:left;"> History </td>
   <td style="text-align:left;"> Survey </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 9 </td>
   <td style="text-align:left;"> History </td>
   <td style="text-align:left;"> GIS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 10 </td>
   <td style="text-align:left;"> History </td>
   <td style="text-align:left;"> Machine Learning </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 11 </td>
   <td style="text-align:left;"> Philosophy </td>
   <td style="text-align:left;"> Qualitative </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 12 </td>
   <td style="text-align:left;"> Philosophy </td>
   <td style="text-align:left;"> Survey, Qualitative </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 13 </td>
   <td style="text-align:left;"> Spanish </td>
   <td style="text-align:left;"> GIS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 14 </td>
   <td style="text-align:left;"> Spanish </td>
   <td style="text-align:left;"> Qualitative </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 15 </td>
   <td style="text-align:left;"> Geosciences </td>
   <td style="text-align:left;"> Machine Learning, Compositional </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 16 </td>
   <td style="text-align:left;"> Geosciences </td>
   <td style="text-align:left;"> GIS, Compositional </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Professor 17 </td>
   <td style="text-align:left;"> Geosciences </td>
   <td style="text-align:left;"> Compositional, Survey, Machine Learning, Qualitative </td>
  </tr>
</tbody>
</table>

This app provides a graphical means of exploring the dataframe and the relationships between individuals and departments, highlighting the strength of existing connections and potentially revealing areas for future development.

## Use

The sidebar of this app allows users to adjust node and edge parameters, alter the linkage sensitivity and highlight algorithm, and filter the visualization based on departments. The output can be zoomed, nodes can be dragged to reorient the plot, and hovering enables tooltips to describe the shared technologies between faculty members.

{{% alert note %}}
This app can be forked [here on Github](https://github.com/ScottStetkiewicz/Network-Analysis). 
{{% /alert %}}
