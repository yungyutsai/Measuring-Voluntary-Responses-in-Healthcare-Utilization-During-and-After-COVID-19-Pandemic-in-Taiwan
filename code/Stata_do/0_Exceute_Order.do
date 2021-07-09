if c(username) == "Tina" {
	global wdata = "/Users/Tina/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/投稿/NHB/github/data/wdata"
	global rdata = "/Users/Tina/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/投稿/NHB/github/data/rdata"
	global figure = "/Users/Tina/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/投稿/NHB/github/figure"
	global table = "/Users/Tina/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/投稿/NHB/github/table"
	global do = "/Users/Tina/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/投稿/NHB/github/code/Stata_do"
}

do "$do/1_Data_Clean/1_calender/1_calender.do"

do "$do/1_Data_Clean/2_weather/1_clean_raw_data.do"
do "$do/1_Data_Clean/2_weather/2_collapse_by_county.do"

do "$do/1_Data_Clean/3_population/1_load_raw_data.do"
do "$do/1_Data_Clean/3_population/2_append_all.do"

do "$do/1_Data_Clean/4_NHI/1_csv_to_dta.do"
do "$do/1_Data_Clean/4_NHI/2_merge_all_NHI.do"

do "$do/2_Merge_Variables/merge_variables.do"

do "$do/3_Analysis/Table_1.do"
do "$do/3_Analysis/Table_2.do"
do "$do/3_Analysis/Table_3.do"
do "$do/3_Analysis/Figure_1.do"
do "$do/3_Analysis/Figure_2.do"
do "$do/3_Analysis/Figure_3.do"
do "$do/3_Analysis/Figure_4.do"
do "$do/3_Analysis/Figure_5.do"
do "$do/3_Analysis/Figure_6.do"
do "$do/3_Analysis/Figure_7.do"
do "$do/3_Analysis/Table_B1.do"
do "$do/3_Analysis/Table_B2.do"
do "$do/3_Analysis/Table_B3.do"
do "$do/3_Analysis/Table_B4.do"
do "$do/3_Analysis/Figure_C1.do"
do "$do/3_Analysis/Figure_C2.do"
do "$do/3_Analysis/Figure_C3.do"

do "$do/4_Appendix_A_Google_Trend/1_clean_google_trend_TW.do"
do "$do/4_Appendix_A_Google_Trend/2_clean_google_trend_US.do"
do "$do/4_Appendix_A_Google_Trend/3_Figure_A1_A2_TW.do"
do "$do/4_Appendix_A_Google_Trend/4_Figure_A1_A2_A3_US.do"
