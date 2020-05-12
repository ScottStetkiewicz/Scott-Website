---
title: "Multiple Regression using the state.x77 Dataset"

draft: false
toc: true
toc_float: true
type: docs

linktitle: Multiple Regression
menu:
  docs:
    parent: Regression
    weight: 3
---




```r
require(tidyverse)
require(MASS)
require(caret)
require(GGally)
require(glmnet)
require(car)
require(ggfortify)
```

## Import Dataset

The `state.x77` dataset is a 50 row x 8 column matrix compiled by the U.S. Department of Commerce (Bureau of the Census) documenting the following variables in 50 states in the 1970's: 

* **Population**: population estimate as of July 1, 1975
* **Income**: per capita income (1974)
* **Illiteracy**: illiteracy (1970, percent of population)
* **Life Exp**: life expectancy in years (1969–71)
* **Murder**: murder and non-negligent manslaughter rate per 100,000 population (1976)
* **HS Grad**: percent high-school graduates (1970)
* **Frost**: mean number of days with minimum temperature below freezing (1931–1960) in capital or large city
* **Area**: land area in square miles

The aim of this exercise is to arrive at an optimized model for predicting life expectancy using the other variables in `state.x77`.


```r
state <- as.data.frame(state.x77)
colnames(state)[c(4, 6)] <- c("Life.Exp", "HS.Grad")
str(state)
```

```
## 'data.frame':	50 obs. of  8 variables:
##  $ Population: num  3615 365 2212 2110 21198 ...
##  $ Income    : num  3624 6315 4530 3378 5114 ...
##  $ Illiteracy: num  2.1 1.5 1.8 1.9 1.1 0.7 1.1 0.9 1.3 2 ...
##  $ Life.Exp  : num  69 69.3 70.5 70.7 71.7 ...
##  $ Murder    : num  15.1 11.3 7.8 10.1 10.3 6.8 3.1 6.2 10.7 13.9 ...
##  $ HS.Grad   : num  41.3 66.7 58.1 39.9 62.6 63.9 56 54.6 52.6 40.6 ...
##  $ Frost     : num  20 152 15 65 20 166 139 103 11 60 ...
##  $ Area      : num  50708 566432 113417 51945 156361 ...
```

```r
head(state)
```

```
##            Population Income Illiteracy Life.Exp Murder HS.Grad Frost   Area
## Alabama          3615   3624        2.1    69.05   15.1    41.3    20  50708
## Alaska            365   6315        1.5    69.31   11.3    66.7   152 566432
## Arizona          2212   4530        1.8    70.55    7.8    58.1    15 113417
## Arkansas         2110   3378        1.9    70.66   10.1    39.9    65  51945
## California      21198   5114        1.1    71.71   10.3    62.6    20 156361
## Colorado         2541   4884        0.7    72.06    6.8    63.9   166 103766
```

## Assumption Checks

Before we can begin our modeling, we need to ensure the data meets the basic assumtions for multiple regression:

### 1. DV/IV Linear Relationships

Scatterplots of the relationships between the dependent and independent variables can be created using the `ggpairs` pairplot function:


```r
ggpairs(state, lower=list(continuous="smooth"))
```

<img src="/docs/multi_regression/multi_regression_files/figure-html/unnamed-chunk-3-1.png" width="672" />

Most predictors display a linear relationship with `Life.Exp`, though `Population` indicates low overall correlation with other variables. `Area` shows virtually no linear tendency, meaning it may need to be dropped. 

### 2. No Multicollinearity

We can check for for multicollinearity between the 7 other variables besides life expectancy (magnitude of correlation coefficients should be < .80): 


```r
ggpairs(state %>% dplyr::select(-Life.Exp), lower=list(continuous="smooth"))
```

<img src="/docs/multi_regression/multi_regression_files/figure-html/unnamed-chunk-4-1.png" width="672" />

We can then assess the multicollinearity of an initial model with all variables by using variance inflation factor (VIF) scoring, which measures how much the variance of a regression coefficient is inflated:


```r
model <- lm(Life.Exp ~ ., data = state)
car::vif(model)
```

```
## Population     Income Illiteracy     Murder    HS.Grad      Frost       Area 
##   1.499915   1.992680   4.403151   2.616472   3.134887   2.358206   1.789764
```

VIF values greater than 5-10 indicate problematically high correlation between variables, typically necessitating the removal of certain predictors. None of the `state.x77` VIF scores are above that threshold, so it is reasonable to use the initial multiple regression model above with all 7 predictors to start this exercise.

### 3. Residuals Values are Independent

The Durbin-Watson statistic can be used to detect autocorrelation in our regression model, where the H<sub>0</sub> is that there is no correlation among residuals, i.e., they are independent and H<sub>a</sub> is that residuals are autocorrelated:


```r
durbinWatsonTest(model)
```

```
##  lag Autocorrelation D-W Statistic p-value
##    1      0.02076189       1.92928   0.838
##  Alternative hypothesis: rho != 0
```

This assumption had been met, as the obtained Durbin-Watson value is close to 2 and p > .05. 

### 4. Homoscedasticity  
### 5. Residuals are Normally Distributed  
### 6. No Influential Cases Biasing Model   

All three of these assumptions can be checked using the `autoplot` function in the `ggfortify` package:


```r
autoplot(model)
```

<img src="/docs/multi_regression/multi_regression_files/figure-html/unnamed-chunk-7-1.png" width="672" />

The residuals variance appears to be relatively constant in the first plot, thus satisfying **Assumption #4**. Looking at the *QQ plot* we can see that for the most part our residuals look like they are normally distributed, satisfying **Assumtion #5** (only extreme deviances are likely to have significant impact on the model). Lastly, the *Residuals v.s. Leverage* plot shows that the states of Alaska and Hawaii may represent leverage points in our model and merit further investigation. 

Cook's Distance measurement is a statistic that identifies significant outliers, with values greater than 1 represting problematic leverage points:


```r
x <- ggally_nostic_cooksd(model, ggplot2::aes(state$Life.Exp, .cooksd, label=state.name))
x + geom_text(aes(label = state.abb, hjust=-0.25, vjust=0))
```

<img src="/docs/multi_regression/multi_regression_files/figure-html/unnamed-chunk-8-1.png" width="672" />

We likely do not need to remove Hawaii from the analysis, and will revisit this particular state later in the **Model Tuning** section. The state of Alaska, however, is almost certainly being impacted by its immense area and extremely small population metrics compared to all other US states. Once we begin to drop predictors (including `Area`), this outlier disappears from the Cook's Distance plots (see **Model Tuning**). Therefore we can ignore this point for now, having satisfied the requirements of **Assumption #6**, and can proceed with model selection procedures.

## Model Testing and Predictor Selection

There are several ways to run multiple regression in `r`. The most basic is to simply run the `lm` function, as in the previous section, using all independent variables. 

### `lm` Call

The `summary` call will return several important statistics, including the variable coefficients and their associated significance codes, allowing us to tentatively select which predictors to drop from subsequent model iterations:  


```r
summary(model)
```

```
## 
## Call:
## lm(formula = Life.Exp ~ ., data = state)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -1.48895 -0.51232 -0.02747  0.57002  1.49447 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  7.094e+01  1.748e+00  40.586  < 2e-16 ***
## Population   5.180e-05  2.919e-05   1.775   0.0832 .  
## Income      -2.180e-05  2.444e-04  -0.089   0.9293    
## Illiteracy   3.382e-02  3.663e-01   0.092   0.9269    
## Murder      -3.011e-01  4.662e-02  -6.459 8.68e-08 ***
## HS.Grad      4.893e-02  2.332e-02   2.098   0.0420 *  
## Frost       -5.735e-03  3.143e-03  -1.825   0.0752 .  
## Area        -7.383e-08  1.668e-06  -0.044   0.9649    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.7448 on 42 degrees of freedom
## Multiple R-squared:  0.7362,	Adjusted R-squared:  0.6922 
## F-statistic: 16.74 on 7 and 42 DF,  p-value: 2.534e-10
```

The p-value of the F-statistic is a highly significant 2.534e-10, meaning that at least one of the predictor variables is significantly related to the outcome variable. Looking at the summary of our model coefficients, `Population`, `Murder`, `HS.Grad`, and `Frost` are the predictors that display the most meaningful `t-statistic` values, which evaluate whether or not there is significant association between selected predictors and the outcome variable. We can see which variables are returned by other models to verify the quality of this inital assessment. 

### Stepwise Regression

While stepwise regression is a [highly controversial method](https://www.stata.com/support/faqs/statistics/stepwise-regression-problems/) in modern statistics, for a dataset with only 7 predictors it can serve as a useful means of double-checking the initial identification of the four primary predictors. Using sequential stepwise regression, we can arrive at a best-fit model for our data by dropping certain predictors:


```r
# Fit the full model 
full.model <- lm(Life.Exp ~., data = state)
# Stepwise regression model
step.model <- stepAIC(full.model, direction = "both", 
                      trace = FALSE)
summary(step.model)
```

```
## 
## Call:
## lm(formula = Life.Exp ~ Population + Murder + HS.Grad + Frost, 
##     data = state)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -1.47095 -0.53464 -0.03701  0.57621  1.50683 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  7.103e+01  9.529e-01  74.542  < 2e-16 ***
## Population   5.014e-05  2.512e-05   1.996  0.05201 .  
## Murder      -3.001e-01  3.661e-02  -8.199 1.77e-10 ***
## HS.Grad      4.658e-02  1.483e-02   3.142  0.00297 ** 
## Frost       -5.943e-03  2.421e-03  -2.455  0.01802 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.7197 on 45 degrees of freedom
## Multiple R-squared:  0.736,	Adjusted R-squared:  0.7126 
## F-statistic: 31.37 on 4 and 45 DF,  p-value: 1.696e-12
```

The summary call again identifies `Population`, `Murder`, `HS.Grad`, and `Frost` as the most statistically significant predictors for life expectancy. 

### Penalized Regression

We can also employ [penalized regression models](https://support.sas.com/rnd/app/stat/papers/2015/PenalizedRegression_LinearModels.pdf), which reduce the coefficient values towards zero; ensuring that less contributive variables will have a lower overall impact on the model. Lasso and elastic net models can be created using functionality within the `caret` and `glmnet` packages, and by partitioning the data into training/test sets we can then assess model performace (see **Model Selection and Performance**):


```r
# Split the data into training and test set
set.seed(123)
training.samples <- state$Life.Exp %>%
  createDataPartition(p = 0.8, list = FALSE)
train.data  <- state[training.samples, ]
test.data <- state[-training.samples, ]

# Predictor variables
x <- model.matrix(Life.Exp~., train.data)[,-1]
# Outcome variable
y <- train.data$Life.Exp

# Create grid of lamba values
lambda <- 10^seq(-3, 3, length = 100)
```


```r
# Build the lasso model
set.seed(123)
lasso <- train(
  Life.Exp ~., data = train.data, method = "glmnet",
  trControl = trainControl("cv", number = 10),
  tuneGrid = expand.grid(alpha = 1, lambda = lambda)
  )
# Model lasso coefficients
coef(lasso$finalModel, lasso$bestTune$lambda)
```

```
## 8 x 1 sparse Matrix of class "dgCMatrix"
##                         1
## (Intercept)  7.133002e+01
## Population   2.885396e-05
## Income       .           
## Illiteracy   .           
## Murder      -2.786323e-01
## HS.Grad      3.906142e-02
## Frost       -5.129102e-03
## Area         .
```


```r
# Build the elastic model
set.seed(123)
elastic <- train(
  Life.Exp ~., data = train.data, method = "glmnet",
  trControl = trainControl("cv", number = 10),
  tuneLength = 10
  )
# Model elastic coefficients
coef(elastic$finalModel, elastic$bestTune$lambda)
```

```
## 8 x 1 sparse Matrix of class "dgCMatrix"
##                         1
## (Intercept) 71.3086462184
## Population   0.0000256294
## Income       .           
## Illiteracy   .           
## Murder      -0.2700233930
## HS.Grad      0.0373016465
## Frost       -0.0044968250
## Area         .
```

Both the lasso and elastic models identify the same four `Population`, `Murder`, `HS.Grad`, and `Frost` predictors as the stepwise regression, meaning our model should incorporate these variables. 

## Model Tuning

We can therefore assume that these four components indeed represent the best predictors for life expectancy in the dataset. A quick check of these variables in a scatterplot matrix indicates no obvious issues of correlation, though it does highlight potential issues with the non-normal distribution of the `Population` predictor:


```r
ggscatmat(state, columns = c("Population", "Murder", "HS.Grad", "Frost"))
```

<img src="/docs/multi_regression/multi_regression_files/figure-html/unnamed-chunk-14-1.png" width="672" />

### Outliers

Returning to the issues with the state of Hawaii, we can see it still represents a leverage point in our Cook's Distance plot for a model built using the four predictors identified in the previous section:


```r
model2 <- lm(Life.Exp ~ Population + Murder + HS.Grad + Frost, data = state)
x <- ggally_nostic_cooksd(model2, ggplot2::aes(state$Murder, .cooksd, label=state.name))
x + geom_text(aes(label = state.abb, hjust=-0.25, vjust=0))
```

<img src="/docs/multi_regression/multi_regression_files/figure-html/unnamed-chunk-15-1.png" width="672" />

Note that by removing `Area`, Alaska is no longer present as an outlier in this graphic. Hawaii can be removed from the dataset so we can see how omitting this row affects the calculations:


```r
noHawaii <- state[-11, ]
model_noHawaii <- lm(Life.Exp ~ Population + Murder + HS.Grad + Frost, data = noHawaii)
summary(model_noHawaii)
```

```
## 
## Call:
## lm(formula = Life.Exp ~ Population + Murder + HS.Grad + Frost, 
##     data = noHawaii)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -1.48967 -0.50158  0.01999  0.54355  1.11810 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  7.106e+01  8.998e-01  78.966  < 2e-16 ***
## Population   6.363e-05  2.431e-05   2.618   0.0121 *  
## Murder      -2.906e-01  3.477e-02  -8.357 1.24e-10 ***
## HS.Grad      3.728e-02  1.447e-02   2.576   0.0134 *  
## Frost       -3.099e-03  2.545e-03  -1.218   0.2297    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.6796 on 44 degrees of freedom
## Multiple R-squared:  0.7483,	Adjusted R-squared:  0.7254 
## F-statistic: 32.71 on 4 and 44 DF,  p-value: 1.15e-12
```

Looking at the resultant statistics, a slightly lower Residual Standard Error of 0.7197 and higher Adjusted R<sup>2</sup> value of 0.7254 does not dramatically improve the overall efficiency of the our model. This means it is best to leave Hawaii in the dataset to prevent over-fitting.

### Transforming `Population` Predictor

One final adjustment is to see how a log transformation of the `Population` variable impacts our multiple regression model. The initial QQ plot for this predictor visually indicates a right-skewed distribution, with a Shapiro-Wilk p-value of <.05:


```r
qplot(sample = Population, data = state) + stat_qq_line()
```

<img src="/docs/multi_regression/multi_regression_files/figure-html/unnamed-chunk-17-1.png" width="672" />

```r
shapiro.test(state$Population)
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  state$Population
## W = 0.76999, p-value = 1.906e-07
```

Log transformation of this predictor yields a much more stable QQ line with a Shapiro-Wilk p-value > .05.


```r
state$PopulationLOG <- log(state$Population)
qplot(sample = PopulationLOG, data = state) + stat_qq_line()
```

<img src="/docs/multi_regression/multi_regression_files/figure-html/unnamed-chunk-18-1.png" width="672" />

```r
shapiro.test(state$PopulationLOG)
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  state$PopulationLOG
## W = 0.9748, p-value = 0.3585
```

We can then incorporate this new field into a separate regression model and look at the summary output:


```r
model3 <- lm(Life.Exp ~ PopulationLOG + Murder + HS.Grad + Frost, data = state)
summary(model3)
```

```
## 
## Call:
## lm(formula = Life.Exp ~ PopulationLOG + Murder + HS.Grad + Frost, 
##     data = state)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -1.41760 -0.43880  0.02539  0.52066  1.63048 
## 
## Coefficients:
##                Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   68.720810   1.416828  48.503  < 2e-16 ***
## PopulationLOG  0.246836   0.112539   2.193 0.033491 *  
## Murder        -0.290016   0.035440  -8.183 1.87e-10 ***
## HS.Grad        0.054550   0.014758   3.696 0.000591 ***
## Frost         -0.005174   0.002482  -2.085 0.042779 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.7137 on 45 degrees of freedom
## Multiple R-squared:  0.7404,	Adjusted R-squared:  0.7173 
## F-statistic: 32.09 on 4 and 45 DF,  p-value: 1.17e-12
```

Although this does marginally increase the `t-value` for the `Population` predictor, the overall impact on the model is negligible (`Model2` Adjusted R<sup>2</sup>: 0.7126, `Model3` Adjusted R<sup>2</sup>: 0.7173). As such, we can simply use the original `Population` variable as-is.

## Model Selection and Performance

With a firm grasp of the predictors that account for variance in life expectancy, we can lastly assess the performance of different models. Using predictions from our lasso and elastic models, we can see how well these perform on the test sets using the RSME and R<sup>2</sup> values as metrics:


```r
# Make lasso predictions
predictions <- lasso %>% predict(test.data)
# Model lasso prediction performance
data.frame(
  RMSE = RMSE(predictions, test.data$Life.Exp),
  Rsquare = R2(predictions, test.data$Life.Exp)
)
```

```
##        RMSE   Rsquare
## 1 0.7173416 0.7781383
```


```r
# Make elastic predictions
predictions <- elastic %>% predict(test.data)
# Model elastic prediction performance
data.frame(
  RMSE = RMSE(predictions, test.data$Life.Exp),
  Rsquare = R2(predictions, test.data$Life.Exp)
)
```

```
##      RMSE   Rsquare
## 1 0.71558 0.7847331
```


```r
models <- list(lasso = lasso, elastic = elastic)
resamples(models) %>% summary( metric = c("RMSE", "Rsquare"))
```

```
## 
## Call:
## summary.resamples(object = ., metric = c("RMSE", "Rsquare"))
## 
## Models: lasso, elastic 
## Number of resamples: 10 
## 
## RMSE 
##              Min.   1st Qu.    Median      Mean   3rd Qu.     Max. NA's
## lasso   0.4115675 0.4972837 0.7668623 0.7724632 0.9652196 1.192139    0
## elastic 0.4076371 0.5015034 0.7864021 0.7742010 0.9604124 1.231829    0
## 
## Rsquare 
##                Min.   1st Qu.    Median      Mean   3rd Qu.      Max. NA's
## lassod   0.02578738 0.4696152 0.7646330 0.6553759 0.9368338 0.9792684    0
## elasticd 0.03095748 0.4808654 0.7607484 0.6569412 0.9410070 0.9835805    0
```

When selecting the best model to use, we want to minimize the prediction error (RMSE) on the test set to ensure maximal predictive capabilities. The stepwise 4-predictor model yielded an RMSE of 0.784, while the two regularization methods provide similar levels of performance at 0.767 and 0.786. As the lasso model has the lowest median RMSE (0.767), this penalized regression model should be selected. However, all three models exhibit broadly similar performance.  

## Conclusions

The calculations above demonstrate that a lasso regression model including the `Population`, `Murder`, `HS.Grad`, and `Frost` predictors accounts for 76% (resampled median R<sup>2</sup>  = 0.764) of the variance in the `Life.Exp` outcome variable.

Some of the predictors initally removed from our regression model seem intuitive; the `Area` variable would seem to have little bearing on lifespan, while `Illiteracy` is not necessarily an indicator of susceptibility to violence. The removal of the `Income` predictor, however, is quite interesting. This is a factor that many would likely assume to play an important role in overall life expectancy as it could lead to prefential access to medical care, better quality dietary sources, and the ability to purchase property in desirable (typically safer) locations. This may relate to the time in which this data was originally gathered, and it would be useful to see how this compares to more modern figures.

It should come as no surprise that high `Murder` rates have a strong negative correlation with life expectancy, while `HS.Grad` rates are positively correlated with the `Life.Exp` outcome variable. Though `Population` might be expected to play a more prominent role in lifespans, the impact of this predictor is the weakest of the explanatory variables. Far and away the most unusual result of this exercise is the identification of `Frost` as a significant predictor of life expectancy, indicating the potential for harsh weather conditions to adversely affect population health even in the later 20<sup>th</sup> century. 

Further useful areas of exploration include the incorporation of demographic information into the dataset for comparative purposes and an investigation into longer term trends in public health. 
