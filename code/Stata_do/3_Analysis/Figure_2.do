clear
set more off
capture log close

local opd_flu = "(A) Outpatient care: ILI diseases"
local opd_non_flu = "(B) Outpatient care: Non-ILI diseases"
local ipd_flu = "(C) Inpatient care: ILI diseases" 
local ipd_non_flu = "(D) Inpatient care: Non-ILI diseases"

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

collapse 	(mean)perc_flu perc_non_flu ///
			(sem)se_flu = perc_flu ///
			(sem)se_non_flu = perc_non_flu , by(week treatment)

gen upper_flu = perc_flu + 1.96 * se_flu
gen lower_flu = perc_flu - 1.96 * se_flu
gen upper_non_flu = perc_non_flu + 1.96 * se_non_flu
gen lower_non_flu = perc_non_flu - 1.96 * se_non_flu

foreach x in flu non_flu{
forv i = 0(1)1{
sum perc_`x' if inrange(week,2,2) & treatment == `i'
replace perc_`x' = ((perc_`x' / r(mean)) - 1) * 100 if treatment == `i'
replace upper_`x' = ((upper_`x' / r(mean)) - 1) * 100 if treatment == `i'
replace lower_`x' = ((lower_`x' / r(mean)) - 1) * 100 if treatment == `i'
}
}

replace week = week - 4

cd "$figure/temp"
foreach x in flu non_flu{
twoway	(line perc_`x' week if treatment == 1, lw(thin)) ///
		(line perc_`x' week if treatment == 0, lpattern(dash) lw(thin)) ///
		(rcap upper_`x' lower_`x' week if treatment == 0, lc(maroon) lw(thin)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		legend(order(1 "2020" 2 "2014 to 2019") size(small) symxsize(6pt)) ///
		xtitle("Weeks form the 4{superscript:th} week of a year", size(small)) ///
		ytitle("Percentage Change from the Baseline (%)", size(small)) ///
		xlabel(-5(5)50) xline(0, lpattern(dash) lcolor(gray)) ///
		ylabel(-75(25)50, angle(0)) ///
		title(``y'_`x'', color(black) size(medlarge) margin(medium)) ///
		name("Fig2_`y'_`x'", replace) fxsize(100) fysize(80)
}
}

grc1leg Fig2_opd_flu Fig2_opd_non_flu Fig2_ipd_flu Fig2_ipd_non_flu, scheme(s1color) cols(2) legendfrom(Fig2_opd_flu) saving(Fig2, replace)
graph display, ysize(65) xsize(79.25)

graph export "$figure/Fig2.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/Fig2.eps", as(eps) replace fontface("Times New Roman")


