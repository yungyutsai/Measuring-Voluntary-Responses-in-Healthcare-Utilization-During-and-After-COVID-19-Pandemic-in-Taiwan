local var = "total infection non_infection"
local did = "covid19 treatment post"
local control1 = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10"
local control2 = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local control3 = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local control4 = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb1 = "year week"
local absorb2 = "year week"
local absorb3 = "year week city_no"
local absorb4 = "city_no#year city_no#week"

clear
set more off

foreach x in `var' {
foreach y in opd ipd{
use $wdata/NHI_`y'_for_analysis.dta, clear

forv i = 1(1)4{

sum `x' if treatment == 1 & inrange(week,1,3) //用2020年1至3週當Baseline Mean 
local mean = `r(mean)'

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl city_cd) exp(population)
matrix V = e(V)
local se_city = round(sqrt(V[1,1]),.01)

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl yearweek) exp(population)
matrix V = e(V)
local se_yw = round(sqrt(V[1,1]),.01)

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl city_cd yearweek) exp(population)

if "`y'" == "opd" & `i' == 1{
outreg2 using "$table/temp/Table_B1_`x'", ///
replace title("Outcomes: `x'") ctitle(`y') nocon keep(covid19) bd(2) sd(2) ///
addtext(Cluster at County Level, "[`se_city']", Cluster at YearWeek Level, "{`se_yw'}")
}
else{
outreg2 using "$table/temp/Table_B1_`x'", ///
append title("Outcomes: `x'") ctitle(`y') nocon keep(covid19) bd(2) sd(2) ///
addtext(Cluster at County Level, "[`se_city']", Cluster at YearWeek Level, "{`se_yw'}")
}
}
}
clear
import delimited $table/temp/Table_B1_`x'.txt
save $table/temp/Table_B1_`x'.dta, replace
}

use $table/temp/Table_B1_total.dta, clear
ap using $table/temp/Table_B1_infection.dta
ap using $table/temp/Table_B1_non_infection.dta

drop in 7/8
drop in 9/10
drop in 10/12
drop in 12/13
drop in 14/15
drop in 15/17
drop in 17/18

forv i = 2(1)9{
	replace v`i' = subinstr(v`i',"[.","[0.",.)
	replace v`i' = subinstr(v`i',"{.","{0.",.)
}

compress

export excel using "$table/Table_B1.xlsx", replace

log close
