clear
set more off
capture log close

foreach y in opd ipd{

if "`y'" == "opd" {
local title = "Outpatients Visits"
}
if "`y'" == "ipd" {
local title = "Inpatients Admission"
}

use "$wdata/NHI_`y'_for_analysis.dta", clear

keep if year >= 2014 & year <= 2020
keep if week <= 52

collapse 	(mean)perc_infection perc_non_infection ///
			(sem)se_infection = perc_infection ///
			(sem)se_non_infection = perc_non_infection , by(week treatment)

gen upper_infection = perc_infection + 1.96 * se_infection
gen lower_infection = perc_infection - 1.96 * se_infection
gen upper_non_infection = perc_non_infection + 1.96 * se_non_infection
gen lower_non_infection = perc_non_infection - 1.96 * se_non_infection

foreach x in infection non_infection{
forv i = 0(1)1{
sum perc_`x' if inrange(week,2,2) & treatment == `i'
replace perc_`x' = ((perc_`x' / r(mean)) - 1) * 100 if treatment == `i'
replace upper_`x' = ((upper_`x' / r(mean)) - 1) * 100 if treatment == `i'
replace lower_`x' = ((lower_`x' / r(mean)) - 1) * 100 if treatment == `i'
}
}

replace week = week - 4

foreach x in infection non_infection{
twoway	(line perc_`x' week if treatment == 1) ///
		(line perc_`x' week if treatment == 0, lpattern(dash)) ///
		(rcap upper_`x' lower_`x' week if treatment == 0, lc(maroon)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		legend(order(1 "2020" 2 "2014–2019")) ///
		xtitle("Weeks form the 4{superscript:th} week of a year") ///
		ytitle("Percentage Change from the Baseline (%)") ///
		xlabel(-5(5)50) xline(0, lpattern(dash) lcolor(gray)) ///
		ylabel(-60(15)45, angle(0))
graph export "$figure/Figure_1_`y'_`x'.png", as(png) replace
}
}

