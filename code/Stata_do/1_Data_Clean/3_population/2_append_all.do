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

rename population county_pop
lab var county_pop "County Population (Monthly)"

merge 1:1 city year month using "$wdata/population/gender_ratio.dta"
drop if _m == 1
drop _m

merge m:1 city year using "$wdata/population/education_level.dta"
drop _m


foreach x of varlist pop* gender{
	egen `x'mean = mean(`x'), by(year city)
	replace `x' = `x'mean
	drop `x'mean
}

save "$wdata/population/population.dta", replace
