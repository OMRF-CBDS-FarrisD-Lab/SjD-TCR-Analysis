#Load the required R packages, following comands can be run on RStudio 
library(dplyr)
library(ggplot2)
library(stats)

#Store the table containing unique CDR3β sequences detected in healthy controls and their respective mean frequency across all controls clearing the clonotype sampling threshold in a data frame 'df_controls_rgrsn' 
df_controls_rgrsn <- read.table("plot_input_rgrsn_hc.txt", header = TRUE, sep = "\t")

#Convert the pGen and mean frequency values to log scale and check the top 10 lines
df_controls_rgrsn_log <- df_controls_rgrsn %>% log10() 
df_controls_rgrsn_log %>% head()

#Reepeat the above steps on lines 5 and 9 for cases and check
df_cases_rgrsn <- read.table("plot_input_rgrsn_p.txt", header = TRUE, sep = "\t")
df_cases_rgrsn_log <- df_cases_rgrsn %>% log10()
df_cases_rgrsn_log %>% head()

#Add a third column 'group' to the above data frames and assign descriptor values "case" and "control" 
#to case and control data tables, respectively   
df_cases_rgrsn_log$group <- "case"
df_controls_rgrsn_log$group <- "control"

#Combine the two data sets on cases and controls into a single table 
df_input_rgrsn_log <- rbind(df_controls_rgrsn_log, df_cases_rgrsn_log)

#Remove any rows with an absolute ZERO value (log converted to Inf) corresponding to mean frequency, these are sequences exclusively detected in cases and HCs that did not clear the clonoytpe sampling threshold
df_input_rgrsn_log <- df_input_rgrsn_log[which(df_input_rgrsn_log$mean_freq!="Inf"),]
df_input_rgrsn_log <- df_input_rgrsn_log[which(df_input_rgrsn_log$mean_freq!="-Inf"),]

#Repeat the step on line #25 for pGen values as well
df_input_rgrsn_log <- df_input_rgrsn_log[which(df_input_rgrsn_log$pGen!="-Inf"),]
df_input_rgrsn_log <- df_input_rgrsn_log[which(df_input_rgrsn_log$pGen!="Inf"),]

#Store the modifeid combined input into a new variable data2
data2 = df_input_rgrsn_log 

#Check input containing one column of pGen and one column of corresponding mean_frequency. 
data2 %>% head()
data2 %>% tail()


model <- glm(data=data2, pGen~mean_freq+group+group*mean_freq)
#A generalized linear model (glm function) is fitted to 'data2' and stored to 'model'. 'data2' specifies that the dataframe containing variables pGen & Mean-frequency (mean_freq), divided into 'case' and 'control' groups 

#glm tries to model pGen (response variable) of CDR3s as a function of predictor variables i) mean_freq ii) group, and iii) interaction between the two   

#    i)mean_freq is a numeric variable representing average frequency of CDR3s
#   ii)group is a categorical variable that defines the case and control 'categories' in the data
#  iii)interaction term allows the model to incorporate the effect of mean_freq on the pGen of CDR3s based on different 'levels' of group i.e. case or control   

#[pgen~mean_freq+group+group*mean_freq]:defines relationship between response and predictor variables 
# The + sign indicates inclusion of main effects, and the * sign indicates inclusion of interaction terms. So, group * freq includes both the main effects of group and freq, as well as their interaction.

#summarizes coefficients of 'model':
summary(model)

#---------------------------------------------------------------------
#                        Estimate Std. Error t value Pr(>|t|)
#(Intercept)            -5.673063   0.028593 -198.41   <2e-16 ***
#mean_freq               0.606841   0.004537  133.74   <2e-16 ***
#groupcontrol            1.810960   0.042853   42.26   <2e-16 ***
#mean_freq:groupcontrol  0.290378   0.006782   42.82   <2e-16 ***

#Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#---------------------------------------------------------------------

#Results summary:
#1. Estimate: This column shows the estimated coefficients for every predictor variable and interaction term as follows:

#2. The intercept term (Intercept) has an estimated coefficient of -5.673063 (β0)

#3. mean_freq has an estimated coefficient of 0.606841 (β1), indicating that for every one-unit increase in mean_freq, response variable 'pGen' increases by approximately 0.606841 units holding all other variables constant.

#4. groupcontrol has an estimated coefficient of 1.810960 (β2), indicates that pGen is expected to be approximately 1.810960 units higher for the control group compared to the reference group (cases) when holding all other variables constant.

#5. mean_freq:groupcontrol i.e. interaction term has an estimated coefficient (β3) of 0.290378. Suggests that relationship between mean_freq and pGen differs between the two 'groups' as follows:
#For one-unit increase in mean_freq, pGen is expected to increase by approximately 0.290378 units more in the control group compared to the reference group.
#Std. Error: provides the standard errors associated with each coefficient estimate. It measures the variability or uncertainty in the coefficient estimates.

#6. t value: The t value is calculated by dividing the coefficient estimate by its standard error. It measures the signal-to-noise ratio in the data and indicates how many standard deviations the coefficient estimate is from zero.

#7. Pr(>|t|): This column presents p-values associated with each coefficient estimate. Indicates the probability of observing a t value as extreme as, or more extreme than, the observed t value, assuming that the null hypothesis (the coefficient is zero) is true. Lower p-values suggest greater evidence against null hypothesis and are interpreted as indicative of a significant relationship between predictor and response variables.

#In summary, coefficients table provides information on the estimated effects of predictor variables and their interaction on a response variable, as well as the uncertainty associated with these estimates.
#The significance of each predictor variable and interaction term can be assessed based on the associated p-values.

#Plot the glm model for case and control CDR3s

#Prepare data for plotting
df_cases_for_plotting <- df_cases_rgrsn_log[, -3]
df_controls_for_plotting <- df_controls_rgrsn_log[, -3]

#Store trendline equation for HC data in 'equation_hc'  
equation_hc <- expression(paste("pGen = -3.86 + (0.897219 x Mean Abundance)"))
#Refer to methods for equation 

#Set label titles 
x_label <- expression(log[10]*"(CDR3β Mean Abundance)")
y_label <- expression(log[10]*"(Generation Probability)")

#Plot HC data and trendline 
df_graph_controls_mod <- ggplot(df_controls_for_plotting, aes(x = mean_freq, y = pGen)) +
  geom_point() +
  geom_abline(slope = summary(model)$coefficients[2, 1] + summary(model)$coefficients[4, 1], 
              intercept = summary(model)$coefficients[1, 1] + summary(model)$coefficients[3, 1], 
              col = "red", 
              lwd = 1.5) +
  ggtitle("Healthy Controls") + 
  xlab(x_label) +
  ylab(y_label) + 
  theme(plot.title = element_text(hjust = 0.5, size = 24),
        axis.text.x = element_text(size = 16, color = "black"),
        axis.text.y = element_text(size = 16, color = "black"),
        axis.title = element_text(size = 16),
        plot.subtitle = element_text(size = 18)) +
    labs(subtitle = equation_hc)  
  png('test_control.png', type = "cairo")
        df_graph_controls_mod
        dev.off()


#Store trendline for cases as mentioned on line 90
equation_p <- expression(paste("pGen = -5.67 + (0.606841 x Mean Abundance)"))

#Plot SjD case data and trendline
df_graph_cases_mod <- ggplot(df_cases_for_plotting, aes(x = mean_freq, y = pGen)) +
  geom_point() +
  geom_abline(slope = summary(model)$coefficients[2,1], 
            intercept = summary(model)$coefficients[1,1], 
            col = "red", 
            lwd = 1.5) +
  ggtitle("SjD cases") + 
  xlab(x_label) +
  ylab(y_label) + 
theme(plot.title = element_text(hjust = 0.5, size = 24),
        axis.text.x = element_text(size = 16, color = "black"),
        axis.text.y = element_text(size = 16, color = "black"),
        axis.title = element_text(size = 18),
        plot.subtitle = element_text(size = 18)) +
    labs(subtitle = equation_p)  
png('test_case.png', type = "cairo")
df_graph_cases_mod
dev.off() 

#Now, we perform random sampling of the case and control data to pick smaller sub-samples 
#We will then run multiple iterations of the glm model on these to plot a distribution of interaction term coefficients and associated p values 
#This distribution will determine whether the effect of mean_freq on pGen differs between cases and controls for the randomly-sampled data picked over several iterations   

#select subsets from case and control groups and assign to 'cases' and 'controls'  
cases=subset(data2, group=="case")
controls=subset(data2, group=="control")

#This initializes an empty matrix called 'model2' with 10000 rows and 2 columns.
model2=matrix(data = NA, nrow = 10000, ncol = 2)

#The loop for (j in 1:10000) runs 10000 times, where each iteration does the following:
#'resample1' and 'resample2' are generated by randomly sampling 10000 row names from the data frames 'cases' and 'controls', respectively, without replacement.
for (j in 1:10000) {
  resample1=sample(row.names(cases), 10000, replace = F)
  resample2=sample(row.names(controls), 10000, replace = F)
  
  #'casesamp' and 'contsamp' are created by subsetting 'cases' and 'controls' using the randomly sampled row names. 'samp' is created by combining 'casesamp' and 'contsamp' using rbind.
  casesamp=cases[resample1,]
  contsamp=controls[resample2,]
  samp=rbind(casesamp, contsamp)
  

#A logistic regression model (glm) is fitted to samp with the formula pGen~mean_freq+group+mean_freq*group. The summary of the model is stored in sampmodel.

sampmodel=summary(glm(data=samp, pGen~mean_freq+group+mean_freq*group))
 
#assigning values from the sampmodel object to the model2:
#model2[j, 1:2]: you are assigning values to rows j and columns 1 to 2 of the object model2 - updating specific elements within a matrix or data frame.
#sampmodel$coefficients[4, c(1, 4)]: it extracts values from the fourth row and the first and fourth columns of the coefficients attribute of the sampmodel object and assign to specific rows and columns in model2
  
  model2[j,1:2]=sampmodel$coefficients[4,c(1,4)]
  
  }

#Coefficients of 'model2'
summary(model2)

#Store mean beta 3 value in a dataframe
mean_slope_model2 <- mean(model2[,1])

# Open TIFF device to plot effect size (beta3) distribution 
tiff('model2_beta3.tiff', type = "cairo", width = 6, height = 6, units = "in", res = 600)
# Create the histogram with customized font sizes
hist(model2[,1], 
     breaks = 20, 
     xlab = "Slope (n = 10,000 CDR3β sequences)", 
     ylab = "Frequency", 
     main = "Distribution of β3 across sub-samples",
     cex.main = 1.4,  # Font size for the main title 
     cex.lab = 1.4,   # Font size for the axis labels 
     cex.axis = 1.4)  # Font size for the axis text 

# Add vertical line for mean slope
abline(v = mean_slope_model2, col = "red", lty = 2, lwd = 3)

# Close the TIFF device
dev.off()

# Open TIFF device to plot p value distribution 
tiff('model2_pvalues.tiff', type = "cairo", width = 6, height = 6, units = "in", res = 600)
hist(model2[,2], 
     breaks = 20, 
     xlab = "P value (n = 10,000 CDR3β sequences)", 
     ylab = "Frequency", 
     main = "P value distribution",
     cex.main = 1.4,  # Font size for the main title
     cex.lab = 1.4,   # Font size for the axis labels 
     cex.axis = 1.4)  # Font size for the axis text
abline(v = 0.05, col = "red", lwd = 3)

# Close the TIFF device
dev.off()

