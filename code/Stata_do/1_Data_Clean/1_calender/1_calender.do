***人事行政總處行事曆
import excel "$rdata/calendar/calendar.xlsx", sheet("工作表1") firstrow clear
drop if date == .

save "$wdata/calendar/calendar.dta", replace

local url = "https://raw.githubusercontent.com/cv04356015/WhoYearWeekMaker/master/output.csv"

import delimited `url', varnames(1) clear

rename date date_string
gen y = substr(date_string,1,4)
gen m = substr(date_string,6,2)
gen d = substr(date_string,9,2)
destring y m d, replace
gen date = mdy(m,d,y)
format date %tdCCYYNNDD
gen week = mod(yearweek,100)

gen ym = y * 100 + m
egen key_ym = min(ym), by(yearweek)
replace key_ym = 200812 if yearweek == 200853

gen y2 = floor(yearweek/100) //該年週算第幾年 (有時候12月會算下一年，1月會算上一年)
egen m2 = min(m), by(yearweek) //該年週的起始月份
replace m2 = 12 if (y2 == y & m == 12 & d > 23) | (y2 == y - 1 & m == 1 & d < 8) //每年12月的週跨到1月時的特殊處裡
egen v1 = min(week), by(y2 m2) //該月最小的週數
gen week_of_month = week - v1 + 1 //該週是該月第幾週

keep date date_st yearweek week key_ym week_of_month
order date date_st yearweek week key_ym week_of_month

keep if year < 202112

merge 1:1 date using "$wdata/calendar/calendar.dta"
//keep if _m == 3
drop _m

gen workday = holiday == 0
egen sumworkdays = sum(workday), by(yearweek)

save "$wdata/calendar/yearweek_table.dta", replace



