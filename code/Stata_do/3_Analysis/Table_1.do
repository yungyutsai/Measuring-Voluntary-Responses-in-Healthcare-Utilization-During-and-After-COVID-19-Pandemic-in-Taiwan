clear
set more off

** Inpatient Admission
use "$wdata/NHI_ipd_for_analysis.dta", clear
keep if year >= 2014

merge m:1 yearweek using "$wdata/NHI/CDC_Flu_Pneumonia_death.dta"

gen postsecondary = graduate + college + juniorcollege
gen secondary = highschool + juniorhigh
gen lower = primary + illiterate
replace population = population / 1000
			 
collapse	(mean) perc_total 		(sd) sd1  = perc_total ///
			(mean) perc_flu			(sd) sd2  = perc_flu ///
			(mean) perc_non_flu 	(sd) sd3  = perc_non_flu ///
			(mean) death 			(sd) sd4  = death ///
			(mean) population		(sd) sd5  = population ///
			(mean) ageb14			(sd) sd6  = ageb14 ///
			(mean) age1564			(sd) sd7  = age1564 ///
			(mean) agea65			(sd) sd8  = agea65 ///
			(mean) gender_ratio		(sd) sd9 = gender_ratio ///
			(mean) postsecondary	(sd) sd10 = postsecondary ///
			(mean) secondary		(sd) sd11 = secondary ///
			(mean) lower			(sd) sd12 = lower ///
			(mean) Temperature		(sd) sd13  = Temperature ///
			(mean) Precp			(sd) sd14  = Precp ///
			(count) N = year, by(treatment post)

gsort -treatment post

xpose, clear v

rename v1 Treatment_Pre
rename v2 Treatment_Post
rename v3 Control_Pre
rename v4 Control_Post
rename _var Variable
order Variable
drop in 1/2

replace V = "" if substr(V,1,2) == "sd"

cap mkdir "$wdata/intermediate"
save "$wdata/intermediate/Summary_Stat.dta", replace

** Outpatient Visits
use "$wdata/NHI_opd_for_analysis.dta", clear
keep if year >= 2014
gen perc_influenza_like = influenza_like / population * 100000


collapse	(mean) perc_total 		(sd) sd1  = perc_total ///
			(mean) perc_flu			(sd) sd2  = perc_flu ///
			(mean) perc_non_flu 	(sd) sd3  = perc_non_flu ///
			, by(treatment post)
			
gsort -treatment post

xpose, clear v

rename v1 Treatment_Pre
rename v2 Treatment_Post
rename v3 Control_Pre
rename v4 Control_Post
rename _var Variable
order Variable
drop in 1/2

replace V = "" if substr(V,1,2) == "sd"

ap using "$wdata/intermediate/Summary_Stat.dta"
tostring T* C*, format(%15.2fc) replace force
foreach x of varlist T* C*{
	replace `x' = "("+`x'+")" if mod(_n,2) == 0
}


local N = _N + 3
set obs `N'
gen row = _n

replace V = "~~Number of total outpatient visits" in 1
replace V = "~~Number of outpatient visits for ILI diseases" in 3
replace V = "~~Number of outpatient visits for Non-ILI diseases" in 5
replace V = "~~Number of total inpatient admissions" in 7
replace V = "~~Number of inpatient admissions for ILI diseases" in 9
replace V = "~~Number of inpatient admissions for Non-ILI diseases" in 11
replace V = "~~Number of ILI deaths" in 13
replace V = "~~Population Size (1,000)" in 15
replace V = "~~Share of Age below 14" in 17
replace V = "~~Share of Age between 15 to 64" in 19
replace V = "~~Share of Age above 65" in 21
replace V = "~~Sex Ratio (Female to Male)" in 23
replace V = "~~Share of Post-Secondary Degree" in 25
replace V = "~~Share of High-School Degree" in 27
replace V = "~~Share of Non-High-School Degree" in 29
replace V = "~~Temperature (\textdegree{}C)" in 31
replace V = "~~Precipitation (mm)" in 33
replace V = "Observations" in 35
replace V = "\textbf{Outcome Variables} (per 100,000 population)" in 36
replace V = "\textbf{Demographic Variables}" in 37
replace V = "\textbf{Weather Variables}" in 38

replace row = 0.5 in 36
replace row = 14.5 in 37
replace row = 30.5 in 38
sort row
drop row

save "$wdata/intermediate/Summary_Stat.dta", replace

export excel using "$table/Table_1.xlsx" , sheet("Summary Statistics", replace) firstrow(variables)

texsaveyt 	_all using "$tex/tables/Tab1.tex", replace ///
			title ("Summary statistics for the treated and untreated years") nonames ///
			headerlines("& \multicolumn{2}{c}{Treated Year} & \multicolumn{2}{c}{Untreated Years} \\ & \multicolumn{2}{c}{2020} & \multicolumn{2}{c}{2014--2019} \\ \cmidrule(r){2-3} \cmidrule(l){4-5} & Pre-outbreak & Post-outbreak & Pre-outbreak & Post-outbreak \\ \midrule") ///
			hlines(15 32 37) nofix size(footnotesize) align(@{}lcccc@{}) ///
			label(summary_stat) frag rh(0.975) cs(2) ///
			footnote("This table displays summary statistics for the outcome variables and covariates during the pre-outbreak period (i.e., the first three weeks of a year) and the post-outbreak period (i.e., the 4\textsuperscript{th} to 52\textsuperscript{nd} weeks of a year) in the treated year (i.e., 2020) and untreated years (i.e., 2014--2019). Healthcare utilization data comes from the Taiwan National ILI Disease Statistics System, which originates from 2014--2020 NHI claim data. We divide the number of outpatient visits and inpatient admissions by the population of each corresponding county per year to obtain the incidence rate of outpatient visits/inpatient admissions per 100,000 population for specific types of diseases. Demographic information comes from the population statistics database provided by the Ministry of Interior (MOI), Taiwan. Population size is measured on monthly basis, and other demographic variables are measured on annual basis. Weather variables are from the Central Weather Bureau's (CWB) observation data inquiry system. Standard deviations are in parentheses.")
