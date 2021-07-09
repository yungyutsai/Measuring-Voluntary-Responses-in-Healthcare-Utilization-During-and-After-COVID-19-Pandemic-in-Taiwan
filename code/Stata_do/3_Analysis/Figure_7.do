local var = "total infection non_infection"
local control = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb = "city_no#year city_no#week"

clear
set more off

clear matrix
clear mata
set maxvar 9999
cap mkdir "$figure/temp"
cap rm "$figure/temp/Figure_7.dta"
foreach x in `var' {
foreach y in opd ipd{
		
	forv i = 1(1)1000{
	if `i' == 1 {
		dis "Running Placebo Test for `y' Sample, Outcomes `x' (1000)"
		dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
	}
	_dots `i' 0
	
	qui{
		use "$wdata/NHI_`y'_for_placebo.dta", clear
		
		
		replace week = week - 4
		forv j = 3(-1)1{
			cap replace pre`j'Xtreat = treat`i' == 1 & week == - `j'
		}
		forv j = 0(1)48{
			replace post`j'Xtreat = treat`i' == 1 & week == `j'
		}
		replace week = week + 4

		ppmlhdfe `x' p*treat treat`i' `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek) exp(population)
		parmest , saving("$figure/temp/Figure_7_temp.dta", replace) idstr("`y',`x'") idnum(`i')

		if "`x'" == "total" & "`y'" == "opd" & `i' == 1{
			use "$figure/temp/Figure_7_temp.dta", clear
			keep if substr(parm,-6,6) == "Xtreat"
			save "$figure/temp/Figure_7.dta", replace
		}
		else{
			use "$figure/temp/Figure_7.dta", clear
			ap using "$figure/temp/Figure_7_temp.dta"
			keep if substr(parm,-6,6) == "Xtreat"
			save "$figure/temp/Figure_7.dta", replace
		}
	}
	}

}
}
** Re estimate Main Specification

foreach x in `var' {
foreach y in opd ipd{
use $wdata/NHI_`y'_for_analysis.dta, clear

ppmlhdfe `x' p*treat treatment `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek) exp(population)
parmest , saving($figure/temp/Figure_7_temp.dta, replace) idstr("`y',`x'") idnum(0)

use "$figure/temp/Figure_7.dta", clear
ap using "$figure/temp/Figure_7_temp.dta"
keep if substr(parm,-6,6) == "Xtreat"
save "$figure/temp/Figure_7.dta", replace
}
}

** Graphing
use "$figure/temp/Figure_7.dta", replace

cap gen week = parm
cap replace week = subinstr(week,"Xtreat","",.)
cap replace week = subinstr(week,"pre","-",.)
cap replace week = subinstr(week,"post","",.)
cap destring week, replace

save "$figure/temp/Figure_6_Placebo_EventStudy_Poisson.dta", replace

keep idnum idstr
duplicates drop
expand 52

bysort idnum idstr: gen week = _n
replace week = week - 4

merge 1:1 idnum idstr week using "$figure/temp/Figure_7.dta"
drop _m

recode estimate . = 0
recode min95 . = 0
recode max95 . = 0
  
gen main = idnum == 0

sort idn week
foreach x in total infection non_infection {
foreach y in opd ipd{

local figure = ""
forv i = 1(1)1000{
	local figure = `"`figure' (line estimate week if idn == `i' & ids == "`y',`x'", mcolor(gs12) lc(gs12) lw(vthin))"'
}
	
twoway	`figure' ///
		(rline max95 min95 week if idn == 0 & ids == "`y',`x'", lc(navy) lp(dash)) ///
		(connect estimate week if idn == 0 & ids == "`y',`x'", mcolor(maroon) lc(maroon)) ///
		(scatteri 0 -3 0 48, recast(line) lc(black) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		yscale(range(-1 0.61)) ylabel(-1(0.2)0.6, nogrid format(%9.1f) angle(0)) ///
		xlabel(0(5)45) leg(col(3) order(1002 "Main Estimate" 1001 "Main Estimate 95% CI" 1 "Placebo Test") size(small)) ///
		ytitle("Estimated Coefficients") ///
		xtitle("Weeks form the 4{superscript:th} week of a year") 
graph export "$figure/Figure_7_`y'_`x'.png", as(png) replace
}
}

