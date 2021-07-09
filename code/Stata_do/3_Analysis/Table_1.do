clear
set more off

use "$wdata/NHI_ipd_for_analysis.dta", clear
keep if year >= 2014
gen perc_influenza_like = influenza_like / population * 100000


collapse	(mean) perc_total 		(sd) sd1  = perc_total ///
			(mean) perc_infection	(sd) sd2  = perc_infection ///
			(mean) perc_non_infection (sd) sd3  = perc_non_infection ///
			(mean) perc_influenza_like (sd) sd4  = perc_influenza_like ///
			(mean) population		(sd) sd5  = population ///
			(mean) Temperature		(sd) sd6  = Temperature ///
			(mean) Precp			(sd) sd7  = Precp ///
			(mean) sumworkdays		(sd) sd8  = sumworkdays ///
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

use "$wdata/NHI_opd_for_analysis.dta", clear
keep if year >= 2014
gen perc_influenza_like = influenza_like / population * 100000


collapse	(mean) perc_total 		(sd) sd1  = perc_total ///
			(mean) perc_infection	(sd) sd2  = perc_infection ///
			(mean) perc_non_infection (sd) sd3  = perc_non_infection ///
			(mean) perc_influenza_like (sd) sd4  = perc_influenza_like ///
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
save "$wdata/intermediate/Summary_Stat.dta", replace

export excel using "$table/Table_1.xlsx" , sheet("Summary Statistics", replace) firstrow(variables)
