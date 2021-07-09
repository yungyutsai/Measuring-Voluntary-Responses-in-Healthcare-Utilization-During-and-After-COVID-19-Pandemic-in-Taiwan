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
twoway 	(line hits_`y' normday), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Days from the first COVID-19 cases") ///
		ytitle("Daily Google Trend Serching Index") ///
		xlabel(-40(40)320) xscale(range(-25 320)) ///
		ylabel(0(20)100, angle(0)) yscale(range(0 100)) ///
		xline(0, lp(dash)) xline(7, lp(dash)) ///
		xline(28, lp(dash)) xline(138, lp(dash)) ///
		text(50 -2  "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(small) place(nw) just(right)) ///
		text(0 9   "{bf:2020.01.28}" "First Local" "COVID-19" "Cases", size(small)  place(ne) just(left)) ///
		text(80 30 "{bf:2020.02.18}" "First" "Death Case", size(small)  place(ne) just(left)) ///
		text(50 140 "{bf:2020.06.07}" "Regulation" "Lift", size(small)  place(ne) just(left))

graph export "$figure/Figure_A2_`y'_TW.png", as(png) replace
}


collapse (sum)hits*, by(normweek)


foreach y in "coronavirus" "sanitizer" "mask"{

twoway 	(line hits_`y' normweek), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xtitle("Weeks from the 4th week of a year") ///
		ytitle("Sum of Daily Google Trend Serching Index") ///
		xlabel(-5(5)45) xscale(range(-6 48)) ///
		ylabel(0(100)600) yscale(range(0 600)) ///
		xline(0, lp(dash)) xline(1, lp(dash)) ///
		xline(4, lp(dash)) xline(20, lp(dash)) ///
		text(300 -0.5 "{bf:2020.01.21}" "First" "COVID-19" "Cases", size(small) place(nw) just(right)) ///
		text(0 1.5  "{bf:2020.01.28}" "First Local" "COVID-19" "Cases", size(small)  place(ne) just(left)) ///
		text(500 4.5  "{bf:2020.02.18}" "First" "Death Case", size(small)  place(ne) just(left)) ///
		text(200 20.5  "{bf:2020.06.07}" "Regulation" "Lift", size(small)  place(ne) just(left))
	
graph export "$figure/Figure_A1_`y'_TW.png", as(png) replace
}
