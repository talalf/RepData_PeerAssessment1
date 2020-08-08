require(tidyverse)
require(dplyr)
require(ggplot2)
require(lubridate)

# read data
unzip("activity.zip")
activitydata <- read_csv("activity.csv")

activitydata$date <- 
        activitydata$date %>%
        ymd() # formate date with lubridate

# group by date
activitydata <- group_by(activitydata, date)

# get mean no. of steps per date
steps_day <- 
        summarise(activitydata, 
                  mean = mean(steps, 
                              na.rm = TRUE))
# plot the histogram
hist(steps_day$mean,
     main = "Mean number of steps taken per day",
     xlab = "Steps per day")

# group by time interval
activitydata <- group_by(activitydata, interval)

steps_interval <-
        summarise(activitydata,
                  mean = mean(steps,
                              na.rm = TRUE))

# produce a plot of mean no. of steps per time interval
barplot(steps_interval$mean,
        names.arg = steps_interval$interval,
        xlab = "Interval",
        ylab = "Number of steps",
        main = "Mean number of steps per interval")

# identify the interval with the highest mean no. of steps

steps_interval %>%
        filter(mean == max(mean)) %>%
        select(interval)

# impute missing values by mean for that interval

# count number of rows with missing data

sum(is.na(activitydata$steps))

# impute missing data

activity_impute <- activitydata

for(i in 1:nrow(activity_impute)) {
        if(is.na(activity_impute[i,"steps"])) {
                intv <- as.numeric(activity_impute[i,"interval"])
                activity_impute[i,"steps"] = as.numeric(steps_interval[steps_interval$interval==intv,"mean"])
        }
}

# group by date
activity_impute <- group_by(activity_impute, date)

# summarise total steps per day

imputed_steps_day <- summarise(activity_impute,
                               total = sum(steps))
