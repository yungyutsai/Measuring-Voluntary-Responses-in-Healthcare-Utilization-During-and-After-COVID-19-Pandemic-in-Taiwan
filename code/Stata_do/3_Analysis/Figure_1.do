clear 
set more off

import delimited "$rdata/NHI/Weekly_Confirmation_Age_County_Gender_19CoV.csv", encoding(UTF-8) clear
gen year = 研判年份
gen week = 研判週別
rename 確定病例數 cases
gen local = 是否為境外移入 == "否" //Local case

collapse (sum)cases, by(year week local)

reshape wide cases, i(year week) j(local)
recode cases0 . = 0
recode cases1 . = 0
gen all_cases = cases0 + cases1
gen local_cases = cases1

keep year week all_cases local_cases
order year week all_cases local_cases

save "$wdata/NHI/cov19_new_cases_weekly.dta", replace

keep if year == 2020

twoway	(bar all_cases week, fcolor(gs12) fintensity(50) lcolor(gs4) lwidth(vthin)) ///
		(bar local_cases week, fcolor(gs2) fintensity(50) lcolor(gs4) lwidth(vthin)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xlabel(5(5)50) xscale(range(1 52)) yscale(range(0 130)) ylabel(0(20)120, angle(0)) ///
		leg(col(1) order(2 "Number of New Local Confirmed Cases" 1 "Number of New Non-Local Confirmed Cases") ///
		ring(0) position(2) size(small) symxsize(3pt)) ///
		xtitle("Week") ytitle("Number of New Confirmed Cases")
graph export "$figure/Fig1.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/Fig1.eps", as(eps) replace fontface("Times New Roman")

