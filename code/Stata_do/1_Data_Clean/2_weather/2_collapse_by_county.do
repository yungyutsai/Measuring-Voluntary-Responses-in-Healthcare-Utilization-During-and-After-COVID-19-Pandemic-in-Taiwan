clear
set more off

forv i = 2014(1)2020{

use "$wdata/weather/CWB_data_`i'.dta", clear

collapse (mean)Temperature Precp SunShine (max)T_Max (min)T_Min, by(city date date_n)
sort city date

lab var city "縣市" //Station City
lab var date "觀測日期" //Date of observation
lab var Temperature "平均氣溫(℃)" //Temperature (in Celsius)
lab var T_Max "當日最高氣溫(℃)" //Max Temperature
lab var T_Min "當日最低氣溫(℃)" //Min Temperature
lab var Precp "平均降水量(mm)" //Precipitation
lab var SunShine "平均日照時數(hour)" //Number of Hours of Sunshine

replace city = subinstr(city,"臺","台",.) //"臺" and "台" are interchangeable in Chinese

sort city date

merge m:1 date using "$wdata/calendar/yearweek_table.dta"
drop if _m == 2
drop _m date_string

collapse (mean)Temperature Precp SunShine (max)T_Max (min)T_Min, by(city yearweek week)
gen year = floor(yearweek/100)

order year week yearweek city 

lab var city "縣市" //Station City
lab var Temperature "平均氣溫(℃)" //Temperature (in Celsius)
lab var T_Max "當日最高氣溫(℃)" //Max Temperature
lab var T_Min "當日最低氣溫(℃)" //Min Temperature
lab var Precp "平均降水量(mm)" //Precipitation
lab var SunShine "平均日照時數(hour)" //Number of Hours of Sunshine

save "$wdata/weather/CWB_city_WHOWeek`i'.dta", replace

}
