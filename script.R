require(tidyverse)
require(dplyr)
require(ggplot2)
require(lubridate)

# read data
unzip("activity.zip")
activitydata <- read_csv("activity.csv")

activitydata$date <- 
        activitydata$date %>%
        ymd() # make date the correct format with lubridate

# group by date
activitydata <- group_by(activitydata, date)

# get mean no. of steps per date
steps_day <- 
        summarise(activitydata, 
                  mean = mean(steps, 
                              na.rm = TRUE))
# produce histogram
hist(steps_day$mean)
