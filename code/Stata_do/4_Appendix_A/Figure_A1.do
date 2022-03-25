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


collapse (sum)hits*, by(normweek)

foreach y in "coronavirus" "sanitizer" "mask"{

twoway 	(line hits_`y' normweek, lw(medthin)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Weeks from the 4th week of a year", size(small)) ///
		ytitle("Sum of Daily Google Trend Serching Index", size(small)) ///
		xlabel(-5(5)45) xscale(range(-6 48)) ///
		ylabel(0(100)600, angle(0)) yscale(range(0 600)) ///
		xline(0, lp(dash) lw(vthin)) xline(1, lp(dash) lw(vthin)) ///
		xline(4, lp(dash) lw(vthin)) xline(20, lp(dash) lw(vthin)) ///
		text(300 -0.5 "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(tiny) place(nw) just(right)) ///
		text(0 1.5  "{bf:2020.01.28}" "First Local" "COVID-19" "Cases", size(tiny)  place(ne) just(left)) ///
		text(500 4.5  "{bf:2020.02.18}" "First" "Death Case", size(tiny)  place(ne) just(left)) ///
		text(200 20.5  "{bf:2020.06.07}" "Regulation" "Lift", size(tiny)  place(ne) just(left)) ///
		title("`TW_`y''", color(black) size(medlarge) margin(medium)) ///
		name("FigA1_TW_`y'", replace) fxsize(100) fysize(80)
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

collapse (sum)hits*, by(region normweek)

foreach x in "US"{
foreach y in "coronavirus" "sanitizer" "mask"{

twoway 	(line hits_`y' normweek if region == "`x'", lw(medthin)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Weeks from the 4th week of a year", size(small)) ///
		ytitle("Sum of Daily Google Trend Serching Index", size(small)) ///
		xlabel(-5(5)45) xscale(range(-6 48)) ///
		ylabel(0(100)600, angle(0)) yscale(range(0 600)) ///
		xline(0, lp(dash) lw(vthin)) xline(2, lp(dash) lw(vthin)) ///
		xline(5, lp(dash) lw(vthin)) ///
		text(200 -0.5 "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(tiny) place(nw) just(right)) ///
		text(100 2.5  "{bf:2020.02.06}" "First" "Death" "Case", size(tiny)  place(ne) just(left)) ///
		text(0 5.5  "{bf:2020.02.26}" "First" "Local" "COVID-19" "Cases", size(tiny)  place(ne) just(left)) ///
		title("``x'_`y''", color(black) size(medlarge) margin(medium)) ///
		name("FigA1_`x'_`y'", replace) fxsize(100) fysize(80)
}
}


graph combine 	FigA1_TW_coronavirus FigA1_US_coronavirus ///
				FigA1_TW_mask FigA1_US_mask ///
				FigA1_TW_sanitizer FigA1_US_sanitizer ///
				, scheme(s1color) cols(2) saving(FigA1, replace) imargin(0 0 0 0)
graph display, ysize(100) xsize(79.25)

graph export "$figure/FigA1.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/FigA1.eps", as(eps) replace fontface("Times New Roman")

