local var = "flu non_flu"
local event = "p*treat"
local control = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb = "city_no#c.yweek city_no#year city_no#week"
local opd_flu = "(A) Outpatient care: ILI diseases"
local opd_non_flu = "(B) Outpatient care: Non-ILI diseases"
local ipd_flu = "(C) Inpatient care: ILI diseases" 
local ipd_non_flu = "(D) Inpatient care: Non-ILI diseases"

clear
set more off

foreach y in opd ipd{
cap rm "$figure/temp/Figure_3_`y'.xls"
cap rm "$figure/temp/Figure_3_`y'.txt"

use "$wdata/NHI_`y'_for_analysis.dta", clear

foreach x in `var' {
replace `x' = `x' / population * 100000

ppmlhdfe `x' `event' `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek)
outreg2 using "$figure/temp/Figure_3_`y'.xls", ///
append title("Event Study") ctitle(`x') nocon keep(p*Xtreat) eform
}
}


foreach y in opd ipd{

import delimited "$figure/temp/Figure_3_`y'.txt", varnames(3) clear 

**Delete Table Head and Foot
drop in 1

local a = _N //106
local b = _N - 3 //103

drop in `b'/`a' //Drop last 4 lines (# of Observations and the Note lines)

**Eliminate Parentheses, Comma, and Symbol
foreach x of varlist `var'{
replace `x' = subinstr(`x',"*","",.)
replace `x' = subinstr(`x',",","",.)
replace `x' = subinstr(`x',"(","",.)
replace `x' = subinstr(`x',")","",.)
destring `x', replace
recode `x' . = 0
rename `x' _`x'
}

**Organize
gen week = -3
replace week = week[_n-2] + 1 if _n > 2
replace week = week + 1 if week >= -2

local a = _N + 2
set obs `a' //Add Reference Groups
replace week = -2 if week == .
foreach x of varlist _*{
recode `x' . = 1
local N = _N
replace `x' = 0 in `N'
}

local a = _N - 1
gen type = "coef"
replace type = "se" if var == ""
replace type = "coef" in `a'
drop var

reshape wide _*, i(week) j(type) string

cd "$figure/temp"
foreach x in `var'{
gen upper_`x' = _`x'coef + 1.96 * _`x'se
gen lower_`x' = _`x'coef - 1.96 * _`x'se

twoway	(scatteri 0.32 20 0.32 0 1.68 0 1.68 20, recast(area) lc(gs13) color(gs12)) ///
		(scatteri 0.32 48 0.32 20 1.68 20 1.68 48, recast(area) lc(gs15) color(gs14)) ///
		(rline upper_`x' lower_`x' week, lc(navy) lp(dash) lw(thin)) ///
		(connect _`x'coef week, mcolor(maroon) lc(maroon) msize(vsmall) lw(thin)) ///
		(scatteri 1 -3 1 48, recast(line) lc(black) lp(dash) lw(thin)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		yscale(range(0.32 1.68)) ylabel(0.4(0.2)1.6, nogrid angle(0) format(%9.1f)) ///
		xlabel(0(5)45) leg(order(4 "IRR" 3 "95% CI") size(small) symxsize(6pt)) ///
		ytitle("IRR") ///
		xtitle("Weeks form the 4{superscript:th} week of a year") ///
		text(1.7 10 "Pandemic Period", size(small) place(n)) ///
		text(1.7 34 "COVID-Free Period", size(small) place(n)) ///
		title(``y'_`x'', color(black) size(medlarge) margin(medium)) ///
		name("Fig3_`y'_`x'", replace) fxsize(100) fysize(80)
}
}


grc1leg Fig3_opd_flu Fig3_opd_non_flu Fig3_ipd_flu Fig3_ipd_non_flu, scheme(s1color) cols(2) legendfrom(Fig3_opd_flu) imargin(0 0 0 0) saving(Fig3, replace)
graph display, ysize(65) xsize(79.25)

graph export "$figure/Fig3.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/Fig3.eps", as(eps) replace fontface("Times New Roman")


