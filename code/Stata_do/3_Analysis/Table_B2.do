local var = "total infection non_infection"
local did = "TxPandemic TxPostPandemic Pandemic PostPandemic"
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
local se_city1 = round(sqrt(V[1,1]),.01)
local se_city2 = round(sqrt(V[2,2]),.01)

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl yearweek) exp(population)
matrix V = e(V)
local se_yw1 = round(sqrt(V[1,1]),.01)
local se_yw2 = round(sqrt(V[2,2]),.01)

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl city_cd yearweek) exp(population)

if "`y'" == "opd" & `i' == 1{
outreg2 using "$table/temp/Table_B2_`x'", ///
replace title("Outcomes: `x'") ctitle(`y') nocon keep(TxPandemic TxPostPandemic) bd(2) sd(2) ///
addtext(Cluster at County Level 1, "[`se_city1']", Cluster at YearWeek Level 1, "{`se_yw1'}", Cluster at County Level 2, "[`se_city2']", Cluster at YearWeek Level 2, "{`se_yw2'}")
}
else{
outreg2 using "$table/temp/Table_B2_`x'", ///
append title("Outcomes: `x'") ctitle(`y') nocon keep(TxPandemic TxPostPandemic) bd(2) sd(2) ///
addtext(Cluster at County Level 1, "[`se_city1']", Cluster at YearWeek Level 1, "{`se_yw1'}", Cluster at County Level 2, "[`se_city2']", Cluster at YearWeek Level 2, "{`se_yw2'}")
}
}
}
clear
import delimited $table/temp/Table_B2_`x'.txt
drop in 9
save $table/temp/Table_B2_`x'.dta, replace

}

use $table/temp/Table_B2_total.dta, clear
ap using $table/temp/Table_B2_infection.dta
ap using $table/temp/Table_B2_non_infection.dta

forv i = 2(1)9{
	replace v`i' = subinstr(v`i',"[.","[0.",.)
	replace v`i' = subinstr(v`i',"{.","{0.",.)
}

compress

gen row = _n

replace row = 6.1 if row == 10
replace row = 6.2 if row == 11
replace row = 8.1 if row == 12
replace row = 8.2 if row == 13
replace row = 0 if row == 9
replace row = 0 if row == 14
replace row = 0 if row == 15
replace row = 21.1 if row == 25
replace row = 21.2 if row == 26
replace row = 23.1 if row == 27
replace row = 23.2 if row == 28
replace row = 0 if row == 17 | row == 18 | row == 19
replace row = 0 if row == 24
replace row = 0 if row == 29
replace row = 0 if row == 30
replace row = 36.1 if row == 40
replace row = 36.2 if row == 41
replace row = 38.1 if row == 42
replace row = 38.2 if row == 43
replace row = 0 if row == 32 | row == 33 | row == 34
replace row = 0 if row == 39

drop if row == 0
sort row
drop row 
compress

export excel using "$table/Table_B2.xlsx", replace

