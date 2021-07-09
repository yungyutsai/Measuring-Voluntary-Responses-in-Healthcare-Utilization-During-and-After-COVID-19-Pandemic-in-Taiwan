clear
set more off

import delimited "$rdata/NHI/CDC_Flu_Pneumonia_death.csv", encoding(UTF-8)

gen year = floor(死亡年週/100)
gen week = mod(死亡年週,100)
rename 肺炎及流感死亡人數 death
//keep if year >= 2014
drop if week > 52
drop if year > 2020
gen treatment = year == 2020

gen yearweek = year * 100 + week

gen pop = .
replace pop = 23037031 if year == 2008
replace pop = 23119772 if year == 2009
replace pop = 23162123 if year == 2010
replace pop = 23224912 if year == 2011
replace pop = 23315822 if year == 2012
replace pop = 23373517 if year == 2013
replace pop = 23433753 if year == 2014
replace pop = 23492074 if year == 2015
replace pop = 23539816 if year == 2016
replace pop = 23571227 if year == 2017
replace pop = 23588932 if year == 2018
replace pop = 23603121 if year == 2019
replace pop = 23583823 if year == 2020

replace death = death / pop * 100000 //每十萬人死亡人數

forv i = 2008(1)2020{
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
		legend(order(1 "2020" 2 "2008–2019")) ///
		xtitle("Weeks form the 4{superscript:th} week of a year") ///
		ytitle("Percentage Change from the Baseline (%)") ///
		xlabel(-5(5)50) xline(0, lpattern(dash) lcolor(gray)) ylabel(, angle(0))
graph export "$figure/Figure_C3.png", as(png) replace
}
