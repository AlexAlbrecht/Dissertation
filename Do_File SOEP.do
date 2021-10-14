//Author: Alexander Albrecht
//Date Started: 16.06.2021
//Stata Version: STATA 16
//Description of Do File: Dissertation Analysis of SOEP Data on NUTS1 level. If I do not get more detailed data I leave this as it is.

* * * PACKAGES * * *
set scheme plottig 
ssc install xttest2 
ssc install coefplot
 


* * * LOCAL VARIABLES * * *
global MY_PATH_IN   "C:\Users\User\Documents\cs-transfer\SOEP-CORE.v36eu_STATA\Stata\"
global MY_PATH_OUT  "C:\Users\User\Documents\cs-transfer\SOEP-CORE.v36eu_STATA\Stata\"
global do_path "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Do"
global output_path "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Do"
global MY_FILE_OUT  ${MY_PATH_OUT}new.dta
global MY_LOG_FILE  ${MY_PATH_OUT}new.log
capture log close
log using "${MY_LOG_FILE}", text replace
set more off
cd "C:\Users\User\Documents\cs-transfer\SOEP-CORE.v36eu_STATA\Stata\"
		
* --------------------------------------------------------------------.
* 						Prepare the  datasets		       	  	      .
*                        					                          .
* --------------------------------------------------------------------.

**Creating the master dataset
clear
import delimited "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\NUTS_AT_2021.csv", encoding(UTF-8)
keep if cntr_code == "DE"
tab nuts_id
generate str nuts2 = substr(nuts_id, 1,4)
generate str nuts1 = substr(nuts_id, 1,3)
rename nuts_id nuts3
drop if nuts1 == "DE"
save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Nuts_Codees_Europa.dta", replace

**Prepating the Refugee Dataset NUts-1 (To be safe)
clear
import delimited "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Schutzsuchende_Nuts1.csv"
drop statistik_label statistik_code zeit_label zeit_code _merkmal_code _merkmal_label v10 v11 v12

gen year=.
replace year = 2008 if zeit == "31.12.2008"
replace year = 2009 if zeit == "31.12.2009"
replace year = 2010 if zeit == "31.12.2010"
replace year = 2011 if zeit == "31.12.2011"
replace year = 2012 if zeit == "31.12.2012"
replace year = 2013 if zeit == "31.12.2013"
replace year = 2014 if zeit == "31.12.2014"
replace year = 2015 if zeit == "31.12.2015"
replace year = 2016 if zeit == "31.12.2016"
replace year = 2017 if zeit == "31.12.2017"
replace year = 2018 if zeit == "31.12.2018"
replace year = 2019 if zeit == "31.12.2019"

rename bev030__schutzsuchende__anzahl refugees
rename _auspraegung_label state

rename state state2

by year state, sort: gen male_refugees = refugees if v13 == "männlich"
by year state, sort: gen female_refugees = refugees if v13 =="weiblich"
by year state, sort: gen mal_refugees = refugees if v13 == "Insgesamt" | v13=="männlich"
keep if v13=="Insgesamt"

//Aligning states
gen state=. 
replace state = 1 if state2 == "Baden-Württemberg"
replace state = 2 if state2 == "Bayern"
replace state = 3 if state2 == "Berlin"
replace state = 4 if state2 == "Brandenburg"
replace state = 5 if state2 == "Bremen"
replace state = 6 if state2 == "Hamburg"
replace state = 7 if state2 == "Hessen"
replace state = 8 if state2 == "Mecklenburg-Vorpommern"
replace state = 9 if state2 == "Niedersachsen"
replace state = 10 if state2 == "Nordrhein-Westfalen"
replace state = 11 if state2 == "Rheinland-Pfalz"
replace state = 12 if state2 == "Saarland"
replace state = 13 if state2 == "Sachsen"
replace state = 14 if state2 == "Sachsen-Anhalt"
replace state = 15 if state2 == "Schleswig-Holstein"
replace state = 16 if state2 == "Thüringen"

save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Refugees_Nutz1.dta", replace


**Preparing the Refugee Dataset Nuts-3 (Just in Case)
clear
import delimited "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Schutzsuchende_Nuts3.csv"
gen str5 code = string(_auspraegung_code, "%05.0f")
destring code, gen(code2)
rename code Schlüsselnummer
save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Refugees Germany.dta", replace

//Using intermediate datasets to merge Kreisnummer and NUTS3 Codes
clear
import excel "C:\Users\User\Downloads\04-kreise.xlsx", sheet("Kreisfreie Städte u. Landkreise") firstrow clear
drop if KreisfreieStadt == "Insgesamt"
drop if Flächeinkm2 ==. 
drop J K L M N O P Q R S
rename Spalte2 weiblich
tab NUTS3
save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Nuts3 and KrNr.dta", replace

//Merge Refugee Data with NUTS3 Information
clear
use "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Refugees Germany.dta", replace
merge m:m Schlüsselnummer using "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Nuts3 and KrNr.dta"
drop if _merge == 1
generate str nuts2 = substr(NUTS3, 1,4)
generate str nuts1 = substr(NUTS3, 1,3)
//Do more elegantly if you have the time.
gen year=.
replace year = 2008 if zeit == "31.12.2008"
replace year = 2009 if zeit == "31.12.2009"
replace year = 2010 if zeit == "31.12.2010"
replace year = 2011 if zeit == "31.12.2011"
replace year = 2012 if zeit == "31.12.2012"
replace year = 2013 if zeit == "31.12.2013"
replace year = 2014 if zeit == "31.12.2014"
replace year = 2015 if zeit == "31.12.2015"
replace year = 2016 if zeit == "31.12.2016"
replace year = 2017 if zeit == "31.12.2017"
replace year = 2018 if zeit == "31.12.2018"
replace year = 2019 if zeit == "31.12.2019"

save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Refugees_final.dta", replace

*---------------------------------------------------------------------.
* 						Renaming Variables for analysis        	      .
*                        					                          .
* --------------------------------------------------------------------.

use "C:\Users\User\OneDrive\Alex_s Zeug\King's\Causal Inference\Course Essay\Datasets\Round 9 Nuts 1_DE.dta", clear 
gen id = _n 
gen population_2010 = n1_tpopsz_2010
gen population_2011 = n1_tpopsz_2011
gen population_2012 = n1_tpopsz_2012
gen population_2013 = n1_tpopsz_2013
gen population_2014 = n1_tpopsz_2014
gen population_2015 = n1_tpopsz_2015
gen population_2016 = n1_tpopsz_2016
gen population_2017 = n1_tpopsz_2017
gen population_2018 = n1_tpopsz_2018
gen population_2019 =. 

reshape long n1_tpopsz_ n1_mio_eur_ n1_unraall_ n1_loun_pc_act_ n1_cnmigratrt_ n1_natgrow_ , i(id)
rename _j year
drop if year <= 2010

//Renaming and labelling variables
rename n1_tpopsz_ population 
label var population "Net Population"

rename n1_unraall_ unemployment_rate
label var unemployment_rate "Unemployment rates by all ages in %"


rename n1_loun_pc_act_ longterm_unemployment_rate
label var longterm_unemployment_rate "Long-term Unemployment (12 months and more), percentage of active population"

rename n1_mio_eur_ gdp
label var gdp "GDP at current market prices in million Euros"


rename n1_cnmigratrt_ migration_rate 
label var migration_rate "Crude Rate of net migration plus statistical adjustment"

rename n1_natgrow_ demographic_trends
label var demographic_trends "Crude rate of natural change of population 2014"


//Dropping
keep gdp year migration_rate demographic_trends longterm_unemployment_rate unemployment_rate population id cntry nuts1 population_2010 population_2011 population_2012 population_2013 population_2014 population_2015 population_2016 population_2017 population_2018

//I also need to fix the unemployment_rate for 2018.
//Source used for unemployment rates: https://www.bpb.de/politik/innenpolitik/arbeitsmarktpolitik/305833/daten-und-fakten-arbeitslosigkeit

save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Nuts1_controlls.dta", replace

//Try to merge it with more recent one
clear
use "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\ESS_NUTS1_NEW.dta"
keep if cntry == "DE"
rename ess9_reg nuts1
gen id = _n

reshape long reg9_tpopsz_ reg9_pode_ reg9_cnmigrat_ reg9_natgrowrt_ reg9_mio_eur_ reg9_loun_pc_act_ reg9_unraall_ reg9_growrt_ , i(id)
rename _j year
drop if year == 2020 | year == 2010 
drop reg9_mpopsz_2018 reg9_mpopsz_2019 reg9_natgrow_2018 reg9_natgrow_2019 reg9_cnmigratrt_2018 reg9_cnmigratrt_2019 reg9_growrt reg9_loun_pc_une_2018


rename reg9_tpopsz_ population 
label var population "Net Population"

rename reg9_unraall_ unemployment_rate
label var unemployment_rate "Unemployment rates by all ages in %"

rename reg9_loun_pc_act_ longterm_unemployment_rate
label var longterm_unemployment_rate "Long-term Unemployment (12 months and more), percentage of active population"

rename reg9_mio_eur_ gdp
label var gdp "GDP at current market prices in million Euros"

rename reg9_cnmigrat_ migration_rate 
label var migration_rate "Crude Rate of net migration plus statistical adjustment"

rename reg9_natgrowrt_ demographic_trends
label var demographic_trends "Crude rate of natural change of population 2014"

rename reg9_pode_ population_density
label var population_density "Population Density"

save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\ESS_NUTS1_NEW_2.dta", replace

clear
use "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Nuts1_controlls.dta"
merge m:m year nuts1 using "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\ESS_NUTS1_NEW_2.dta"
// for whatever reason, 2018 did not work. doing it by hand now.

*------------------------------------------------------------------------------*
*    		  				  												   *
*				Cleaning and Preparing Satisfaction with Merkel Dataset	   	   *	
*																			   *
*------------------------------------------------------------------------------*

clear
import excel "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\11_Arbeit_Merkel.xlsx", sheet("Tabelle4") firstrow
drop year_old good bad
collapse satisfactionwithmerkel, by(year)
save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Arbeit_Merkel.dta", replace 

*------------------------------------------------------------------------------*
*    		  				  												   *
*				Cleaning and Preparing Ausländeranteil Dataset			 	   *	
*																			   *
*------------------------------------------------------------------------------*
clear
import excel "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Auslaenderanteil.xls", sheet("Tabelle1 (2)") firstrow
rename Year year
rename Bundesland state2
rename Wert migrant_rate
destring year, replace
save "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Auslaenderanteil.dta", replace

* --------------------------------------------------------------------.
* 						Loading the Dataset 			       	      .
*                        					                          .
* --------------------------------------------------------------------.
//Attention: Takes a while.
use "pl.dta", clear
drop if syear <= 2010
missings dropvars, force
 
//Merging
merge m:1 pid using "${MY_PATH_OUT}biobirth.dta", keep(master match) nogen
merge m:m pid syear using "${MY_PATH_OUT}bioimmig.dta", keep(master match) nogen
merge m:m cid syear using "${MY_PATH_OUT}regionl.dta", keep(master match) nogen
merge m:m pid syear using "${MY_PATH_OUT}pgen.dta", keep(master match) nogen

 
* --------------------------------------------------------------------.
* 						Renaming Variables for analysis        	      .
*                        					                          .
* --------------------------------------------------------------------.
		
**Satisfaction with life overall
rename plh0182 sat_life_overall
gen sat_life_overall2 = sat_life_overall
replace sat_life_overall2 =. if sat_life_overall == -5 | sat_life_overall == -1 | sat_life_overall == -2

**Satisfaction with income
rename plh0176 sat_personal_income
gen sat_personal_income2 = sat_personal_income
replace sat_personal_income2 =. if sat_personal_income ==-5 | sat_personal_income ==-1 | sat_personal_income ==-2 
		
**Satisfaction with dwelling
rename plh0177 sat_dwelling
gen sat_dwelling2 = sat_dwelling
replace sat_dwelling2 =. if sat_dwelling ==-5 | sat_dwelling ==-2 | sat_dwelling ==-1

		
**Satisfaction with child care
rename plh0179 sat_child_care
gen sat_child_care2 = sat_child_care
replace sat_child_care2 =. if sat_child_care ==-5 | sat_child_care==-1 | sat_child_care ==-2 	
	
**Satisfaction with work
rename plh0173 sat_work
gen sat_work2 = sat_work
replace sat_work2 =. if sat_work ==-5 | sat_work==-2 | sat_work ==-1 

//all of them are scored on a scale from 0-10. But many people do not have childs or work. Shall I create a vector? Or rather regress every single observation on their own?
//generating a vector of the variable
egen sat_index = rowmean(sat_work2 sat_dwelling2 sat_personal_income2 sat_life_overall2)		
		
**Worriedness
**Worried about own personal economic situation
rename plh0033 worried_personal_econ
gen worried_personal_econ2 = worried_personal_econ
replace worried_personal_econ2 =. if worried_personal_econ ==-1 | worried_personal_econ ==-5
		
**Worried about economic development overall
rename plh0032 worried_overall_econ	
gen worried_overall_econ2 = worried_overall_econ
replace worried_overall_econ2 =. if worried_overall_econ==-1 | worried_overall_econ ==-5
		
**Worried about hostility to foreigners
rename plj0047 worried_hostility_foreigners
gen worried_hostility_foreigners2 = worried_hostility_foreigners
replace worried_hostility_foreigners2 =. if worried_hostility_foreigners ==-1 | worried_hostility_foreigners ==-5
		
** Worried about Immigrants coming to Germany 
rename plj0046 worried_immigrants
gen worried_immigrants2 = worried_immigrants
replace worried_immigrants2 =. if worried_immigrants==-1 | worried_immigrants ==-5
		
**Worried about crime in Germany
rename plh0040 worried_crime
gen worried_crime2 = worried_crime
replace worried_crime2 =. if worried_crime==-1 | worried_crime== -5
		
**Worried about work place security
rename plh0042 worried_job
gen worried_job2 = worried_job
replace worried_job2 =. if worried_job ==-1 | worried_job==-6| worried_job==-5 |worried_job==-2

//Generating an Index 
egen worried_index = rowmean(worried_job2 worried_hostility_foreigners2 worried_crime2 worried_immigrants2 worried_personal_econ2 worried_overall_econ2)
egen worried_econ = rowmean(worried_job2 worried_personal_econ2 worried_overall_econ2) 
egen worried_cultural = rowmean(worried_hostility_foreigners2 worried_immigrants2 worried_crime2)

//Doing the the same for the individual controlls
//Gender //binary
drop pla0009_v1 pla0046 pla0047
rename pla0009_v2 gender
tab sex 
drop if sex==-1 //1: mänlich, 2: weiblich, 3: divers

//an Age Dummy 
rename ple0010_h birthyear
replace birthyear =. if birthyear==-5 | birthyear ==-3
gen age = syear - birthyear
gen age_dummy =. 
replace age_dummy=1 if age < 25  //self-explanatory 
replace age_dummy=2 if age < 35 & age >= 25
replace age_dummy=3 if age < 45 & age >= 35
replace age_dummy=4 if age < 55 & age >= 45
replace age_dummy=5 if age < 65 & age >= 55
replace age_dummy=6 if age > 65

//Dummy for the presnece of children
drop pld0173 pld0172 pla0003-pla0007
gen children_dummy =0 if sumkids==0 //0=no children
replace children_dummy=1 if sumkids >= 1 //1= children

//Dummy for being in  relationship // married = pld0134 // Familienstand == pld0131_v1 & v2
gen dummy_relationship= pld0131_v1
replace dummy_relationship=1 if dummy_relationship ==1 | dummy_relationship == 6 //Married
replace dummy_relationship=0 if dummy_relationship == 2 | dummy_relationship == 3 | dummy_relationship == 4 | dummy_relationship==5 | dummy_relationship ==7 // Not married
replace dummy_relationship=. if dummy_relationship==-8 | dummy_relationship == -5 | dummy_relationship ==-1 //Missing Data


//Dummy for employment
rename plb0022_h employment
gen employment_dummy=.
replace employment_dummy=. if employment==-1 // missing data
replace employment_dummy=1 if employment==1 //fully employment_dummy
replace employment_dummy=2 if employment==2 | employment==3 | employment ==4 | employment==5 | employment == 6 | employment == 7 | employment==8 | employment == 10 //Part time, intern, other part time work
replace employment_dummy=3 if employment==9 //not employed

//Dummy for being migrant
rename biimgrp immigrant
gen immigrant_dummy=. 
replace immigrant_dummy=1 if immigrant == 2 | immigrant==3 | immigrant==4 | immigrant==5 | immigrant==6  // Immigrant
replace immigrant_dummy=0 if immigrant==-2 //Not an Immigrant

//Health Dummy 
rename ple0008 health_dummy
replace health_dummy =. if health_dummy==-1 //Self-explanatory

//Dummy for religion
rename plh0258_h religion
gen religion_dummy=1
replace religion_dummy =. if religion == -8 | religion == -5 | religion == -1 //religious in some form
replace religion_dummy = 0 if religion== 6 //not religious

//Dummy for education
rename pgpsbil education
gen education_dummy=. if education== 6 | education == 8
replace education_dummy = 1 if education == 1 // lower secondary school diploma (=Hauptschulabschluss)
replace education_dummy = 2 if education == 2 // Secondary school diploma 
replace education_dummy = 3 if education == 3 // Advanced technical college certificate
replace education_dummy = 4 if education == 4 // A-Levels
replace  education_dummy =. if education == -2 | education == -1 | education == 5 | education == 7 


* --------------------------------------------------------------------.
* 						Merging with Refugee Data	        	      .
*                        					                          .
* --------------------------------------------------------------------.	

drop if nuts1 == -2
rename nuts1 state	
gen nuts1=""
replace nuts1 = "DE1" if state == 1
replace nuts1 = "DE2" if state == 2
replace nuts1 = "DE3" if state == 3
replace nuts1 = "DE4" if state == 4
replace nuts1 = "DE5" if state == 5
replace nuts1 = "DE6" if state == 6
replace nuts1 = "DE7" if state == 7
replace nuts1 = "DE8" if state == 8
replace nuts1 = "DE9" if state == 9
replace nuts1 = "DEA" if state == 10
replace nuts1 = "DEB" if state == 11
replace nuts1 = "DEC" if state == 12
replace nuts1 = "DED" if state == 13
replace nuts1 = "DEE" if state == 14
replace nuts1 = "DEF" if state == 15
replace nuts1 = "DEG" if state == 16

rename syear year

merge m:m state year using "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Refugees_Nutz1.dta"

//Merging with NUTS1 Controlls 
merge m:m year nuts1 using "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\nuts1_final.dta", keep(master match) nogen force

//Dropping Irrelevant variables
drop plg0001-plg0297
drop plb0001-plb0644
//Creating Refugee-to-Population ratio with population level fixed to 2015 to account for endogeneity. 
by state year, sort: gen ref_to_pop2010 = refugees / population_2010 
by state year, sort: gen ref_to_pop2011 = refugees / population_2011 
by state year, sort: gen ref_to_pop2012 = refugees / population_2012 
by state year, sort: gen ref_to_pop2013 = refugees / population_2013 
by state year, sort: gen ref_to_pop2014 = refugees / population_2014 
by state year, sort: gen ref_to_pop2015 = refugees / population_2015 
by state year, sort: gen ref_to_pop2016 = refugees / population_2016 
by state year, sort: gen ref_to_pop2017 = refugees / population_2017 
by state year, sort: gen ref_to_pop2018 = refugees / population_2018 

by state year, sort: gen ref_to_pop = refugees / population

//Mergin with Ausländeranteil 
drop if _merge == 2
drop _merge
merge m:m state2 year using "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Auslaenderanteil.dta"
drop if _merge==1 | _merge==2
gen migrant_rate_lag1 = migrant_rate[_n-1]

//Merging with Merkel data
drop _merge
merge m:m year using "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Arbeit_Merkel.dta"
drop if _merge==1 | _merge==2
rename satisfactionwithmerkel swm

graph twoway (scatter refugees population)
graph twoway (scatter refugees gdp) (lfit refugees gdp)


* --------------------------------------------------------------------
* 						Prepparing the Data for Diff-in-Diff          .
*                        					                          .
* --------------------------------------------------------------------.
	
**Time Dummy for time of treatment
gen time_dummy = 0 if year < 2015
replace time_dummy = 1 if year >= 2015

**Lagging relevant variables
gen demographic_trends_lag1 = demographic_trends[_n-1]
gen demographic_trends_lag2 = demographic_trends[_n-2]

gen gdp_lag1 = gdp[_n-1]
gen gdp_lag2 = gdp[_n-2]
gen gdp_lag3 = gdp[_n-3]

gen gdp_per_cap = gdp / population
gen gdp_per_cap_lag1 = gdp_per_cap[_n-1]
gen gdp_per_cap_lag2 = gdp_per_cap[_n-2]

gen refugees_lag1 = refugees[_n-1]
gen refugees_lag2 = refugees[_n-2]

gen migrant_rate_lag2 = migrant_rate[_n-2] 

gen unemployment_rate_lag1 = unemployment_rate[_n-1]
gen unemployment_rate_lag2 = unemployment_rate[_n-2]

gen population_density_lag1 = population_density[_n-1]
gen population_density_lag2 = population_density[_n-2]

**Creating Groups Dummy // First: Ref-to-Population assigneRatio in 2015!
tab ref_to_pop state if year == 2015
gen treated1 = 1 if nuts1 == "DE5" | nuts1 == "DE6" | nuts1 == "DE3" | nuts1 == "DEC" | nuts1 == "DE8" | nuts1 == "DEA" | nuts1 == "DE9" | nuts1 == "DE7" //Treated: High amount if ref-to-pop ration
replace treated1 = 0 if nuts1 == "DEG" | nuts1 == "DE4" | nuts1 == "DED" | nuts1 == "DE2" | nuts1 == "DEB" | nuts1 == "DE1" | nuts1 == "DEE" | nuts1 == "DEF" //Untreated: Low ref-to-pop ration

**Creating Dummies for Demographics
**Using demographics in 2015
gen pop_change =  demographic_trends / population
tab pop_change state if year==2015
gen treated_d = 1 if nuts1 == "DEE" | nuts1== "DEC" | nuts1 == "DEG" | nuts1 == "DEF" | nuts1 == "DED" | nuts1 == "DE4" | nuts1 == "DE8" | nuts1 == "DE9"  //1 means high negative change of pop rate
replace treated_d = 0 if nuts1 == "DE6" | nuts1 == "DE3" | nuts1 == "DE1" | nuts1 == "DE2" | nuts1 == "DE7" | nuts1 == "DE5" | nuts1 == "DEA" | nuts1 =="DEB"	


**Generate interaction term 
gen did1 = treated1*time_dummy

gen did_d = treated_d*time_dummy

**Making it longitudinal
duplicates drop pid year, force
xtset pid year, yearly
//Removing people that moved states in the Dataset
by pid (state), sort: gen byte moved = (state[1] != state[_N])
drop if moved==1


* --------------------------------------------------------------------.
* 						Descriptive Statistics				          .
*                        					                          .
* --------------------------------------------------------------------.

corr ref_to_pop2015 worried_crime2 worried_hostility_foreigners2 worried_immigrants2 worried_index worried_personal_econ2 worried_overall_econ2 //All the initial correlations are all round -0.03.
corr ref_to_pop2015 sat_dwelling2 sat_child_care2 sat_life_overall2 sat_work2 sat_personal_income2 sat_index //Same, initial correlations are very low. 


pwcorr sex education_dummy immigrant_dummy health_dummy children_dummy age_dummy employment_dummy unemployment_rate population_density gdp_per_cap demographic_trends migrant_rate
eststo correlation
estout correlation using correlation.tex, replace unstack

corr demographic_trends worried_crime2 worried_hostility_foreigners2 worried_immigrants2 worried_index worried_personal_econ2 worried_overall_econ2
//Descriptive Statistics
sum worried_crime2 worried_hostility_foreigners2 worried_immigrants2 worried_job2 worried_personal_econ2 worried_overall_econ2

//Run until here!

* --------------------------------------------------------------------.
* 						Proofing that Refugees only depend on		  .
*									GDP and Population				  .
*                        					                          .
* --------------------------------------------------------------------.

reg refugees population gdp_per_cap unemployment_rate demographic_trends population_density age if year==2011, rob
outreg2 using proof_exogenous.tex, replace ctitle(2011)

reg refugees population gdp_per_cap unemployment_rate demographic_trends population_density age if year==2012, rob 
outreg2 using proof_exogenous.tex, append ctitle(2012)

reg refugees population gdp_per_cap unemployment_rate demographic_trends population_density age if year==2013, rob
outreg2 using proof_exogenous.tex, append ctitle(2013)

reg refugees population gdp_per_cap unemployment_rate demographic_trends population_density age if year==2014, rob 
outreg2 using proof_exogenous.tex, append ctitle(2014)

reg refugees population gdp_per_cap unemployment_rate demographic_trends population_density age if year==2015, rob
outreg2 using proof_exogenous.tex, append ctitle(2015)

reg refugees population gdp_per_cap unemployment_rate demographic_trends population_density age if year==2016, rob
outreg2 using proof_exogenous.tex, append ctitle(2016)

reg refugees population gdp_per_cap unemployment_rate demographic_trends population_density age if year==2017, rob 
outreg2 using proof_exogenous.tex, append ctitle(2017)

reg refugees population gdp_per_cap unemployment_rate demographic_trends population_density age if year==2018, rob 
outreg2 using proof_exogenous.tex, append ctitle(2018)

graph twoway (scatter refugees population)

//Creating the summary descriptive statistics 
by treated2, sort: eststo: quietly estpost sum worried_crime2 worried_hostility_foreigners2 worried_immigrants2 worried_job2 worried_overall_econ2 worried_personal_econ2 worried_index
esttab, cells("count mean sd")

eststo sum worried_crime2 worried_hostility_foreigners2 worried_immigrants2 worried_job2 worried_overall_econ2 worried_personal_econ2 worried_index, by(treated1) ///
statistics(mean sd count) columns(statistics) listwise
esttab using summary_statistic.tex, replace cells("count mean sd")
estout using summary_statistic2.tex, replace

eststo: sum worried_crime2 worried_hostility_foreigners2 worried_immigrants2 worried_job2 worried_overall_econ2 worried_personal_econ2 worried_index
esttab using summary_statistic.tex, replace

quietly estpost sum worried_crime2 worried_hostility_foreigners2 worried_immigrants2 worried_job2 worried_overall_econ2 worried_personal_econ2 worried_index

* --------------------------------------------------------------------.
* 						The actual Analysis					          .
*                        					                          .
* --------------------------------------------------------------------.
//Overview and general idea: First running the models without any controlls
xtdidregress (worried_crime2) (did1), group(state) time(year)
outreg2 using worried_no_controlls.tex, replace ctitle(Crime)

xtdidregress (worried_job2) (did1), group(state) time(year)
outreg2 using worried_no_controlls.tex, append ctitle(Job)

xtdidregress (worried_personal_econ2) (did1), group(state) time(year)
outreg2 using worried_no_controlls.tex, append ctitle(Personal Econ)

xtdidregress (worried_overall_econ2) (did1), group(state) time(year)
outreg2 using worried_no_controlls.tex, append ctitle(Overall Econ)

xtdidregress (worried_hostility_foreigners2) (did1), group(state) time(year)
outreg2 using worried_no_controlls.tex, append ctitle(Hostility)

xtdidregress (worried_immigrants2) (did1), group(state) time(year)
outreg2 using worried_no_controlls.tex, append ctitle(Immigrants)

xtdidregress (worried_index) (did1), group(state) time(year)
outreg2 using worried_no_controlls.tex, append ctitle(Index)



//1.1: Longitudinal TS with NUTS1 controlls. 
xtdidregress (worried_crime2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees) (did1), group(state) time(year) //PV: 0.580
outreg2 using xtdidregress_worried.tex, replace ctitle(Model 1)
estimates store model1

xtdidregress (worried_job2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate) (did1), group(state) time(year) //PV: 0.068
outreg2 using xtdidregress_worried.tex, append ctitle(Model 2) 
estimates store model3

xtdidregress (worried_personal_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried.tex, append ctitle(Model 3) 
estimates store model5

xtdidregress (worried_overall_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried.tex, append ctitle(Model 4) 
estimates store model7

xtdidregress (worried_hostility_foreigners2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried.tex, append ctitle(Model 6) 
estimates store model9

xtdidregress (worried_immigrants2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate) (did1), group(state) time(year)
outreg2 using xtdidregress_worried.tex, append ctitle(Model 5) 
estimates store model11

xtdidregress (worried_index unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried.tex, append ctitle(Model 7) 
estimates store model13
	
//1.2. Longitudinal TS with NUTS1 controlls and individual controlls

xtdidregress (worried_crime2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees swm i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy) (did1), group(state) time(year) //PV: 0.580
outreg2 using xtdidregress_worried2.tex, replace ctitle(Model 1)
estimates store model90

xtdidregress (worried_job2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy) (did1), group(state) time(year) //PV: 0.068
outreg2 using xtdidregress_worried2.tex, append ctitle(Model 2) 
estimates store model91

xtdidregress (worried_personal_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried2.tex, append ctitle(Model 3) 
estimates store model92

xtdidregress (worried_overall_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried2.tex, append ctitle(Model 4) 
estimates store model93

xtdidregress (worried_hostility_foreigners2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried2.tex, append ctitle(Model 6) 
estimates store model94

xtdidregress (worried_immigrants2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy) (did1), group(state) time(year)
outreg2 using xtdidregress_worried2.tex, append ctitle(Model 5) 
estimates store model95

xtdidregress (worried_index unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried2.tex, append ctitle(Model 7) 
estimates store model96


reg worried_crime2 time_dummy##treated1 i.state unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees, cluster(state) rob //PV: 0.580
margins i.state
marginsplot

//1.3. Making a distinction between time invariant amd time variant individual effects
xtdidregress (worried_crime2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year)
outreg2 using xtdidregress_worried_time_variant.tex, replace ctitle(Crime)
estimates store model80

xtdidregress (worried_job2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year)
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Job) 
estimates store model81

xtdidregress (worried_personal_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.health_dummy i.dummy_relationship i.employment_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Personal Econ) 
estimates store model82

xtdidregress (worried_overall_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.employment_dummy i.health_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Overall Econ) 
estimates store model83

xtdidregress (worried_hostility_foreigners2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Hostility) 
estimates store model84

xtdidregress (worried_immigrants2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year)
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Immigrants) 
estimates store model85

xtdidregress (worried_index unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Index) 
estimates store model86


* --------------------------------------------------------------------.
* 						Robustness Checks				          .
*                        					                          .
* --------------------------------------------------------------------.

//Endogneous Treatments
etregress worried_crime2 i.treated1##time_dummy unemployment_rate demographic_trends swm c.migrant_rate##c.refugees population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, treat(treated1 = population gdp) cluster(state) rob
outreg2 using endo_treatment11.tex, replace ctitle(Crime)
outreg2 using endo_treatment1.tex, replace ctitle(Crime)
estimates store model2

etregress worried_job2 i.treated1##time_dummy unemployment_rate demographic_trends swm c.migrant_rate##c.refugees population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, treat(treated1 = population gdp) cluster(state) 
outreg2 using endo_treatment11.tex, append ctitle(Job)
outreg2 using endo_treatment1.tex, append ctitle(Job)
estimates store model4

etregress worried_personal_econ2 i.treated1##time_dummy unemployment_rate demographic_trends c.migrant_rate##c.refugees population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, treat(treated1 = population gdp) cluster(state) 
outreg2 using endo_treatment11.tex, append ctitle(Personal Econ)
outreg2 using endo_treatment1.tex, append ctitle(Personal Econ)
estimates store model6

etregress worried_overall_econ2 i.treated1##time_dummy unemployment_rate demographic_trends c.migrant_rate##c.refugees population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, treat(treated1 = population gdp) cluster(state) 
outreg2 using endo_treatment11.tex, append ctitle(Overall Econ)
outreg2 using endo_treatment2.tex, replace ctitle(Overall Econ)
estimates store model8

etregress worried_hostility_foreigners2 i.treated1##time_dummy unemployment_rate demographic_trends c.migrant_rate##c.refugees population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, treat(treated1 = population gdp) cluster(state) rob
outreg2 using endo_treatment11.tex, append ctitle(Hostility Foreigners)
outreg2 using endo_treatment2.tex, append ctitle(Hostility Foreigners)
estimates store model10

etregress worried_immigrants2 i.treated1##time_dummy unemployment_rate demographic_trends c.migrant_rate##c.refugees population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, treat(treated1 = population gdp) cluster(state) 
outreg2 using endo_treatment11.tex, append ctitle(Immigrants)
outreg2 using endo_treatment2.tex, append ctitle(Immigrants)
estimates store model12

etregress worried_index i.treated1##time_dummy unemployment_rate demographic_trends c.migrant_rate##c.refugees population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, treat(treated1 = population gdp) cluster(state) 
outreg2 using endo_treatment11.tex, append ctitle(Index)
outreg2 using endo_treatment2.tex, append ctitle(Index)
estimates store model14


coefplot model80  model81 model82  model83  model84  model85  model86, title("Effect Size of Refugee to population ration using endogenous treatment") vertical keep(*.treated1#*.time_dummy r1vs0.did1) xlabel("")xtitle("Refugee-to-Population ratio") ytitle("Effect Size") legend(label(2 "Crime") label(4 "Job") label(6 "Personal Econ") label(8 "Overall Econ") label(10 "Hostlity Foreigners") label(12 "Immigrants") label(14 "Index")) yline(0)

coefplot model80 model2 model81 model4 model82 model6 model83 model8 model84 model10 model85 model12 model86 model14, vertical keep(*.treated1#*.time_dummy r1vs0.did1) xtitle("Refugee-to-Population ratio") xlabel("") ytitle("Effect Size") title("Effect Size of Refugee to population ration using endogenous treatment") order(model90 model2 model91 model4 model92 model6 model93 model8 model94 model10 model95 model12 model96 model14) legend(label(2 "Crime") legend(label(2 "Crime") label(4 "Job") label(6 "Personal Econ") label(8 "Overall Econ") label(10 "Hostlity Foreigners") label(12 "Immigrants") label(14 "Index")) //Looks horrible, even with the right labeling

coefplot model80  model81 model82  model83  model84  model85  model86 || model2 model4 model6 model8 model10 model12 model14, title("Endogenous Treatment") vertical keep(*.treated1#*.time_dummy r1vs0.did1) xlabel("") xtitle("Refugee-to-Population ratio") legend(label(2 "Crime") label(4 "Job") label(6 "Personal Econ") label(8 "Overall Econ") label(10 "Hostlity Foreigners") label(12 "Immigrants") label(14 "Index")) title("ATE in the normal model (left) versus ATE in the endogenous treatment model (right)")
//This is going to take me for fucking hours. 


//Robustnesscheck: Using a Probit Model
// First Step: Showing Q-Q-Plots for normal OLS.
reg worried_crime2 time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate, rob cluster(state) 
predict effect, residuals
qnorm effect
graph save "Graph" "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\QQ-Plot.gph", replace 

//Now we run the ordered probit model
xtoprobit worried_crime2 i.treated1##time_dummy unemployment_rate demographic_trends swm migrant_rate population_density c.refugees##c.migrant_rate i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, vce(cluster state)
outreg2 using ordered_probit.tex, replace ctitle(Crime)
outreg2 i.treated1##time_dummy using ordered_probit1.tex, replace ctitle(Crime)
estimates store model20

xtoprobit worried_job2 i.treated1##time_dummy unemployment_rate demographic_trends swm migrant_rate population_density c.refugees##c.migrant_rate i.age_dummy  i.dummy_relationship i.health_dummy i.employment_dummy,  vce(cluster state) 
outreg2 using ordered_probit.tex, append ctitle(Job)
outreg2 i.treated1##time_dummy using ordered_probit1.tex, append ctitle(Job)
estimates store model21

xtoprobit worried_personal_econ2 i.treated1##time_dummy unemployment_rate demographic_trends swm c.refugees##c.migrant_rate population_density c.refugees##c.migrant_rate i.age_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy, vce(cluster state)
outreg2 using ordered_probit.tex, append ctitle(Personal Econ)
outreg2 using ordered_probit1.tex, append ctitle(Personal Econ)
estimates store model22

xtoprobit worried_overall_econ2 i.treated1##time_dummy unemployment_rate demographic_trends swm c.refugees##c.migrant_rate population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, vce(cluster state)
outreg2 using ordered_probit.tex, append ctitle(Overall Econ)
outreg2 using ordered_probit2.tex, replace ctitle(Overall Econ)
estimates store model23

xtoprobit worried_hostility_foreigners2 i.treated1##time_dummy unemployment_rate demographic_trends swm c.refugees##c.migrant_rate population_density i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, vce(cluster state)
outreg2 using ordered_probit.tex, append ctitle(Hostility Foreigners)
outreg2 using ordered_probit2.tex, replace ctitle(Hostility Foreigners)
estimates store model24

xtoprobit worried_immigrants2 i.treated1##time_dummy unemployment_rate demographic_trends swm  population_density c.refugees##c.migrant_rate i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, vce(cluster state) 
outreg2 using ordered_probit.tex, append ctitle(Immigrants)
outreg2 using ordered_probit2.tex, replace ctitle(Immigrants)
estimates store model25

xtoprobit worried_index i.treated1##time_dummy unemployment_rate demographic_trends swm  population_density c.refugees##c.migrant_rate i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, vce(cluster state)
outreg2 using ordered_probit.tex, append ctitle(Immigrants)
outreg2 using ordered_probit2.tex, replace ctitle(Index)
estimates store model26

coefplot model20 model21 model22 model23 model24 model25 model26, vertical keep(*.treated1#*.time_dummy r1vs0.did1) xtitle("Model Specifications") xlabel("") yline(0) ytitle("ATE") title("ATE of the refugee to population ratio using an ordered probit model") legend(label(2 "Crime")  label(4 "Job") label(6 "Personal Econ") label(8 "Overall_Econ") label(10 "Hostility Foreigners") label(12 "Immigrants") label(14 "Index overall"))

coefplot model80  model81 model82  model83  model84  model85  model86 || model20 model21 model22 model23 model24 model25 model26, title("Endogenous Treatment") vertical keep(*.treated1#*.time_dummy r1vs0.did1) xlabel("") xtitle("Refugee-to-Population ratio") legend(label(2 "Crime") label(4 "Job") label(6 "Personal Econ") label(8 "Overall Econ") label(10 "Hostlity Foreigners") label(12 "Immigrants") label(14 "Index")) title("ATE in the normal model (left) versus ATE in the probit model (right)")


graph save "Graph" "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\ATE_ordered_probit.gph", replace

//Robustness to alternative lag specifications.
//How do the three significant coefficient change if we include alternative lag specifications?

xtdidregress (worried_crime2 unemployment_rate_lag1 demographic_trends_lag1 gdp_per_cap_lag1 population_density_lag1 c.migrant_rate_lag1##c.refugees_lag1 i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year)
outreg2 using alternative_lags.tex, replace ctitle(Crime Lag 1)
estimates store model30

xtdidregress (worried_crime2 unemployment_rate_lag2 demographic_trends_lag2 gdp_per_cap_lag2 population_density_lag2 c.migrant_rate_lag2##c.refugees_lag2 i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) 
outreg2 using alternative_lags.tex, append ctitle(Crime Lag 2)
estimates store model31

xtdidregress (worried_immigrants2 unemployment_rate_lag1 demographic_trends_lag1 gdp_per_cap_lag1 population_density_lag1 c.migrant_rate_lag1##c.refugees_lag1 i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) //PV: 0.580
outreg2 using alternative_lags.tex, append ctitle(Immigration Lag 1)
estimates store model32

xtdidregress (worried_immigrants2 unemployment_rate_lag2 demographic_trends_lag2 gdp_per_cap_lag2 population_density_lag2 c.migrant_rate_lag2##c.refugees_lag2 i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) //PV: 0.580
outreg2 using alternative_lags.tex, append ctitle(Immigration Lag 2)
estimates store model33

xtdidregress (worried_personal_econ2 unemployment_rate_lag1 demographic_trends_lag1 gdp_per_cap_lag1 population_density_lag1 c.migrant_rate_lag1##c.refugees_lag1 i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year)
outreg2 using alternative_lags.tex, append ctitle(Personal Econ Lag 1)
estimates store model34

xtdidregress (worried_personal_econ2 unemployment_rate_lag2 demographic_trends_lag2 gdp_per_cap_lag2 population_density_lag2 c.migrant_rate_lag2##c.refugees_lag2 i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) //PV: 0.580
outreg2 using alternative_lags.tex, append ctitle(Personal Econ Lag 2)
estimates store model35

coefplot model80 model30 model31 model85 model32 model33 model82 model34 model35, vertical drop(unemployment_rate demographic_trends swm migrant_rate population_density refugees migrant_rate c.refugees#c.migrant_rate population gdp _cons 1.time_dummy 1.treated1 /athrho  /lnsigma rho) xtitle("Model Specifications") xlabel("") yline(0) ytitle("ATE") title("ATE using different lags") legend(label(2 "Crime No Lag") label(4 "Crime Lag 1") label(6 "Crime Lag 2") label(8 "Immigrants No Lag") label(10 "Immigrants Lag 1") label(12 "Immigrants Lag 2") label(14 "Personal Econ No Lag") label(16 "Personal Econ Lag 1") label(18 "Personal Econ Lag 2")) 

graph save "Graph" "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\ATE_different_lags.gph", replace


* --------------------------------------------------------------------.
* 						Researching Individual Effects 				  .
*                        					                          .
* --------------------------------------------------------------------.

reg worried_crime2 time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap  swm population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy, cluster(state) rob baselevels 
outreg2 using individual_characteristics.tex, replace ctitle(Crime) adjr2

reg worried_job2 time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap swm population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy, cluster(state) rob baselevels
outreg2 using individual_characteristics.tex, append ctitle(Job) adjr2

reg worried_personal_econ2 time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap swm population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy, cluster(state) rob baselevels
outreg2 using individual_characteristics.tex, append ctitle(Personal Econ) adjr2

reg worried_overall_econ2 time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap swm  population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy, cluster(state) rob baselevels
outreg2 using individual_characteristics.tex, append ctitle(Overall Econ) adjr2

reg worried_hostility_foreigners2 time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap swm population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy, cluster(state) rob baselevels
outreg2 using individual_characteristics.tex, append ctitle(Hostility) adjr2

reg worried_immigrants2 time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap swm population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy, cluster(state) rob baselevels
outreg2 using individual_characteristics.tex, append ctitle(Immigrants) adjr2

reg worried_index time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy i.age_dummy##i.education_dummy i.age_dummy#i.sex, cluster(state) rob baselevels //Problem is: Some random variables are ommited due to collinearity. 
outreg2 using individual_characteristics.tex, append ctitle(Index) adjr2

reg worried_econ time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy, cluster(state) rob baselevels //Problem is: Some random variables are ommited due to collinearity. 
outreg2 using individual_characteristics.tex, append ctitle(Econ Index) adjr2

reg worried_cultural time_dummy##treated1 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees i.age_dummy i.sex i.immigrant_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy i.education_dummy i.religion_dummy, cluster(state) rob baselevels //Problem is: Some random variables are ommited due to collinearity. 
outreg2 using individual_characteristics.tex, append ctitle(Cultural Index) adjr2



margins health_dummy
marginsplot, xtitle("Self Reported Health Status") xlabel(1 "Very Good" 2 "Good" 3 "Satisfactory" 4 "Less Good" 5 "Bad", angle(45)) ytitle("Index of overall institutional erosion") title("Effect of health status on perceived institutional erosion (overall index)")

margins children_dummy
marginsplot

margins age_dummy
marginsplot, xtitle("Age Group") xlabel(1 " < 25" 2 "25-35" 3 "35-45" 4 "45-55" 5 "55-65" 6 " > 65") ytitle("Index of overall institutional erosion") title("Effect of age on perceived institutional erosion (overall index)")

margins employment_dummy
marginsplot, xtitle("Education Level") 

margins religion_dummy
marginsplot, xtitle("Religion")

margins sex
marginsplot, xtitle("Sex") xlabel(1 "Male" 2 "Female", angle(45)) ytitle("Index of overall institutional erosion") title("Effect of sex on perceived institutional erosion (overall index)")

margins age_dummy#education_dummy
marginsplot, xlabel(1 " < 25" 2 "25-35" 3 "35-45" 4 "45-55" 5 "55-65" 6 " > 65") ytitle("Index of overall institutional erosion") title("Interactioneffect of Age and Education on perceived institutional erosion (overall index)") noci


margins education_dummy
marginsplot, xtitle("Education Level") legend(label(1 "Control")  label(2 "Treatment")) xlabel(1 "No Education" 2 "Secondary School diploma" 3 "Advanced college certificate" 4 "A-Levels", angle(45))

// lower secondary school diploma (=Hauptschulabschluss)
replace education_dummy = 2 if education == 2 // Secondary school diploma 
// Advanced technical college certificate
 // A-Levels

* --------------------------------------------------------------------.
* 						Parallel Trends								  .
*                        					                          .
* --------------------------------------------------------------------.
//Crime
xtdidregress (worried_crime2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees i.age_dummy i.dummy_relationship i.health_dummy  i.employment_dummy) (did1), group(state) time(year)
estat trendplots, xtitle("Year") ytitle("Concern about Crime") // looks really bad

xtdidregress (worried_crime2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) //PV: 0.580
estat ptrends


//Immigrants
xtdidregress (worried_immigrants2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year)
estat trendplots, xtitle("Year") ytitle("Concern about Immigration")

xtdidregress (worried_immigrants2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees swm i.age_dummy i.dummy_relationship i.health_dummy i.children_dummy i.employment_dummy) (did1), group(state) time(year) //PV: 0.580
estat trendplots
estat ptrends
graph save "Graph" "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Paralell Trends Immigration.gph", replace

//Personal Econ
xtdidregress (worried_personal_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) 
estat trendplots, xtitle("Year") ytitle("Concern about Personal Economic Situation")

xtdidregress (worried_personal_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) //PV: 0.580
estat ptrend

graph save "Graph" "C:\Users\User\OneDrive\Alex_s Zeug\King's\Dissertation\Dissertation\Data\Regional Data and Matching\Paralell Trends Index.gph", replace 

estat trendplots, xlabels
estat ptrends //Trends are not paralllel
estat granger //Anticipation effect of Treatment

* --------------------------------------------------------------------.
* 						 Different Standard Errors					  .
*                        					                          .
* --------------------------------------------------------------------.
//Bell and McCaffrey

xtdidregress (worried_crime2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) vce(hc2)
outreg2 using xtdidregress_worried_bell_lang.tex, replace ctitle(Crime)
estimates store model70

xtdidregress (worried_job2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) vce(hc2)
outreg2 using xtdidregress_worried_bell_lang.tex, append ctitle(Job) 
estimates store model71

xtdidregress (worried_personal_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.health_dummy i.dummy_relationship i.employment_dummy) (did1), group(state) time(year) vce(hc2)
outreg2 using xtdidregress_worried_bell_lang.tex, append ctitle(Personal Econ) 
estimates store model72

xtdidregress (worried_overall_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.employment_dummy i.health_dummy) (did1), group(state) time(year) vce(hc2)
outreg2 using xtdidregress_worried_bell_lang.tex, append ctitle(Overall Econ) 
estimates store model73

xtdidregress (worried_hostility_foreigners2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) vce(hc2)
outreg2 using xtdidregress_worried_bell_lang.tex, append ctitle(Hostility) 
estimates store model74

xtdidregress (worried_immigrants2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) vce(hc2)
outreg2 using xtdidregress_worried_bell_lang.tex, append ctitle(Immigrants) 
estimates store model75

xtdidregress (worried_index unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) vce(hc2)
outreg2 using xtdidregress_worried_bell_lang.tex, append ctitle(Index) 
estimates store model76

//Donald and Lang
xtdidregress (worried_crime2 unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) aggregate(dlang, varying)
outreg2 using xtdidregress_worried_donald_lang.tex, replace ctitle(Crime)
estimates store model60

xtdidregress (worried_job2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) aggregate(dlang, varying)
outreg2 using xtdidregress_worried_donald_lang.tex, append ctitle(Job) 
estimates store model61

xtdidregress (worried_personal_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.health_dummy i.dummy_relationship i.employment_dummy) (did1), group(state) time(year) aggregate(dlang, varying)
outreg2 using xtdidregress_worried_donald_lang.tex, append ctitle(Personal Econ) 
estimates store model62

xtdidregress (worried_overall_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.employment_dummy i.health_dummy) (did1), group(state) time(year) aggregate(dlang, varying)
outreg2 using xtdidregress_worried_donald_lang.tex, append ctitle(Overall Econ) 
estimates store model63

xtdidregress (worried_hostility_foreigners2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) aggregate(dlang, varying)
outreg2 using xtdidregress_worried_donald_lang.tex, append ctitle(Hostility) 
estimates store model64

xtdidregress (worried_immigrants2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) aggregate(dlang, varying)
outreg2 using xtdidregress_worried_donald_lang.tex, append ctitle(Immigrants) 
estimates store model65

xtdidregress (worried_index unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) aggregate(dlang, varying)
outreg2 using xtdidregress_worried_donald_lang.tex, append ctitle(Index) 
estimates store model66

* --------------------------------------------------------------------.
* 						Franz Fratscher and Kritikos				  .
*                        					                          .
* --------------------------------------------------------------------.

xtreg worried_crime2 pop_change unemployment_rate demographic_trends gdp_per_cap population_density c.migrant_rate##c.refugees ref_to_pop i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, cluster(state) robust 
outreg2 using xtdidregress_worried_time_variant.tex, replace ctitle(Crime)
estimates store model80

xtdidregress (worried_job2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did_d), group(state) time(year)
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Job) 
estimates store model81

xtdidregress (worried_personal_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.health_dummy i.dummy_relationship i.employment_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Personal Econ) 
estimates store model82

xtdidregress (worried_overall_econ2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.employment_dummy i.health_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Overall Econ) 
estimates store model83

xtdidregress (worried_hostility_foreigners2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Hostility) 
estimates store model84

xtdidregress (worried_immigrants2 unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year)
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Immigrants) 
estimates store model85

xtdidregress (worried_index unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy) (did1), group(state) time(year) 
outreg2 using xtdidregress_worried_time_variant.tex, append ctitle(Index) 
estimates store model86

//Cunninghams
//Cunninghams cool graph 
xi: reg worried_crime2 time_dummy##treated1 i.state unemployment_rate demographic_trends gdp_per_cap population_density c.refugees##c.migrant_rate swm i.age_dummy i.dummy_relationship i.health_dummy i.employment_dummy, cluster(state) robust

parmest, label for(estimate min95 max95 %8.2f) li(parm label estimate min95 max95) saving(regression_data.dta, replace)

use ./regression_data, replace
keep in 9/15

gen     year=2012 in 1
replace year=2013 in 2
replace year=2014 in 3 
replace year=2015 in 4 
replace year=2016 in 5 
replace year=2017 in 6
replace year=2018 in 7

twoway (connected estimate year, mlabel(year) mlabsize(vsmall) msize(tiny)) (rcap min95 max95 year, msize(vsmall)), ytitle(Treatment x year estimated coefficient) yscale(titlegap(2)) yline(0, lwidth(vvvthin) lcolor(black)) xtitle(Year) xline(2012 2013 2014, lwidth(vvvthick) lpattern(solid) lcolor(ltblue)) xscale(titlegap(2)) title(Estimated effect of refugees  on satisfaction with life) subtitle(Using Groups) legend(off)
