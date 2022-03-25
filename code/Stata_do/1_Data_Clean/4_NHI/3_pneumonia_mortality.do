clear
set more off

import delimited "$rdata/NHI/CDC_Flu_Pneumonia_death.csv", encoding(UTF-8)

gen year = floor(死亡年週/100)
gen week = mod(死亡年週,100)
rename 肺炎及流感死亡人數 death
keep if year >= 2014
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

replace death = death / pop * 100000 //Mortality rate per 100,000 people

keep yearweek year week treatment death

save "$wdata/NHI/CDC_Flu_Pneumonia_death.dta", replace
