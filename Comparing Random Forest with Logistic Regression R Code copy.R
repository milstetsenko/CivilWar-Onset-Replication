
data=read.csv(file="/Users/milanastetsenko/Documents/Assignments/Sophomore Year/CS112/Final Project/dataverse_files/SambnisImp.csv") # data for prediction
# data for causal machanisms
data2<-read.csv("/Users/milanastetsenko/Documents/Assignments/Sophomore Year/CS112/Final Project/dataverse_files/Amelia.Imp3.csv")
library(randomForest) #for random forests
library(caret) # for CV folds and data splitting
library(ROCR) # for ROC plots
library(causaldrf) # for the continuos treatment estmation
library(BayesTree) # required as an addition to causaldrf
library(rbounds) #for check on the binary treatment - genetic matching


###Using only the 88 variables specified in the dataset
data.full<-data[,c("warstds", "ager", "agexp", "anoc", "army85", "autch98", "auto4",
        "autonomy", "avgnabo", "centpol3", "coldwar", "decade1", "decade2",
        "decade3", "decade4", "dem", "dem4", "demch98", "dlang", "drel",
        "durable", "ef", "ef2", "ehet", "elfo", "elfo2", "etdo4590",
        "expgdp", "exrec", "fedpol3", "fuelexp", "gdpgrowth", "geo1", "geo2",
        "geo34", "geo57", "geo69", "geo8", "illiteracy", "incumb", "infant",
        "inst", "inst3", "life", "lmtnest", "ln_gdpen", "lpopns", "major", "manuexp", "milper",
        "mirps0", "mirps1", "mirps2", "mirps3", "nat_war", "ncontig",
        "nmgdp", "nmdp4_alt", "numlang", "nwstate", "oil", "p4mchg",
        "parcomp", "parreg", "part", "partfree", "plural", "plurrel",
        "pol4", "pol4m", "pol4sq", "polch98", "polcomp", "popdense",
        "presi", "pri", "proxregc", "ptime", "reg", "regd4_alt", "relfrac", "seceduc",
        "second", "semipol3", "sip2", "sxpnew", "sxpsq", "tnatwar", "trade",
        "warhist", "xconst")]

###Changing the outcome variable into the Factor with two levels
data.full$warstds<-factor(
  data.full$warstds,
  levels=c(0,1),
  labels=c("peace", "war"))

set.seed(666)


                        
head(data.full)

#Slicing the data and doing 10k cross validation
#this is the input to the train() function performing the regression
tc<-trainControl(method="cv", 
                 number=10,#creates CV folds - 10 
    summaryFunction=twoClassSummary,#provides ROC summary stats in call to model
    classProb=TRUE)#specifying that this is classification algorithm
                 

logistic<-train(as.factor(warstds)~warhist+ln_gdpen+lpopns+lmtnest+ncontig+oil+nwstate
             +inst3+pol4+ef+relfrac,
             metric="ROC", #tweaking the output for easier ROC implementation
             method="glm",#regression 
             family="binomial",#indicating the Logistic Regression
             trControl=tc, #inputting thr 10-k-fold 
             data=data.full)

summary(logistic) #summary of the 10-k-fold logistic regression
logistic # CV summary statsand ROC percentage


confusionMatrix(logistic, norm="average", reference =  ) ### confusion matrix for war onsets




###Running Random Forest without CV to get OOB Error Rate - results not shown in paper###

model_rf<-train(as.factor(warstds)~., 
                metric="ROC", method="rf", 
                sampsize=c(30,90), #Downsampling the class-imbalanced DV
                importance=T, # Variable importance retained
                proximity=F, ntree=1000, # number of trees
                trControl=tc, data=data.full)




###ROC Plots for Different Models###
attach(data.full) #have to attach the data for type = probs to work

###Gathering info for ROC Plots: Uncorrected Logists and Random Forest###
logistic_predicted<-predict(logistic, data.full$warstds, type="prob")
RF_predicted <- predict(model_rf, data.full$warstds, type = "prob")

#getting the classifier evaluations to input into the performance function
prediction_log <- prediction(logistic_predicted$war, data.full$warstds)
prediction_RF <- prediction(RF_predicted$war, data$warstds)

#calcualting the performance of the models - what are the true 
#positive and false positive rates
perf_log <- performance(prediction_log,"tpr","fpr") #true and false positive rates
perf_RF <- performance(prediction_RF, "tpr", "fpr")



plot(perf_log, main="Logit and Random Forests")
plot(perf_RF, lty = 2, add = T)

legend(0.10, 0.25, c("Logistic regression -  0.76", "Random Forest 0.91" ), lty=c(1,2), bty="n", 
       cex = .75)



####
####
###
###Extension to the paper###
##Continuous Treatment

dta <- na.omit(data2) #there are some NA values in the code 

tail(names(sort(table(dta$year))), 1) #checking the most repeated value in "year" - most data from 2000 

tail(names(sort(table(war_dta$year))), 1) #checking most popular year with most war onsets - 1991 

### Subsetting the data to choose the most 
###IF range 1980 - 2000 
dta_range <- subset(dta, year >= "1980" & year <= "2000") #2867 countries in this range 
summary(dta_range)
war_dta_range <- subset(dta_range, dta_range$warstds == "1") #48 countries with civil war onset in this year 
summary(war_dta_range)

gdp_positive <- subset(dta_range, gdpgrowth >= "0" & gdpgrowth <= "1") #to check if it works with positive outcome 
dta_range2 <- subset(dta, year == "1991") #2867 countries in this range 


#seeing the max and the min of the dgpgrowth to input into grid_val_2
min(dta_range2$gdpgrowth)
max(dta_range2$gdpgrowth)




grid_val_2 =seq(-0.26, .35, by = 0.01)# parameter for the bart_test function
#it is the range of the treatment variable that we want to choose to see the
#effect on the outcome, chose all data



#turning the outcome into factor for the function to run
dta_range2$warstds<- as.factor(dta_range2$warstds)


#running the estimation algorithm
bart_estimate_2 <- bart_est(Y = warstds, treat = gdpgrowth,
                            outcome_formula = warstds ~ life + infant + milper + dem + seceduc + trade + partfree, data = dta_range2, grid_val = grid_val_2)


bart_estimate_2$param#outputting the parameters to the estimates - how the outcome 
#grows with treatment growing


#plotting the line of parameters
sample_index <- sample(1:1000, 100)
plot(dta_range$gdpgrowth[sample_index], dta_range$warstds[sample_index], xlab = "GDP Growth",
     ylab = "Civil War Onset", ylim = c(-0.5, 1.5),
     col = "green",
     main = "Bart estimate effect is constant")
lines(grid_val_2, bart_estimate_2$param,
      lty = 2,
      lwd = 2,
      col = "red")









#### Checking the efficiency of the continuous treamtent
#Whether we implemented it correctly and the same outcomes for different treatment
#did not occur because of computational mistake

#Running matching with genetic matching with binary treatment - positive or negative
#growth
#subsetting the data and changing the treatment to binary
dta_range_binary <- dta_range
dta_range_binary$gdpgrowth<- ifelse(dta_range_binary$gdpgrowth <0, 1,0)                    


#matching
attach(dta_range_binary)
X <- cbind(life,infant,milper,dem,seceduc,trade, partfree)
genout <- GenMatch(X = X, Tr = dta_range_binary$gdpgrowth, unif.seed = 123, int.seed = 92485, estimand= "ATT", wait.generations = 3)
matchout.gen <- Match(X = X, Y=dta_range_binary$warstds, Tr = dta_range_binary$gdpgrowth, Weight.matrix=genout, estimand = "ATT")
mb.out1 <- MatchBalance(gdpgrowth ~ life + infant + milper + dem + seceduc + trade + partfree, data = dta_range_binary, match.out = matchout.gen, nboots=1000)


#checking the treatment effect
summary(matchout.gen) #1% only 




