library(dendextend)
library(mlbench)
library(tidyverse)
library(colorspace) # get nice colors
library(factoextra)

res.hc <- mtcars %>%
  scale() %>%                    # Scale the data
  dist(method = "euclidean") %>% # Compute dissimilarity matrix
  hclust(method = "ward.D2")
fviz_dend(res.hc, rect = TRUE, cex = 0.5)

type_labels <- mtcars$cyl
levels(mtcars$cyl) <- unique(mtcars$cyl)
cyl_type <- levels(mtcars$cyl)
cyl_col <- rainbow_hcl(3)[as.numeric(cyl_type)]

dend <- as.dendrogram(res.hc)
# order it the closest we can to the order of the observations:
# dend <- rotate(dend, 1:214)

# Color the branches based on the clusters:
dend <- color_branches(dend, k=3)
# , groupLabels=glass_type)

# Manually match the labels, as much as possible, to the real classification of the flowers:
labels_colors(dend) <-
  rainbow_hcl(3)[sort_levels_values(
    as.numeric(mtcars$cyl)[order.dendrogram(dend)]
  )]

# We shall add the flower type to the labels:
labels(dend) <- paste(as.character(mtcars$cyl)[order.dendrogram(dend)],
                      "(",labels(dend),")",
                      sep = "")# We hang the dendrogram a bit:
# dend <- hang.dendrogram(dend,hang_height=0.1)
# reduce the size of the labels:
# dend <- assign_values_to_leaves_nodePar(dend, 0.5, "lab.cex")
dend <- set(dend, "labels_cex", .5)
# And plot:
par(mar = c(3,3,3,7))
plot(dend,
     main = "Glass",
     horiz =  TRUE,  nodePar = list(cex = .007))
legend("topleft", legend = cyl_type, fill = rainbow_hcl(3))
