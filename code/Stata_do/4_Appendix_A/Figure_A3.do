clear

local Washington_coronavirus = "(A) Coronavirus, Washington"
local Washington_mask = "(C) Mask, Washington" 
local Washington_sanitizer = "(E) Sanitizer, Washington"
local Seattle_coronavirus = "(B) Coronavirus, Seattle"
local Seattle_mask = "(D) Mask, Seattle" 
local Seattle_sanitizer = "(F) Sanitizer, Seattle"

use "$wdata/google_trend/google_trend_for_analysis_US.dta", clear

format date %tdCCYYNNDD

gen date_n = string(date,"%tdCCYYNNDD")
destring date_n, replace
gen year = floor(date_n/10000)
gen month = floor((date_n - year * 10000)/100)
gen day = mod(date_n,100)

**WHO week
merge m:1 date using "$wdata/calendar/yearweek_table.dta", keepusing(yearweek)
drop if _m == 2
drop _m
gen week = mod(yearweek,100)
gen WHOyear = floor(yearweek/100)

gen region = ""
replace region = "US" if geo == "US"
replace region = "Washington" if geo == "US-WA"
replace region = "Seattle" if geo == "US-WA-819"

keep if WHOyear == 2020 & week <= 52
gen normday = date - 21935
gen normweek = week - 4

foreach x in "Washington" "Seattle"{
foreach y in "coronavirus" "sanitizer" "mask"{

twoway 	(line hits_`y' normday if region == "`x'", lw(medthin)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Days from the first COVID-19 cases", size(small)) ///
		ytitle("Daily Google Trend Serching Index", size(small)) ///
		xlabel(-40(40)320) xscale(range(-25 320)) ///
		ylabel(0(20)100, angle(0)) yscale(range(0 100) titlegap(-1)) ///
		xline(0, lp(dash) lw(vthin)) xline(16, lp(dash) lw(vthin)) ///
		xline(36, lp(dash) lw(vthin)) ///
		text(60 -2 "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(tiny) place(nw) just(right)) ///
		text(40 18  "{bf:2020.02.06}" "First" "Death" "Case", size(tiny)  place(ne) just(left)) ///
		text(0 38  "{bf:2020.02.26}" "First" "Local" "COVID-19" "Cases", size(tiny)  place(ne) just(left)) ///
		title("``x'_`y''", color(black) size(medlarge) margin(medium)) ///
		name("FigA3_`x'_`y'", replace) fxsize(100) fysize(80)
}
}



graph combine 	FigA3_Washington_coronavirus FigA3_Seattle_coronavirus ///
				FigA3_Washington_mask FigA3_Seattle_mask ///
				FigA3_Washington_sanitizer FigA3_Seattle_sanitizer ///
				, scheme(s1color) cols(2) saving(FigA3, replace) imargin(0 0 0 0)
graph display, ysize(100) xsize(79.25)

graph export "$figure/FigA3.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/FigA3.eps", as(eps) replace fontface("Times New Roman")

