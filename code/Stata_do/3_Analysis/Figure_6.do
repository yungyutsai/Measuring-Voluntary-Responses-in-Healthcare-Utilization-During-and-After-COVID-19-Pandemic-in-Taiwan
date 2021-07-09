local var = "total infection non_infection"
local control = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb = "city_no#year city_no#week"

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
			gen TxPostPandemic`i' = PostPandemic == 1 & treat`i' == 1
		}
	}
drop num* rank*
save "$wdata/NHI_`y'_for_placebo.dta", replace 
}

** Placebo Estimates
cap mkdir "$figure/temp"
cap rm "$figure/temp/Figure_6.dta"
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

		ppmlhdfe `x' TxPandemic`i' TxPostPandemic`i' treat`i' post `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek) exp(population)
		parmest , saving("$figure/temp/Figure_6_temp.dta", replace) idstr("`y',`x'") idnum(`i')
		
		if "`x'" == "total" & "`y'" == "opd" & `i' == 1{
			use "$figure/temp/Figure_6_temp.dta", clear
			keep if substr(parm,1,7) == "TxPande" | substr(parm,1,7) == "TxPostP"
			save "$figure/temp/Figure_6.dta", replace
		}
		else{
			use "$figure/temp/Figure_6.dta", clear
			ap using "$figure/temp/Figure_6_temp.dta"
			keep if substr(parm,1,7) == "TxPande" | substr(parm,1,7) == "TxPostP"
			save "$figure/temp/Figure_6.dta", replace
		}
	}
	}

}
}

** Re estimate Main Specification
local var = "total infection non_infection"
local control = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb = "city_no#year city_no#week"

foreach x in `var' {
foreach y in opd ipd{

use $wdata/NHI_`y'_for_analysis.dta, clear

ppmlhdfe `x' TxPandemic TxPostPandemic treatment post `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek) exp(population)
parmest , saving($figure/temp/Figure_6_temp.dta, replace) idstr("`y',`x'") idnum(0)
		
use "$figure/temp/Figure_6.dta", clear
ap using "$figure/temp/Figure_6_temp.dta"
keep if substr(parm,1,7) == "TxPande" | substr(parm,1,7) == "TxPostP"
save "$figure/temp/Figure_6.dta", replace

}
}

** Graphing
use "$figure/temp/Figure_6.dta", clear

replace parm = substr(parm,1,5)

sum estimate if parm == "TxPan" & ids == "ipd,infection" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.01
sum estimate if parm == "TxPos" & ids == "ipd,infection" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.01

twoway 	(hist estimate if parm == "TxPan" & ids == "ipd,infection" & idn > 0, lc(maroon%50) fc(maroon%50) frac start(-0.5) width(0.02)) ///
		(hist estimate if parm == "TxPos" & ids == "ipd,infection" & idn > 0, lc(navy%50) fc(navy%50) frac start(-0.5) width(0.02)) ///
		(scatteri 0 `main1' 0.14 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.14 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.5 0.35)) xlabel(-0.45(0.15)0.3) ylabel(0(0.02)0.14) ///
		text(0.1 `textpos1' "Real Estimate" "(During Pandemic)", place(ne) color(maroon) size(small)) ///
		text(0.08 `textpos2' "Real Estimate" "(After Pandemic)", place(ne) color(navy) size(small)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (During Pandemic)" 2 "Placebo Estimates (After Pandemic)") size(small))
graph export "$figure/Figure_6_ipd_infectious.png", as(png) replace

sum estimate if parm == "TxPan" & ids == "opd,infection" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.01
sum estimate if parm == "TxPos" & ids == "opd,infection" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.01

twoway 	(hist estimate if parm == "TxPan" & ids == "opd,infection" & idn > 0, lc(maroon%50) fc(maroon%50) frac start(-0.5) width(0.02)) ///
		(hist estimate if parm == "TxPos" & ids == "opd,infection" & idn > 0, lc(navy%50) fc(navy%50) frac start(-0.5) width(0.02)) ///
		(scatteri 0 `main1' 0.15 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.15 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.62 0.22)) xlabel(-0.6(0.1)0.2) ylabel(0(0.03)0.15) ///
		text(0.1 `textpos1' "Real Estimate" "(During Pandemic)", place(ne) color(maroon) size(small)) ///
		text(0.08 `textpos2' "Real Estimate" "(After Pandemic)", place(ne) color(navy) size(small)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (During Pandemic)" 2 "Placebo Estimates (After Pandemic)") size(small))
graph export "$figure/Figure_6_opd_infectious.png", as(png) replace


sum estimate if parm == "TxPan" & ids == "ipd,non_infection" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.002
sum estimate if parm == "TxPos" & ids == "ipd,non_infection" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.002

twoway 	(hist estimate if parm == "TxPan" & ids == "ipd,non_infection" & idn > 0, lc(maroon%50) fc(maroon%50) frac start(-0.12) width(0.01)) ///
		(hist estimate if parm == "TxPos" & ids == "ipd,non_infection" & idn > 0, lc(navy%50) fc(navy%50) frac start(-0.12) width(0.01)) ///
		(scatteri 0 `main1' 0.17 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.17 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.12 0.32)) xlabel(-0.10(0.05)0.3) ylabel(0(0.04)0.16) ///
		text(0.155 `textpos1' "Real Estimate" "(During Pandemic)", place(ne) color(maroon) size(small)) ///
		text(0.145 `textpos2' "Real Estimate" "(After Pandemic)", place(ne) color(navy) size(small)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (During Pandemic)" 2 "Placebo Estimates (After Pandemic)") size(small))
graph export "$figure/Figure_6_ipd_non_infection.png", as(png) replace


sum estimate if parm == "TxPan" & ids == "opd,non_infection" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.002
sum estimate if parm == "TxPos" & ids == "opd,non_infection" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.002

twoway 	(hist estimate if parm == "TxPan" & ids == "opd,non_infection" & idn > 0, lc(maroon%50) fc(maroon%50) frac start(-0.1) width(0.005)) ///
		(hist estimate if parm == "TxPos" & ids == "opd,non_infection" & idn > 0, lc(navy%50) fc(navy%50) frac start(-0.1) width(0.005)) ///
		(scatteri 0 `main1' 0.12 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.12 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.19 0.1)) xlabel(-0.18(0.03)0.09) ylabel(0(0.02)0.12) ///
		text(0.1 `textpos1' "Real Estimate" "(During Pandemic)", place(ne) color(maroon) size(small)) ///
		text(0.1 `textpos2' "Real Estimate" "(After Pandemic)", place(ne) color(navy) size(small)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (During Pandemic)" 2 "Placebo Estimates (After Pandemic)") size(small))
graph export "$figure/Figure_6_opd_non_infection.png", as(png) replace

sum estimate if parm == "TxPan" & ids == "ipd,total" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.002
sum estimate if parm == "TxPos" & ids == "ipd,total" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.002

twoway 	(hist estimate if parm == "TxPan" & ids == "ipd,total" & idn > 0, lc(maroon%50) fc(maroon%50) frac start(-0.12) width(0.01)) ///
		(hist estimate if parm == "TxPos" & ids == "ipd,total" & idn > 0, lc(navy%50) fc(navy%50) frac start(-0.12) width(0.01)) ///
		(scatteri 0 `main1' 0.17 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.17 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.12 0.32)) xlabel(-0.10(0.05)0.3) ylabel(0(0.04)0.16) ///
		text(0.160 `textpos1' "Real Estimate" "(During Pandemic)", place(ne) color(maroon) size(small)) ///
		text(0.140 `textpos2' "Real Estimate" "(After Pandemic)", place(ne) color(navy) size(small)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (During Pandemic)" 2 "Placebo Estimates (After Pandemic)") size(small))
graph export "$figure/Figure_6_ipd_total.png", as(png) replace


sum estimate if parm == "TxPan" & ids == "opd,total" & idn == 0
local main1 = r(mean)
local textpos1 = `main1' + 0.002
sum estimate if parm == "TxPos" & ids == "opd,total" & idn == 0
local main2 = r(mean)
local textpos2 = `main2' + 0.002

twoway 	(hist estimate if parm == "TxPan" & ids == "opd,total" & idn > 0, lc(maroon%50) fc(maroon%50) frac start(-0.1) width(0.005)) ///
		(hist estimate if parm == "TxPos" & ids == "opd,total" & idn > 0, lc(navy%50) fc(navy%50) frac start(-0.1) width(0.005)) ///
		(scatteri 0 `main1' 0.1 `main1', recast(line) lc(maroon) lp(dash)) ///
		(scatteri 0 `main2' 0.1 `main2', recast(line) lc(navy) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.22 0.1)) xlabel(-0.21(0.03)0.09) ylabel(0(0.02)0.1) ///
		text(0.08 `textpos1' "Real Estimate" "(During Pandemic)", place(ne) color(maroon) size(small)) ///
		text(0.08 `textpos2' "Real Estimate" "(After Pandemic)", place(ne) color(navy) size(small)) ///
		xtitle(Placebo Estimate) ytitle(Fraction) ///
		legend(order(1 "Placebo Estimates (During Pandemic)" 2 "Placebo Estimates (After Pandemic)") size(small))
graph export "$figure/Figure_6_opd_total.png", as(png) replace
