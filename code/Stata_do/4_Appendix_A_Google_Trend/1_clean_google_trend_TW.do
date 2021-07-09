clear
set more off

use "$rdata/google_trend/google_trend_monthly_TW.dta", clear

format date %tdCCYYNN
gen ym = string(date, "%tdCCYYNN")
drop date
destring ym, replace
order ym

replace hits = "0" if hits == "<1"
destring hits, replace
rename hits index

save "$wdata/google_trend/google_trend_monthly_TW.dta", replace

use "$rdata/google_trend/google_trend_daily_TW.dta", clear

format date %tdCCYYNNDD

replace hits = "0" if hits == "<1"
destring hits, replace

save "$wdata/google_trend/google_trend_daily_TW.dta", replace

use "$wdata/google_trend/google_trend_monthly_TW.dta", clear
drop ym index
duplicates drop

expand 2556 // from 2014-01-01 to 2020-12-31

sort key geo
by key geo, sort: gen date = _n + 19723
format date %tdCCYYNNDD
gen ymd = string(date, "%tdCCYYNNDD")
gen ym = substr(ymd,1,6)
destring ym, replace

merge 1:1 date keyword geo using "$wdata/google_trend/google_trend_daily_TW.dta"
drop _m
merge m:1 ym keyword geo using "$wdata/google_trend/google_trend_monthly_TW.dta"
drop _m

recode hits . = 0

egen tothits = sum(hits), by(ym keyword geo)

gen search = hits/tothits * index
recode search . = 0

replace hits = search
keep date key geo hits

foreach x in "TW"{
foreach y in "武漢 肺炎" "口罩" "酒精"{
sum hits if geo == "`x'" & key == "`y'"
local max = `r(max)'
replace hits = hits * 100 / `max' if geo == "`x'" & key == "`y'"
}
}

replace key = "coronavirus" if key == "武漢 肺炎"
replace key = "mask" if key == "口罩"
replace key = "sanitizer" if key == "酒精"

drop geo
rename hits hits_
reshape wide hits, i(date) j(key) string

lab var hits_coronavirus "武漢 肺炎"
lab var hits_mask "口罩"
lab var hits_sanitizer "酒精"

save "$wdata/google_trend/google_trend_for_analysis_TW.dta", replace
