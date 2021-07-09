# Please use "UTF-8" to open this file

rm(list = ls())
Sys.setlocale("LC_ALL","English")
#devtools::install_github("PMassicotte/gtrendsR") #should install this one instead
library(gtrendsR)
library(foreign)

geo <- c("TW") # Set Location
key <- c("武漢 肺炎","口罩","洗手","酒精","確診")

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

write.dta(monthly.data, "C:/nest/Dropbox/RA_research/COVID-19_impact/Google_trend/rawdata/google_trend_monthly.dta")

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

write.dta(daily.data, "C:/nest/Dropbox/RA_research/COVID-19_impact/Google_trend/rawdata/google_trend_daily.dta")
