# CivilWar-Onset-Replication
Random Forest and Logistic Regression replication


# Prediction

The following project evaluates and extends the findings of Muchlinski, David & Siroky, David & He, Jingrui & Kocher, Matthew (2015) research. The project includes the ROC curve comparing the logistic regression with 10-fold-CV with Random Forest to check the model's precision. 

I extended the findings by estimating the causal effects of GDP growth on civil war onset and showed that the variable doesn't affect the outcome causally despite being a strong predictor.

<img width="254" alt="Logistic Regression" src="https://user-images.githubusercontent.com/65287937/106389782-f1334480-63ed-11eb-979e-ed5d1f60f365.png">

# Causal Inference

Civil war onset dependent variable took a binary value of 0 when no civil war started in a given
year in a country, and 1 when it did. GDP growth is the treatment variable and is expressed as a
percentage relative to the year before. Countries where the civil war started, were likely to have
negative GDP growth. I have identified seven key covariates, variables that explain some
variability in the outcome. They are life expectancy, infant mortality, military capability,
democracy, secondary education, trade openness, autonomy.​ These were more likely to influence
4 the civil war onset. 


Given the GDP growth treatment takes on continuous values, I used the causaldrf R package to estimate the Average Dose Response Functions (ADRF). Bart fits a response surface to the whole dataset but does not require fitting a treatment model. That makes the treatment effect unbiased. We have chosen this technique because it has proven to be efficient compared to its competitors (Schafer, & Galagate, 2015). The largest drawback was the computational power it requires, which limited our analysis and made us reduce the data significantly to be able to run. This is where we are keeping hesitant with the inference from the causaldrf package.


<img width="287" alt="Causal Inference" src="https://user-images.githubusercontent.com/65287937/106389867-64d55180-63ee-11eb-94d9-1eaeea155dce.png">



# Conclusions
As the GDP Growth changes from -26% to 35%, the treatment effect remains the same: at 1.21068. So, the GDP Growth across this range of percentage does not affect the outcome when the treatment effect is not biased (refer to Figure 4). Because there is no change in the coefficient as the treatment effect grows( it remains constant at 1.210681), there is no significant treatment effect as GDP grows or declines. That disproves the claim made by the authors of the paper that
5 GDP Growth has the highest causal effect on the outcome. ​
