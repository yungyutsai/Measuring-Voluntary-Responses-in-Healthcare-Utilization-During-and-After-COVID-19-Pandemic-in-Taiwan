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

twoway 	(line hits_`y' normday if region == "`x'"), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Days from the first COVID-19 cases") ///
		ytitle("Daily Google Trend Serching Index") ///
		xlabel(-40(40)320) xscale(range(-25 320)) ///
		ylabel(0(20)100, angle(0)) yscale(range(0 100)) ///
		xline(0, lp(dash)) xline(16, lp(dash)) ///
		xline(36, lp(dash)) ///
		text(60 -2 "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(small) place(nw) just(right)) ///
		text(40 18  "{bf:2020.02.06}" "First" "Death" "Case", size(small)  place(ne) just(left)) ///
		text(0 38  "{bf:2020.02.26}" "First" "Local" "COVID-19" "Cases", size(small)  place(ne) just(left))
graph export "$figure/Figure_A2_`y'_`x'.png", as(png) replace
}
}


foreach x in "Washington" "Seattle"{
foreach y in "coronavirus" "sanitizer" "mask"{

twoway 	(line hits_`y' normday if region == "`x'"), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Weeks from the week of 1/19 to 1/25") ///
		ytitle("Sum of Daily Google Trend Serching Index") ///
		xlabel(-5(5)45) xscale(range(-6 48)) ///
		ylabel(0(100)600) yscale(range(0 600)) ///
		xline(0, lp(dash)) xline(2, lp(dash)) ///
		xline(5, lp(dash)) ///
		text(200 -0.5 "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(small) place(nw) just(right)) ///
		text(100 2.5  "{bf:2020.02.06}" "First" "Death" "Case", size(small)  place(ne) just(left)) ///
		text(0 5.5  "{bf:2020.02.26}" "First" "Local" "COVID-19" "Cases", size(small)  place(ne) just(left))
		
graph export "$figure/Figure_A3_`y'_`x'.png", as(png) replace
}
}

collapse (sum)hits*, by(region normweek)

foreach x in "US"{
foreach y in "coronavirus" "sanitizer" "mask"{

twoway 	(line hits_`y' normweek if region == "`x'"), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Weeks from the week of 1/19 to 1/25") ///
		ytitle("Sum of Daily Google Trend Serching Index") ///
		xlabel(-5(5)45) xscale(range(-6 48)) ///
		ylabel(0(100)600) yscale(range(0 600)) ///
		xline(0, lp(dash)) xline(2, lp(dash)) ///
		xline(5, lp(dash)) ///
		text(200 -0.5 "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(small) place(nw) just(right)) ///
		text(100 2.5  "{bf:2020.02.06}" "First" "Death" "Case", size(small)  place(ne) just(left)) ///
		text(0 5.5  "{bf:2020.02.26}" "First" "Local" "COVID-19" "Cases", size(small)  place(ne) just(left))
		
graph export "$figure/Figure_A1_`y'_`x'.png", as(png) replace
}
}






