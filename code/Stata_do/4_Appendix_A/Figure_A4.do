clear 
set more off
capture log close

import delimited "$rdata/yougov/yougov-chart-mask.csv", encoding(UTF-8) clear

keep datetime taiwan usa
gen year = substr(date,1,4)
gen month = substr(date,6,2)
gen day = substr(date,9,2)
destring year, replace
destring month, replace
destring day, replace

gen date = mdy(month,day,year)
format date %tdCCYYMonDD
keep if year == 2020
keep date taiwan usa

twoway	(connect taiwan date, msiz(small))(connect us date, symbol(S) msiz(small)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		yscale(range(0 100)) ylabel(0(20)100, angle(0)) ///
		tlabel(21946(31)22250, format(%dm)) ///
		leg(col(2) order(1 "Taiwan" 2 "United States")) ///
		xtitle("Survey Date") ytitle("% of people who say they are:" "Wearing a face mask when in public places")
		

graph export "$figure/FigA4.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/FigA4.eps", as(eps) replace fontface("Times New Roman")
