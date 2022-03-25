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
capture log close

cap mkdir "$table/temp"

foreach x in `var' {
foreach y in opd ipd{
	
use "$wdata/NHI_`y'_for_analysis.dta", clear
gen postsecondary = graduate + college + juniorcollege
gen secondary = highschool + juniorhigh
gen lower = primary + illiterate
replace `x' = `x' / population * 100000

forv i = 1(1)4{

ppmlhdfe `x' `did' `control`i'' [pweight = population], absorb(`absorb`i'') vce(cl city_cd yearweek)

if "`y'" == "opd" & `i' == 1{
outreg2 using "$table/temp/Table_2_`x'", ///
replace title("Outcomes: `x'") ctitle(`y') nocon keep(covid19) dec(2) alpha(0.001, 0.01, 0.05) eform st(coef se ci_low ci_high)
}
else{
outreg2 using "$table/temp/Table_2_`x'", ///
append title("Outcomes: `x'") ctitle(`y') nocon keep(covid19) dec(2) alpha(0.001, 0.01, 0.05) eform st(coef se ci_low ci_high)
}
}
}
clear
import delimited "$table/temp/Table_2_`x'.txt"
save "$table/temp/Table_2_`x'.dta", replace
}

use "$table/temp/Table_2_total.dta", clear
ap using "$table/temp/Table_2_flu.dta"
ap using "$table/temp/Table_2_non_flu.dta"

keep if inrange(_n,4,9) | inrange(_n,16,21) | inrange(_n,28,34)

replace v1 = "\multicolumn{9}{@{}l@{}}{\textbf{Panel A:} All diseases}" in 1 
replace v1 = "\multicolumn{9}{@{}l@{}}{\textbf{Panel B:} ILI diseases}" in 7
replace v1 = "\multicolumn{9}{@{}l@{}}{\textbf{Panel C:} Non-ILI diseases}" in 13
replace v1 = "\$Y_{2020} \times Post$" if v1 == "covid19"

foreach var of varlist v2-v9{
	replace `var' = subinstr(`var',"(","",.) if mod(_n,6) == 5
	replace `var' = subinstr(`var',")","",.) if mod(_n,6) == 5
	replace `var' = "[" + `var'[_n-2] + "," + `var'[_n-1] + "]"  if mod(_n,6) == 0
}
drop if mod(_n,6) == 4 | mod(_n,6) == 5

export excel using "$table/Table_2.xlsx", replace

drop in 13

texsaveyt 	_all using "$tex/tables/Tab2_temp.tex", replace ///
			title ("Effects of COVID-19 outbreak on non-COVID-19 health utilization") nonames ///
			headerlines("& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\ \cmidrule(r){2-5} \cmidrule(l){6-9} & \multicolumn{4}{c}{Outpatient Care} & \multicolumn{4}{c}{Inpatient Care}") ///
			bottomlines("Observation & \multicolumn{8}{c}{8,008} \\ Basic control & \checkmark & \checkmark & \checkmark & \checkmark & \checkmark & \checkmark& \checkmark & \checkmark  \\ Demographic variables & & \checkmark & \checkmark & & & \checkmark & \checkmark &  \\ Weather variables & & \checkmark & \checkmark & \checkmark & & \checkmark & \checkmark & \checkmark \\ County fixed effect & & & \checkmark & \checkmark & & & \checkmark & \checkmark \\ County-by-year fixed effect & & & & \checkmark & & & & \checkmark \\ County-by-week fixed effect & & & & \checkmark & & & & \checkmark \\ County specific time trend & & & & \checkmark & & & & \checkmark \\") ///
			hlines(0 4 8 12 12) nofix size(footnotesize) align(@{}lcccccccc@{}) ///
			label(did_table) frag rh(1.25) cs(1) ///
			footnote("This table shows the incidence-rate ratios (IRR) for the estimated $\gamma_{0}$ (i.e. the coefficient on \$Y_{2020} \times Post_{d}$) in the equation (\ref{eq:eq1}), which is a Poisson regression. Sample period is 2014--2020. {\textit Basic Control} includes the year fixed effect, the week fixed effect and various holiday dummies such as, New Year Eve, New Year, Lunar New Year, Peace Memorial Day, Qing-Ming Festival, Labor's Day, and Dragon Boat Festival, Moon Festival, and National Day. {\textit Demographic Variables} includes annually county-level age structure, sex ratio, educational attainment. {\textit Weather Variables} includes weekly county-level temperatures and precipitation. All regressions are weighted by the monthly population size of a county. Robust standard errors clustered at the year-week and county levels are reported in parentheses. 95\% CI reported in squared brackets. \\ $^{*} p < 0.05 ~~^{**} p < 0.01 ~~^{***} p < 0.001$")

			
filefilter "$tex/tables/Tab2_temp.tex" "$tex/tables/Tab2.tex", from("&&&&&&&&") to("") replace
cap rm "$tex/tables/Tab2_temp.tex"

