clear
set more off

forv i = 2014(1)2020{
use "$rdata/weather/CWB_data_`i'.dta", clear

gen station_type = 0
replace station_type = 1 if substr(station_no,1,2) == "46"
replace station_type = 2 if substr(station_no,1,2) == "C0"
replace station_type = 3 if substr(station_no,1,2) == "C1"

lab de station_type 1 "中央氣象局地面氣象站" 2 "中央氣象局自動氣象站" 3 "中央氣象局自動雨量站"
lab val station_type station_type
**1 地面氣象站：全部觀測資料
**2 自動氣象站：測站氣壓、氣溫、相對溼度、風速、風向、降水量資料
**3 自動雨量站：降水量

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

lab var station_no "測站編號"
lab var station_name "測站名稱"
lab var station_type "測站類型"
lab var address "測站地址"
lab var city "測站所在縣市"
lab var altitude "測站海拔高度(公尺)"
lab var longitude "測站經度"
lab var latitude "測站緯度"
lab var open_date "測站資料起始日期"
lab var close_date "測站撤站日期"
lab var note "測站備註"
lab var date "觀測日期"
lab var StnPres "測站氣壓(hPa)"
lab var SeaPres "海平面氣壓(hPa)"
lab var StnPresMax "測站最高氣壓(hPa)"
lab var StnPresMaxTime "測站最高氣壓時間"
lab var StnPresMin "測站最低氣壓(hPa)"
lab var StnPresMinTime "測站最低氣壓時間"
lab var Temperature "氣溫(℃)"
lab var T_Max "最高氣溫(℃)"
lab var T_Max_Time "最高氣溫時間"
lab var T_Min "最低氣溫(℃)"
lab var T_Min_Time "最低氣溫時間"
lab var Td_dew_point "露點溫度(℃)"
lab var RH "相對溼度(%)"
lab var RHMin "最小相對溼度(%)"
lab var RHMinTime "最小相對溼度時間"
lab var WS "風速(m/s)"
lab var WD "風向(360degree)"
lab var WSGust "最大陣風(m/s)"
lab var WDGust "最大陣風風向(360degree)"
lab var WGustTime "最大陣風風速時間"
lab var Precp "降水量(mm)"
lab var PrecpHour "降水時數(hour)"
lab var PrecpMax10 "最大十分鐘降水量(mm)"
lab var PrecpMax10Time "最大十分鐘降水量起始時間"
lab var PrecpHrMax "最大六十分鐘降水量(mm)"
lab var PrecpHrMaxTime "最大六十分鐘降水量起始時間"
lab var SunShine "日照時數(hour)"
lab var SunShineRate "日照率(%)"
lab var GloblRad "全天空日射量(MJ/㎡)"
lab var VisbMean "能見度(km)	"
lab var EvapA "A型蒸發量(mm)"
lab var UVI_Max "日最高紫外線指數"
lab var UVI_Max_Time "日最高紫外線指數時間"
lab var Cloud_Amount "總雲量(0~10)"

order 	station_no station_name station_type address city altitude longitude ///
		latitude open_date close_date note date date_n StnPres-Cloud_Amount
keep 	station_no station_name station_type address city altitude longitude ///
		latitude open_date close_date note date date_n StnPres-Cloud_Amount

compress

save "$wdata/weather/CWB_data_`i'.dta", replace
}

