# Please use "UTF-8" to open this file

rm(list = ls())
Sys.setlocale("LC_ALL","English")
#devtools::install_github("PMassicotte/gtrendsR") #should install this one instead
library(gtrendsR)
library(foreign)

geo <- c("US","US-WA","US-WA-819") # Set Location
key <- c("coronavirus","covid","mask","wash hand","sanitizer","confirmed case")

whole <- "2014-01-01 2020-12-31"

# get trends data
for(x in geo){
  for(y in key){
    trends <- gtrends(y, geo = x, time = whole, tz = "Etc/GMT+8")$interest_over_time
    data <- trends[,1:4]
    if(x == geo[1] & y == key[1]){
      monthly.data <- data
    }
    else{
      monthly.data <- rbind(monthly.data,data)
    }
  }
}

write.dta(monthly.data, "/Users/Tina/YourPath/Dropbox/RA_research/COVID-19_impact/Google_trend/rawdata/google_trend_monthly_US.dta")

time <- c("2014-01-01 2014-06-30","2014-07-01 2014-12-31",
          "2015-01-01 2015-06-30","2015-07-01 2015-12-31",
          "2016-01-01 2016-06-30","2016-07-01 2016-12-31",
          "2017-01-01 2017-06-30","2017-07-01 2017-12-31",
          "2018-01-01 2018-06-30","2018-07-01 2018-12-31",
          "2019-01-01 2019-06-30","2019-07-01 2019-12-31",
          "2020-01-01 2020-06-30","2020-07-01 2020-12-31")

# get trends data
for(x in geo){
  for(y in key){
    for(z in time){
      tryCatch({ 
        trends <- gtrends(y, geo = x, time = z, tz = "Etc/GMT+8")$interest_over_time
        data <- trends[,1:4]
        if(x == geo[1] & y == key[1] & z == time[1]){
          daily.data <- data
        }
        else{
          daily.data <- rbind(daily.data,data)
        }
      }, error=function(e){})
    }
  }
}

write.dta(daily.data, "/Users/Tina/YourPath/Dropbox/RA_research/COVID-19_impact/Google_trend/rawdata/google_trend_daily_US.dta")
