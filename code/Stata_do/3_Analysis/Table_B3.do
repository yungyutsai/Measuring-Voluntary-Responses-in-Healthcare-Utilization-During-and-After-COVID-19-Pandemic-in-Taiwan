local var = "total flu non_flu"
local did = "covid19 treatment post"
local control1 = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10"
local control2 = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp ageb14 age1564 agea65 gender_ratio postsecondary secondary lower"
local control3 = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp ageb14 age1564 agea65 gender_ratio postsecondary secondary lower"
local control4 = "i.eve i.ny i.cny i.peace i.qingming i.labor i.dragon i.moon i.double10 Temp Precp"
local absorb1 = "year week"
local absorb2 = "year week"
local absorb3 = "year week city_no"
local absorb4 = "city_no#c.yweek city_no#year city_no#week"    

clear
set more off

foreach x in `var' {
foreach y in opd ipd{
	
use "$wdata/NHI_`y'_for_analysis.dta", clear
gen postsecondary = graduate + college + juniorcollege
gen secondary = highschool + juniorhigh
gen lower = primary + illiterate
replace `x' = `x' / population * 100000

forv i = 1(1)4{

sum `x' if treatment == 1 & inrange(week,1,3) //Baseline Mean as the 1st to 3rd week
local mean = `r(mean)'

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl city_cd)

if "`y'" == "opd" & `i' == 1{
outreg2 using "$table/temp/Table_B3a_`x'", ///
replace title("Outcomes: `x'") ctitle(`y') nocon keep(covid19) dec(2) alpha(0.001, 0.01, 0.05) eform st(coef se ci_low ci_high)
}
else{
outreg2 using "$table/temp/Table_B3a_`x'", ///
append title("Outcomes: `x'") ctitle(`y') nocon keep(covid19) dec(2) alpha(0.001, 0.01, 0.05) eform st(coef se ci_low ci_high)
}

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl yearweek)

if "`y'" == "opd" & `i' == 1{
outreg2 using "$table/temp/Table_B3b_`x'", ///
replace title("Outcomes: `x'") ctitle(`y') nocon keep(covid19) dec(2) alpha(0.001, 0.01, 0.05) eform st(coef se ci_low ci_high)
}
else{
outreg2 using "$table/temp/Table_B3b_`x'", ///
append title("Outcomes: `x'") ctitle(`y') nocon keep(covid19) dec(2) alpha(0.001, 0.01, 0.05) eform st(coef se ci_low ci_high)
}

}
}
import delimited using "$table/temp/Table_B3a_`x'.txt", clear
save "$table/temp/Table_B3a_`x'.dta", replace
import delimited using "$table/temp/Table_B3b_`x'.txt", clear
save "$table/temp/Table_B3b_`x'.dta", replace
}

clear
ap using "$table/temp/Table_B3a_total.dta"
ap using "$table/temp/Table_B3b_total.dta"
ap using "$table/temp/Table_B3a_flu.dta"
ap using "$table/temp/Table_B3b_flu.dta"
ap using "$table/temp/Table_B3a_non_flu.dta"
ap using "$table/temp/Table_B3b_non_flu.dta"

keep if inrange(_n,4,8) | inrange(_n,19,20) | ///
		inrange(_n,28,32) | inrange(_n,43,44) | ///
		inrange(_n,52,56) | inrange(_n,67,68) | inrange(_n,70,72)

foreach var of varlist v2-v9{
	replace `var' = subinstr(`var',"*","",.)
	replace `var' = subinstr(`var',"(","",.) if mod(_n,7) == 5 | mod(_n,7) == 0
	replace `var' = subinstr(`var',")","",.) if mod(_n,7) == 5 | mod(_n,7) == 0
	replace `var' = "[" + `var'[_n-1] + "," + `var' + "]"  if mod(_n,7) == 5
	replace `var' = "{" + `var'[_n-1] + "," + `var' + "}"  if mod(_n,7) == 0
}
drop if mod(_n,7) == 3 | mod(_n,7) == 4 | mod(_n,7) == 6


replace v1 = "\multicolumn{9}{@{}l@{}}{\textbf{Panel A:} All diseases}" in 1 
replace v1 = "\multicolumn{9}{@{}l@{}}{\textbf{Panel B:} ILI diseases}" in 5
replace v1 = "\multicolumn{9}{@{}l@{}}{\textbf{Panel C:} Non-ILI diseases}" in 9
replace v1 = "\$Y_{2020} \times Post$" if v1 == "covid19"
replace v1 = "Cluster at county level" if mod(_n,4) == 3
replace v1 = "Cluster at year-week level" if mod(_n,4) == 0

drop in 14

export excel using "$table/Table_B3.xlsx", replace

drop in 13


texsaveyt 	_all using "$tex/tables/TabB3_temp.tex", replace ///
			title ("Robustness check: Clustering levels of standard errors (DID design)") nonames ///
			headerlines("& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\ \cmidrule(r){2-5} \cmidrule(l){6-9} & \multicolumn{4}{c}{Outpatient Care} & \multicolumn{4}{c}{Inpatient Care}") ///
			bottomlines("Observation & \multicolumn{8}{c}{8,008} \\ Basic control & \checkmark & \checkmark & \checkmark & \checkmark & \checkmark & \checkmark& \checkmark & \checkmark  \\ Demographic variables & & \checkmark & \checkmark & & & \checkmark & \checkmark &  \\ Weather variables & & \checkmark & \checkmark & \checkmark & & \checkmark & \checkmark & \checkmark \\ County fixed effect & & & \checkmark & \checkmark & & & \checkmark & \checkmark \\ County-by-year fixed effect & & & & \checkmark & & & & \checkmark \\ County-by-week fixed effect & & & & \checkmark & & & & \checkmark \\ County specific time trend & & & & \checkmark & & & & \checkmark \\") ///
			hlines(0 4 8 12 12) nofix size(footnotesize) align(@{}lcccccccc@{}) ///
			label(did_table_app) frag rh(1.25) cs(1) ///
			footnote("This table shows the incidence-rate ratios (IRR) for the estimated $\gamma_{0}$ (i.e. the coefficient on $Y_{2020} \times Post_{d}$) in the equation (\ref{eq:eq1}), which is a Poisson regression. Sample period is 2014--2020. {\textit Basic Control} includes the year fixed effect, the week fixed effect and various holiday dummies such as, New Year Eve, New Year, Lunar New Year, Peace Memorial Day, Qing-Ming Festival, Labor's Day, and Dragon Boat Festival, Moon Festival, and National Day. {\textit Demographic Variables} includes annually county-level age structure, sex ratio, educational attainment. {\textit Weather Variables} includes weekly county-level temperatures and precipitation. All regressions are weighted by the monthly population size of a county. 95\% CI computed with standard errors clustered at the county level reported in squared brackets. 95\% CI computed with standard errors clustered at the year-week reported in curly brackets. \\ $^{*} p < 0.05 ~~^{**} p < 0.01 ~~^{***} p < 0.001$")
			
filefilter "$tex/tables/TabB3_temp.tex" "$tex/tables/TabB3.tex", from("&&&&&&&&") to("") replace
cap rm "$tex/tables/TabB3_temp.tex"
