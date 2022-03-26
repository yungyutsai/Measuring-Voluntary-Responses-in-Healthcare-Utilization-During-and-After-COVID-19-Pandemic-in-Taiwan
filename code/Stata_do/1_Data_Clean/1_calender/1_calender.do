** Read the Taiwan Holiday Calendar
import excel "$rdata/calendar/calendar.xlsx", sheet("Sheet1") firstrow clear
drop if date == .

save "$wdata/calendar/calendar.dta", replace

** Read the WHO Year Week Calendar
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
egen key_ym = max(ym), by(yearweek)
replace key_ym = 200812 if yearweek == 200853

gen y2 = floor(yearweek/100) //The year of week (Sometimes December is counted toward the next year; Sometimes January is counted toward last year)
egen m2 = min(m), by(yearweek) //The month of week
replace m2 = 12 if (y2 == y & m == 12 & d > 23) | (y2 == y - 1 & m == 1 & d < 8) //for bridge from December to January
egen v1 = min(week), by(y2 m2) //The minimum week of month
gen week_of_month = week - v1 + 1 //The number of week within the month

keep date date_st yearweek week key_ym week_of_month
order date date_st yearweek week key_ym week_of_month

keep if yearweek < 202112
keep if yearweek >= 201401

merge 1:1 date using "$wdata/calendar/calendar.dta"
keep if _m == 3
drop _m

gen workday = holiday == 0
egen sumworkdays = sum(workday), by(yearweek)

gen cny = 1 if note == "初一" //First day of Chinese New Year
gen cnyweek = week if cny == 1 //The week according to Lunar Calendar
gen year = floor(yearweek/100)
egen cweek = sum(cnyweek), by(year)
replace cweek = week - cweek

save "$wdata/calendar/yearweek_table.dta", replace



