set more off
cd "$rdata/NHI"

local files : dir . files "NHI*.csv" //capture the name of csv fiels

foreach x of local files {
import delimited `x', varnames(1) encoding(utf8) clear
order 健保就診總人次 //Total visits/admission
quiet des, varlist
loc lastvar: word `c(k)' of `r(varlist)'
collapse (sum) 健保就診總人次 `lastvar', by(年 週 就診類別 縣市) //year week type city
local y = subinstr("`x'",".csv",".dta",.)
save "$wdata/NHI/`y'", replace
}
