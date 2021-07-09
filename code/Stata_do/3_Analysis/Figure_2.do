local var = "total infection non_infection"
local control = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb = "city_no#year city_no#week"

clear
set more off

foreach x in `var' {
foreach y in opd ipd{
use "$wdata/NHI_`y'_for_analysis.dta", clear

rename covid19 `y' //for graphing purpose
ppmlhdfe `x' `y' `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek) exp(population)
estimates store Model_`x'_`y'

}
}

foreach x in opd ipd{
cap drop __*
coefplot 	(Model_total_`x', ciopts(recast(rcap) lcol(navy)) mc(navy)) ///
			(Model_infection_`x', ciopts(recast(rcap) lcol(maroon)) mc(maroon) ms(S)) ///
			(Model_non_infection_`x', ciopts(recast(rcap) lcol(forest_green)) mc(forest_green) ms(D) msize(medsmall)), ///
			keep(`x') verti scheme(s1color) ///
			yline(0, lc(black) lp(dash)) ytitle(Estimated Coefficients) name(coefplot1, replace) generate
replace __mlbl = string(__b, "%6.2f") if !missing(__b)
gen __mlblci = "[" + string(__ll1, "%6.2f") + "; " + string(__ul1, "%6.2f") + "]" if !missing(__b)

replace __mlpos = __ll1 -0.01
gen __mlposci = __mlpos -0.04
gen __atci = __at

addplot: (scatter __mlpos __at, ms(i) mlabel(__mlbl) mlabsize(small) mlabc(black) mlabp(6)) ///
		(scatter __mlposci __atci, ms(i) mlabel(__mlblci) mlabsize(small) mlabc(black) mlabp(6)), ///
		xlabel(none) xscale(range(0.6 1.4)) xtitle(" ") ///
		ylabel(-0.7(0.1)0.2, format(%9.1f) angle(0)) yscale(range(-0.75 0.25)) ///
		legend(off) ///
		text(0.15 0.75 "Total", place(n)) text(0.15 1 "Infectious Diseases", place(n)) text(0.15 1.25 "Other Diseases", place(n))
graph export "$figure/Figure_2_`x'.png", as(png) replace
}
