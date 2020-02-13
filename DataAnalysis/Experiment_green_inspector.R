library(ggplot2)
library(reshape)
library(e1071)
library(effsize)
library(car)
library(dunn.test)
library(FSA)
require(plyr)
require(gridExtra)
library(DescTools)
# Install these packages if they are not already in your system
install.packages("gridExtra")
install.packages("ggplot2")
install.packages("reshape")
install.packages("e1071")
install.packages("effsize")
install.packages("dunn.test")
install.packages("FSA")
install.packages("gridExtra")
install.packages("car")
install.packages("openxlsx")

# To get a dataframe with all the data of the webapges and their energy consumed on each run,
# Call the function get_energy_data(dir_path) where dir_path is the path to the directory with the name of the device in the output files.
# There is an example at the end of the file



#Given a dataframe with the webpages and their energy consumption on each iteration, returns a new data frame with the webpages and the mean of their energy consumption
get_mean_data<-function(data){
  mean_data <- data.frame("Webpage"=character(),"Mean_energy_consumption"=double(),stringsAsFactors = TRUE)
  #mean_data <- data.frame("Webpage"=character(),"Energy_consumption"=double(),stringsAsFactors = FALSE)
  for (webpage in levels(data$Webpage)) {
    webpage_data <- data[which(data$Webpage == webpage),]
    webpage_mean <- mean(webpage_data$Energy_consumption)
    mean_data <- rbind(mean_data,data.frame("Webpage"=webpage,"Mean_energy_consumption"=webpage_mean))
  }
  return(mean_data)
}

#Creates a dataframe with the webpages, performance category, performance score and time to interactive
#The categories are obtained with python script get_categories.py and they are added manually.
get_lighthouse_data<-function(){
  performance_data <- data.frame("Webpage"=character(),"Performance_score"=double(),"Performance"=character(),stringsAsFactors = TRUE)
  #performance_data <- data.frame("Webpage"=character(),"Performance"=character(),stringsAsFactors = FALSE)
  
  performance_data <- rbind(performance_data,data.frame("Webpage"="yandexru","Performance_score"=0.83,"Performance"="Good","Time_interactive"=5070.721))
  performance_data <- rbind(performance_data,data.frame("Webpage"="xnxxcom","Performance_score"=0.8,"Performance"="Good","Time_interactive"=5839.8585))
  performance_data <- rbind(performance_data,data.frame("Webpage"="popadsnet","Performance_score"=0.94,"Performance"="Good","Time_interactive"=2756.281))
  performance_data <- rbind(performance_data,data.frame("Webpage"="microsoftcom","Performance_score"=0.86,"Performance"="Good","Time_interactive"=3775.443))
  performance_data <- rbind(performance_data,data.frame("Webpage"="xvideoscom","Performance_score"=0.76,"Performance"="Good","Time_interactive"=6610.909))
  performance_data <- rbind(performance_data,data.frame("Webpage"="youtubecom","Performance_score"=0.75,"Performance"="Good","Time_interactive"=6091.047))
  performance_data <- rbind(performance_data,data.frame("Webpage"="askcom","Performance_score"=0.94,"Performance"="Good","Time_interactive"=3364.1665))
  
  performance_data <- rbind(performance_data,data.frame("Webpage"="paypalcom","Performance_score"=0.63,"Performance"="Average","Time_interactive"=5062.576))
  performance_data <- rbind(performance_data,data.frame("Webpage"="instagramcom","Performance_score"=0.69,"Performance"="Average","Time_interactive"=5609.32))
  performance_data <- rbind(performance_data,data.frame("Webpage"="tianyacn","Performance_score"=0.52,"Performance"="Average","Time_interactive"=5156.5285))
  performance_data <- rbind(performance_data,data.frame("Webpage"="twittercom","Performance_score"=0.48,"Performance"="Average","Time_interactive"=7372.841))
  performance_data <- rbind(performance_data,data.frame("Webpage"="applecom","Performance_score"=0.45,"Performance"="Average","Time_interactive"=6926.777))
  performance_data <- rbind(performance_data,data.frame("Webpage"="quoracom","Performance_score"=0.59,"Performance"="Average","Time_interactive"=7745.406))
  performance_data <- rbind(performance_data,data.frame("Webpage"="whatsappcom","Performance_score"=0.63,"Performance"="Average","Time_interactive"=7255.729))
  
  performance_data <- rbind(performance_data,data.frame("Webpage"="coccoccom","Performance_score"=0.22,"Performance"="Poor","Time_interactive"=14360.126))
  performance_data <- rbind(performance_data,data.frame("Webpage"="theguardiancom","Performance_score"=0.43,"Performance"="Poor","Time_interactive"=13140.6175))
  performance_data <- rbind(performance_data,data.frame("Webpage"="ettodaynet","Performance_score"=0.04,"Performance"="Poor","Time_interactive"=16075.1635))
  performance_data <- rbind(performance_data,data.frame("Webpage"="hao123com","Performance_score"=0.17,"Performance"="Poor","Time_interactive"=12862.1185))
  performance_data <- rbind(performance_data,data.frame("Webpage"="cnncom","Performance_score"=0.01,"Performance"="Poor","Time_interactive"=32485.614))
  performance_data <- rbind(performance_data,data.frame("Webpage"="amazonawscom","Performance_score"=0.13,"Performance"="Poor","Time_interactive"=26959.452))
  performance_data <- rbind(performance_data,data.frame("Webpage"="chinacom","Performance_score"=0.08,"Performance"="Poor","Time_interactive"=14128.0095))
  
  return(performance_data)
}

get_merged_data<-function(data){
  mean_data <- get_mean_data(data)
  performance_data <- get_lighthouse_data()
  merged_data <- merge(mean_data,performance_data,by = "Webpage")
  
  return(merged_data)
}

##################################################
# GREENSPECTOR
##################################################

get_green_inspector_data<-function(file_name){
  green_raw_data<-read.csv(file = file_name,header = TRUE)
  green_data <- data.frame("Webpage"=character(),"Energy_consumption"=double(),stringsAsFactors = TRUE)
  i=1
  for(webpage in colnames(green_raw_data)){
    for(data in green_raw_data[,i]){
      if(webpage != "quoracom" || data < 400){ # This condition ommits the outlier in the 5th iteration of the experiment for the webpage quora.com
        green_data <- rbind(green_data,data.frame("Webpage"=webpage,"Energy_consumption"=data))
      }
    }
    i = i+1
  }
  return(green_data)
}


######################################################################


# Must update the directory to your own folder.  Pay special attention to your system's
#   representation of directories. For windows, use escape sequences for slashes and make sure
#   to use absolute paths rather than relative paths. This operation takes a long time to finish. let loading take place
#   before performing other operations.  
green_data<-get_green_inspector_data("./measured_energy.csv")
data<-green_data
data
summary(data)
sd(data$Energy_consumption)

# Visualize the data using Histograms, qqnorm and qqplot

histo_raw <-qplot(data$Energy_consumption, geom="histogram", xlab = "Energy Consumption (joules)", ylab = "Density", col = I("White"))

qqplot_raw <-ggplot(data.frame(y = data$Energy_consumption), aes(sample = y)) +
  stat_qq() + stat_qq_line(col="red", lty=2) + ylab("Energy Consumption Sample Quantile (joules)") + 
  xlab("Normal Theoretical Quantile")

grid.arrange(histo_raw, qqplot_raw, ncol=2)


# Perform the summary of the Energy Consumption data
summary(data$Energy_consumption)  

  # Perform the standard deviation of the Energy Consumption data
sd(data$Energy_consumption)  


# Test the data for normality -- Fail
shapiro.test(data$Energy_consumption)
# Test for skewness
skewness(data$Energy_consumption)

# Manipulating the data to check if skewness can be fixxed
energy_squared <-data$Energy_consumption ^ 2
energy_natural_log <- log(data$Energy_consumption)        # performs natural log
energy_reciprocal <- 1/ data$Energy_consumption

# Check the skewness of each transformation
skewness(energy_squared)
skewness(energy_natural_log)
skewness(energy_reciprocal)


## Visualize the reciprocal of the data -- No major improvement
histo_reciprocal <- qplot(energy_reciprocal, geom="histogram", xlab = "Reciprocal of Energy Consumption (1/ joules)", ylab = "Density", col = I("White"))
qqplot_reciprocal <- ggplot(data.frame(y = energy_reciprocal), aes(sample = y)) +
  stat_qq() + stat_qq_line(col="red", lty=2)+ ylab("Energy Consumption Sample Quantile\n(1/ joules)") + 
  xlab("Normal Theoretical Quantile") 

grid.arrange(histo_reciprocal, qqplot_reciprocal, ncol=2)

## Visualize the square of the data -- No major improvement
hist_sqr <- qplot(energy_squared, geom="histogram", xlab = "Square of Energy Consumption (joules ^ 2)", ylab = "Density", col = I("White"))
qqplot_sqr <- ggplot(data.frame(y = energy_squared), aes(sample = y)) +
  stat_qq() + stat_qq_line(col="red", lty=2)+ ylab("Energy Consumption Sample Quantile (joules ^ 2)") + 
  xlab("Normal Theoretical Quantile") 

grid.arrange(hist_sqr, qqplot_sqr, ncol=2)

## Visualize the log of the data -- Promising
hist_log <- qplot(energy_natural_log, geom="histogram",  xlab = "Natural Log of Energy Consumption Ln(joules)", ylab = "Density", col=I("White"))
qqplot_log <- ggplot(data.frame(y = energy_natural_log), aes(sample = y)) +
  stat_qq() + stat_qq_line(col="red", lty=2)+ ylab("Energy Consumption Sample Quantile Ln(joules )") + 
  xlab("Normal Theoretical Quantile") 

grid.arrange(hist_log, qqplot_log, ncol=2)

  # Test the data for normality of the log -- Fail
shapiro.test(energy_natural_log)
ks.test(x=energy_natural_log, "pnorm", mean(energy_natural_log), sd(energy_natural_log) )

# Test for skewness -- Substantially lower but still skewed
skewness(energy_natural_log)

# We conclude that even with data manipulation, the energy consumption is not normal.
#       We perform kruskal wallis (non-parametric test)

Performance_data = get_lighthouse_data()
energy_consumption_values = data
energy_with_performance = join(Performance_data, energy_consumption_values, by="Webpage", type="inner")

# View A scatter plot of the data per Performance Level
View(energy_with_performance)

p <- ggplot(data.frame(y = energy_with_performance$Energy_consumption), aes(x = energy_with_performance$Performance, y=y, sample = y, color = energy_with_performance$Performance)) +
  labs(title="Scatter Plot of Performance Level versus Energy Consumption", x="Performance Level",  y = "Energy Consumption (joules)", color = "Performance Level")+
  geom_point() 
p

# View a scatter plot of the data per Performance Score
ggplot(data.frame(y = energy_with_performance$Energy_consumption), aes(x = energy_with_performance$Performance_score, y=y, sample = y, color = energy_with_performance$Performance)) +
  labs( x="Performance Score",  y = "Energy Consumption (joules)", color = "Performance Level")+
  geom_point()



# View Box Plot of the data per Performance Score
ggplot(data.frame(y = energy_with_performance$Energy_consumption), aes(x = (energy_with_performance$Performance), y=y, sample = y, fill = (energy_with_performance$Performance))) +
  labs(x="Performance Level",  y = "Energy Consumption (joules)", fill = "Performance Level")+
  geom_boxplot() + scale_x_discrete(breaks=c("Poor", "Average", "Good"), 
                                    labels=c("Poor", "Average", "Good"))



# View Box Plot of Each Website versus its energy consumption per trial

ggplot(data.frame(y = energy_with_performance$Energy_consumption), aes(x = energy_with_performance$Webpage, y=y, sample = y, fill = energy_with_performance$Performance)) +
  theme(axis.text.x = element_text(angle= -75, hjust = 0, size = 11))+
  labs(title="Boxplot: Energy Consumption per Web app", x="Web app",  y = "Energy Consumption (joules)", fill = "Performance Level")+
  geom_boxplot() + scale_x_discrete(limits= rev(levels(energy_with_performance$Webpage)))



rank_values <- data.frame("Performance"=character(), "Rank" = numeric(), stringsAsFactors = TRUE)
rank_values <- rbind(rank_values,data.frame("Performance"="Good","Rank"=3))
rank_values <- rbind(rank_values,data.frame("Performance"="Average","Rank"=2))
rank_values <- rbind(rank_values,data.frame("Performance"="Poor","Rank"=1))

energies_with_ranks = join(energy_with_performance, rank_values, by="Performance", type="inner")

# Make an analysis of variance for Energy consumption values with performance as a 
#   factor
kruskal.test(energy_with_performance$Energy_consumption, energy_with_performance$Performance)


# Perform a Dunn post-hoc test on the individual performance groups 
#   (effectively performing 3 * (3-1) / 2 pairwise tests) on the individual
#   performance groups.  Apply Holms correction to correct for multiple tests:
# https://www.rdocumentation.org/packages/FSA/versions/0.8.20/topics/dunnTest
dunnTest(Energy_consumption ~ Performance, data = energies_with_ranks,method="bonferroni")

 dunn.test(x=energies_with_ranks$Energy_consumption, g = energies_with_ranks$Performance, method = "Bonferroni",list=TRUE)



# Make an analysis of Correlion which is non-parametric.
#   Perform it between the ranks and the Energy COnsumption (Ranks must be ordered 
#   Such that high performance has a higher value than lower performance)
cor.test(energies_with_ranks$Energy_consumption,energies_with_ranks$Rank, method="spearman")

# Make an analysis of th3e Effect size
energy_good_performance <- energies_with_ranks[energies_with_ranks$Performance == "Good", ]
energy_average_performance <- energies_with_ranks[energies_with_ranks$Performance == "Average", ]
energy_poor_performance <- energies_with_ranks[energies_with_ranks$Performance == "Poor", ]

# Make a Density Plot for the Performance Levels and Energy Consumption
ggplot(energies_with_ranks, aes(energies_with_ranks$Energy_consumption, fill = Performance) ) +
  geom_density(alpha = 0.4)   + xlim(0, 250)+ labs( x = "Energy Consumption (joules)", y = "Density") 


#cliff.delta( energies_with_ranks$Energy_consumption, energies_with_ranks$Performance_score, formula=Energy_consumption ~ Performance_score, data =energies_with_ranks)
cliff.delta( energy_good_performance$Energy_consumption, energy_average_performance$Energy_consumption )
cliff.delta( energy_good_performance$Energy_consumption, energy_poor_performance$Energy_consumption )
cliff.delta( energy_average_performance$Energy_consumption, energy_poor_performance$Energy_consumption )


# Test
shapiro.test(data[which(data$Webpage == "amazonawscom"),]$Energy_consumption)[[2]]

par(mfrow=c(3,4));
#Generate a QQplot and histogram of each webpage with its energy consumption
for(webpage in levels(data$Webpage)){
  webpage_data <- data[which(data$Webpage == webpage),]
  qqnorm(webpage_data$Energy_consumption, main = webpage, ylab = "Energy Consumption")
  qqline(webpage_data$Energy_consumption)
  hist(webpage_data$Energy_consumption, main = webpage, xlab = "Energy Consumption")
  
  p_value <- shapiro.test(webpage_data$Energy_consumption)[[2]]
  cat(webpage,p_value)
  print("")
}

#mean_data <- get_mean_data(data)
#performance_data <- get_lighthouse_data()

merged_data <- get_merged_data(data)
merged_data


#Checking normality of the data on each category
par(mfrow=c(3,3));
for(performance in levels(merged_data$Performance)){
  performance_data <- merged_data[which(merged_data$Performance == performance),]
  
  qqnorm(performance_data$Mean_energy_consumption, main = performance, ylab = "Mean energy consumption")
  qqline(performance_data$Mean_energy_consumption)
  hist(performance_data$Mean_energy_consumption, main = performance, xlab = "Mean energy consumption")
  boxplot(performance_data$Mean_energy_consumption)
  
  p_value <- shapiro.test(performance_data$Mean_energy_consumption)[[2]]
  cat(performance,p_value)
  print("")
}


# 
# Energy_with_log = data
# Energy_with_log$log = energy_natural_log
# Energy_Log_with_Performance = join(Performance_data, Energy_with_log, by="Webpage", type="inner")




# 
# energy_aov <- lm(Energy_consumption~Performance, data = Energy_Log_with_Performance)
# anova(energy_aov)
# 
# summary(energy_aov)
# qqnorm(residuals(energy_aov))
# confint(energy_aov)
