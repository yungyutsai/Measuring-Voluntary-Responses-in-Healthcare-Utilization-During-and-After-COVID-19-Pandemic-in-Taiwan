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

		ppmlhdfe `x' covid19`i' treat`i' post `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek) exp(population)
		parmest , saving("$figure/temp/Figure_5_temp.dta", replace) idstr("`y',`x'") idnum(`i')
		
		if "`x'" == "total" & "`y'" == "opd" & `i' == 1{
			use "$figure/temp/Figure_5_temp.dta", clear
			keep if substr(parm,1,7) == "covid19"
			save "$figure/temp/Figure_5.dta", replace
		}
		else{
			use "$figure/temp/Figure_5.dta", clear
			ap using "$figure/temp/Figure_5_temp.dta"
			keep if substr(parm,1,7) == "covid19"
			save "$figure/temp/Figure_5.dta", replace
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

ppmlhdfe `x' covid19 treatment post `control' [pweight = population], absorb(`absorb') vce(cl city_cd yearweek) exp(population)
parmest , saving("$figure/temp/Figure_5_temp.dta", replace) idstr("`y',`x'") idnum(0)

use "$figure/temp/Figure_5.dta", clear
ap using "$figure/temp/Figure_5_temp.dta"
keep if substr(parm,1,7) == "covid19"
save "$figure/temp/Figure_5.dta", replace
}
}


** Graphing
use "$figure/temp/Figure_5.dta", clear

replace parm = substr(parm,1,5)

sum estimate if parm == "covid" & ids == "ipd,infection" & idn == 0
local main = r(mean)
local textpos = `main' + 0.01
twoway 	(hist estimate if parm == "covid" & ids == "ipd,infection" & idn > 0, lc(gs10) fc(gs12) frac) ///
		(scatteri 0 `main' 0.1 `main', recast(line) lc(red) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.5 0.35)) xlabel(-0.45(0.15)0.3) ylabel(0(0.02)0.1) legend(off)  ///
		text(0.085 `textpos' "Real Estimate", place(ne) color(maroon)) ///
		xtitle(Placebo Estimates) ytitle(Fraction)
graph export "$figure/Figure_5_ipd_infectious.png", as(png) replace
		
sum estimate if parm == "covid" & ids == "opd,infection" & idn == 0
local main = r(mean)
local textpos = `main' + 0.005
twoway 	(hist estimate if parm == "covid" & ids == "opd,infection" & idn > 0, lc(gs10) fc(gs12) frac) ///
		(scatteri 0 `main' 0.08 `main', recast(line) lc(red) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.5 0.15)) xlabel(-0.45(0.15)0.15) ylabel(0(0.02)0.08) legend(off)  ///
		text(0.065 `textpos' "Real Estimate", place(ne) color(maroon)) ///
		xtitle(Placebo Estimates) ytitle(Fraction)
graph export "$figure/Figure_5_opd_infectious.png", as(png) replace
		
sum estimate if parm == "covid" & ids == "opd,non_infection" & idn == 0
local main = r(mean)
local textpos = `main' + 0.002
twoway 	(hist estimate if parm == "covid" & ids == "opd,non_infection" & idn > 0, lc(gs10) fc(gs12) frac) ///
		(scatteri 0 `main' 0.1 `main', recast(line) lc(red) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.11 0.11)) xlabel(-0.1(0.025)0.1) ylabel(0(0.02)0.1) legend(off)  ///
		text(0.085 `textpos' "Real Estimate", place(ne) color(maroon)) ///
		xtitle(Placebo Estimates) ytitle(Fraction)
graph export "$figure/Figure_5_opd_other.png", as(png) replace

sum estimate if parm == "covid" & ids == "ipd,non_infection" & idn == 0
local main = r(mean)
local textpos = `main' + 0.005
twoway 	(hist estimate if parm == "covid" & ids == "ipd,non_infection" & idn > 0, lc(gs10) fc(gs12) frac) ///
		(scatteri 0 `main' 0.18 `main', recast(line) lc(red) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.12 0.32)) xlabel(-0.1(0.05)0.3) ylabel(0(0.04)0.16) legend(off)  ///
		text(0.125 `textpos' "Real Estimate", place(ne) color(maroon)) ///
		xtitle(Placebo Estimates) ytitle(Fraction)
graph export "$figure/Figure_5_ipd_other.png", as(png) replace
		
sum estimate if parm == "covid" & ids == "opd,total" & idn == 0
local main = r(mean)
local textpos = `main' + 0.002
twoway 	(hist estimate if parm == "covid" & ids == "opd,total" & idn > 0, lc(gs10) fc(gs12) frac) ///
		(scatteri 0 `main' 0.08 `main', recast(line) lc(red) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.16 0.11)) xlabel(-0.15(0.05)0.1) ylabel(0(0.02)0.08) legend(off)  ///
		text(0.065 `textpos' "Real Estimate", place(ne) color(maroon)) ///
		xtitle(Placebo Estimates) ytitle(Fraction)
graph export "$figure/Figure_5_opd_total.png", as(png) replace

sum estimate if parm == "covid" & ids == "ipd,total" & idn == 0
local main = r(mean)
local textpos = `main' + 0.005
twoway 	(hist estimate if parm == "covid" & ids == "ipd,total" & idn > 0, lc(gs10) fc(gs12) frac) ///
		(scatteri 0 `main' 0.20 `main', recast(line) lc(red) lp(dash)), ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		xscale(range(-0.11 0.31)) xlabel(-0.1(0.05)0.3) ylabel(0(0.04)0.20) legend(off)  ///
		text(0.16 `textpos' "Real Estimate", place(ne) color(maroon)) ///
		xtitle(Placebo Estimates) ytitle(Fraction)
graph export "$figure/Figure_5_ipd_total.png", as(png) replace
