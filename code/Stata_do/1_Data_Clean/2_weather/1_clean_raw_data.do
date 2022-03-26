clear
set more off

forv i = 2014(1)2020{
use "$rdata/weather/CWB_data_`i'.dta", clear

gen station_type = 0
replace station_type = 1 if substr(station_no,1,2) == "46"
replace station_type = 2 if substr(station_no,1,2) == "C0"
replace station_type = 3 if substr(station_no,1,2) == "C1"

** Type of weather station
lab de station_type 1 "中央氣象局地面氣象站" 2 "中央氣象局自動氣象站" 3 "中央氣象局自動雨量站"
lab val station_type station_type
**1 = Ground Weather Station 地面氣象站：全部觀測資料
**2 = Automatic Weather Station 自動氣象站：測站氣壓、氣溫、相對溼度、風速、風向、降水量資料
**3 = Automatic Rainfall Observation Station 自動雨量站：降水量

capture rename PrecpMax60 PrecpHrMax
capture rename PrecpMax60Time PrecpHrMaxTime

destring altitude longitude latitude StnPres SeaPres StnPresMax StnPresMin ///
		 Temperature T_Max T_Min Td_dew_point RH RHMin WS WD WSGust WDGust ///
		 Precp PrecpHour PrecpMax10 PrecpHrMax SunShine SunShineRate GloblRad ///
		 EvapA UVI_Max Cloud_Amount, force replace

gen date2 = date(date, "20YMD")
rename date date_n
rename date2 date
format date open_date close_date %tdCCYYNNDD
replace date_n = subinstr(date_n,"-","",.)
destring date_n, replace

drop if open_date > date | close_date < date

foreach x of varlist *Time{
gen `x'2 = clock(`x', "20YMD hm")
drop `x'
rename `x'2 `x'
format `x' %tCHH:MM
} 

lab var station_no "測站編號" //Station Number
lab var station_name "測站名稱" //Station Name
lab var station_type "測站類型" //Station Type
lab var address "測站地址" //Station Address
lab var city "測站所在縣市" //Station City
lab var altitude "測站海拔高度(公尺)" //Altitude (m)
lab var longitude "測站經度" //Longitude
lab var latitude "測站緯度" //Latitude
lab var open_date "測站資料起始日期" //Start date of data record
lab var close_date "測站撤站日期" //Closure data of station
lab var note "測站備註" //Note
lab var date "觀測日期" //Date of observation
lab var StnPres "測站氣壓(hPa)" //Station Pressure (hpa)
lab var SeaPres "海平面氣壓(hPa)" //Sea Pressure (hpa)
lab var StnPresMax "測站最高氣壓(hPa)" //Station Max Pressure (hpa)
lab var StnPresMaxTime "測站最高氣壓時間" //Time of Station Max Pressure
lab var StnPresMin "測站最低氣壓(hPa)" //Station Min Pressure (hpa)
lab var StnPresMinTime "測站最低氣壓時間" //Time of Station Min Pressure
lab var Temperature "氣溫(℃)" //Temperature (in Celsius)
lab var T_Max "最高氣溫(℃)" //Max Temperature
lab var T_Max_Time "最高氣溫時間" //Time of Max Temperature
lab var T_Min "最低氣溫(℃)" //Min Temperature
lab var T_Min_Time "最低氣溫時間" //Time of Min Temperature
lab var Td_dew_point "露點溫度(℃)" //Dew Point Temperature
lab var RH "相對溼度(%)" //Relative humidity
lab var RHMin "最小相對溼度(%)" //Min Relative humidity
lab var RHMinTime "最小相對溼度時間" //Time of Min Relative humidity
lab var WS "風速(m/s)" //Wind Speed (m/s)
lab var WD "風向(360degree)" //Wind Direction (360 degree)
lab var WSGust "最大陣風(m/s)" //Max Wind Speed
lab var WDGust "最大陣風風向(360degree)" //Direction of Max Wind Speed
lab var WGustTime "最大陣風風速時間" //Time of Max Wind Speed
lab var Precp "降水量(mm)" //Precipitation
lab var PrecpHour "降水時數(hour)" //Number of Hours of Precipitation
lab var PrecpMax10 "最大十分鐘降水量(mm)" //Max Precipitation per 10 mins
lab var PrecpMax10Time "最大十分鐘降水量起始時間" //Times of Max Precipitation per 10 mins
lab var PrecpHrMax "最大六十分鐘降水量(mm)" //Max Precipitation per 60 mins
lab var PrecpHrMaxTime "最大六十分鐘降水量起始時間" //Time of Max Precipitation per 60 mins
lab var SunShine "日照時數(hour)" //Number of Hours of Sunshine
lab var SunShineRate "日照率(%)" //Sunshine Rate
lab var GloblRad "全天空日射量(MJ/㎡)" //Global Horizontal Irradiance
lab var VisbMean "能見度(km)	" //Visibility
lab var EvapA "A型蒸發量(mm)" //Type A Evaporation
lab var UVI_Max "日最高紫外線指數" //Max Ultra-violet Index
lab var UVI_Max_Time "日最高紫外線指數時間" //Time of Max Ultra-violet Index
lab var Cloud_Amount "總雲量(0~10)" //Total Cloud Amount

order 	station_no station_name station_type address city altitude longitude ///
		latitude open_date close_date note date date_n StnPres-Cloud_Amount
keep 	station_no station_name station_type address city altitude longitude ///
		latitude open_date close_date note date date_n StnPres-Cloud_Amount

compress

save "$wdata/weather/CWB_data_`i'.dta", replace
}

