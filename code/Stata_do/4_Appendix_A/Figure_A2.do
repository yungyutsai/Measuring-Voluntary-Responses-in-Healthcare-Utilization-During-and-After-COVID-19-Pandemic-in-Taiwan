clear

local TW_coronavirus = "(A) Coronavirus, Taiwan"
local TW_mask = "(C) Mask, Taiwan" 
local TW_sanitizer = "(E) Sanitizer, Taiwan"
local US_coronavirus = "(B) Coronavirus, US"
local US_mask = "(D) Mask, US" 
local US_sanitizer = "(F) Sanitizer, US"

use "$wdata/google_trend/google_trend_for_analysis_TW.dta", clear

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

keep if WHOyear == 2020 & week <= 52
gen normday = date - 21935
gen normweek = week - 4

foreach y in "coronavirus" "sanitizer" "mask"{
twoway 	(line hits_`y' normday, lw(medthin)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Days from the first COVID-19 cases", size(small)) ///
		ytitle("Daily Google Trend Serching Index", size(small)) ///
		xlabel(-40(40)320) xscale(range(-25 320)) ///
		ylabel(0(20)100, angle(0)) yscale(range(0 100) titlegap(-1)) ///
		xline(0, lp(dash) lw(vthin)) xline(7, lp(dash) lw(vthin)) ///
		xline(28, lp(dash) lw(vthin)) xline(138, lp(dash) lw(vthin)) ///
		text(50 -2  "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(tiny) place(nw) just(right)) ///
		text(0 9   "{bf:2020.01.28}" "First Local" "COVID-19" "Cases", size(tiny)  place(ne) just(left)) ///
		text(80 30 "{bf:2020.02.18}" "First" "Death Case", size(tiny)  place(ne) just(left)) ///
		text(50 140 "{bf:2020.06.07}" "Regulation" "Lift", size(tiny)  place(ne) just(left)) ///
		title("`TW_`y''", color(black) size(medlarge) margin(medium)) ///
		name("FigA2_TW_`y'", replace) fxsize(100) fysize(80)
}

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


foreach x in "US"{
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
		name("FigA2_`x'_`y'", replace) fxsize(100) fysize(80)
}
}



graph combine 	FigA2_TW_coronavirus FigA2_US_coronavirus ///
				FigA2_TW_mask FigA2_US_mask ///
				FigA2_TW_sanitizer FigA2_US_sanitizer ///
				, scheme(s1color) cols(2) saving(FigA2, replace) imargin(0 0 0 0)
graph display, ysize(100) xsize(79.25)

graph export "$figure/FigA2.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/FigA2.eps", as(eps) replace fontface("Times New Roman")

