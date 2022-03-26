foreach x in opd ipd {
	import delimited "$rdata/county/county_township_list.txt", varnames(1) encoding(big5) clear 

	rename 縣市名稱 city
	rename 縣市代碼 city_cd

	keep c*
	duplicates drop
	replace city = subinstr(city,"臺","台",.) //"臺" and "台" are interchangeable in Chinese

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

	merge m:m yearweek using "$wdata/calendar/yearweek_table.dta", keepusing(key_ym week_of_month sumworkdays cweek) update
	drop if _m == 2
	drop _m
	merge m:1 city key_ym using "$wdata/population/population.dta"
	drop if _m == 2
	drop _m
	gen population = county_pop

	replace year = year - 1911
	merge m:1 city year using "$wdata/population/education_level.dta", update replace
	replace year = year + 1911
	drop if _m == 2
	drop _m

	gen ageb14 = popagegroup1 + popagegroup2 + popagegroup3
	gen agea65 = popagegroup14 + popagegroup15 + popagegroup16 + popagegroup17 + ///
				 popagegroup18 + popagegroup19 + popagegroup20
	gen age1564 = 1 - ageb14 - agea65
	drop popage*

	forv i = 2014(1)2020{
		merge m:1 yearweek city using "$wdata/weather/CWB_city_WHOWeek`i'.dta", update
		drop if _m == 2
		drop _m
	}

	gen infection = total - non_infection
	order infection, b(non_infection)
	lab var infection "Infectious Diseases"

	foreach z of varlist total-other_infection{
		local lab: variable label `z'
		recode `z' . = 0
		gen log_`z' = log(`z')
		lab var log_`z' "Log `lab' Visits"
		recode log_`z' . = 0
		gen perc_`z' = `z' / population * 100000
		lab var perc_`z' "`lab' Visits per 100 Thousand Population"
	}

	keep if year >= 2014
	drop if week == 53

	gen eve = 0 //The new year's eve
	lab var eve "New Year Eve"
	replace eve = 1 if year == 2014 & week == 1
	replace eve = 1 if year == 2014 & week == 53 //The new year's eve of 2015 was in 2014 week 53
	replace eve = 1 if year == 2015 & week == 52 //The new year's eve of 2016
	replace eve = 1 if year == 2016 & week == 52 //The new year's eve of 2017
	replace eve = 1 if year == 2018 & week == 1
	replace eve = 1 if year == 2019 & week == 1
	replace eve = 1 if year == 2020 & week == 1

	gen ny = 0 //The new year
	lab var ny "New Year"
	replace ny = 1 if year == 2014 & week == 1
	replace ny = 1 if year == 2014 & week == 53 //The new year of 2015 was in 2014 week 53
	replace ny = 1 if year == 2015 & week == 52 //The new year of 2016
	replace ny = 1 if year == 2017 & week == 1
	replace ny = 1 if year == 2018 & week == 1
	replace ny = 1 if year == 2019 & week == 1
	replace ny = 1 if year == 2020 & week == 1

	gen bcny = 0
	lab var bcny "The Week before Chinese New Year"
	replace bcny = 1 if year == 2014 & week == 4
	replace bcny = 1 if year == 2015 & week == 6
	replace bcny = 1 if year == 2016 & week == 5
	replace bcny = 1 if year == 2017 & week == 3
	replace bcny = 1 if year == 2018 & week == 6
	replace bcny = 1 if year == 2019 & week == 5
	replace bcny = 1 if year == 2020 & week == 3

	gen cny = 0
	lab var cny "Chinese New Year"

	replace cny = 3 if year == 2014 & week == 5 // 2014.1.30 (Chinese NY Eve) - 2014.2.1
	replace cny = 3 if year == 2014 & week == 6 // 2014.2.2 - 2014.2.4 (Fifth Day of Chinese NY)

	replace cny = 4 if year == 2015 & week == 7 // 2015.2.18 (Chinese NY Eve) - 2015.2.21
	replace cny = 2 if year == 2015 & week == 8 // 2015.2.22 - 2015.2.23 (Fifth Day of Chinese NY)

	replace cny = 6 if year == 2016 & week == 6 // 2016.2.7 (Chinese NY Eve) - 2016.2.12 (Fifth Day of Chinese NY)

	replace cny = 2 if year == 2017 & week == 4 // 2017.1.27 (Chinese NY Eve) - 2017.1.28
	replace cny = 4 if year == 2017 & week == 5 // 2017.1.29 - 2017.2.2 (Fifth Day of Chinese NY)


	replace cny = 3 if year == 2018 & week == 7 // 2018.2.15 (Chinese NY Eve) - 2018.2.17
	replace cny = 3 if year == 2018 & week == 8 // 2018.2.18 - 2018.2.20 (Fifth Day of Chinese NY)

	replace cny = 6 if year == 2019 & week == 6 // 2019.2.4 (Chinese NY Eve) - 2019.2.9 (Fifth Day of Chinese NY) (The Sixth day is Saturday)

	replace cny = 2 if year == 2020 & week == 4 // 2020.1.24 (Chinese NY Eve) - 2020.1.25
	replace cny = 4 if year == 2020 & week == 5 // 2020.1.26 - 2020.1.29 (Fifth Day of Chinese NY)

	**228 (Peace Festival)
	gen peace = 0
	lab var peace "228 Peace Memorial"
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

	**清明節 (Qing-Ming Festival)
	gen qingming = 0
	lab var qingming "Qing-Ming Festival"
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

	**勞動節 (Labor's Day)
	gen labor = 0
	lab var labor "Labor's Day"
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

	**端午節 (Dragon Boat Festival)
	gen dragon = 0
	lab var dragon "Dragon Boat Festival"
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

	**中秋節 (Mid-Autumn Festival)
	gen moon = 0
	lab var moon "Mid-Autumn Festival"
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

	**國慶 (National Day)
	gen double10 = 0
	lab var double10 "National Day"
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
	lab var treatment "Treatment = Year 2020"
	gen post = week >= 4
	lab var post "Post = After Week 4"
	gen covid19 = treat * post
	lab var covid19 "covid19 = Treatment X Post"

	gen Pandemic = week >= 4 & week < 24
	lab var Pandemic "Between Week 4 to Week 23"
	gen COVIDFree = week >= 24
	lab var COVIDFree "Between Week 24 to Week 52"

	gen TxPandemic = Pandemic == 1 & year == 2020
	lab var TxPandemic "Treatment X Pandemic"
	gen TxCOVIDFree = COVIDFree == 1 & year == 2020
	lab var TxCOVIDFree "Treatment X COVIDFree"

	replace week = week - 4 //  1/19 - 1/25, the week of first confirmed case

	forv i = 3(-1)1{
		gen pre`i'Xtreat = treat == 1 & week == - `i'
	}
	forv i = 0(1)48{
		gen post`i'Xtreat = treat == 1 & week == `i'
	}

	drop pre2Xtreat

	replace week = week + 4

	encode city_cd, gen(city_no)

	** time trend
	gen yweek = (year-2014)*52+week

	drop type
	sort city_cd yearweek
	order city city_cd city_no year week yw yearweek yweek week_of_month

	** Labels
	lab var city "City/County Name" 
	lab var city_cd "City/County Code (String)"
	lab var city_no "City/County Code (Numeric)"
	lab var year "Year"
	lab var week "Week"
	lab var yw "Year Week (Date Format)"
	lab var yearweek "Year Week (Numeric Format)"
	lab var yweek "Time Trend from 2014 First Week"
	lab var week_of_month "Week of Month"
	lab var key_ym "Year Month for Linked Monthly Data"
	lab var month "Month"
	lab var sumworkdays "Numner of Workday in the Week"
	lab var cweek "Lunar Calendar Week"
	lab var gender_ratio "Gender Ratio (Female = 100)"
	lab var graduate "Proportion of Graduate Degree"
	lab var college "Proportion of College Degree"
	lab var juniorcollege "Proportion of Junior College Degree"
	lab var highschool "Proportion of High School Degree"
	lab var juniorhigh "Proportion of Junior High School Degree"
	lab var primary "Proportion of Primary School Degree"
	lab var illiterate "Proportion of Illiterate"
	lab var ageb14 "Proportion of Aged 0 to 14"
	lab var agea65 "Proportion of Aged 65 up"
	lab var age1564 "Proportion of Aged 15 to 64"
	lab var Temperature "Temperature(℃)" 
	lab var T_Max "Max Temperature(℃)" 
	lab var T_Min "Min Temperature(℃)" 
	lab var Precp "Average Precipitation(mm)" 
	lab var SunShine "Average Number of Hours of Sunshine(hour)" 


	save "$wdata/NHI_`x'_for_analysis.dta", replace

}

