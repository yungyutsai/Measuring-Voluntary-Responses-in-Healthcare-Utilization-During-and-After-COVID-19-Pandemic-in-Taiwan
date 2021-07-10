clear
set more off

forv i = 102(1)109{ //Equivalent to A.D. 2013 to 2020
forv j = 1(1)12{
ap using "$wdata/population/`i'_`j'.dta"
}
}

replace city = subinstr(city,"臺","台",.)

compress

gen key_ym = (y+1911) * 100 + m //Change to A.D.

foreach x in "" "_age04" "_age514" "_age1524" "_age2564" "_age65up" "_age15up"{
	rename population`x' county_pop`x'
	lab var county_pop`x' "County Population (Monthly)"
}

save "$wdata/population/population.dta", replace
