forv i = 102(1)109{ //Equivalent to A.D. 2013 to 2020
local y = substr("0"+"`i'",-3,3)
if `i' == 110 {
local a = 4
}
else {
local a = 12
}
forv j = 1(1)`a'{
local m = substr("0"+"`j'",-2,2)
if `i' <= 102{
local sheet = "`i'"+"`m'"
}
else{
local sheet = "`m'"
}

dis "Year `i' Month `j'"
import excel "$rdata/population/m1s2-`y'00.xls", sheet("`sheet'") clear
destring C-DT, replace force

rename A city
rename C population
rename D popagegroup1
rename J popagegroup2
rename P popagegroup3
rename V popagegroup4
rename AB popagegroup5
rename AH popagegroup6
rename AN popagegroup7
rename AT popagegroup8
rename AZ popagegroup9
rename BF popagegroup10
rename BL popagegroup11
rename BR popagegroup12
rename BX popagegroup13
rename CD popagegroup14 //age 65
rename CJ popagegroup15
rename CP popagegroup16
rename CV popagegroup17
rename DB popagegroup18
rename DH popagegroup19
gen popagegroup20 = DN + DT

forv group = 1(1)20{
	replace popagegroup`group' = popagegroup`group' / population
}

replace city = city[_n+1] if B == "計" //Total rows
keep if B == "計" //Total rows
keep city pop*
replace city = subinstr(city," ","",.)
drop if city == "總　　計" | city == "臺灣省" | city == "福建省" | city == "臺灣地區" //Total and Subtotal Rows
** Counties and Cities that ever Changed Names
replace city = "新北市" if city == "臺北縣"
replace city = "桃園市" if city == "桃園縣"
replace city = "臺中市" if city == "臺中縣"
replace city = "臺南市" if city == "臺南縣"
replace city = "高雄市" if city == "高雄縣"
destring pop*, replace

collapse (sum)population (mean)popage*, by(city) //Collapse by cities/counties

gen year = `i'
gen month = `j'
order y m

save "$wdata/population/`i'_`j'.dta", replace

}
}

import excel "$rdata/population/county_gender_ratio.xlsx", sheet("`sheet1'") clear

** Extract the year and month
gen year = substr(A,1,3) if strpos(A,"年") ~= 0 & strpos(A,"月") ~= 0 //"年"=year; "月"=month
destring year, replace
gen month = usubstr(A,-3,2) if strpos(A,"年") ~= 0 & strpos(A,"月") ~= 0
destring month, replace

** Fill in all rows
replace year = year[_n-1] if year == .
replace month = month[_n-1] if month == .

destring B, replace force //Column B = gender ration (female = 100)
drop if B == .
rename B gender_ratio

drop if strpos(A,"年") ~= 0 //The rows of date
rename A city //Column A = city/county
replace city = usubinstr(city,"臺","台",.) //"臺" and "台" are interchangeable in Chinese

compress
save "$wdata/population/gender_ratio.dta", replace

import excel "$rdata/population/county_education_level.xlsx", sheet("`sheet1'") clear

** Extract the year and month
gen year = substr(A,1,3) if strpos(A,"性別總計") == 0 //Rows of Date
destring year, replace

** Fill in all rows
replace year = year[_n-1] if year == .

foreach x of varlist B-M{
	replace `x' = subinstr(`x',",","",.)
	destring `x', replace force
}

drop if B == .


gen city = usubstr(A,1,3) if strpos(A,"性別總計") ~= 0 //ignore total rows
drop if city == ""
drop if city == "桃園縣" //an old county
replace city = usubinstr(city,"臺","台",.) //"臺" and "台" are interchangeable in Chinese

rename B tot
rename D graduate
rename E college
rename F juniorcollege
rename G highschool
replace highschool = highschool + H
rename I juniorhigh
replace juniorhigh = juniorhigh + J
rename K primary
rename L illiterate
replace illiterate = illiterate + M

foreach x in graduate college juniorcollege highschool juniorhigh primary illiterate{
	replace `x' = `x' / tot
}

keep year city graduate college juniorcollege highschool juniorhigh primary illiterate

compress
save "$wdata/population/education_level.dta", replace
