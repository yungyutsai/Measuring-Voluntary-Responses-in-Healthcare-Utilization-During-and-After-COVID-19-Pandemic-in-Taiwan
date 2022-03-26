clear
set more off

local file = "Diarrhea enteroviralinfection handfootmouthdisease herpangina influenza influenza_like_illness otherpneumonia scarletfever varicella"

**All
use "$wdata/NHI/NHI_acuteupperrespiratoryinfections.dta", clear
foreach x in `file' {
capture noisily merge 1:1 年 週 就診類別 縣市 using "$wdata/NHI/NHI_`x'.dta", nogen update
}

rename 年 year
rename 週 week
rename 縣市 city
rename 就診類別 type

rename 健保就診總人次 total
rename 急性上呼吸道感染健保就診人次 acute_uri
rename 腹瀉健保就診人次 diarrhea
rename 腸病毒健保就診人次 enterovirus 
rename 手足口病健保就診人次 hfmd
rename 疱疹性咽峽炎健保就診人次 herpangina
rename 流感及其所致肺炎健保就診人次 influenza
rename 類流感健保就診人次 influenza_like
rename 其他肺炎健保就診人次 other_pneumonia
rename 猩紅熱健保就診人次 scarlet_fever
rename 水痘健保就診人次 varicella

lab var total "Total" //
lab var acute_uri "Acute Upper Respiratory Infection"
lab var diarrhea "Diarrhea"
lab var enterovirus "Enterovirus"
lab var hfmd "Hand, Foot, and Mouth Disease (HFMD)"
lab var herpangina "Herpangina"
lab var influenza "Influenza and Influenza Caused Pneumonia"
lab var influenza_like "Influenza-like illness"
lab var other_pneumonia "Other Pneumonia"
lab var scarlet_fever "Scarlet Fever"
lab var varicella "Varicella"

gen yw = yw(year,week)
format yw %twCCYYWW

order yw year w city type total

keep if year > 2008

foreach x of varlist total-varicella{
recode `x' . = 0
}

gen flu = influenza_like + acute_uri
gen non_flu = total - flu
gen other_infection = diarrhea + enterovirus + scarlet_fever + varicella
gen non_infection = total - flu - other_infection

lab var flu "ILI and Acute URI"
lab var non_flu "Non ILI and Acute URI"
lab var other_infection "Other Infectious Diseases"
lab var non_infection "Non Infectious Diseases"

order flu non_flu non_infection acute_uri other_infection, a(total)

save "$wdata/NHI/NHI_all.dta", replace

keep if type == "門診" //Outpatient
replace type = "Outpatient"
save "$wdata/NHI/NHI_opd.dta", replace

use "$wdata/NHI/NHI_all.dta", clear
keep if type == "住院" //Inpatient
replace type = "Inpatient"
save "$wdata/NHI/NHI_ipd.dta", replace
