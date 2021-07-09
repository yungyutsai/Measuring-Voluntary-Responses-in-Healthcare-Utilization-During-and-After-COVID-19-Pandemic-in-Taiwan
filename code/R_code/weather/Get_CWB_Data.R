rm(list = ls())

### Required Package ###
library(xml2)   # for function "read_html"
library(rvest)  # for function "html_table", "minimal_html"
library(httpuv) # for function "encodeURI"
library(RCurl)  # for function "getURL"
library(haven)  # for function "write_dta"

Sys.setlocale("LC_ALL","English") # Need to change language to English (though the tables going to be loaded are in Chinese...)

### Get List of Station ###
URL <- 'https://e-service.cwb.gov.tw/wdps/obs/state.htm?fbclid=IwAR0hqTflupJsnhtox7lrhcT3XG95wet7DOlLXwOPEPYhCMZqD7cbd3rtIHw'
html <- read_html(URL)
tables <- html_table(html, fill = TRUE) # Get all tables in the html
station.list <- tables[[1]] # Get the first table in the tables list (there is only one)
station.list <- station.list[,-12:-13] # Remove the last two columns (not required)
# lable variables
colnames(station.list) <- c("station_no","station_name","altitude","latitude","longitude",
                            "city","address","open_date","close_date","note","old_no")

# The first character of "station_no" should be "4" or "C"
# Remove unnecessary rows (the heads)
station.list$check_cd <- substr(station.list$station_no, 1, 1) 
station.list <- subset(station.list,station.list$check_cd == "4" | station.list$check_cd == "C")

station.list$open_date  <- as.Date(station.list$open_date, format = "%Y/%m/%d")
station.list$close_date <- as.Date(station.list$close_date, format = "%Y/%m/%d")

start.time <- Sys.time()
# Loop by Years
for(y in c(2014:2020)){
  Data.Start.Date <- as.Date(paste0(y,"-01-01"))
  Data.End.Date <- as.Date(paste0(y,"-12-31"))
  
  # Extract Stations which are opened in the observation period
  station.list.needed <- subset(station.list,station.list$open_date < Data.End.Date &
                                  (is.na(station.list$close_date) | station.list$close_date > Data.Start.Date))
  
  ### Read HTML Tables ###
  # Generate Dates List
  date.list <- seq(Data.Start.Date, Data.End.Date, by = "days")
  date.list <- format(as.Date(date.list), "%Y-%m") # Turn date list into month format
  date.list <- unique(date.list) # Keep only unique one
  # Basic Website URL
  Site <- "https://e-service.cwb.gov.tw/HistoryDataQuery/MonthDataController.do?command=viewMain"
  
  # Loop from the first station to the last
  for(i in c(1:length(station.list.needed$station_no))){
    no <- station.list.needed$station_no[i]
    name <- station.list.needed$station_name[i]
    name.encode <- encodeURI(name)
    name.encode <- gsub("%","%25",name.encode)
    for(j in date.list){
      URL <- paste0(Site,"&station=",no,"&stname=",name.encode,"&datepicker=",j)
      tryCatch({ # Some URLs may failed to be load, skip these
        Sys.setlocale("LC_ALL","English") # Need to change language to English (though the tables going to be loaded are in Chinese...)
        webpage <- getURL(URL) # Because this website is created by javascript, we need to getURL first
        html <- minimal_html(webpage) # similiar as read_html, but can work with the result of getURL
        tables <- html_table(html, header = F) # Get all tables in the html
        table <- tables[[2]] # Get the second table in the tables list (the first is a menu)
        colname <- as.character(table[3,]) # Extract column name from the third row (replace as 2 if want chinese name instead)
        colname <- gsub(" ","_",colname) # Stata does not allow variable names with space, replace them
        table <- as.vector(table[-1:-3,]) # Remove first three rows (not required)
        colnames(table) <- colname # lable variables names
        table$date <- paste0(j,"-",table[,1]) # generate variable of date
        table$station_no <- station.list.needed$station_no[i] # generate variable of station number
        table$station_name <- station.list.needed$station_name[i] # generate variable of station name
        if(is.data.frame(data) == F){
          data <- table # if "data" not exists, create a new one
        } else {
          data <- rbind(data,table) # if "data" exists, append new table with it
        }
      }, error=function(e){})
    }
  }
  
  # Keep required date period
  data <- subset(data,data$date >= Data.Start.Date & data$date <= Data.End.Date)
  # Merge daily data with station information
  data <- merge(data,station.list,by = c("station_no","station_name"))
  # Assigned filed saved path and name
  save.name <- paste0("/Users/Tina/YourPath/Dropbox/RA_research/COVID-19_impact/TW_temperature/rawdata/daily/CWB_data_",y,".dta")
  # Save data as Stata format
  write_dta(data,save.name)
  rm(data)
}

end.time <- Sys.time()

end.time - start.time