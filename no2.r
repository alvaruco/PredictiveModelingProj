setwd("/Users/Jaime/Desktop/Master/PredictiveModeling/Project1/")
#setwd("C:/Users/alvaro/Desktop/Segundo_Semicuatrimestre/PredictiveModelling/Group_project")

library("psych")
library("MASS")
library("scatterplot3d")
library("pracma")
dev.off()

no2 = read.csv("NO2.csv ", col.names = c("particles", "carsHour", "temp2", "windSpeed", "tempDiff25to2", "windDir", "time", "day"))
attach(no2)
head(no2)

pairs.panels(no2, 
             method = "pearson", # correlation method
             hist.col = "#00146E",
             col = "red",
             lm = FALSE,
             ellipses = FALSE,
             smooth = FALSE,
             #pch = c(21,21)[class],
             #bg=my_cols[class],
             rug = FALSE,
             cex.cor = 5,
             scale = TRUE,
             density = TRUE  # show density plots
)

## WindDir Solucionado
clusterWindDir <- kmeans(windDir,2)$cluster

#car::scatterplotMatrix(no2, col = 1, regLine = list(col = 2), smooth = list(col.smooth = 4, col.spread = 4))

mod <- lm(particles ~ ., data = no2)
modBIC <- stepAIC(mod, k=log(length(particles)))


## Does residuals follow normal distribution?
plot(density(modBIC$residuals),col="red")
lines(col="blue",x = density(rnorm(n = 10000,sd=sd(modBIC$residuals))))
no2BIC <- no2[,c(1,2,3,4,5,7)]
head(no2BIC)

pairs.panels(no2BIC, 
             method = "pearson", # correlation method
             hist.col = "#00146E",
             col = "red",
             lm = FALSE,
             ellipses = FALSE,
             smooth = FALSE,
             #pch = c(21,21)[class],
             #bg=my_cols[class],
             rug = FALSE,
             cex.cor = 5,
             scale = TRUE,
             density = TRUE  # show density plots
)

summary(modBIC)

#############################################NEW##############################################
## Linear model with wind direction fixed

par(mfrow=c(1,2))
temp=data.frame("Direction"=no2$windDir,"Speed"=no2$windSpeed)
plot(x = temp$Speed*cos(temp$Direction/365),y = temp$Speed*sin(temp$Direction/365),pch=19,xlab = "",ylab = "")
no2$windDir <- clusterWindDir
plot(x = temp$Speed*cos(temp$Direction/365),y = temp$Speed*sin(temp$Direction/365),col=no2$windDir,pch=19,xlab = "",ylab = "")
dev.off() ### To reset the graphs

for (i in 1:nrow(no2)) {
  no2$windDir[i] <- no2$windDir[i]-1
}
head(no2)

## In this plot we can see that windDirection does not have an influence on the particles

pairs.panels(no2[,c(1,2,3,4,5,7,8)],
             method = "pearson", # correlation method
             hist.col = "#00146E",
             lm = FALSE,
             ellipses = FALSE,
             smooth = FALSE,
             pch = c(21,21)[clusterWindDir],
             bg=c("green", "red")[clusterWindDir],
             rug = FALSE,
             cex.cor = 5,
             scale = TRUE,
             density = TRUE  # show density plots
)
## As seen in the plot the Bayesian Information Criteria supresses the variable WindDirection
modClean1 <- lm(particles ~ ., data = no2)
summary(modClean1)

modCleanAIC1 <- stepAIC(modClean1, k = log(length(particles)))
summary(modCleanAIC1)
############################################################################################

##################################NEW#######################################
## Clean day by season. The day variable is measured as number of days from October 1. 2001
## October, November, December --> Autumn (2) 0-91; 366-457
## January, February, March --> Winter (3) 92-183; 458-549
## April, May, June --> Spring (0) 184-275; 549-608
## July, August, September --> Summer (1) 276-365
summary(day)
seasons <- day
for (i in 1:length(day)) {
  if ((day[i] >= 0 && day[i] <= 91) || (day[i] >= 366 && day[i] <= 457)) {
    seasons[i] <- "Autumn"
  }
  else if ((day[i] >= 92 && day[i] <= 183) || (day[i] >= 458 && day[i] <= 549)) {
    seasons[i] <- "Winter"
  }
  else if ((day[i] >= 184 && day[i] <= 275) || (day[i] >= 549 && day[i] <= 608)) {
    seasons[i] <- "Spring"
  }
  else if (day[i] >= 276 && day[i] <= 365) {
    seasons[i] <- "Summer"
  }
}
head(seasons)
no2$day <- as.factor(seasons)
## Like in the previous case it seems like there is not much relation between the season and the particles
pairs.panels(no2[,c(1,2,3,4,5,6,7)],
             method = "pearson", # correlation method
             hist.col = "#00146E",
             lm = FALSE,
             ellipses = FALSE,
             smooth = FALSE,
             pch = c(21,21,21,21)[as.factor(seasons)],
             bg=c("green", "red", "yellow", "blue")[as.factor(seasons)],
             rug = FALSE,
             cex.cor = 5,
             scale = TRUE,
             density = TRUE  # show density plots
)
as.factor(seasons)
no2$day <- relevel(no2$day, ref = "Spring")
## As expected the BIC gets rid of the season variable...
modClean2 <- lm(particles ~ ., data = no2)
summary(modClean2)
modCleanBIC2 <- stepAIC(modClean2, k = log(length(particles)))
summary(modCleanBIC2)
############################################################################################

##################################NEW#######################################
## We are going to try to prove that time has a trigonometric relation with carsHour
summary(time)
per <- max(time)
plot(carsHour~time)
timePlot <- linspace(1, 24, 1000)
lines(6.2 - 2.2*sin((2*pi/24)*(timePlot+1.8))~timePlot)
## Difficult to fit a model, with this I think we can show the trigonometric relation between time and carsHour
## which is enough to not use it
############################################################################################

######## NEW #########################################################
## Linear model without time and with the rest of the variables fixed
head(no2)
cleanModel <- lm(no2[,c(1,2,3,4,5,6,8)])
cleanModelBIC <- stepAIC(cleanModel, k = log(length(particles)))
summary(cleanModelBIC)
head(no2)
pairs.panels(no2[,c(1,2,3,4,5)],
             method = "pearson", # correlation method
             hist.col = "#00146E",
             lm = FALSE,
             ellipses = FALSE,
             smooth = FALSE,
             #pch = c(21,21,21,21)[as.factor(seasons)],
             #bg=c("green", "red", "yellow", "blue")[as.factor(seasons)],
             rug = FALSE,
             cex.cor = 5,
             scale = TRUE,
             density = TRUE  # show density plots
)

############################################## NEW ##############################################
## Check model assuptions
plot(cleanModelBIC) ### This returns various graphs that might help seeing if the model assumptions are met
##### Linearity -> Difficult to check, but we've been able to prove the trigonometric relation between
##### carsHour and time and we have got rid of it.

##### Error normality -> With the two graphs we can check that the residual errors are almos normal.
plot(density(cleanModelBIC$residuals),col="red")
lines(col="blue",x = density(rnorm(n = 10000,sd=sd(cleanModelBIC$residuals))))
plot(cleanModelBIC$residuals)
## The residual errors are "normal enough"
#####

##### Homoscedasticity -> The variance is approximately constant
ncvTest(cleanModelBIC)
#####
## Don't know how to check for independence, we might have to "see" it from the graph

#############################################################################

## particles vs carsHour (I could see a linear relation) -> Low R^2?
mod1 <- lm(particles ~ carsHour, data = no2)
summary(mod1)

library(car)
scatterplot(particles ~ carsHour, col = 1, regLine = FALSE, smooth = FALSE)
abline(mod1$coefficients, col = "red")
plot(density(mod1$residuals))
lines(density(rnorm(n=10000,sd=sd(mod1$residuals))),col="blue")
#abline(modBIC$coefficients[1:2], col = "green")

## particles vs temp2 (Cannot see a linear relation)
mod2 <- lm(particles ~ temp2, data = no2)
summary(mod2)

scatterplot(particles ~ temp2, col = 1, regLine = FALSE, smooth = FALSE)
abline(mod2$coefficients, col = "red")
plot(density(mod2$residuals))
lines(density(rnorm(n=10000,sd=sd(mod2$residuals))),col="blue")



## particles vs windSpeed (There is a linear relation)
mod3 <- lm(particles ~ windSpeed)
summary(mod3)

scatterplot(particles ~ windSpeed, col = 1, regLine = FALSE, smooth = FALSE)
abline(mod3$coefficients, col = "red")

## particles vs tempDiff25to2 (Cannot see a linear relation)
mod4 <- lm(particles ~ tempDiff25to2)
summary(mod4)

scatterplot(particles ~ tempDiff25to2, col = 1, regLine = FALSE, smooth = FALSE)
abline(mod4$coefficients, col = "red")

## particles vs windDir (Cannot see a linear relation) -> Probably should divide this varibale into two groups.
mod5 <- lm(particles ~ windDir)
summary(mod5)

scatterplot(particles ~ windDir, col = 1, regLine = FALSE, smooth = FALSE)
abline(mod5$coefficients, col = "red")

## particles vs time (This one might have sense just because the number of cars increases with the time)
mod6 <- lm(particles ~ time)
summary(mod6)

scatterplot(particles ~ time, col = 1, regLine = FALSE, smooth = FALSE)
abline(mod6$coefficients, col = "red")

scatterplot(carsHour ~ time, col = 1, regLine = FALSE, smooth = FALSE)

## particles vs day (This model does not even make sense at all)
mod7 <- lm(particles ~ day)
summary(mod7)

scatterplot(particles, day, col = 1, regLine = FALSE, smooth = FALSE)
abline(mod7$coefficients, col = "red")

## TODO:
# Split WindDir in two groups *****DONE*****
# Fix or get rid of day since it has a very weird shape ****DONE****
# Redo the multiple linear model with the fixed variables and only taking into account those that seem important
# Test that all model assumptions are met (i.e. error normality, etc)
# Try to fit a sin/cos regression function between carsHour and Time ****DONE****
# 1.- Descripcion general del dataset (Sacar estadisticos de cada variable) ******Almost Done*****
# 2.- Preprocesado -> windDir y day y time ****************DONE*****************
# 3.- Descripcion "Asi ha quedado el dataset"
# 4.- Probar modelo lineal (Comprobar que se cumplen las hipotesis del modelo lineal)
# 5.- Probar modelos no lineales (x^2+xy+y^2+x+y+intercept etc)
# 6.- Lasso y ridge regression

######################Descripcion General Dataset############3



##########Descriptive Analisis for each variable######################
head(no2)
str(no2[1:5,])
boxplot(sapply(no2[,sapply(no2,is.numeric)],scale))

str(no2)

box_plot<-function(data){
  par(mfrow=c(2,4))
  for (i in 1:length(data)){
    boxplot(data[,i],main=names(data)[i])
    text(x = 1.4,labels = round(boxplot.stats(data[,i])$stats,1),y = boxplot.stats(data[,i])$stats)
  }
}
box_plot(no2[,sapply(no2,class)!="factor"])


#Normalized data
dat=data.frame(sapply(no2,scale))
box_plot(dat)

variable_analysis<-function(data,chart_name="chart_name"){
  par(mfrow=c(1,2),oma=c(0,0,2,0))
  
  boxplot(data,main=names(data),title="Boxplot")
  text(x = 1.4,labels = round(boxplot.stats(data)$stats,1),y = boxplot.stats(data)$stats)
  
  #boxplot(scale(data),main=names(data))
  #text(x = 1.4,labels = round(boxplot.stats(scale(data))$stats,1),y = boxplot.stats(scale(data))$stats)
  
  plot(density(boxplot.stats((data))$stats),main = "",xlab = "")  
  
  mtext(chart_name,outer = T,cex=2)
}

#To be repeated with all variables
variable_analysis(no2[,1],names(no2)[1])

############################################################################################
############################################################################################
############################################################################################

#La primera es el azul, la segunda el mostaza - En funci?n de la direcci?n del viento
my_cols_wind <- c("#00AFBB", "#E7B800")
#En funci?n de las estaciones - azul_invierno - verde_primavera - naranja_verano - marron_oto?o
my_cols_season <- c("#194edf", "#0dd611","#eebd27","#a57942")
my_cols_season["Winter"]
str(season)

#Pre-processing data: 
# Dates: fix_dates[dates,season]
# Wind: wind_clus[wind_clus] 1 or 2 depending on the angle of the wind!


#--------------Ploting by Direction------------------
pairs(no2_clean,
      pch = c(21,21)[direction],
      bg=my_cols_wind[direction]
)

pairs(no2_clean[direction==1,],pch=c(21,21),bg=my_cols_wind[1])
pairs(no2_clean[direction==2,],pch=c(21,21),bg=my_cols_wind[2])

pairs.panels(no2[,-c(8)], 
             method = "pearson", # correlation method
             hist.col = "#00146E",
             col = "red",
             lm = FALSE,
             ellipses = FALSE,
             smooth = FALSE,
             pch = c(21,21)[direction],
             bg=my_cols_wind[direction],
             rug = FALSE,
             cex.cor = 5,
             scale = TRUE,
             density = TRUE  # show density plots
)

mod <- lm(particles ~ ., data = no2)
modBIC <- stepAIC(mod, k=2*log(length(particles)))

no2BIC <- no2[,c(1,2,3,4,5,7)]
head(no2BIC)

pairs.panels(no2BIC, 
             method = "pearson", # correlation method
             hist.col = "#00146E",
             col = "red",
             lm = FALSE,
             ellipses = FALSE,
             smooth = FALSE,
             #pch = c(21,21)[class],
             #bg=my_cols[class],
             rug = FALSE,
             cex.cor = 5,
             scale = TRUE,
             density = TRUE  # show density plots
)

summary(modBIC)

scatterplot(particles ~ carsHour, col = 1, regLine = FALSE, smooth = FALSE)
abline(modBIC$coefficients[1:2], col = "red")

scatterplot(particles ~ temp2, col = 1, regLine = FALSE, smooth = FALSE)
abline(a = mean(particles)+modBIC$coefficients[1], b = -0.01869914, col = "red")

scatterplot(particles ~ windSpeed, col = 1, regLine = FALSE, smooth = FALSE)
abline(a = mean(particles)+modBIC$coefficients[1], b = modBIC$coefficients[4], col = "red")

scatterplot(particles ~ tempDiff25to2, col = 1, regLine = FALSE, smooth = FALSE)
abline(modBIC$coefficients[1:2], col = "red")

scatterplot(particles ~ time, col = 1, regLine = FALSE, smooth = FALSE)
abline(modBIC$coefficients[1:2], col = "red")

