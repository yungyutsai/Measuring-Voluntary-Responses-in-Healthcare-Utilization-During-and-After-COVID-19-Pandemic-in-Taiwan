if c(username) == "yungyu" {
	global wdata = "/Users/yungyu/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/Github/data/wdata"
	global rdata = "/Users/yungyu/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/Github/data/rdata"
	global figure = "/Users/yungyu/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/Github/figure"
	global tex = "/Users/yungyu/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/content"
	global table = "/Users/yungyu/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/Github/table"
	global do = "/Users/yungyu/YourPath/Dropbox/RA_research/COVID-19_impact/TW_health/Github/code/Stata_do"
}
if c(username) == "ttyang" {
	global wdata = "C:/nest/Dropbox/RA_research/COVID-19_impact/TW_health/Github/data/wdata"
	global rdata = "C:/nest/Dropbox/RA_research/COVID-19_impact/TW_health/Github/data/rdata"
	global figure = "C:/nest/Dropbox/RA_research/COVID-19_impact/TW_health/Github/figure"
	global tex = "C:/nest/Dropbox/RA_research/COVID-19_impact/TW_health/content"
	global table = "C:/nest/Dropbox/RA_research/COVID-19_impact/TW_health/Github/table"
	global do = "C:/nest/Dropbox/RA_research/COVID-19_impact/TW_health/Github/code/Stata_do"
}

** check needed package
foreach x in outreg2 ppmlhdfe reghdfe coefplot addplot parmest grc1leg{
	cap which `x'
	if _rc ~= 0{
		ssc install `x' 
	}
}

** Clean Raw Data
do "$do/1_Data_Clean/1_calender/1_calender.do"
do "$do/1_Data_Clean/2_weather/1_clean_raw_data.do"
do "$do/1_Data_Clean/2_weather/2_collapse_by_county.do"
do "$do/1_Data_Clean/3_population/1_load_raw_data.do"
do "$do/1_Data_Clean/3_population/2_append_all.do"
do "$do/1_Data_Clean/4_NHI/1_csv_to_dta.do"
do "$do/1_Data_Clean/4_NHI/2_merge_all_NHI.do"
do "$do/1_Data_Clean/4_NHI/3_pneumonia_mortality.do"

** Build Dataset
do "$do/2_Merge_Variables/merge_variables.do"

** Tables
do "$do/ado/texsaveyt.ado" //Stata to Tex file
do "$do/3_Analysis/Table_1.do" //Summary Statistics
do "$do/3_Analysis/Table_2.do" //DID
do "$do/3_Analysis/Table_3.do" //Multiple-Period DID
do "$do/3_Analysis/Table_B1.do" //DID (Coefficient Version)
do "$do/3_Analysis/Table_B2.do" //Multiple-Period DID  (Coefficient Version)
do "$do/3_Analysis/Table_B3.do" //Robustness Check DID (Cluster SE)
do "$do/3_Analysis/Table_B4.do" //Robustness Check Multiple-Period DID (Cluster SE)
do "$do/3_Analysis/Table_B5.do" //Robustness Check DID (Unweighted)
do "$do/3_Analysis/Table_B6.do" //Robustness Check Multiple-Period DID (Unweighted)

** Figures
do "$do/3_Analysis/Figure_1.do" //Confrimed cases
do "$do/3_Analysis/Figure_2.do" //Raw data
do "$do/3_Analysis/Figure_3.do" //Event-Study
do "$do/3_Analysis/Figure_4.do" //Placebo DID
do "$do/3_Analysis/Figure_5.do" //Placebo Multiple-Period DID
do "$do/3_Analysis/Figure_6.do" //Placebo Event-Study
do "$do/3_Analysis/Figure_7.do" //ILI Mortality
do "$do/3_Analysis/Figure_B1.do" //Event-Study (Coefficient Version)

** Appendix A
do "$do/4_Appendix_A/clean_google_trend_TW.do"
do "$do/4_Appendix_A/clean_google_trend_US.do"
do "$do/4_Appendix_A/Figure_A1.do" //Weekly Google Trend
do "$do/4_Appendix_A/Figure_A2.do" //Daily Google Trend
do "$do/4_Appendix_A/Figure_A3.do" //Washington and Seattle
do "$do/4_Appendix_A/Figure_A4.do" //Yougov Survey
