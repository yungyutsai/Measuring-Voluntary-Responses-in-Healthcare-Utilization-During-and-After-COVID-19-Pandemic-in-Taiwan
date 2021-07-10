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
capture log close

foreach x in `var' {
foreach y in opd ipd{
use "$wdata/NHI_`y'_for_analysis.dta", clear

forv i = 1(1)4{

sum `x' if treatment == 1 & inrange(week,1,3) //用2020年1至3週當Baseline Mean 
local mean = `r(mean)'

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl city_cd yearweek) exp(population)

if "`y'" == "opd" & `i' == 1{
outreg2 using "$table/temp/Table_3_`x'", ///
replace title("Outcomes: `x'") ctitle(`y') nocon keep(TxPandemic TxPostPandemic) bd(2) sd(2) 
}
else{
outreg2 using "$table/temp/Table_3_`x'", ///
append title("Outcomes: `x'") ctitle(`y') nocon keep(TxPandemic TxPostPandemic) bd(2) sd(2)
}
}
}
clear
import delimited "$table/temp/Table_3_`x'.txt"
save "$table/temp/Table_3_`x'.dta", replace

}

use "$table/temp/Table_3_total.dta"
ap using "$table/temp/Table_3_infection.dta"
ap using "$table/temp/Table_3_non_infection.dta"

keep if inrange(_n,4,8) | inrange(_n,16,20) | inrange(_n,28,36)

replace v1 = "Panel A: Total Visits/Admissions" in 1 
replace v1 = "Panel B: Infectious Diseases" in 6
replace v1 = "Panel C: Non-infectious diseases" in 11

export excel using "$table/Table_3.xlsx", replace
