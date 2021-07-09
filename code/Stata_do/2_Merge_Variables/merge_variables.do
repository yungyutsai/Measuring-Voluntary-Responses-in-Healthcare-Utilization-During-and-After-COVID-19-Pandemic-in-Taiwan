foreach x in opd ipd {
import delimited "$rdata/county/county_township_list.txt", varnames(1) encoding(big5) clear 

rename 縣市名稱 city
rename 縣市代碼 city_cd

keep c*
duplicates drop
replace city = subinstr(city,"臺","台",.)

expand 7 //2014-2020, 7 years
sort city_cd
by city_cd, sort: gen year = 2013 + _n

expand 52 //52 Weeks
sort city_cd year
by city_cd year, sort: gen week = _n

merge 1:m city year week using "$wdata/NHI/NHI_`x'.dta"
drop if _m == 2
drop _m

gen yearweek = year * 100 + week
replace yw = yw(year,week)

merge m:m yearweek using "$wdata/calendar/yearweek_table.dta", keepusing(key_ym week_of_month sumworkdays) update
drop if _m == 2
drop _m
merge m:1 city key_ym using "$wdata/population/population.dta"
drop if _m == 2
drop _m
gen population = county_pop
drop county_pop_age*


forv i = 2014(1)2020{
merge m:1 yearweek city using "$wdata/weather/CWB_city_WHOWeek`i'.dta", update
drop if _m == 2
drop _m
}

foreach z of varlist total-other_infection{
recode `z' . = 0
gen log_`z' = log(`z')
recode log_`z' . = 0
gen perc_`z' = `z' / population * 100000
}

gen infection = total - non_infection
gen perc_infection = infection / population * 100000

keep if year >= 2014
drop if week == 53

gen eve = 0 //2015,2016,2017的跨年夜在前一年
replace eve = 1 if year == 2014 & week == 1
replace eve = 1 if year == 2014 & week == 53 //2015年的跨年夜，其實不需要因為沒有納入53週
replace eve = 1 if year == 2015 & week == 52 //2016年的跨年夜
replace eve = 1 if year == 2016 & week == 52 //2017年的跨年夜
replace eve = 1 if year == 2018 & week == 1
replace eve = 1 if year == 2019 & week == 1
replace eve = 1 if year == 2020 & week == 1

gen ny = 0 //2015,2016的元旦在前一年
replace ny = 1 if year == 2014 & week == 1
replace ny = 1 if year == 2014 & week == 53 //2015年的元旦，其實不需要因為沒有納入53週
replace ny = 1 if year == 2015 & week == 52 //2016年的元旦
replace ny = 1 if year == 2017 & week == 1
replace ny = 1 if year == 2018 & week == 1
replace ny = 1 if year == 2019 & week == 1
replace ny = 1 if year == 2020 & week == 1

gen bcny = 0
replace bcny = 1 if year == 2014 & week == 4
replace bcny = 1 if year == 2015 & week == 6
replace bcny = 1 if year == 2016 & week == 5
replace bcny = 1 if year == 2017 & week == 3
replace bcny = 1 if year == 2018 & week == 6
replace bcny = 1 if year == 2019 & week == 5
replace bcny = 1 if year == 2020 & week == 3

gen cny = 0

replace cny = 3 if year == 2014 & week == 5 // 2014.1.30 (除夕) - 2014.2.1
replace cny = 3 if year == 2014 & week == 6 // 2014.2.2 - 2014.2.4 (初五)

replace cny = 4 if year == 2015 & week == 7 // 2015.2.18 (除夕) - 2015.2.21
replace cny = 2 if year == 2015 & week == 8 // 2015.2.22 - 2015.2.23 (初五)

replace cny = 6 if year == 2016 & week == 6 // 2016.2.7 (除夕) - 2016.2.12 (初五)

replace cny = 2 if year == 2017 & week == 4 // 2017.1.27 (除夕) - 2017.1.28
replace cny = 4 if year == 2017 & week == 5 // 2017.1.29 - 2017.2.2 (初五)


replace cny = 3 if year == 2018 & week == 7 // 2018.2.15 (除夕) - 2018.2.17
replace cny = 3 if year == 2018 & week == 8 // 2018.2.18 - 2018.2.20 (初五)

replace cny = 6 if year == 2019 & week == 6 // 2019.2.4 (除夕) - 2019.2.9 (初五) (因為初六星期日，所以實際上放到初六)

replace cny = 2 if year == 2020 & week == 4 // 2020.1.24 (除夕) - 2020.1.25 (今年小除夕其實也有彈性放假)
replace cny = 4 if year == 2020 & week == 5 // 2020.1.26 - 2020.1.29 (初五)

**228
gen peace = 0
replace peace = 3 if year == 2014 & week == 9
replace peace = 2 if year == 2015 & week == 8
replace peace = 1 if year == 2015 & week == 9
replace peace = 3 if year == 2016 & week == 9
replace peace = 1 if year == 2017 & week == 8
replace peace = 3 if year == 2017 & week == 9
replace peace = 1 if year == 2018 & week == 9
replace peace = 3 if year == 2019 & week == 9
replace peace = 1 if year == 2019 & week == 10
replace peace = 3 if year == 2020 & week == 9

**清明節
gen qingming = 0
replace qingming = 2 if year == 2014 & week == 14
replace qingming = 1 if year == 2014 & week == 15
replace qingming = 2 if year == 2015 & week == 13
replace qingming = 2 if year == 2015 & week == 14
replace qingming = 1 if year == 2016 & week == 13
replace qingming = 3 if year == 2016 & week == 14
replace qingming = 1 if year == 2017 & week == 13
replace qingming = 3 if year == 2017 & week == 14
replace qingming = 4 if year == 2018 & week == 14
replace qingming = 3 if year == 2019 & week == 14
replace qingming = 1 if year == 2019 & week == 15
replace qingming = 3 if year == 2020 & week == 14
replace qingming = 1 if year == 2020 & week == 15

**勞動節
gen labor = 0
replace labor = 1 if year == 2014 & week == 18
replace labor = 2 if year == 2015 & week == 17
replace labor = 1 if year == 2015 & week == 18
replace labor = 1 if year == 2016 & week == 17
replace labor = 1 if year == 2016 & week == 18
replace labor = 1 if year == 2017 & week == 17
replace labor = 2 if year == 2017 & week == 18
replace labor = 1 if year == 2018 & week == 18
replace labor = 1 if year == 2019 & week == 18
replace labor = 2 if year == 2020 & week == 18
replace labor = 1 if year == 2020 & week == 19

**端午節
gen dragon = 0
replace dragon = 1 if year == 2014 & week == 22
replace dragon = 2 if year == 2014 & week == 23
replace dragon = 2 if year == 2015 & week == 24
replace dragon = 1 if year == 2015 & week == 25
replace dragon = 3 if year == 2016 & week == 23
replace dragon = 1 if year == 2016 & week == 24
replace dragon = 1 if year == 2017 & week == 21
replace dragon = 3 if year == 2017 & week == 22
replace dragon = 1 if year == 2018 & week == 24
replace dragon = 2 if year == 2018 & week == 25
replace dragon = 2 if year == 2019 & week == 23
replace dragon = 1 if year == 2019 & week == 24
replace dragon = 3 if year == 2020 & week == 26
replace dragon = 1 if year == 2020 & week == 27

**中秋節
gen moon = 0
replace moon = 1 if year == 2014 & week == 36
replace moon = 2 if year == 2014 & week == 37
replace moon = 1 if year == 2015 & week == 38
replace moon = 2 if year == 2015 & week == 39
replace moon = 3 if year == 2016 & week == 37
replace moon = 1 if year == 2016 & week == 38
replace moon = 1 if year == 2017 & week == 40
replace moon = 1 if year == 2018 & week == 38
replace moon = 2 if year == 2018 & week == 39
replace moon = 2 if year == 2019 & week == 37
replace moon = 1 if year == 2019 & week == 38
replace moon = 3 if year == 2020 & week == 40
replace moon = 1 if year == 2020 & week == 41

**國慶
gen double10 = 0
replace double10 = 2 if year == 2014 & week == 41
replace double10 = 1 if year == 2014 & week == 42
replace double10 = 2 if year == 2015 & week == 40
replace double10 = 1 if year == 2015 & week == 41
replace double10 = 1 if year == 2016 & week == 40
replace double10 = 2 if year == 2016 & week == 41
replace double10 = 1 if year == 2017 & week == 40
replace double10 = 3 if year == 2017 & week == 41
replace double10 = 1 if year == 2018 & week == 41
replace double10 = 3 if year == 2019 & week == 41
replace double10 = 1 if year == 2019 & week == 42
replace double10 = 2 if year == 2020 & week == 41
replace double10 = 1 if year == 2020 & week == 42

gen treatment = year == 2020
gen post = week >= 4
gen covid19 = treat * post

gen Outbreak = week >= 4 & week < 8
gen Comminfect = week >= 8 & week < 24
gen Unblock = week >= 24 & week < 49
gen Winter = week >= 49

gen TxOutbreak = Outbreak == 1 & year == 2020
gen TxComminfect = Comminfect == 1 & year == 2020
gen TxUnblock = Unblock == 1 & year == 2020
gen TxWinter = Winter == 1 & year == 2020

gen Pandemic = week >= 4 & week < 24
gen PostPandemic = week >= 24
gen TxPandemic = Pandemic == 1 & year == 2020
gen TxPostPandemic = PostPandemic == 1 & year == 2020

replace week = week - 4 //  1/19 - 1/25

forv i = 3(-1)1{
gen pre`i'Xtreat = treat == 1 & week == - `i'
}
forv i = 0(1)48{
gen post`i'Xtreat = treat == 1 & week == `i'
}

drop pre2Xtreat

replace week = week + 4

encode city_cd, gen(city_no)

** city trend
forv i =1(1)22{
gen city_no_trend`i' = (city_no ==`i')*week
}

** trend for 2020
gen treatment_trend = treatment*week
gen treatment_trend_2 = treatment*week^2

gen cny_week = cny/7

drop type
sort city_cd yearweek
order city city_cd city_no year week yw yearweek week_of_month

save "$wdata/NHI_`x'_for_analysis.dta", replace

}

