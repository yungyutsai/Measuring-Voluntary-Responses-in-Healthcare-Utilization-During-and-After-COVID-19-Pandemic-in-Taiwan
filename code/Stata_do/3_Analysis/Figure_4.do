local var = "total infection non_infection"
local event = "p*treat"
local control = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb = "city_no#year city_no#week"

clear
set more off

foreach y in opd ipd{

use "$wdata/NHI_`y'_for_analysis.dta", clear

foreach x in `var' {

ppmlhdfe `x' `event' `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek) exp(population)

if "`x'" == "total"{
outreg2 using "$figure/Figure_4_`y'.xls", ///
replace title("Event Study") ctitle(`x') nocon keep(p*Xtreat)
}
else{
outreg2 using "$figure/Figure_4_`y'.xls", ///
append title("Event Study") ctitle(`x') nocon keep(p*Xtreat)
}
}
}

foreach y in opd ipd{

import delimited "$figure/Figure_4_`y'.txt", varnames(3) clear 

**刪除表頭與表尾
drop in 1

local a = _N //106
local b = _N - 3 //103

drop in `b'/`a' //Drop last 4 lines (# of Observations and the Note lines)

**移除括號與逗點
foreach x of varlist total-non_infection{
replace `x' = subinstr(`x',"*","",.)
replace `x' = subinstr(`x',",","",.)
replace `x' = subinstr(`x',"(","",.)
replace `x' = subinstr(`x',")","",.)
destring `x', replace
recode `x' . = 0
rename `x' _`x'
}

**整理成漂亮的格式
gen week = -3
replace week = week[_n-2] + 1 if _n > 2
replace week = week + 1 if week >= -2

local a = _N + 2
set obs `a' //多兩行放Reference Groups
replace week = -2 if week == .
foreach x of varlist _total-_non_infection{
recode `x' . = 0
}

local a = _N - 1
gen type = "coef"
replace type = "se" if var == ""
replace type = "coef" in `a'
drop var

reshape wide _*, i(week) j(type) string

foreach x in `var'{
gen upper_`x' = _`x'coef + 1.96 * _`x'se
gen lower_`x' = _`x'coef - 1.96 * _`x'se

twoway	(scatteri 0.61 20 0.61 0 -1 0 -1 20, recast(area) lc(gs13) color(gs12)) ///
		(scatteri 0.61 48 0.61 20 -1 20 -1 48, recast(area) lc(gs15) color(gs14)) ///
		(rline upper_`x' lower_`x' week, lc(navy) lp(dash)) ///
		(connect _`x'coef week, mcolor(maroon) lc(maroon)) ///
		(scatteri 0 -3 0 48, recast(line) lc(black) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		yscale(range(-1 0.61)) ylabel(-1(0.2)0.6, nogrid angle(0) format(%9.1f)) ///
		xlabel(0(5)45) leg(order(4 "Estimates" 3 "95% CI")) ///
		ytitle("Estimated Coefficients") ///
		xtitle("Weeks form the 4{superscript:th} week of a year") ///
		text(0.62 10 "During Pandemic Period", size(small) place(n)) ///
		text(0.62 34 "After Pandemic Period", size(small) place(n))
graph export "$pic/Figure_4_`y'_`x'.png", as(png) replace
}
}
