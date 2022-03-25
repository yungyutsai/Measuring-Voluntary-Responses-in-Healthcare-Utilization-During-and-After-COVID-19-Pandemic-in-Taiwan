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
			gen TxCOVIDFree`i' = COVIDFree == 1 & treat`i' == 1
		}
	}
drop num* rank*
save "$wdata/NHI_`y'_for_placebo.dta", replace 
}


** Placebo Estimates
cap mkdir "$figure/temp"
cap rm "$figure/temp/Figure_5.dta"
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

		ppmlhdfe `x' TxPandemic`i' TxCOVIDFree`i' treat`i' post `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek)
		parmest , saving("$figure/temp/Figure_5_temp.dta", replace) idstr("`y',`x'") idnum(`i') eform
		
		if "`x'" == "total" & "`y'" == "opd" & `i' == 1{
			use "$figure/temp/Figure_5_temp.dta", clear
			keep if substr(parm,1,7) == "TxPande" | substr(parm,1,7) == "TxCOVID"
			save "$figure/temp/Figure_5.dta", replace
		}
		else{
			use "$figure/temp/Figure_5.dta", clear
			ap using "$figure/temp/Figure_5_temp.dta"
			keep if substr(parm,1,7) == "TxPande" | substr(parm,1,7) == "TxCOVID"
			save "$figure/temp/Figure_5.dta", replace
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

ppmlhdfe `x' TxPandemic TxCOVIDFree treatment post `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek)
parmest , saving("$figure/temp/Figure_5_temp.dta", replace) idstr("`y',`x'") idnum(0) eform
		
use "$figure/temp/Figure_5.dta", clear
ap using "$figure/temp/Figure_5_temp.dta"
keep if substr(parm,1,7) == "TxPande" | substr(parm,1,7) == "TxCOVID"
save "$figure/temp/Figure_5.dta", replace

}
}

** Graphing
use "$figure/temp/Figure_5.dta", clear

replace parm = substr(parm,1,5)


sum estimate if ids == "opd,flu"

sum estimate if parm == "TxPan" & ids == "opd,flu" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.01
sum estimate if parm == "TxCOV" & ids == "opd,flu" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.01

twoway 	(hist estimate if parm == "TxPan" & ids == "opd,flu" & idn > 0, lc(maroon%0) fc(erose) frac start(0.5) width(0.015)) ///
		(hist estimate if parm == "TxCOV" & ids == "opd,flu" & idn > 0, lc(navy) fc(none) lw(thin) frac start(0.5) width(0.015)) ///
		(scatteri 0 `main1' 0.15 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.15 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(0.5 1.2)) xlabel(0.5(0.1)1.2, format(%4.1f)) ylabel(0(0.03)0.15, angle(0) format(%4.2f)) ///
		text(0.12 `textpos1' "Real Estimate" "(Pandemic Period)", place(ne) color(maroon) size(vsmall)) ///
		text(0.09 `textpos2' "Real Estimate" "(COVID-Free Period)", place(ne) color(navy) size(vsmall)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (Pandemic Period)" 2 "Placebo Estimates (COVID-Free Period)") size(vsmall) symxsize(6pt)) ///
		title("(A) Outpatient care: ILI diseases", color(black) size(medlarge) margin(medium)) ///
		name("Fig5_opd_flu", replace) fxsize(100) fysize(80)
		

sum estimate if ids == "opd,non_flu"

sum estimate if parm == "TxPan" & ids == "opd,non_flu" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.0025
sum estimate if parm == "TxCOV" & ids == "opd,non_flu" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.0025

twoway 	(hist estimate if parm == "TxPan" & ids == "opd,non_flu" & idn > 0, lc(maroon%0) fc(erose) frac start(0.8) width(0.005)) ///
		(hist estimate if parm == "TxCOV" & ids == "opd,non_flu" & idn > 0, lc(navy) fc(none) lw(thin) frac start(0.8) width(0.005)) ///
		(scatteri 0 `main1' 0.15 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.15 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(0.80 1.06)) xlabel(0.8(0.05)1.05, format(%4.2f)) ylabel(0(0.03)0.15, angle(0) format(%4.2f)) ///
		text(0.12 `textpos1' "Real Estimate" "(Pandemic Period)", place(ne) color(maroon) size(vsmall)) ///
		text(0.14 `textpos2' "Real Estimate" "(COVID-Free Period)", place(ne) color(navy) size(vsmall)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (Pandemic Period)" 2 "Placebo Estimates (COVID-Free Period)") size(vsmall) symxsize(6pt)) ///
		title("(B) Outpatient care: Non-ILI diseases", color(black) size(medlarge) margin(medium)) ///
		name("Fig5_opd_non_flu", replace) fxsize(100) fysize(80)	


sum estimate if ids == "ipd,flu"

sum estimate if parm == "TxPan" & ids == "ipd,flu" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.005
sum estimate if parm == "TxCOV" & ids == "ipd,flu" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.005

twoway 	(hist estimate if parm == "TxPan" & ids == "ipd,flu" & idn > 0, lc(maroon%0) fc(erose) frac start(0.5) width(0.018)) ///
		(hist estimate if parm == "TxCOV" & ids == "ipd,flu" & idn > 0, lc(navy) fc(none) lw(thin) frac start(0.5) width(0.018)) ///
		(scatteri 0 `main1' 0.15 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.15 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(0.59 1.32)) xlabel(0.5(0.1)1.3, format(%4.1f)) ylabel(0(0.03)0.15, angle(0) format(%4.2f)) ///
		text(0.12 `textpos1' "Real Estimate" "(Pandemic Period)", place(ne) color(maroon) size(vsmall)) ///
		text(0.09 `textpos2' "Real Estimate" "(COVID-Free Period)", place(ne) color(navy) size(vsmall)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (Pandemic Period)" 2 "Placebo Estimates (COVID-Free Period)") size(vsmall) symxsize(6pt)) ///
		title("(C) Inpatient care: ILI diseases", color(black) size(medlarge) margin(medium)) ///
		name("Fig5_ipd_flu", replace) fxsize(100) fysize(80)
		
		
sum estimate if ids == "ipd,non_flu"

sum estimate if parm == "TxPan" & ids == "ipd,non_flu" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.003
sum estimate if parm == "TxCOV" & ids == "ipd,non_flu" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.003

twoway 	(hist estimate if parm == "TxPan" & ids == "ipd,non_flu" & idn > 0, lc(maroon%0) fc(erose) frac start(0.9) width(0.0085)) ///
		(hist estimate if parm == "TxCOV" & ids == "ipd,non_flu" & idn > 0, lc(navy) fc(none) lw(thin) frac start(0.9) width(0.0085)) ///
		(scatteri 0 `main1' 0.15 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.15 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(0.91 1.31)) xlabel(0.9(0.1)1.3, format(%4.1f)) ylabel(0(0.03)0.15, angle(0) format(%4.2f)) ///
		text(0.13 `textpos1' "Real Estimate" "(Pandemic Period)", place(ne) color(maroon) size(vsmall)) ///
		text(0.10 `textpos2' "Real Estimate" "(COVID-Free Period)", place(ne) color(navy) size(vsmall)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (Pandemic Period)" 2 "Placebo Estimates (COVID-Free Period)") size(vsmall) symxsize(6pt)) ///
		title("(D) Inpatient care: Non-ILI diseases", color(black) size(medlarge) margin(medium)) ///
		name("Fig5_ipd_non_flu", replace) fxsize(100) fysize(80)


grc1leg Fig5_opd_flu Fig5_opd_non_flu Fig5_ipd_flu Fig5_ipd_non_flu, scheme(s1color) cols(2) legendfrom(Fig5_opd_flu) imargin(0 0 0 0) saving(Fig5, replace)
graph display, ysize(65) xsize(79.25)

graph export "$figure/Fig5.eps", as(eps) replace fontface("Times New Roman")
cap graph export "$tex/Fig5.eps", as(eps) replace fontface("Times New Roman")
