clear
set more off

use "$wdata/NHI/CDC_Flu_Pneumonia_death.dta", clear

forv i = 2014(1)2020{
sum death if week == 2 & year == `i'  //first three week as baseline
local mean = r(mean)
replace death = ((death / `mean') - 1) * 100 if year == `i'
}

collapse (mean)death (sem)se = death , by(week treatment)

gen upper = death + 1.96 * se
gen lower = death - 1.96 * se

replace week = week - 4

sum death if week == -2 & treatment == 1
local baseline = r(mean)
dis `baseline'
local min = `baseline' * -40
local max = `baseline' * 20
dis `min'
dis `max'

foreach x in death{
twoway	(line `x' week if treatment == 1) ///
		(line `x' week if treatment == 0, lpattern(dash)) ///
		(rcap upper lower week if treatment == 0, lc(maroon)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		legend(order(1 "2020" 2 "2014 to 2019") symxsize(6pt)) ///
		xtitle("Weeks form the 4{superscript:th} week of a year") ///
		ytitle("Percentage Change from the Baseline (%)") ///
		xlabel(-5(5)50) ylabel(-40(10)50) xline(0, lpattern(dash) lcolor(gray)) ylabel(, angle(0))
graph export "$figure/Fig7.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/figures/Fig7.eps", as(eps) replace fontface("Times New Roman")
}
