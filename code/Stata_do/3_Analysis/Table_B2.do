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
use "$wdata/NHI_`y'_for_analysis.dta", clear

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
import delimited "$table/temp/Table_B2_`x'.txt"
save "$table/temp/Table_B2_`x'.dta", replace

}

use "$table/temp/Table_B2_total.dta", clear
ap using "$table/temp/Table_B2_infection.dta"
ap using "$table/temp/Table_B2_non_infection.dta"

forv i = 2(1)9{
	replace v`i' = subinstr(v`i',"[.","[0.",.)
	replace v`i' = subinstr(v`i',"{.","{0.",.)
}

compress

gen row = _n

replace row = 6.1 if row == 11
replace row = 6.2 if row == 12
replace row = 8.1 if row == 13
replace row = 8.2 if row == 14
replace row = 22.1 if row == 27
replace row = 22.2 if row == 28
replace row = 24.1 if row == 29
replace row = 24.2 if row == 30
replace row = 38.1 if row == 42
replace row = 38.2 if row == 43
replace row = 40.1 if row == 44
replace row = 40.2 if row == 45

sort row
drop row 
compress

keep if inrange(_n,4,12) | inrange(_n,20,28) | inrange(_n,36,47) 

replace v1 = "Panel A: Total Visits/Admissions" in 1 
replace v1 = "Panel B: Infectious Diseases" in 10
replace v1 = "Panel C: Non-infectious diseases" in 19


export excel using "$table/Table_B2.xlsx", replace

