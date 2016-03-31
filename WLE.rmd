# Weight Lifting Exercise Prediction

## Summary

The goal of this project is by using a machine learning technique to predict the manner in which 20 preselected moves from 6 different participants performed the exercise: correct or incorrect and if incorrect what was the type of mistake.

The data for the project comes from the original study performed by Velloso, E.; Bulling, A.; Gellersen, H.; Ugulino, W.; Fuks, H. : "Qualitative Activity Recognition of Weight Lifting Exercises."

The original study is focusing on analyzing the quality of weight lifting excercise. The data is collected from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. The participants were asked to perform one set of 10 repetitions of the Unilateral Dumbbell Biceps Curl in five different fashions: exactly according to the specification (Class A), throwing the elbows to the front (Class B), lifting the dumbbell only halfway (Class C), lowering the dumbbell only halfway (Class D) and throwing the hips to the front (Class E).

Read more: http://groupware.les.inf.puc-rio.br/har#ixzz44AOnZzNY
More information is available from the website here: http://groupware.les.inf.puc-rio.br/har (see the section on the Weight Lifting Exercise Dataset). 


The training data for this project are available here:

https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv

The test data are available here:

https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv

##Exploring the data

First download the files from the links and read them into R.

```{r}
wletrain<-read.csv("./WLETRAIN.csv")
wletest<-read.csv("./WLETEST.csv")
```

The dataset consist of 160 variables 1) feature of Euler angles (roll, pitch and yaw) 2)Each of the 4 IMUs providing 3-axes accelerator, gyroscope and magnetometer data 3) Eight features calculated for the Euler angels for eacn of the 4 sensors (mean, variance, sd, max, min, amplitude, kurtosis, skewness)

For the purpose of the analysis I clean the columns with the variables from group 3 above. They are only populated for varable "new_window"== yes and they are not part of the test dataset (shown as NAs)

```{r,results='hide',message=FALSE}
library(dplyr)

Wtrain<-select(wletrain, c(3, 4, 7:11, 37:49, 60:68, 84:86, 102, 113:124, 140, 151:160))
head(Wtrain)
dim(Wtrain)

Wtest<-select(wletest, c(3, 4, 7:11, 37:49, 60:68, 84:86, 102, 113:124, 140, 151:160))
head(Wtest)
dim(Wtest)
```

##Creating the model. 

First we create data partitions- dividing the original training data for the project into 75%training and 25%testing partitions.

```{r}
library(caret) 
inTrain <- createDataPartition(y=Wtrain$classe,
                               p=0.75, list=FALSE)
training <- Wtrain[inTrain,]
testing <- Wtrain[-inTrain,]
dim(training)
```
Considering the high number of variables not being linearly related, we can not use GLM model. Instead we use classification model such as classification trees. For high accuracy and low out of sample error we choose to build a random forest "rf" model. Further for processing the 75% of the partition the "rf" is using bootstrapping with resampling for the cross validation of the data.
```{r,cache=TRUE}
set.seed(44)
modelFit <- train(classe ~.,data=training, method="rf")
print(modelFit$finalModel)
```
## Error estimation
The finalModel shows that the in sample error rate is as low as 0.05%. For out of sample error we can apply the model to the testing partition (the 25%) and compare to the actual "classe"variable from testing$classe/ the result from the table below shows only two errors from 4904 - for an out of sample estimated error rate of 0.04%
```{r,cache=TRUE}
set.seed(45)
print(modelFit)
table(predict(modelFit,testing),testing$classe)
```
Predicting the 20 diferrent test cases
```{r,message=FALSE}
predict(modelFit,Wtest)
```

```{r, cache=TRUE}
library(ggplot2)
qplot(predict(modelFit,testing),classe, data=testing)
```

