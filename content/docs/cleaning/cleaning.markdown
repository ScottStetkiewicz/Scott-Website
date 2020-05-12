---
title: "Cleaning ADS Repository Data: (Ponting & Butcher 2015)"
draft: false
toc: true
toc_float: true
type: docs
linktitle: Dataset Preprocessing
menu:
  docs:
    parent: EDA
    weight: 1
---



A quick internet search for "*data wrangling*" can produce mountains of results relating to marketing, survey and clinical data. However, finding data science principles applied to archaeological questions and datasets specifically is a much tougher challenge. To illustrate exactly how archaeologists can use `r` for cleaning, tidying and exploring their data, the following tutorial provides a step-by-step walkthrough using freely available archaeometallurgical/numismatic data. 

## **Background**

The dataset used here is a collection of compositional analyses (ICP-AES, AAS and LA-MC-ICP-MS) of Roman silver coins carried out by [Butcher and Ponting](http://archaeologydataservice.ac.uk/archives/view/coins_lt_2005/overview.cfm) over nearly two decades to explore [diachronic variation in currency purity](https://www.academia.edu/318923/The_Roman_Denarius_Under_the_Julio-Claudian_Emperors_Mints_Metallurgy_and_Technology).

## **Data Wrangling and Cleaning**

Before we can begin to explore this dataset, we'll need to perform several iterative steps of cleaning and transformation. The majority of this will be done using packages from the `tidyverse` ecosystem, particularly `dplyr` and `tidyr`.

### First Steps

The very first step is to read in the .csv files from the ADS repository:


```r
den1<- read_csv("Denarii_JC_to_Trajans_reform_final.csv")
```

```
## Warning: Missing column names filled in: 'X29' [29], 'X30' [30], 'X31' [31],
## 'X32' [32], 'X33' [33]
```

```r
den2<-read_csv("Provincial_JC_to_Trajans_reform_final.csv")
```

Right away, I'd like to merge these two datasets into a single file that I can wrangle/tidy more effectively. However, the error message above has already tipped me off to the fact that something isn't right. When I try to run: 


```r
den<-rbind(den1,den2)
```

```
## Error in rbind(deparse.level, ...): numbers of columns of arguments do not match
```

I get an error saying the number of columns do not match. Upon looking closer at the `den1` table, I can see that five extra unnamed columns are present, with values beginning at line 93. These are in fact Pb isotope data that are present on a separate .csv sheet in the downloaded `Denarii_JC_to_Trajans_reform_final` file, but seem to have been errorneously duplicated here. Thus, we can delete the columns and merge the datasets using the `select()` function from `dplyr`. 


```r
den1<-select(den1,-(X29:X33))
den<-rbind(den1,den2)
```

This provides us with the complete dataset of 1076 inidividual entries for analysis. We can now remove unnecessary columns (for our purposes) and rename elements according to their periodic table symbols. Unfortunately, the `WEIGHT` parameter (which is pretty important) has only 103 recorded measurements; while these may have been useful in more focused micro-analyses, there aren't enough values to merit including this in our new combined dataset. 


```r
den <- den %>% 
  select(-WEIGHT,-OBVERSE,-REVERSE,-DONOR,-DONORREF,-WALKER,-COMMENTS) %>%
  rename(As=ARSENIC,
         Au=GOLD,
         Cu=COPPER,
         Fe=IRON,
         Ni=NICKEL,
         Pb=LEAD,
         Sb=ANTIMONY,
         Sn=TIN,
         Zn=ZINC,
         Mn=MANGANESE,
         Cr=CHROMIUM,
         Co=COBALT,
         Bi=BISMUTH,
         Ag=SILVER)
```

After this, we want to remove any missing values in the table and transform them into more standardized **NA**'s.


```r
den<-na_if(den, '<null>')
```

Then, we can get a sense for how the new tibble looks using `glimpse`:


```r
glimpse(den)
```

```
## Rows: 1,076
## Columns: 21
## $ REF          <chr> "BCC10", "BCC11", "BCC12", "BCC13", "BCC137", "BCC138", …
## $ DENOMINATION <chr> "denarius", "denarius", "denarius", "denarius", "denariu…
## $ MINT         <chr> "Rome", "Rome", "Rome", "Rome", "Rome", "Rome", "Rome", …
## $ EMPEROR      <chr> "Vespasian", "Vespasian", "Vespasian", "Vespasian", "Ner…
## $ NAMED        <chr> "Vespasian", "Titus", "Titus", "Titus", "Nero", "Nero", …
## $ HOARD        <chr> "Magiovinium", "Magiovinium", "Magiovinium", "Magioviniu…
## $ As           <dbl> 0.003, 0.003, 0.002, 0.011, 0.003, 0.009, 0.003, 0.003, …
## $ Au           <dbl> 0.378, 0.377, 0.631, 0.599, 0.395, 0.300, 0.923, 0.475, …
## $ Cu           <dbl> 20.60, 22.99, 19.30, 17.08, 9.60, 20.39, 12.22, 23.65, 1…
## $ Fe           <dbl> 0.014, 0.008, 0.006, 0.004, 0.004, 0.042, 0.003, 0.013, …
## $ Ni           <dbl> 0.001, 0.002, 0.001, 0.003, 0.001, 0.003, 0.000, 0.002, …
## $ Pb           <dbl> 0.59, 0.63, 0.46, 0.29, 1.09, 0.61, 1.07, 0.74, 1.26, 1.…
## $ Sb           <dbl> 0.001, 0.008, 0.005, 0.015, 0.004, 0.012, 0.001, 0.011, …
## $ Sn           <dbl> 0.0023, 0.0270, 0.0010, 0.0009, 0.0013, 0.0078, 0.0011, …
## $ Zn           <dbl> 0.0106, 0.2527, 0.0001, 0.0003, 0.0010, 0.0006, 0.0033, …
## $ Mn           <dbl> 0.00007, 0.00008, 0.00014, 0.00031, 0.00014, 0.00009, 0.…
## $ Cr           <dbl> 0.00005, 0.00005, 0.00004, 0.00004, 0.00006, 0.00004, 0.…
## $ Co           <dbl> 0.0001, 0.0001, 0.0003, 0.0004, 0.0001, 0.0004, 0.0001, …
## $ Bi           <dbl> 0.009, 0.021, 0.000, 0.000, 0.029, 0.020, 0.008, 0.000, …
## $ Ag           <dbl> 78.40, 75.68, 79.59, 84.31, 88.87, 78.60, 85.77, 75.10, …
## $ BULLION      <dbl> 79.37, 76.70, 80.69, 85.20, 90.38, 79.53, 87.77, 76.31, …
```

### Dealing With Problematic Data Entries

Having merged our datasets and run a cursory cleaning, the next step is to look at invidual columns of data to see if any unexpected problems exist. 

Taking a look at the unique names present in the MINT column, for instance, we can see a few issues: 


```r
unique(den$MINT)
```

```
##  [1] "Rome"              "Spanish"           "Gaul"             
##  [4] "Gaul or Spain"     "?"                 "Lyon"             
##  [7] "UG3"               "Ephesus"           "O mint"           
## [10] "Antioch"           "UG5"               "Carthage"         
## [13] "Tarraco"           "Antony"            "Alexandria"       
## [16] "Caesarea"          "Tyre"              "Syria"            
## [19] "Pergamon/Ephesus?" "Mauretania"        "Seleucia"         
## [22] "Cyprus"            "Numidia"           "Tarsus"           
## [25] "Judaea"            "Asia"              NA                 
## [28] "Lycia"             "FALSE"
```

There are a few coin analyses where the `MINT` variable is a "?", "O mint" and "FALSE" rather than the expected city/region. These three aberrant classifications don't really help us at all and appear to be unintentional errors from the original research compilation stage. Looking a bit closer at these seven analyses, there doesn't seem to be anything to indicate what the mint should be: 


```r
filter(den,MINT=="FALSE" | MINT=="?" | MINT=="O mint")
```

```
## # A tibble: 7 x 21
##   REF   DENOMINATION MINT  EMPEROR NAMED HOARD    As    Au    Cu    Fe     Ni
##   <chr> <chr>        <chr> <chr>   <chr> <chr> <dbl> <dbl> <dbl> <dbl>  <dbl>
## 1 BM008 denarius     ?     Civil … Civi… <NA>  0.09  0.015  99.5 0.04  0.016 
## 2 BM010 denarius     ?     Civil … Civi… <NA>  0.017 0.003  99.7 0.023 0.013 
## 3 BM042 denarius     O mi… Vespas… Titus <NA>  0.011 0.598  18.2 0.005 0.001 
## 4 BM043 denarius     O mi… Vespas… Domi… <NA>  0.008 0.577  18.1 0.005 0.002 
## 5 C3    denarius     O mi… Vespas… Vesp… <NA>  0.025 0.657  18.9 0.005 0.002 
## 6 w37   denarius     O mi… Vespas… Titus <NA>  0.01  0.621  16.8 0.007 0.003 
## 7 Y72   didrachm     FALSE Nero +… <NA>  <NA>  0.136 0      97.6 0.038 0.0143
## # … with 10 more variables: Pb <dbl>, Sb <dbl>, Sn <dbl>, Zn <dbl>, Mn <dbl>,
## #   Cr <dbl>, Co <dbl>, Bi <dbl>, Ag <dbl>, BULLION <dbl>
```

Outside of the `MINT` issue, these samples don't exhibit any problematic behavior. Therefore, it makes the most sense to leave these entries in the dataframe, but to rename their `MINT` variables with **NA**'s so we know there's a problem with the minting location.


```r
den$MINT<-na_if(den$MINT,"FALSE")
den$MINT<-na_if(den$MINT,"?")
den$MINT<-na_if(den$MINT,"O mint")
```

This general process can then be repeated for all of the remaining categorical values in the dataframe.

Looking through the `EMPEROR`, `NAMED` and `HOARD` columns, nothing needs to be fixed. In the `DENOMINATION` column, we have a situation where we want to combine certain duplicate variables like `Didrachm` and `didrachm` (we'll also do the same with `Didrachm?`, as this classification doesn't offer any real benefits).  


```r
unique(den$DENOMINATION)
```

```
##  [1] "denarius"    "Tetradrachm" "Drachm"      "Didrachm"    "Cistophorus"
##  [6] NA            "tetradrachm" "drachm"      "cistophorus" "didrachm"   
## [11] "Didrachm?"
```

Since we're not turning these into **NA**'s, we use the `recode` function from `dplyr` to standardize the variables:


```r
den<-den %>% 
  mutate(DENOMINATION = recode(DENOMINATION,
      denarius = "Denarius",
      Tetradrachm = "Tetradrachm",
      Drachm = "Drachm",
      Didrachm = "Didrachm",
      Cistophorus = "Cistophorus",
      tetradrachm = "Tetradrachm",
      drachm = "Drachm",
      cistophorus = "Cistophorus",
      didrachm = "Didrachm",
      "Didrachm?" = "Didrachm"
    )
  )
```

Note that since the variable `Didrachm?` has a question mark, it needs to be used inside quotation marks in the above `mutate` call.

### Establishing A Chronology

As a non-Romanist, the 29 different levels of the `EMPEROR` column don't mean a whole to me:


```r
unique(den$EMPEROR)
```

```
##  [1] "Vespasian"             "Nero"                  "Galba"                
##  [4] "Vitellius"             "Titus"                 "Domitian"             
##  [7] "Nerva"                 "Civil War"             "Claudius"             
## [10] "Caligula"              "Tiberius"              "Augustus"             
## [13] "Otho"                  "Antony"                "Hellenistic"          
## [16] "Posthumous Philip"     "Juba I"                "Juba and Cleo."       
## [19] "Juba II"               "Juba II and Cleo."     "Cleopatra"            
## [22] "Tiberius/Drusus"       "Philip"                "Ptolemy"              
## [25] "Germanicus"            "Domitia"               "Nero + Divus Claudius"
## [28] "Claudius/Agrippina"    "Nero + Agrippina"
```

To chronologically contextualize the emperors and get a sense of diachronic compositional change, we can `mutate` the dataset using the `case_when` helper function to identify each occurrence of a particular emperor and create a new variable column that will produce a temporal date range (in years AD).


```r
dennys<-den %>% mutate(
  Years = case_when(
    EMPEROR=="Vespasian"~"AD 69-79",
    EMPEROR=="Nero"~"AD 54-68",
    EMPEROR=="Galba"~"AD 68-69",
    EMPEROR=="Vitellius"~"AD 69",
    EMPEROR=="Titus"~"AD 79-81",
    EMPEROR=="Domitian"~"AD 81-96",
    EMPEROR=="Nerva"~"AD 96-98",
    EMPEROR=="Civil War"~"BC 49-46",
    EMPEROR=="Claudius"~"AD 41-54",
    EMPEROR=="Caligula"~"AD 37-41",
    EMPEROR=="Tiberius"~"AD 14-37",
    EMPEROR=="Augustus"~"BC 27-14 AD",
    EMPEROR=="Otho"~"AD 69",
    EMPEROR=="Antony"~"BC 44-31",
    EMPEROR=="Hellenistic"~"0",
    EMPEROR=="Posthumous Philip"~"AD 250",
    EMPEROR=="Juba I"~"AD 60-46",
    EMPEROR=="Juba and Cleo."~"AD 60-46",
    EMPEROR=="Juba II"~"BC 25-23 AD",
    EMPEROR=="Juba II and Cleo."~"BC 25-23 AD",
    EMPEROR=="Cleopatra"~"BC 51-30",
    EMPEROR=="Tiberius/Drusus"~"0",
    EMPEROR=="Philip"~"AD 244-249",
    EMPEROR=="Ptolemy"~"AD 20-40",
    EMPEROR=="Germanicus"~"AD 7-19",
    EMPEROR=="Domitia"~"0",
    EMPEROR=="Nero + Divus Claudius"~"AD 54-68",
    EMPEROR=="Claudius/Agrippina"~"0",
    EMPEROR=="Nero + Agrippina"~"AD 54-68"
  )
)
```


```r
dennys<-den %>% mutate(
  Years = case_when(
    EMPEROR=="Vespasian"~"69",
    EMPEROR=="Nero"~"54",
    EMPEROR=="Galba"~"68",
    EMPEROR=="Vitellius"~"69",
    EMPEROR=="Titus"~"79",
    EMPEROR=="Domitian"~"81",
    EMPEROR=="Nerva"~"96",
    EMPEROR=="Civil War"~"-49",
    EMPEROR=="Claudius"~"41",
    EMPEROR=="Caligula"~"37",
    EMPEROR=="Tiberius"~"14",
    EMPEROR=="Augustus"~"-27",
    EMPEROR=="Otho"~"69",
    EMPEROR=="Antony"~"-44",
    EMPEROR=="Hellenistic"~"0",
    EMPEROR=="Posthumous Philip"~"250",
    EMPEROR=="Juba I"~"-60",
    EMPEROR=="Juba and Cleo."~"-60",
    EMPEROR=="Juba II"~"-25",
    EMPEROR=="Juba II and Cleo."~"-25",
    EMPEROR=="Cleopatra"~"-51",
    EMPEROR=="Tiberius/Drusus"~"0",
    EMPEROR=="Philip"~"244",
    EMPEROR=="Ptolemy"~"20",
    EMPEROR=="Germanicus"~"7",
    EMPEROR=="Domitia"~"0",
    EMPEROR=="Nero + Divus Claudius"~"54",
    EMPEROR=="Claudius/Agrippina"~"0",
    EMPEROR=="Nero + Agrippina"~"54"
  )
)

dennys$Years<-as.numeric(dennys$Years)
```

### Tidying the Data

Here we're going to convert the dataset from wide format to long, as this will optimize the data for computer-based analyses. The definition of ["tidy" data](http://vita.had.co.nz/papers/tidy-data.pdf) necessitates: 

1. Each variable forms a column.
2. Each observation forms a row.
3. Each type of observational unit forms a table.

Thus we need to gather each constituent element from our inital dataset into a single, new column. 


```r
longden <- dennys %>% 
  gather(As:Ag, key = Elements, value = Composition)
```

## **Exploratory Data Analysis**

With our data now officially tidy, we can begin to explore trends depending on our research questions.


```r
ggplot(dennys) + geom_bar(aes(x = DENOMINATION, fill = DENOMINATION), color="black") + theme_bw()
```

<img src="/docs/cleaning/cleaning_files/figure-html/unnamed-chunk-16-1.png" width="672" />


```r
ggplot(dennys, aes(x=reorder(EMPEROR,Years),y=BULLION,fill=EMPEROR), color="black") + geom_boxplot() + theme_bw() + coord_flip() + theme(legend.position = "none")
```

```
## Warning: Removed 2 rows containing non-finite values (stat_boxplot).
```

<img src="/docs/cleaning/cleaning_files/figure-html/unnamed-chunk-17-1.png" width="672" />
