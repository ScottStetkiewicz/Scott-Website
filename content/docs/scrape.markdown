---
title: "Web Scraping Archaeology Jobs"

draft: false
toc: true
toc_float: true
type: docs

linktitle: Scraping Job Posts
menu:
  docs:
    parent: Web Scraping
    weight: 2
---



## Background

Following my PhD, I spent quite a lot of time and effort applying for jobs in the UK. Each day, I'd scroll through numerous job forums that were organized in different fashions, trying to identify the best employment opportunities. While a lot of these sites had the specific information I wanted, they weren't particularly helpful when it came to visualizing where these jobs were and how the stacked up to one another in terms of salary. So I decided to explore web scraping with `rvest` as an option to automate the process of searching for new jobs on **Indeed.co.uk** and using `leaflet` as a GIS interface to plot the postings across the UK. 


```r
library(tidyverse)
library(xml2)
library(rvest)
library(stringr)
library(jsonlite)
library(leaflet)
library(htmltools)
```

### Scraping and Dataframe Construction

The first stage in this process is to set the `url` to the indeed.co.uk link, and then assign that to a new variable called `webpage`. With that complete, we can use `dplyr` chaining to identify the nodes of interest on the webpage and extract these to a dataframe called `df`:


```r
url <- "https://www.indeed.co.uk/jobs?q=Archaeology"
webpage <- read_html(url)

df <- webpage %>% 
    html_nodes('.jobsearch-SerpJobCard') %>%   
    map_df(~list(Title = html_nodes(.x, '.jobtitle') %>% 
                     html_text() %>% 
                     {if(length(.) == 0) NA else .},    
                 Salary = html_nodes(.x, '.salary') %>% 
                     html_text() %>% 
                     {if(length(.) == 0) NA else .},
                 Employer = html_nodes(.x, '.company') %>% 
                     html_text() %>% 
                     {if(length(.) == 0) NA else .},
                 Location = html_nodes(.x, '.location') %>% 
                     html_text() %>% 
                     {if(length(.) == 0) NA else .},
                 Postdate = html_nodes(.x, '.date') %>% 
                     html_text() %>% 
                     {if(length(.) == 0) NA else .}))
```

Some of the values extracted from the `Salary` node are not numeric values (e.g. "Competitive Salary", etc.):


```r
df <- df %>% mutate(salary2=parse_number(Salary))
```

### Geocoding

In order to map the jobs now compiled in our database, we have to be able to geolocate the opportunities to identify their latitude and longitude for mapping. Michael Hainke's [`nominatim`-based solution](http://www.hainke.ca) provides the base function for performing this task: 


```r
nominatim_osm <- function(address = NULL)
{
  if(suppressWarnings(is.null(address)))
    return(data.frame("NA"))
  tryCatch(
    d <- jsonlite::fromJSON(flatten = TRUE, 
      gsub('\\@addr\\@', gsub('\\s+', '\\%20', address), 
           'http://nominatim.openstreetmap.org/search/@addr@?format=json&addressdetails=1&limit=1')
    ), error = function(c) return(data.frame("NA"))
  )
  if(length(d) == 0) return(data.frame("NA"))
  return(data.frame(lon = as.numeric(d$lon), 
                    lat = as.numeric(d$lat), 
                    District = if(is.null(d$address.state_district)){paste("Not Available")} else {as.character(d$address.state_district)}, 
                    State = if(is.null(d$address.state)){paste("Not Available")} else {as.character(d$address.state)}, 
                    Country = as.character(d$address.country)))
}
```

We can then use the function to look up the addresses of the job posts from our `df$Location` vector and create a new dataframe with the geolocation information:


```r
addresses <- df$Location
d <- suppressWarnings(lapply(addresses, function(address) {
  api_output <- nominatim_osm(address)
  return(data.frame(address = address, api_output))
  }) %>%
bind_rows() %>% data.frame())

test2<-cbind(d,df)
# Jitter points in case multiple jobs are in the same city
test2$lat <- jitter(test2$lat, factor = 1.5)
test2$lon <- jitter(test2$lon, factor = 1.5)
```

Here's what the dataframe looks like:

```r
head(test2)
```

```
##               address        lon      lat           District         State
## 1 Newcastle upon Tyne -1.6106079 54.96849 North East England       England
## 2      United Kingdom -3.2783916 54.70301      Not Available Not Available
## 3           Edinburgh -3.1872061 55.95845      Not Available      Scotland
## 4           Cambridge  0.1261140 52.20818    East of England       England
## 5     London WC1E 7HX -0.1454397 51.48360     Greater London       England
## 6              London -0.1258030 51.50841     Greater London       England
##          Country                                              Title
## 1 United Kingdom                                     \nReceptionist
## 2 United Kingdom        \n2020 Environmental Degree Apprenticeships
## 3 United Kingdom                          \nStudent Support Officer
## 4 United Kingdom \nUniversity Lecturer in Environmental Archaeology
## 5 United Kingdom                          \nPOSTDOCTORAL RESEARCHER
## 6 United Kingdom                          \nPOSTDOCTORAL RESEARCHER
##                           Salary                           Employer
## 1 \n\n£18,342 - £19,133 a year\n           \n\nNewcastle University
## 2                           <NA>                            \n\nWSP
## 3                           <NA>        \n\nUniversity of Edinburgh
## 4 \n\n£41,526 - £52,559 a year\n        \n\nUniversity of Cambridge
## 5 \n\n£38,594 - £44,113 a year\n  \n\nBirkbeck University of London
## 6 \n\n£38,594 - £44,113 a year\n \n\nBirkbeck, University of London
##              Location     Postdate salary2
## 1 Newcastle upon Tyne  25 days ago   18342
## 2      United Kingdom 30+ days ago      NA
## 3           Edinburgh  14 days ago      NA
## 4           Cambridge 30+ days ago   41526
## 5     London WC1E 7HX 30+ days ago   38594
## 6              London 30+ days ago   38594
```

### Customizing the Layout

So we now have our jobs scraped with relevant information like salary, title, organization, etc. as well as the salient geolocation data for each opportunity. Befoe plotting in `leaflet`, however, I wanted a way of classifying the jobs based on the advertised salary. To do this, I used `mutate` to create a new variable assigning a color to different salary bands:


```r
test2 <- test2 %>%
  mutate(Color_code = case_when(
    is.na(test2$salary2) ~ "gray",
    test2$salary2 == 0.00 ~ "gray",
    test2$salary2 <= 20000 ~ "red",
    test2$salary2 >= 20000 & test2$salary2 <= 29999 ~ "orange",
    test2$salary2 >= 30000 & test2$salary2 <= 39999 ~ "blue",
    test2$salary2 >= 40000 ~ "green"
  ))
```


```r
test2 <- test2 %>% rename(Salary_low=salary2,Post_date=Postdate)
test2 <- test2 %>% select(Title,Location,Employer,Salary,lon,lat,Salary_low,Color_code,District,Country,State,Post_date)
```

Lastly, I like tooltips. A lot. So this code sets the labels for each job:


```r
labs <- lapply(seq(nrow(test2)), function(i) {
  paste0( '<p>', "<b>Employer:</b>",test2[i, "Employer"], '<p></p>', 
          "<b>Position: </b>",test2[i, "Title"], ' ', 
          test2[i, "location"],'</p><p>', 
          "<b>Salary: </b>",test2[i, "Salary"], '</p>' ) 
})
```

### Plotting the Output

The final step is to simply plug in our variables and final `test2` dataframe into `leaflet` to visualize the results:


```r
leaflet(test2) %>% addTiles() %>%
  addAwesomeMarkers(~lon, ~lat, popup = ~Salary, icon = awesomeIcons(icon = 'ion-ionic', library = 'ion', markerColor = test2$Color_code), 
                    label = lapply(labs, htmltools::HTML),labelOptions = labelOptions(
                      style=list(
                        'background'='rgba(243, 241, 239, 1)',
                        'border-color' = 'rgba(46, 49, 49, 1)',
                        'border-radius' = '2px',
                        'border-style' = 'solid',
                        'border-width' = '2px'))) %>% 
  addLegend("bottomright", 
            colors =c("#70AF28",  "#38ADDF", "	#F79530", "#CC3E24", "#575556"),
            labels= c("Over £40,000","£30,000 - £39,999","£20,000 - £29,999","Below £20,000","Rate Unavailable"),
            title= "Salary",
            opacity = 1)
```

<!--html_preserve--><div id="htmlwidget-78a8f5c959b6c4894cb4" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-78a8f5c959b6c4894cb4">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addAwesomeMarkers","args":[[54.9684910471045,54.7030141153202,55.9584457473516,52.2081835760211,51.4835977256618,51.5084128477919,52.2660389729378,42.359429492367,55.9475937654938,51.5591614364449,53.478428786523,51.7483809880176,54.9682832646926,52.2071687756122,54.7023339044066],[-1.61060793805982,-3.27839164731265,-3.18720607624186,0.126114027326015,-0.145439709322279,-0.125803002761544,-0.027542623967988,-71.0623166287205,-3.18878374998208,-1.78458647899142,-2.24649194118557,-1.25644667078063,-1.61066427532745,0.123806053437312,-3.27921388652161],{"icon":"ion-ionic","markerColor":["red","gray","gray","green","blue","blue","gray","gray","gray","blue","gray","green","orange","blue","gray"],"iconColor":"white","spin":false,"squareMarker":false,"iconRotate":0,"font":"monospace","prefix":"ion"},null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},["\n\n£18,342 - £19,133 a year\n",null,null,"\n\n£41,526 - £52,559 a year\n","\n\n£38,594 - £44,113 a year\n","\n\n£38,594 - £44,113 a year\n",null,null,null,"\n\n£30,782 a year\n",null,"\n\n£70,579 a year\n","\n\n£28,331 - £40,322 a year\n","\n\n£36,914 - £49,553 a year\n",null],null,null,null,["<p><b>Employer:<\/b>\n\nNewcastle University<p><\/p><b>Position: <\/b>\nReceptionist <\/p><p><b>Salary: <\/b>\n\n£18,342 - £19,133 a year\n<\/p>","<p><b>Employer:<\/b>\n\nWSP<p><\/p><b>Position: <\/b>\n2020 Environmental Degree Apprenticeships <\/p><p><b>Salary: <\/b>NA<\/p>","<p><b>Employer:<\/b>\n\nUniversity of Edinburgh<p><\/p><b>Position: <\/b>\nStudent Support Officer <\/p><p><b>Salary: <\/b>NA<\/p>","<p><b>Employer:<\/b>\n\nUniversity of Cambridge<p><\/p><b>Position: <\/b>\nUniversity Lecturer in Environmental Archaeology <\/p><p><b>Salary: <\/b>\n\n£41,526 - £52,559 a year\n<\/p>","<p><b>Employer:<\/b>\n\nBirkbeck University of London<p><\/p><b>Position: <\/b>\nPOSTDOCTORAL RESEARCHER <\/p><p><b>Salary: <\/b>\n\n£38,594 - £44,113 a year\n<\/p>","<p><b>Employer:<\/b>\n\nBirkbeck, University of London<p><\/p><b>Position: <\/b>\nPOSTDOCTORAL RESEARCHER <\/p><p><b>Salary: <\/b>\n\n£38,594 - £44,113 a year\n<\/p>","<p><b>Employer:<\/b>\nRSK Environment GmbH<p><\/p><b>Position: <\/b>\nAssistant Ecological Consultant <\/p><p><b>Salary: <\/b>NA<\/p>","<p><b>Employer:<\/b>\n\nMorgan Hunt Group<p><\/p><b>Position: <\/b>\nLecturer <\/p><p><b>Salary: <\/b>NA<\/p>","<p><b>Employer:<\/b>\n\nUniversity of Edinburgh<p><\/p><b>Position: <\/b>\nResearch Training Centre Administrative Officer <\/p><p><b>Salary: <\/b>NA<\/p>","<p><b>Employer:<\/b>\n\nAHRC<p><\/p><b>Position: <\/b>\nPublic Engagement Manager <\/p><p><b>Salary: <\/b>\n\n£30,782 a year\n<\/p>","<p><b>Employer:<\/b>\n\nWYG Group Ltd<p><\/p><b>Position: <\/b>\nGraduate Transport Planner (Manchester) <\/p><p><b>Salary: <\/b>NA<\/p>","<p><b>Employer:<\/b>\n\nUniversity of Oxford<p><\/p><b>Position: <\/b>\nHead of Development â€“ Ashmolean Museum (maternity cover) <\/p><p><b>Salary: <\/b>\n\n£70,579 a year\n<\/p>","<p><b>Employer:<\/b>\n\nNewcastle University<p><\/p><b>Position: <\/b>\nCommunity Archaeologist <\/p><p><b>Salary: <\/b>\n\n£28,331 - £40,322 a year\n<\/p>","<p><b>Employer:<\/b>\n\nUniversity of Cambridge<p><\/p><b>Position: <\/b>\nSenior Teaching Associate in Quantitative Methods in Archaeo... <\/p><p><b>Salary: <\/b>\n\n£36,914 - £49,553 a year\n<\/p>","<p><b>Employer:<\/b>\n\nWSP<p><\/p><b>Position: <\/b>\nBuilt Heritage Specialist <\/p><p><b>Salary: <\/b>NA<\/p>"],{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"style":{"background":"rgba(243, 241, 239, 1)","border-color":"rgba(46, 49, 49, 1)","border-radius":"2px","border-style":"solid","border-width":"2px"},"className":"","sticky":true},null]},{"method":"addLegend","args":[{"colors":["#70AF28","#38ADDF","\t#F79530","#CC3E24","#575556"],"labels":["Over £40,000","£30,000 - £39,999","£20,000 - £29,999","Below £20,000","Rate Unavailable"],"na_color":null,"na_label":"NA","opacity":1,"position":"bottomright","type":"unknown","title":"Salary","extra":null,"layerId":null,"className":"info legend","group":null}]}],"limits":{"lat":[42.359429492367,55.9584457473516],"lng":[-71.0623166287205,0.126114027326015]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

![](/scrape.png)

### Final Thoughts

This is a fairly simplistic setup, and could be built-out as needed. Scraping multiple pages is the next obvious step, and creating a more nuanced system for dealing with salary ranges would be helpful. But this workflow helped to achieve my goals at the time, and can hopefully be of some use to you!
