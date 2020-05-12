---
title: "k-Means Clustering"

draft: false
toc: true
toc_float: true
type: docs

linktitle: k-Means Clustering
menu:
  docs:
    parent: Machine Learning
    weight: 1
---



## Overview

When attempting to cluster data, degrees of similarity and dissimilarity between observations are calculated using [distance measurements](https://www.datanovia.com/en/lessons/clustering-distance-measures/). Quantifying (dis)similarity in such a manner allows a variety of clustering algorithms to then be applied depending on statistical goals and the nature of the data itself. One of the most popular partitioning clustering methods, [*k*-means](https://en.wikipedia.org/wiki/K-means_clustering), uses the mean values of data points to formulate clusters; with the actual number of clusters (*k*) being pre-defined by the user. The `factoextra` package allows for quick and easy *k*-means clustering visualization, while the `NbClust` and `fpc` packages allow us to identify the optimal number of clusters in our data and validate results.  


```r
library(mlbench)
library(tidyverse)
library(cluster)
library(factoextra)
library(NbClust)
library(fpc)
```

For this exercise we'll be using the multivariate [Glass Identification](https://archive.ics.uci.edu/ml/datasets/Glass+Identification) dataset from the UCI machine learning repository, which documents the compostion of 214 glass samples by 10 chemical variables. 


```r
# Load data
data(Glass)
head(Glass)
```

```
##        RI    Na   Mg   Al    Si    K   Ca Ba   Fe Type
## 1 1.52101 13.64 4.49 1.10 71.78 0.06 8.75  0 0.00    1
## 2 1.51761 13.89 3.60 1.36 72.73 0.48 7.83  0 0.00    1
## 3 1.51618 13.53 3.55 1.54 72.99 0.39 7.78  0 0.00    1
## 4 1.51766 13.21 3.69 1.29 72.61 0.57 8.22  0 0.00    1
## 5 1.51742 13.27 3.62 1.24 73.08 0.55 8.07  0 0.00    1
## 6 1.51596 12.79 3.61 1.62 72.97 0.64 8.07  0 0.26    1
```

```r
# Select only numeric variables and scale data
glass <- Glass %>% 
  select(Na:Fe) %>% 
  scale()   
```

## Checking Clustering Tendency

Since clustering algorithms both impose and magnify order within a dataset, it's important to make sure that there are inherent groups present within the data to begin with. Otherwise, we can end up creating spurious clusters. Using the [Hopkins statistic](https://en.wikipedia.org/wiki/Hopkins_statistic), we can perform a hypothesis test where the H~0~ assumes the data is uniformly randomly distributed. A value of close to 1 indicates the data has significant group structure, close to 0.5 suggests truly random data, while a value close to 0 represents uniformly distributed data. 


```r
res <- get_clust_tendency(glass, n = nrow(glass)-1, graph = FALSE)
res$hopkins_stat
```

```
## [1] 0.8689191
```

Since H > 0.5, and is in fact close to 1, we can reject H~0~ and conclude that our data is suitable for clustering.  

## Determining Optimal Number of Clusters

In order to decide how many clusters to display, we can use the `NbClust` function to cycle through a variety of different tests avialable in `r` including the elbow method, silhouette method and the gap statistic method among [many others](https://www.rdocumentation.org/packages/NbClust/versions/3.0/topics/NbClust). The specific details of different clustering algorithms are beyond the scope of our exercise today, but for further information refer to `NbClust`'s associated article in the [Journal of Statistical Software](https://www.jstatsoft.org/index.php/jss/article/view/v061i06/v61i06.pdf). In essence, selecting the "correct" number of clusters is dependent on domain knowledge, specific statistical considerations based on the data, and whether you're looking for [knowledge or data-driven results](https://stats.stackexchange.com/questions/23472/how-to-decide-on-the-correct-number-of-clusters):


```r
glass.nbclust <- glass %>%
  NbClust(distance = "euclidean",
          min.nc = 2, max.nc = 10, 
          method = "complete", index ="all") 
```


```r
fviz_nbclust(glass.nbclust)
```

```
## Among all indices: 
## ===================
## * 2 proposed  0 as the best number of clusters
## * 1 proposed  1 as the best number of clusters
## * 6 proposed  2 as the best number of clusters
## * 1 proposed  3 as the best number of clusters
## * 1 proposed  4 as the best number of clusters
## * 3 proposed  5 as the best number of clusters
## * 3 proposed  8 as the best number of clusters
## * 1 proposed  9 as the best number of clusters
## * 8 proposed  10 as the best number of clusters
## 
## Conclusion
## =========================
## * According to the majority rule, the best number of clusters is  10 .
```

<img src="/docs/kmeans/kmeans_files/figure-html/unnamed-chunk-5-1.png" width="672" />

Since our tutorial assumes no background in compositional analysis, for this example we'll proceed using both *k*=10 as suggested above as well as *k*=2 to compare the results. We can then insert these values into our `fviz_cluster` calls to plot the clusters:


```r
# Randomize
set.seed(123)
# Calculate k-means clusters
km10.res <- kmeans(glass, 10, nstart = 25)
km2.res <- kmeans(glass, 2, nstart = 25)
# Plot k=2
fviz_cluster(km2.res, data = glass,
             # ellipse = FALSE,
             ellipse.type = "norm",
             palette = "jco",
             ggtheme = theme_minimal())
```

<img src="/docs/kmeans/kmeans_files/figure-html/unnamed-chunk-6-1.png" width="672" />

```r
# Plot k=10
fviz_cluster(km10.res, data = glass,
             # ellipse = FALSE,
             ellipse.type = "norm",
             palette = "jco",
             ggtheme = theme_minimal())
```

<img src="/docs/kmeans/kmeans_files/figure-html/unnamed-chunk-6-2.png" width="672" />

Depending on our research questions either *k*=2 or *k*=10 could prove useful, as each allows a different visualization of the data and highlights different trends. If we're exploring minute variations in composition based on barium content, the complex plot of *k*=10 may better elucidate chemical relationships for our purposes. However, if we want to simply see broad trends in the data, *k*=2 may be better suited for cursory evaluation.   

## Assessing Clustering Quality

Cluster validation can be calculated quantitatively using either [internal or external validation measures](https://www.jstatsoft.org/article/view/v025i04), which either 1) assess the compaction/separation of clusters or 2) quantify the fit between the clustering and external references, respectively. Each of the metrics in this section uses a scale of -1 (poor) to 1 (good) to assess clustering quality.

### Internal measures

[Silhouette coefficients](https://en.wikipedia.org/wiki/Silhouette_(clustering)) measure similarity between objects within the same cluster versus those in the neighboring cluster, and plots of these coefficients are among the most widely-used methods of internal validation: 


```r
# Calcluate silhouettes from k-means
sil_2 <- silhouette(km2.res$cluster, dist(glass))
sil_10 <- silhouette(km10.res$cluster, dist(glass))
# Plot silhouettes
fviz_silhouette(sil_2)
```

```
##   cluster size ave.sil.width
## 1       1   33          0.19
## 2       2  181          0.52
```

<img src="/docs/kmeans/kmeans_files/figure-html/unnamed-chunk-7-1.png" width="672" />

```r
fviz_silhouette(sil_10)
```

```
##    cluster size ave.sil.width
## 1        1   88          0.50
## 2        2    2          0.97
## 3        3   29          0.20
## 4        4   15          0.13
## 5        5   21          0.33
## 6        6   23          0.09
## 7        7    5          0.09
## 8        8   24          0.51
## 9        9    1          0.00
## 10      10    6         -0.06
```

<img src="/docs/kmeans/kmeans_files/figure-html/unnamed-chunk-7-2.png" width="672" />

The average width of the silhouettes with *k*=2 is appreciably higher than with *k*=10, although both have clusters below the mean line (something we'd like to avoid). This would indicate that neither method is able to provide truly high quality clustering within the dataset (something quite clearly visibile in the previous biplots).

Similarly, the [Dunn index](https://en.wikipedia.org/wiki/Dunn_index), which measures cluster compaction quality, also presents a sub-optimal value (range -1 to 1): 


```r
km_stats <- cluster.stats(dist(glass), km10.res$cluster)
km_stats$dunn
```

```
## [1] 0.04860787
```

### External Measures

We can use the corrected [Rand index](https://en.wikipedia.org/wiki/Rand_index) to see how our clusters match up to known groups (if present in the dataset). In our case, this could be tested against the `Type` variable from the original `Glass` dataframe:


```r
type <- as.numeric(Glass$Type)
clust_stats <- cluster.stats(d = dist(glass), 
                             type, km10.res$cluster)
clust_stats$corrected.rand
```

```
## [1] 0.1855973
```

Given the poor performance of *k*-means clustering in the internal validation measurements, a low corrected Rand score here is unsurprising. 

## Final Thoughts

This brief overview of *k*-means clustering highlights some of the practical applications of partitioning clustering on multivariate data. While useful in exploratory data analysis, *k*-means is highly susceptible to outlier influence, and may be passed over in favor of more robust methods like [*k*-medioids (PAM)](https://en.wikipedia.org/wiki/K-medoids) or [hierarchical clustering](https://en.wikipedia.org/wiki/Hierarchical_clustering) depending on the depth of analysis.
