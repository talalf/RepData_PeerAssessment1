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

# report mean and median daily step counts of imputed data

mean(imputed_steps_day$total)
median(imputed_steps_day$total)

# produce a histogram

hist(imputed_steps_day$total,
     breaks = c(seq(from = 0, to = 25000, by = 2500)),
     ylim = c(0,25),
     main = "Daily step count (imputed data)",
     xlab = "Total steps per day")

# check for weekend differences

# add day variable and weekend variable
activity_impute <- activity_impute %>% 
        mutate(day = weekdays(date))

for(i in 1:nrow(activity_impute)) {
        ifelse(activity_impute[i,"day"] == "Saturday" | activity_impute[i,"day"] == "Sunday",
               activity_impute[i,"weekend"] <- "Weekend",
               activity_impute[i,"weekend"] <- "Weekday"
        )
}

# grouping by interval then by weekend or weekday status
activity_impute <- activity_impute %>%
        group_by(interval,weekend)

# calculating means for each interval per weekend/weekday status
grouped_imputed_data <- activity_impute %>% 
        summarise(mean_daily_steps = mean(steps))

# graphing
ggplot(data = grouped_imputed_data, aes(x = interval,y = mean_daily_steps)) +
        geom_line() +
        facet_wrap(~weekend, ncol = 1) +
        labs(x = "Interval", y = "Number of steps")