forv i = 103(1)109{
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
rename D population_age04
gen population_age514 = J + P
gen population_age1524 = V + AB
gen population_age2564 = AH + AN + AT + AZ + BF + BL + BR + BX
gen population_age65up = population - population_age04 - population_age514 - population_age1524 - population_age2564
gen population_age15up = population - population_age04 - population_age514

replace city = city[_n+1] if B == "計"
keep if B == "計"
keep city population*
replace city = subinstr(city," ","",.)
drop if city == "總　　計" | city == "臺灣省" | city == "福建省" | city == "臺灣地區"
replace city = "新北市" if city == "臺北縣"
replace city = "桃園市" if city == "桃園縣"
replace city = "臺中市" if city == "臺中縣"
replace city = "臺南市" if city == "臺南縣"
replace city = "高雄市" if city == "高雄縣"
destring population*, replace

collapse (sum)population*, by(city) //合併升格前新舊縣市

gen year = `i'
gen month = `j'
order y m

save "$wdata/population/`i'_`j'.dta", replace

}
}
