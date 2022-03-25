local var = "total flu non_flu"
local control = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb = "city_no#c.yweek city_no#year city_no#week"

clear
set more off

clear matrix
clear mata
set maxvar 9999
set seed 20200518

* create 1000 random variables
foreach y in opd ipd{
	qui use "$wdata/NHI_`y'_for_analysis.dta", clear
	qui drop if year >= 2020
	forv i = 1(1)1000{
	if `i' == 1 {
		dis "Create Ramdom Variables for `y' Sample (1000)"
		dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
	}
	_dots `i' 0
		qui{
			bys city_no: gen num`i' = runiform() if week == 1
			bys city_no: egen rank`i' = rank(num`i')
			egen minrank`i' = min(rank`i'), by(city_no year)
		
			gen treat`i' = 0
			replace treat`i' = 1 if minrank`i' == 1

			gen covid19`i' = 0
			replace covid19`i' = 1 if treat`i' == 1 & post == 1

			gen TxPandemic`i' = Pandemic == 1 & treat`i' == 1
			gen TxCOVIDFree`i' = TxCOVIDFree == 1 & treat`i' == 1
		}
	}
drop num* rank*
save "$wdata/NHI_`y'_for_placebo.dta", replace 
}

** Placebo Estimates
cap mkdir "$figure/temp"
cap rm "$figure/temp/Figure_4.dta"
foreach x in `var' {
foreach y in opd ipd{
		
	forv i = 1(1)1000{
	if `i' == 1 {
		dis "Running Placebo Test for `y' Sample, Outcomes `x' (1000)"
		dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
	}
	_dots `i' 0
	
	qui{
		use "$wdata/NHI_`y'_for_placebo.dta", clear
		replace `x' = `x' / population * 100000

		ppmlhdfe `x' covid19`i' treat`i' post `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek)
		parmest , saving("$figure/temp/Figure_4_temp.dta", replace) idstr("`y',`x'") idnum(`i') eform
		
		if "`x'" == "total" & "`y'" == "opd" & `i' == 1{
			use "$figure/temp/Figure_4_temp.dta", clear
			keep if substr(parm,1,7) == "covid19"
			save "$figure/temp/Figure_4.dta", replace
		}
		else{
			use "$figure/temp/Figure_4.dta", clear
			ap using "$figure/temp/Figure_4_temp.dta"
			keep if substr(parm,1,7) == "covid19"
			save "$figure/temp/Figure_4.dta", replace
		}		
	}
	}

}
}

** Re estimate Main Specification

foreach x in `var' {
foreach y in opd ipd{
use "$wdata/NHI_`y'_for_analysis.dta", clear
replace `x' = `x' / population * 100000

ppmlhdfe `x' covid19 treatment post `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek)
parmest , saving("$figure/temp/Figure_4_temp.dta", replace) idstr("`y',`x'") idnum(0) eform

use "$figure/temp/Figure_4.dta", clear
ap using "$figure/temp/Figure_4_temp.dta"
keep if substr(parm,1,7) == "covid19"
save "$figure/temp/Figure_4.dta", replace
}
}


** Graphing
use "$figure/temp/Figure_4.dta", clear

replace parm = substr(parm,1,5)

sum estimate if parm == "covid" & ids == "opd,flu"		
sum estimate if parm == "covid" & ids == "opd,flu" & idn == 0
local main = r(mean)
local textpos = `main' + 0.015
twoway 	(hist estimate if parm == "covid" & ids == "opd,flu" & idn > 0, lc(gs10) fc(gs12) frac bin(15)) ///
		(scatteri 0 `main' 0.15 `main', recast(line) lc(maroon) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(0.6 1.2)) xlabel(0.6(0.1)1.2, format(%4.1f)) ///
		ylabel(0(0.03)0.15, angle(0) format(%4.2f)) legend(off)  ///
		text(0.065 `textpos' "Real Estimate", place(ne) color(maroon) size(small)) ///
		xtitle(Placebo Estimates) ytitle(Fraction) ///
		title("(A) Outpatient care: ILI diseases", color(black) size(medlarge) margin(medium)) ///
		name("Fig4_opd_flu", replace) fxsize(100) fysize(80)

sum estimate if parm == "covid" & ids == "opd,non_flu"
sum estimate if parm == "covid" & ids == "opd,non_flu" & idn == 0
local main = r(mean)
local textpos = `main' + 0.006
twoway 	(hist estimate if parm == "covid" & ids == "opd,non_flu" & idn > 0, lc(gs10) fc(gs12) frac bin(20)) ///
		(scatteri 0 `main' 0.15 `main', recast(line) lc(maroon) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(0.9 1.05)) xlabel(0.9(0.05)1.05, format(%4.2f)) ///
		ylabel(0(0.03)0.15, angle(0) format(%4.2f)) legend(off)  ///
		text(0.085 `textpos' "Real Estimate", place(ne) color(maroon) size(small)) ///
		xtitle(Placebo Estimates) ytitle(Fraction) ///
		title("(B) Outpatient care: Non-ILI diseases", color(black) size(medlarge) margin(medium)) ///
		name("Fig4_opd_non_flu", replace) fxsize(100) fysize(80)		

sum estimate if parm == "covid" & ids == "ipd,flu"
sum estimate if parm == "covid" & ids == "ipd,flu" & idn == 0
local main = r(mean)
local textpos = `main' + 0.03
twoway 	(hist estimate if parm == "covid" & ids == "ipd,flu" & idn > 0, lc(gs10) fc(gs12) frac bin(20)) ///
		(scatteri 0 `main' 0.15 `main', recast(line) lc(maroon) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(0.6 1.3)) xlabel(0.6(0.1)1.3, format(%4.1f)) ///
		ylabel(0(0.03)0.15, angle(0) format(%4.2f)) legend(off)  ///
		text(0.085 `textpos' "Real Estimate", place(ne) color(maroon) size(small)) ///
		xtitle(Placebo Estimates) ytitle(Fraction) ///
		title("(C) Inpatient care: ILI diseases", color(black) size(medlarge) margin(medium)) ///
		name("Fig4_ipd_flu", replace) fxsize(100) fysize(80)

sum estimate if parm == "covid" & ids == "ipd,non_flu"
sum estimate if parm == "covid" & ids == "ipd,non_flu" & idn == 0
local main = r(mean)
local textpos = `main' + 0.005
twoway 	(hist estimate if parm == "covid" & ids == "ipd,non_flu" & idn > 0, lc(gs10) fc(gs12) frac bin(35)) ///
		(scatteri 0 `main' 0.15 `main', recast(line) lc(maroon) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(0.9 1.3)) xlabel(0.9(0.1)1.3, format(%4.1f)) ///
		ylabel(0(0.03)0.15, angle(0) format(%4.2f)) legend(off)  ///
		text(0.095 `textpos' "Real Estimate", place(ne) color(maroon) size(small)) ///
		xtitle(Placebo Estimates) ytitle(Fraction) ///
		title("(D) Inpatient care: Non-ILI diseases", color(black) size(medlarge) margin(medium)) ///
		name("Fig4_ipd_non_flu", replace) fxsize(100) fysize(80)
		
		

graph combine Fig4_opd_flu Fig4_opd_non_flu Fig4_ipd_flu Fig4_ipd_non_flu, scheme(s1color) cols(2) imargin(0 0 0 0) saving(Fig4, replace)
graph display, ysize(65) xsize(79.25)

graph export "$figure/Fig4.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/Fig4.eps", as(eps) replace fontface("Times New Roman")
