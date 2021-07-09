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

lab var total "健保就診總人次"
lab var acute_uri "急性上呼吸道感染健保就診人次"
lab var diarrhea "腹瀉健保就診人次"
lab var enterovirus "腸病毒健保就診人次"
lab var hfmd "手足口病健保就診人次"
lab var herpangina "疱疹性咽峽炎健保就診人次"
lab var influenza "流感及其所致肺炎健保就診人次"
lab var influenza_like "類流感健保就診人次"
lab var other_pneumonia "其他肺炎健保就診人次"
lab var scarlet_fever "猩紅熱健保就診人次"
lab var varicella "水痘健保就診人次"

gen yw = yw(year,week)
format yw %twCCYYWW

order yw year w city type total

keep if year > 2008

foreach x of varlist total-varicella{
recode `x' . = 0
}

gen flu = influenza_like
gen non_flu = total - flu
gen other_infection = diarrhea + enterovirus + scarlet_fever + varicella
gen non_infection = total - flu - acute_uri - other_infection

lab var flu "流感、類流感及肺炎健保就診人次"
lab var non_flu "非流感肺炎類健保就診人次"
lab var other_infection "其他傳染性、感染性疾病健保就診人次"
lab var non_infection "非傳染性、感染性疾病健保就診人次"

order flu non_flu non_infection acute_uri other_infection, a(total)

save "$wdata/NHI/NHI_all.dta", replace

keep if type == "門診"
save "$wdata/NHI/NHI_opd.dta", replace

use "$wdata/NHI/NHI_all.dta", clear
keep if type == "住院"
save "$wdata/NHI/NHI_ipd.dta", replace
