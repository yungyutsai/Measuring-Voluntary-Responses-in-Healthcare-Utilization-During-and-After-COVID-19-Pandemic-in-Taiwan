# Please use "UTF-8" to open this file

rm(list = ls())
Sys.setlocale("LC_ALL","English")
devtools::install_github("PMassicotte/gtrendsR") #should install this one instead

library(gtrendsR)
library(foreign)

rawdata <- "/Users/yungyu/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/Github/data/rdata/google_trend" # Set raw data saved folders
geo <- c("TW") # Set Location
key <- c("武漢 肺炎","口罩","洗手","酒精","確診") # The corresponding Chinese terms of "Coronavirus," "mask," "wash hand," "sanitizer," and "confirmed cases" respectively.

whole <- "2014-01-01 2020-12-31"

# Get trends data (Monthly)
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

save.name <- paste0(rawdata,"/google_trend_monthly.dta")
write.dta(monthly.data,save.name)

# Get trends data (Daily)
time <- c("2014-01-01 2014-06-30","2014-07-01 2014-12-31",
          "2015-01-01 2015-06-30","2015-07-01 2015-12-31",
          "2016-01-01 2016-06-30","2016-07-01 2016-12-31",
          "2017-01-01 2017-06-30","2017-07-01 2017-12-31",
          "2018-01-01 2018-06-30","2018-07-01 2018-12-31",
          "2019-01-01 2019-06-30","2019-07-01 2019-12-31",
          "2020-01-01 2020-06-30","2020-07-01 2020-12-31") # Retrieve 6 months per inquiry

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

save.name <- paste0(rawdata,"/google_trend_daily.dta")
write.dta(daily.data,save.name)