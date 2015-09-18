
**********************************************************************************************************
**  YIZZAYIZZAYIZZA
**  YIZZAYIZZAYIZZA
**  MCC-Namibia CBRLM evaluation 																		**
**  Created by Pierre-Yves Durand on 20 Jan 2015; last updated by Dylan Groves on July 18 2015			**
** 	Insheets the raw data downloaded from the SurveyCTO Client and saves to middata folders  			**
**  Runs the auto-generated do.files created by the SurveyCTO Client and saves to dtafiles				**
**  	Note: This does not include the direct observation or redo survey data							**
**		Note: Behavioral_Survey_v17.csv FINAL BEHAVIORAL V1/2/3/5/6 contain actual data					**
**		Note: Behavioral_Survey_v6/9/10/12/14 contain only data from testing and piloting				**
**********************************************************************************************************
**  1: INSHEET CSV FILES CREATED BY SURVEYCTO															**
**  2: RUN THE DO.FILES CREATED BY SURVEYCTO CLIENT: 													**
**  	2A: Imports and aggregates "Behavioral_Survey_v17" (ID: Behavioral_Survey_v17) data.			**
**  	2B: Imports and aggregates "FINAL BEHAVIORAL V1" (ID: FINAL_BEHAVIORAL_V1) data.				**
**  	2C: Imports and aggregates "FINAL BEHAVIORAL V2" (ID: FINAL_BEHAVIORAL_V2) data					**
**  	2D: Imports and aggregates "FINAL BEHAVIORAL V3" (ID: FINAL_BEHAVIORAL_V3) data.				**
**  	2E: Imports and aggregates "FINAL BEHAVIORAL V5" (ID: FINAL_BEHAVIORAL_V5) data.				**
**  	2F: Imports and aggregates "FINAL BEHAVIORAL V6" (ID: FINAL_BEHAVIORAL_V6) data.				**
**  3: PREPARE FOR ADDITION OF REDO DATA:  																**
**  	3A: Append dtafiles created by SurveyCTO Client  												**
**  	3B: Create farmer unique_id to merge the data set with the redo 								**
**  4: ADD IN REDO DATA, I.E., RESPONDENTS WE CAME BACK TO, PARTICULARLY FOR PLANNED GRAZING INFO:  	**
**  	4A: Imports and aggregates "FINAL_Behavioral_redo_v4" (ID: FINAL_Behavioral_redo_v4) data. 		**
**  	4B: Imports and aggregates "FINAL_Behavioral_redo_v5" (ID: FINAL_Behavioral_redo_v5) data.		**
**  	4C: Imports and aggregates "FINAL_behavioral_redo_v7" (ID: FINAL_behavioral_redo_v7) data.		**
**  	4D: Imports and aggregates "FINAL_behavioral_redo_v8" (ID: FINAL_behavioral_redo_v8) data.		**
**  	4E: Append redo dtafiles created by SurveyCTO Client  											**
**		4F: Prepare redo dta file for merging with main dta file										**
**		4G: Merge main and redo dta file																**											
**********************************************************************************************************

clear all
clear matrix
clear mata
set mem 20m
set varabbrev off
set more off
set mem 100m

local date_b1_data 								"2015.01.19" // Date of data

tempfile v17 v1 v2 v3 v5 v6
tempfile vredo4 vredo5 vredo7 vredo8 

**  Pierre's paths
*gl stata "C:\Users\pierre-yves\Dropbox (Personnelle)\Shared Namibia\Stata Folder"
**  Luke's path
*gl stata "C:\Users\IPA1\Dropbox\namibia_mcc_rangeland\Stata Folder"
**  Dylan's path
gl stata "C:\Users\Dylan\Dropbox\Shared Namibia\Stata Folder"

#delimit ;


********************************************************************************************************** ;
********************************************************************************************************** ;
**  STEP 1: INSHEET CSV FILES CREATED BY SURVEYCTO														** ;
********************************************************************************************************** ;
********************************************************************************************************** ;

insheet using "$stata\rawdata\behavioral\Behavioral_Survey_v17.csv", names clear ;
save "$stata\middata\behavioral\Behavioral_Survey_v17.dta", replace ;

foreach i of numlist 1/3 5 6  { ;
	insheet using "$stata\rawdata\behavioral\FINAL BEHAVIORAL V`i'.csv", names clear ;
	save "$stata\middata\behavioral\FINAL BEHAVIORAL V`i'.dta", replace ;
} ;


********************************************************************************************************** ;
********************************************************************************************************** ;
**  STEP 2: RUN THE DO.FILES CREATED BY SURVEYCTO CLIENT 												** ;
********************************************************************************************************** ;
********************************************************************************************************** ;

********************************************************************************************************** ;
**  STEP 2A: Imports and aggregates "Behavioral_Survey_v17" (ID: Behavioral_Survey_v17) data.			** ;
********************************************************************************************************** ;

#delimit cr

use "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_Behavioral_Survey_v17.dta", clear 
destring combherdrain_whynot, replace force 
save "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_Behavioral_Survey_v17.dta", replace 

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\Behavioral_Survey_v17.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_Behavioral_Survey_v17.dta"
local corrfile "$stata\rawdata\behavioral\Behavioral_Survey_v17_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local note_fields1 "informed_consent enumwait waitformanager plannedgrazingintro combinedherdingintro introherding lstockmgmtintro commnote socdyn_intro followup_combine followup_grazingarea"
local note_fields2 "followup_generaldevt request_numbers"
local text_fields1 "deviceid subscriberid simid devicephonenum region enum_id text_audit ga_id farmer_number farmer_id respondent_firstname respondent_surname language_other relation_manager_other location_manager"
local text_fields2 "graze_location educ_owner educ_owner_other occup_owner occup_owner_other liveswhere relation_owner relation_owner_other rains grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months"
local text_fields3 "grazeplanrain_writtenshare_oth grazeplan_otherlocfreq combherdrain_whynot_other herd_managerherds herd_gear herd_gear_other herd_paygroup herd_gear_self herd_gear_other_self"
local text_fields4 "whynoherd lsmgmt_othvac lsmgmt_othvac_other lsmgmt_pay lsmgmt_supplement lsmgmt_supplement_other lsoff_buyers lsoff_buyers_other lsoff_salereasons lsoff_salereasons_other lsoff_animalreasons"
local text_fields5 "lsoff_animalreason_other lsoff_restructure lsoff_restructure_other comm_devt_desc mgr_relation_ta owner_relation_ta comments"
local date_fields1 ""
local datetime_fields1 "starttime endtime date_beginning datetime_end"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear
tempfile datetime all
save `all'
gen rank_id = _n
keep rank_id date_beginning datetime_end key
save `datetime'
use `all'

* continue only if there's at least one row of data to import
if _N > 0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\Behavioral_Survey_v17-`repeatgroup'.csv", names clear
	
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
	
	* drop note fields (since they don't contain any real data) 1
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms"[,2025])
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm"[,2025]) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 1
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				foreach stringvar of varlist `svarlist' {
					quietly: replace `ismissingvar'=.
					quietly: cap replace `ismissingvar'=1 if `stringvar'==.
					cap tostring `stringvar', format(%100.0g) replace
					cap replace `stringvar'="" if `ismissingvar'==1
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable date_beginning "Enter date and time"
	note date_beginning: "Enter date and time"

	label variable region "What regional team are you a part of?"
	note region: "What regional team are you a part of?"

	label variable enum_id "ENUMERATOR: What is your name?"
	note enum_id: "ENUMERATOR: What is your name?"

	label variable gpslatitude "ENUMERATOR: Enter your GPS Coordinates (latitude)"
	note gpslatitude: "ENUMERATOR: Enter your GPS Coordinates (latitude)"

	label variable gpslongitude "ENUMERATOR: Enter your GPS Coordinates (longitude)"
	note gpslongitude: "ENUMERATOR: Enter your GPS Coordinates (longitude)"

	label variable gpsaltitude "ENUMERATOR: Enter your GPS Coordinates (altitude)"
	note gpsaltitude: "ENUMERATOR: Enter your GPS Coordinates (altitude)"

	label variable gpsaccuracy "ENUMERATOR: Enter your GPS Coordinates (accuracy)"
	note gpsaccuracy: "ENUMERATOR: Enter your GPS Coordinates (accuracy)"

	label variable consent "Do you agree to taking the survey?"
	note consent: "Do you agree to taking the survey?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable live_interview "ENUMERATOR: Is this a live interview, or are you entering an interview that was "
	note live_interview: "ENUMERATOR: Is this a live interview, or are you entering an interview that was conducted on paper?"
	label define live_interview 1 "This is a live interview" 2 "This is an interview that was originally conducted on paper"
	label values live_interview live_interview

	label variable ga_id "ENUMERATOR: What is the name of the grazing area?"
	note ga_id: "ENUMERATOR: What is the name of the grazing area?"

	label variable farmer_number "ENUMERATOR: What number was this respondent on your listing form?"
	note farmer_number: "ENUMERATOR: What number was this respondent on your listing form?"

	label variable respondent_firstname "What is your first name?"
	note respondent_firstname: "What is your first name?"

	label variable respondent_surname "What is your surname?"
	note respondent_surname: "What is your surname?"

	label variable gender "ENUMERATOR: Is the manager male or female?"
	note gender: "ENUMERATOR: Is the manager male or female?"
	label define gender 1 "Male" 2 "Female"
	label values gender gender

	label variable language "What is the primary language spoken in your home?"
	note language: "What is the primary language spoken in your home?"
	label define language 1 "Herero" 2 "Kwanyama" 3 "Ndonga" 4 "Kwambi" 5 "Ngandjera" 6 "Mbalunhu" 7 "Kwaluudhi" 8 "Eunda" 9 "Nkolonkadhi" 10 "Zemba" 11 "Himba" 12 "Kwangali" 13 "Shambyu" 14 "Gciriku" 16 "Mbukushu" -77 "Other: specify"
	label values language language

	label variable language_other "Other: Specify"
	note language_other: "Other: Specify"

	label variable manages_owncattle "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make deci"
	note manages_owncattle: "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, and make decisions when there are problems with the cattle?"
	label define manages_owncattle 1 "Yes" 0 "No"
	label values manages_owncattle manages_owncattle

	label variable manages_othercattle "Do you manage a herd of 10 or more cattle, including cattle that belong to other"
	note manages_othercattle: "Do you manage a herd of 10 or more cattle, including cattle that belong to others? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, and make decisions when there are problems with the cattle?"
	label define manages_othercattle 1 "Yes" 0 "No"
	label values manages_othercattle manages_othercattle

	label variable relation_manager "What is your relation to the manager?"
	note relation_manager: "What is your relation to the manager?"
	label define relation_manager 1 "The manager is my husband/wife" 2 "The manager is my mother/father" 3 "The manager is my brother/sister" 4 "The manager is my son/daughter" -77 "I am related to the manager in some other way" -78 "I am not related to the manager: specify"
	label values relation_manager relation_manager

	label variable relation_manager_other "Other: Specify"
	note relation_manager_other: "Other: Specify"

	label variable location_manager "ENUMERATOR Where is the manager currently?"
	note location_manager: "ENUMERATOR Where is the manager currently?"

	label variable return_manager "ENUMERATOR: When do you expect the manager to return?"
	note return_manager: "ENUMERATOR: When do you expect the manager to return?"
	label define return_manager 1 "In just a few minutes" 2 "Later today" 3 "Tomorrow" 4 "Later than tomorrow"
	label values return_manager return_manager

	label variable capable_responding "ENUMERATOR: Do you think this person is capable of answering questions about the"
	note capable_responding: "ENUMERATOR: Do you think this person is capable of answering questions about the management of these livestock?"
	label define capable_responding 1 "Yes" 0 "No"
	label values capable_responding capable_responding

	label variable graze_location "Where is the location where you currently graze these cattle?"
	note graze_location: "Where is the location where you currently graze these cattle?"

	label variable age_mgr "How old are you?"
	note age_mgr: "How old are you?"

	label variable years_managed "For how many years have you managed the cattle in this kraal?"
	note years_managed: "For how many years have you managed the cattle in this kraal?"

	label variable hhs_managed "For how many households do you manage cattle?"
	note hhs_managed: "For how many households do you manage cattle?"

	label variable age_owner "How old is the owner of the kraal?"
	note age_owner: "How old is the owner of the kraal?"

	label variable educ_owner "What is the highest level of education that the OWNERS have received?"
	note educ_owner: "What is the highest level of education that the OWNERS have received?"

	label variable educ_owner_other "Other: Specify"
	note educ_owner_other: "Other: Specify"

	label variable occup_owner "What occupations do the owners of the cattle have?"
	note occup_owner: "What occupations do the owners of the cattle have?"

	label variable occup_owner_other "Other: Specify"
	note occup_owner_other: "Other: Specify"

	label variable livesin_ga "Do you live in \${graze_location}"
	note livesin_ga: "Do you live in \${graze_location}"
	label define livesin_ga 1 "Yes" 0 "No"
	label values livesin_ga livesin_ga

	label variable liveswhere "Where do you live?"
	note liveswhere: "Where do you live?"

	label variable relation_owner "How are you related to the owners of the cattle?"
	note relation_owner: "How are you related to the owners of the cattle?"

	label variable relation_owner_other "ENUMERATOR: if the person is related to the owners in any other way, please desc"
	note relation_owner_other: "ENUMERATOR: if the person is related to the owners in any other way, please describe it here"

	label variable cattle_managed "How many cattle do you manage?"
	note cattle_managed: "How many cattle do you manage?"

	label variable cows_managed "How many cows are in the herd you manage?"
	note cows_managed: "How many cows are in the herd you manage?"

	label variable bulls_managed "How many bulls are in the herd you manage?"
	note bulls_managed: "How many bulls are in the herd you manage?"

	label variable herd_freq "How often do you visit this herd?"
	note herd_freq: "How often do you visit this herd?"
	label define herd_freq 1 "Daily or near daily" 2 "Weekly or near weekly" 3 "Monthly or near monthly" 4 "Less frequently than monthly" -88 "Refuses to say"
	label values herd_freq herd_freq

	label variable own_catinherd "Do you also own any cattle that are a part of this herd?"
	note own_catinherd: "Do you also own any cattle that are a part of this herd?"
	label define own_catinherd 1 "Yes" 0 "No"
	label values own_catinherd own_catinherd

	label variable grazeplandry_basicplan "Do you have a plan for where you want your cattle to graze within \${graze_locat"
	note grazeplandry_basicplan: "Do you have a plan for where you want your cattle to graze within \${graze_location} during the most recent dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general grazing plan as your herd?"
	note grazeplandry_otherherds: "Did other farmers follow the same general grazing plan as your herd?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals also followed this grazing plan?"
	note grazeplandry_numkraal: "How many other kraals also followed this grazing plan?"

	label variable grazeplandry_groupplan "Is this grazing plan one that was decided on as a group?"
	note grazeplandry_groupplan: "Is this grazing plan one that was decided on as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Is there someone who was personally responsible for making sure the grazing plan"
	note grazeplandry_responsible: "Is there someone who was personally responsible for making sure the grazing plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Is this plan written?"
	note grazeplandry_write: "Is this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during the past rainy season?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often do you adhere to this plan?"
	note grazeplanrain_freq: "In a month when you were following a plan, how often do you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general grazing plan as your herd?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general grazing plan as your herd?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals also followed this grazing plan?"
	note grazeplanrain_numkraal: "How many other kraals also followed this grazing plan?"

	label variable grazeplanrain_groupplan "Is this grazing plan one that was decided on as a group?"
	note grazeplanrain_groupplan: "Is this grazing plan one that was decided on as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who is personally responsible for making sure the grazing plan"
	note grazeplanrain_responsible: "Was there someone who is personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Is this plan shared with others?"
	note grazeplan_postrainshare: "Is this plan shared with others?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, has the entire herd grazed outside \${graze_location} at "
	note grazeplan_gafullyear: "In the past 12 months, has the entire herd grazed outside \${graze_location} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons has the entire herd grazed outside of \${graze_location}?"
	note grazeplan_otherlocfreq: "For which seasons has the entire herd grazed outside of \${graze_location}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_grazeplan comprehend_grazeplan

	label variable combherddry_combines "During this past dry season, did your cattle usually combine with herds from oth"
	note combherddry_combines: "During this past dry season, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherddry_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_combines combherddry_combines

	label variable combherddry_specificherds "When your herd was combined during this dry season, were there particular herds "
	note combherddry_specificherds: "When your herd was combined during this dry season, were there particular herds that you intentionally combined with?"
	label define combherddry_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_specificherds combherddry_specificherds

	label variable combherddry_whynot "Why did you not engage in combined herding during that dry season?"
	note combherddry_whynot: "Why did you not engage in combined herding during that dry season?"
	label define combherddry_whynot 1 "Not enough grass on the land" 2 "Herders are unwilling" 3 "'Not something our people do'" 4 "I will not pay for herders" 5 "People will not let me in the combined herd" -77 "Other: specify"
	label values combherddry_whynot combherddry_whynot

	label variable combherddry_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during this "
	note combherddry_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during this dry season?"
	label define combherddry_discussmgr 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_discussmgr combherddry_discussmgr

	label variable combherddry_numkraals "How many kraals are in this combined herd in total during this dry season?"
	note combherddry_numkraals: "How many kraals are in this combined herd in total during this dry season?"

	label variable combherddry_numcat "How many cattle in total were in this combined herd during this dry season?"
	note combherddry_numcat: "How many cattle in total were in this combined herd during this dry season?"

	label variable combherddry_numbull "How many bulls in total were in this combined herd during this dry season?"
	note combherddry_numbull: "How many bulls in total were in this combined herd during this dry season?"

	label variable combherdrain_combines "During this past rainy season, did your cattle usually combine with herds from o"
	note combherdrain_combines: "During this past rainy season, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherdrain_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_combines combherdrain_combines

	label variable combherdrain_specificherds "When you combined your herd during the rainy season, were there particular herds"
	note combherdrain_specificherds: "When you combined your herd during the rainy season, were there particular herds that you intentionally combined with during that rainy season?"
	label define combherdrain_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_specificherds combherdrain_specificherds

	label variable combherdrain_whynot "Why did you not engage in combined herding during that rainy season?"
	note combherdrain_whynot: "Why did you not engage in combined herding during that rainy season?"

	label variable combherdrain_whynot_other "Other: Specify"
	note combherdrain_whynot_other: "Other: Specify"

	label variable combherdrain_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during this "
	note combherdrain_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during this rainy season?"
	label define combherdrain_discussmgr 1 "Yes" 0 "No"
	label values combherdrain_discussmgr combherdrain_discussmgr

	label variable combherdrain_numkraals "How many kraals are in this combined herd in total during this rainy season?"
	note combherdrain_numkraals: "How many kraals are in this combined herd in total during this rainy season?"

	label variable combherdrain_numcat "How many cattle in total are in this combined herd?"
	note combherdrain_numcat: "How many cattle in total are in this combined herd?"

	label variable combherdrain_numbull "How many bulls in total are in this combined herd during this rainy season?"
	note combherdrain_numbull: "How many bulls in total are in this combined herd during this rainy season?"

	label variable comprehend_combherd "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_combherd: "ENUMERATOR: How well do you think the respondent understood these questions about combined herding, and do you trust their responses?"
	label define comprehend_combherd 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_combherd comprehend_combherd

	label variable herd_managerherds "Do you herd these cattle, or does someone else?"
	note herd_managerherds: "Do you herd these cattle, or does someone else?"

	label variable herd_drynumherders "In the dry season, how many herders were usually looking after the cattle?"
	note herd_drynumherders: "In the dry season, how many herders were usually looking after the cattle?"

	label variable herd_rainnumherders "In the rainy season, how many herders were usually looking after the cattle?"
	note herd_rainnumherders: "In the rainy season, how many herders were usually looking after the cattle?"

	label variable comm_herders "How often do you communicate with your herders?"
	note comm_herders: "How often do you communicate with your herders?"
	label define comm_herders 1 "Daily" 2 "Most days (multiple times a week)" 3 "Approximately once a week" 4 "Less than once a week (but more than once a month)" 5 "Once a month or less often" -99 "Don’t know" -88 "Refuses to say"
	label values comm_herders comm_herders

	label variable herd_paycash "Do you pay your herders in cash?"
	note herd_paycash: "Do you pay your herders in cash?"
	label define herd_paycash 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_paycash herd_paycash

	label variable herd_cashvalue "How much do you pay your herders?"
	note herd_cashvalue: "How much do you pay your herders?"

	label variable herd_cashvalue_units "Units"
	note herd_cashvalue_units: "Units"
	label define herd_cashvalue_units 1 "Per week" 2 "Per month" 3 "Per year"
	label values herd_cashvalue_units herd_cashvalue_units

	label variable herd_payinkind "Do you pay your herders in any other form, including in food, calves, or another"
	note herd_payinkind: "Do you pay your herders in any other form, including in food, calves, or another form?"
	label define herd_payinkind 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_payinkind herd_payinkind

	label variable herd_inkindvalue "What is the total value of in-kind payments to herders?"
	note herd_inkindvalue: "What is the total value of in-kind payments to herders?"

	label variable herd_inkindvalue_units "Units"
	note herd_inkindvalue_units: "Units"
	label define herd_inkindvalue_units 1 "Per week" 2 "Per month" 3 "Per year"
	label values herd_inkindvalue_units herd_inkindvalue_units

	label variable herd_related "Are you related to your herders?"
	note herd_related: "Are you related to your herders?"
	label define herd_related 1 "Yes" 0 "No"
	label values herd_related herd_related

	label variable herd_gear "In the past 12 months, have you provided any of the following items for a herder"
	note herd_gear: "In the past 12 months, have you provided any of the following items for a herder?"

	label variable herd_gear_other "Other: Specify"
	note herd_gear_other: "Other: Specify"

	label variable herd_paygroup "Do you pay your herders individually, or do you pay your herders with managers f"
	note herd_paygroup: "Do you pay your herders individually, or do you pay your herders with managers from other kraals?"

	label variable herd_gear_self "In the past 12 months, have you acquired any of the following gear?"
	note herd_gear_self: "In the past 12 months, have you acquired any of the following gear?"

	label variable herd_gear_other_self "Other: Specify"
	note herd_gear_other_self: "Other: Specify"

	label variable herd_intensitydry "During the dry season, after you herders take your cattle to water, do they push"
	note herd_intensitydry: "During the dry season, after you herders take your cattle to water, do they push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensitydry 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensitydry herd_intensitydry

	label variable herd_intensityrains "During the rainy season, after you herders take your cattle to water, do they pu"
	note herd_intensityrains: "During the rainy season, after you herders take your cattle to water, do they push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensityrains 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensityrains herd_intensityrains

	label variable whynoherd "Why do you just push your animals, instead of remaining with them?"
	note whynoherd: "Why do you just push your animals, instead of remaining with them?"

	label variable herd_typewalk "Which picture best shows the way that your herd walks away from the water point "
	note herd_typewalk: "Which picture best shows the way that your herd walks away from the water point to pasture?"
	label define herd_typewalk 1 "Cattle in a tight bunch" 2 "Cattle in a line" 3 "Cattle scattered" -99 "Don't know"
	label values herd_typewalk herd_typewalk

	label variable herd_typegraze "Which picture best shows the way that your herd is managed when your cattle are "
	note herd_typegraze: "Which picture best shows the way that your herd is managed when your cattle are grazing?"
	label define herd_typegraze 1 "Cattle in a tight bunch" 2 "Cattle scattered" -99 "Don't know"
	label values herd_typegraze herd_typegraze

	label variable herd_animalsmissing "The last time you saw your herd, were any cattle missing?"
	note herd_animalsmissing: "The last time you saw your herd, were any cattle missing?"
	label define herd_animalsmissing 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_animalsmissing herd_animalsmissing

	label variable herd_numbermissing "How many were missing?"
	note herd_numbermissing: "How many were missing?"

	label variable herd_lastsawmissingqty "When was the last time you saw these missing cattle?"
	note herd_lastsawmissingqty: "When was the last time you saw these missing cattle?"

	label variable herd_lastsawmissingunit "Unit"
	note herd_lastsawmissingunit: "Unit"
	label define herd_lastsawmissingunit 1 "days" 2 "weeks" 3 "months"
	label values herd_lastsawmissingunit herd_lastsawmissingunit

	label variable herd_catlost "In the past 12 months, how many cattle have been lost, stolen or killed by a pre"
	note herd_catlost: "In the past 12 months, how many cattle have been lost, stolen or killed by a predator?"

	label variable water_freq "On average, how many times per day do you take your cattle to water?"
	note water_freq: "On average, how many times per day do you take your cattle to water?"
	label define water_freq 1 "Less than once a day" 2 "Once a day" 3 "Sometimes once a day, sometimes twice a day" 4 "Twice a day" 5 "There is a water point at my kraal"
	label values water_freq water_freq

	label variable water_quant "In the last three years, has the quantity of water you have access to gotten bet"
	note water_quant: "In the last three years, has the quantity of water you have access to gotten better, worse, or stayed the same?"
	label define water_quant 1 "Gotten better" 2 "Stayed the same" 3 "Gotten worse" -99 "Don't know"
	label values water_quant water_quant

	label variable water_qual "In the last three years, has the quality of water you have access to gotten bett"
	note water_qual: "In the last three years, has the quality of water you have access to gotten better, worse, or stayed the same?"
	label define water_qual 1 "Gotten better" 2 "Stayed the same" 3 "Gotten worse" -99 "Don't know"
	label values water_qual water_qual

	label variable water_dist "In the last three years, has the distance you normally travel to get water now f"
	note water_dist: "In the last three years, has the distance you normally travel to get water now further, closer, or the same?"
	label define water_dist 1 "It is now further" 2 "It is now closer" 3 "It is the same distance" -99 "Don't know"
	label values water_dist water_dist

	label variable water_animals "In the last three years, has the number of animals that use the water point you "
	note water_animals: "In the last three years, has the number of animals that use the water point you normally go to increased significantly, decreased significantly, or stayed about the same?"
	label define water_animals 1 "Increased significantly" 2 "Decreased significantly" 3 "Stayed about the same" -99 "Don't know"
	label values water_animals water_animals

	label variable water_barriers "Are there now barriers to your access to water that did not exist three years ag"
	note water_barriers: "Are there now barriers to your access to water that did not exist three years ago? For example, do you now have to pay for water use (apart from for diesel), or do you no longer have access to a particular water point?"
	label define water_barriers 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values water_barriers water_barriers

	label variable lsmgmt_dvs "In the past 12 months, did the government vaccinate your cattle?"
	note lsmgmt_dvs: "In the past 12 months, did the government vaccinate your cattle?"
	label define lsmgmt_dvs 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_dvs lsmgmt_dvs

	label variable lsmgmt_othvacyn "Did you vaccinate your cattle for any diseases apart from the ones provided by t"
	note lsmgmt_othvacyn: "Did you vaccinate your cattle for any diseases apart from the ones provided by the government?"
	label define lsmgmt_othvacyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_othvacyn lsmgmt_othvacyn

	label variable lsmgmt_othvac "Against which diseases did you vaccinate them?"
	note lsmgmt_othvac: "Against which diseases did you vaccinate them?"

	label variable lsmgmt_othvac_other "ENUMERATOR: Record any other vaccines the enumerator mentions"
	note lsmgmt_othvac_other: "ENUMERATOR: Record any other vaccines the enumerator mentions"

	label variable lsmgmt_howmanyvac "Did you vaccinate all of your cattle, or just some of them?"
	note lsmgmt_howmanyvac: "Did you vaccinate all of your cattle, or just some of them?"
	label define lsmgmt_howmanyvac 1 "All of the animals" 2 "Only one, or some of them"
	label values lsmgmt_howmanyvac lsmgmt_howmanyvac

	label variable lsmgmt_whyvac "Why did you vaccinate this/these cattle?"
	note lsmgmt_whyvac: "Why did you vaccinate this/these cattle?"
	label define lsmgmt_whyvac 1 "The animal was sick" 2 "To prevent the animals from getting sick"
	label values lsmgmt_whyvac lsmgmt_whyvac

	label variable lsmgmt_pay "Did the farmers in your kraal pay for vaccinations with other kraals?"
	note lsmgmt_pay: "Did the farmers in your kraal pay for vaccinations with other kraals?"

	label variable lsmgmt_deworm "In the past 12 months, have you dewormed your cattle?"
	note lsmgmt_deworm: "In the past 12 months, have you dewormed your cattle?"
	label define lsmgmt_deworm 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_deworm lsmgmt_deworm

	label variable lsmgmt_supplement "In the past 12 months, what supplements, if any, have you provided to your cattl"
	note lsmgmt_supplement: "In the past 12 months, what supplements, if any, have you provided to your cattle?"

	label variable lsmgmt_supplement_other "Other: Specify"
	note lsmgmt_supplement_other: "Other: Specify"

	label variable lsmgmt_ticfreq "How often are your cattle checked for tics?"
	note lsmgmt_ticfreq: "How often are your cattle checked for tics?"
	label define lsmgmt_ticfreq 1 "Once a week or more frequently" 2 "Every 8 days to every 30 days" 3 "Less than once every 30 days" 4 "Never" -99 "Don't know"
	label values lsmgmt_ticfreq lsmgmt_ticfreq

	label variable lsmgmt_locexpertsick "When you have questions about your cattle when they are sick, including diagnosi"
	note lsmgmt_locexpertsick: "When you have questions about your cattle when they are sick, including diagnosing illnesses or purchasing medicines is there someone in your community that you can ask?"
	label define lsmgmt_locexpertsick 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertsick lsmgmt_locexpertsick

	label variable lsmgmt_locexpertmgmt "When you have general questions about your cattle, including inseminating cows a"
	note lsmgmt_locexpertmgmt: "When you have general questions about your cattle, including inseminating cows and herding, is there someone in your community that you can ask?"
	label define lsmgmt_locexpertmgmt 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertmgmt lsmgmt_locexpertmgmt

	label variable lsmgmt_bullcow "What do you think is the ideal bull to cow ratio?"
	note lsmgmt_bullcow: "What do you think is the ideal bull to cow ratio?"

	label variable comprehend_lsmgmt "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_lsmgmt: "ENUMERATOR: How well do you think the respondent understood these questions about livestock management, and do you trust their responses?"
	label define comprehend_lsmgmt 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_lsmgmt comprehend_lsmgmt

	label variable lsoff_numsold "How many live cattle have you sold in the past 12 months?"
	note lsoff_numsold: "How many live cattle have you sold in the past 12 months?"

	label variable lsoff_valsold "How much money did you receive in total for these cattle?"
	note lsoff_valsold: "How much money did you receive in total for these cattle?"

	label variable lsoff_valsoldunits "In total or average"
	note lsoff_valsoldunits: "In total or average"
	label define lsoff_valsoldunits 1 "In total" 2 "Per animal"
	label values lsoff_valsoldunits lsoff_valsoldunits

	label variable lsoff_buyers "To whom have you sold cattle in the past 12 months?"
	note lsoff_buyers: "To whom have you sold cattle in the past 12 months?"

	label variable lsoff_buyers_other "Other: Specify"
	note lsoff_buyers_other: "Other: Specify"

	label variable lsoff_numslaughtfest "In the past 12 months, how many cattle have you slaughtered or gifted for weddin"
	note lsoff_numslaughtfest: "In the past 12 months, how many cattle have you slaughtered or gifted for weddings or funerals?"

	label variable lsoff_numgift "In the past 12 months, how many cattle have you lent or gifted to another househ"
	note lsoff_numgift: "In the past 12 months, how many cattle have you lent or gifted to another household months for reasons apart from weddings and funerals?"

	label variable lsoff_numslaughtsale "In the past 12 months, how many cattle have you slaughtered and sold? Do not inc"
	note lsoff_numslaughtsale: "In the past 12 months, how many cattle have you slaughtered and sold? Do not include animals slaughtered and sold for weddings and funerals"

	label variable lsoff_valslaughter "How much did you receive in total for the cattle you slaughtered and sold?"
	note lsoff_valslaughter: "How much did you receive in total for the cattle you slaughtered and sold?"

	label variable lsoff_valslaughtunits "In total or average"
	note lsoff_valslaughtunits: "In total or average"
	label define lsoff_valslaughtunits 1 "In total" 2 "Per animal"
	label values lsoff_valslaughtunits lsoff_valslaughtunits

	label variable lsoff_salereasons "For what reasons have you sold cattle in the past 12 months? Check all that appl"
	note lsoff_salereasons: "For what reasons have you sold cattle in the past 12 months? Check all that apply"

	label variable lsoff_salereasons_other "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those "
	note lsoff_salereasons_other: "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those in the list"

	label variable lsoff_animalreasons "When you last decided to sell cattle, how did you decide which cattle to sell?"
	note lsoff_animalreasons: "When you last decided to sell cattle, how did you decide which cattle to sell?"

	label variable lsoff_animalreason_other "Other: Specify"
	note lsoff_animalreason_other: "Other: Specify"

	label variable lsoff_restructure "What kind of herd restructuring did you participate in?"
	note lsoff_restructure: "What kind of herd restructuring did you participate in?"

	label variable lsoff_restructure_other "Other: Specify"
	note lsoff_restructure_other: "Other: Specify"

	label variable comm_wat_yesno "Are you a part of group that makes decisions about how the group manages water? "
	note comm_wat_yesno: "Are you a part of group that makes decisions about how the group manages water? This can include a group of people that decides how to pay for repairs when a borehole/well breaks down"
	label define comm_wat_yesno 1 "Yes" 0 "No"
	label values comm_wat_yesno comm_wat_yesno

	label variable comm_wat_mtgno "In the past 12 months, how many meetings did you attend for this water group?"
	note comm_wat_mtgno: "In the past 12 months, how many meetings did you attend for this water group?"

	label variable comm_wat_mtgunit "Units"
	note comm_wat_mtgunit: "Units"
	label define comm_wat_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_wat_mtgunit comm_wat_mtgunit

	label variable comm_wat_finyn "In the past 12 months, have you contributed financially to this water group?"
	note comm_wat_finyn: "In the past 12 months, have you contributed financially to this water group?"
	label define comm_wat_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_wat_finyn comm_wat_finyn

	label variable comm_graze_yesno "Are you a part of group that makes decisions about how the group manages cattle "
	note comm_graze_yesno: "Are you a part of group that makes decisions about how the group manages cattle and grazing?"
	label define comm_graze_yesno 1 "Yes" 0 "No"
	label values comm_graze_yesno comm_graze_yesno

	label variable comm_graze_mtgno "In the past 12 months, how many grazing meetings did you attend?"
	note comm_graze_mtgno: "In the past 12 months, how many grazing meetings did you attend?"

	label variable comm_graze_mtgunit "Units"
	note comm_graze_mtgunit: "Units"
	label define comm_graze_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_graze_mtgunit comm_graze_mtgunit

	label variable comm_graze_finyn "In the past 12 months, have you contributed financially to a grazing area group?"
	note comm_graze_finyn: "In the past 12 months, have you contributed financially to a grazing area group?"
	label define comm_graze_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_graze_finyn comm_graze_finyn

	label variable comm_new_yesno "Are you a part of a group that makes a decision when someone new wants to enter "
	note comm_new_yesno: "Are you a part of a group that makes a decision when someone new wants to enter the community?"
	label define comm_new_yesno 1 "Yes" 0 "No"
	label values comm_new_yesno comm_new_yesno

	label variable comm_new_mtgno "In the past 12 months, how many of these meetings did you attend?"
	note comm_new_mtgno: "In the past 12 months, how many of these meetings did you attend?"

	label variable comm_new_mtgunit "Units"
	note comm_new_mtgunit: "Units"
	label define comm_new_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_new_mtgunit comm_new_mtgunit

	label variable comm_devt_yesno "Are you currently a part of a group that makes general development decisions in "
	note comm_devt_yesno: "Are you currently a part of a group that makes general development decisions in your community, for example about local projects?"
	label define comm_devt_yesno 1 "Yes" 0 "No"
	label values comm_devt_yesno comm_devt_yesno

	label variable comm_devt_desc "What is this organization?"
	note comm_devt_desc: "What is this organization?"

	label variable comm_devt_mtgno "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"
	note comm_devt_mtgno: "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"

	label variable comm_devt_mtgunit "Units"
	note comm_devt_mtgunit: "Units"
	label define comm_devt_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_devt_mtgunit comm_devt_mtgunit

	label variable comm_devt_finyn "In the past 12 months, have you contributed financially to a general development"
	note comm_devt_finyn: "In the past 12 months, have you contributed financially to a general development group?"
	label define comm_devt_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_devt_finyn comm_devt_finyn

	label variable socdyn_mobile "Do you have a mobile phone?"
	note socdyn_mobile: "Do you have a mobile phone?"
	label define socdyn_mobile 1 "Yes" 0 "No"
	label values socdyn_mobile socdyn_mobile

	label variable socdyn_radio "Do you have a radio?"
	note socdyn_radio: "Do you have a radio?"
	label define socdyn_radio 1 "Yes" 0 "No"
	label values socdyn_radio socdyn_radio

	label variable socdyn_watch "Do you have a watch?"
	note socdyn_watch: "Do you have a watch?"
	label define socdyn_watch 1 "Yes" 0 "No"
	label values socdyn_watch socdyn_watch

	label variable socdyn_mobneivill "'I would lend my cell phone to a person in a neighboring village and let them ou"
	note socdyn_mobneivill: "'I would lend my cell phone to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_mobneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobneivill socdyn_mobneivill

	label variable socdyn_mobfirstime "'I would lend my cell phone to a person I just met for the first time and let th"
	note socdyn_mobfirstime: "'I would lend my cell phone to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_mobfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobfirstime socdyn_mobfirstime

	label variable socdyn_radneivill "'I would lend my radio to a person in a neighboring village and let them out of "
	note socdyn_radneivill: "'I would lend my radio to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_radneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radneivill socdyn_radneivill

	label variable socdyn_radfirstime "'I would lend my radio to a person I just met for the first time and let them ou"
	note socdyn_radfirstime: "'I would lend my radio to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_radfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radfirstime socdyn_radfirstime

	label variable socdyn_watneivill "'I would lend my watch to a person in a neighboring village.'"
	note socdyn_watneivill: "'I would lend my watch to a person in a neighboring village.'"
	label define socdyn_watneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watneivill socdyn_watneivill

	label variable socdyn_watfirstime "'I would lend my watch to a person I just met for the first time'"
	note socdyn_watfirstime: "'I would lend my watch to a person I just met for the first time'"
	label define socdyn_watfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watfirstime socdyn_watfirstime

	label variable socdyn_trust "'In general, I believe people can be relied on.'"
	note socdyn_trust: "'In general, I believe people can be relied on.'"
	label define socdyn_trust 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_trust socdyn_trust

	label variable mgr_relation_ta "Is the manager related to the local TAs or headman?"
	note mgr_relation_ta: "Is the manager related to the local TAs or headman?"

	label variable owner_relation_ta "Are any of the owners related to the local TAs or headman?"
	note owner_relation_ta: "Are any of the owners related to the local TAs or headman?"

	label variable ta_freq "In the last three weeks, how many times have you spoken with someone on the TA?"
	note ta_freq: "In the last three weeks, how many times have you spoken with someone on the TA?"
	label define ta_freq 1 "Every day" 2 "Most days (more than once a week)" 3 "Once a week" 4 "Between once a week and once a month" 5 "Less than once a month"
	label values ta_freq ta_freq

	label variable socdyn_ta "'Even though the traditional authority is working hard, sometimes they do not ma"
	note socdyn_ta: "'Even though the traditional authority is working hard, sometimes they do not make the right decisions.'"
	label define socdyn_ta 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_ta socdyn_ta

	label variable socdyn_fence "'If I could build a fence around \${graze_location}, I would.'"
	note socdyn_fence: "'If I could build a fence around \${graze_location}, I would.'"
	label define socdyn_fence 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_fence socdyn_fence

	label variable socdyn_sharegrass "'If a farmer from the next village has no grass in his village, but there is gra"
	note socdyn_sharegrass: "'If a farmer from the next village has no grass in his village, but there is grass in \${graze_location}, I believe that farmer should be welcomed at \${graze_location}.'"
	label define socdyn_sharegrass 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_sharegrass socdyn_sharegrass

	label variable socdyn_toomanyothers "'The headman and other elders in \${graze_location} let too many outsiders bring"
	note socdyn_toomanyothers: "'The headman and other elders in \${graze_location} let too many outsiders bring their cattle to graze in \${graze_location}.'"
	label define socdyn_toomanyothers 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_toomanyothers socdyn_toomanyothers

	label variable socdyn_locusgen "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	note socdyn_locusgen: "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	label define socdyn_locusgen 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusgen socdyn_locusgen

	label variable socdyn_locuscattle "'I feel as though my actions personally affect the health and value of my cattle"
	note socdyn_locuscattle: "'I feel as though my actions personally affect the health and value of my cattle.'"
	label define socdyn_locuscattle 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locuscattle socdyn_locuscattle

	label variable socdyn_locusrange "'I can personally affect the quality of the rangeland and grass in my community'"
	note socdyn_locusrange: "'I can personally affect the quality of the rangeland and grass in my community'"
	label define socdyn_locusrange 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusrange socdyn_locusrange

	label variable socdyn_inctrust "In the last three years, has the number of people you trust increased, decreased"
	note socdyn_inctrust: "In the last three years, has the number of people you trust increased, decreased, or stayed the same?"
	label define socdyn_inctrust 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_inctrust socdyn_inctrust

	label variable socdyn_incconf "In the last three years, has the number of people you have conflict with increas"
	note socdyn_incconf: "In the last three years, has the number of people you have conflict with increased, decreased, or stayed the same?"
	label define socdyn_incconf 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_incconf socdyn_incconf

	label variable num_auctions "In the last three years, has the number of auctions near you increased, decrease"
	note num_auctions: "In the last three years, has the number of auctions near you increased, decreased, or stayed the same?"
	label define num_auctions 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values num_auctions num_auctions

	label variable gopa_knows "Have you heard of the GOPA project?"
	note gopa_knows: "Have you heard of the GOPA project?"
	label define gopa_knows 1 "Yes" 0 "No"
	label values gopa_knows gopa_knows

	label variable gopa_farmer "Were you a participant in the GOPA project?"
	note gopa_farmer: "Were you a participant in the GOPA project?"
	label define gopa_farmer 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_farmer gopa_farmer

	label variable gopa_offered "Were you offered the chance to participate in the GOPA project?"
	note gopa_offered: "Were you offered the chance to participate in the GOPA project?"
	label define gopa_offered 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_offered gopa_offered

	label variable comments "ENUMERATOR: Please offer any comments you have about the survey here (optional)"
	note comments: "ENUMERATOR: Please offer any comments you have about the survey here (optional)"

	label variable datetime_end "Enter date and time"
	note datetime_end: "Enter date and time"

	* append old, previously-imported data (if any) 1
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data 1
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 1
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
global v17_run 1

if "`c(username)'"=="pierre-yves" {
	gen rank_id = _n
	drop date_beginning datetime_end
	merge 1:1 key using `datetime'
	gen space = substr(date_beginning, 2, 1)==" "
	gen day = substr(date_beginning, 1,1) if space==1
	replace day=substr(date_beginning, 1, 2) if space==0
	gen month_str=substr(date_beginning, 4, 3) if space==0
	replace month_str=substr(date_beginning, 3, 3) if space==1
	gen month=.
	replace month=10 if month_str=="oct"
	replace month=11 if month_str=="nov"
	replace month=12 if month_str=="dec"
	gen time_beginning = substr(date_beginning, 13, 8) if space==0
	replace time_beginning = substr(date_beginning, 12, 8) if space==1
	gen space_end = substr(datetime_end, 2, 1)==" "
	gen time_end = substr(datetime_end, 13, 8) if space==0
	replace time_end = substr(datetime_end, 12, 8) if space==1
	gen double clock_begin = clock(time_beginning, "hms")
	gen double clock_end = clock(time_end, "hms")
	gen svy_length = (clock_end - clock_begin)/60000
	drop rank_id month_str
	destring day, replace
	rename month month_exp
}	

#delimit ; 

**  Generate a variable to indicate the version of the survey ;
gen v = 17 ;
save `v17', replace ;


********************************************************************************************************** ; 
**  STEP 2B: Imports and aggregates "FINAL BEHAVIORAL V1" (ID: FINAL_BEHAVIORAL_V1) data.				** ;
********************************************************************************************************** ;

#delimit cr 

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V1.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL BEHAVIORAL V1.dta"
local corrfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V1_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local note_fields1 "informed_consent enumwait waitformanager note_for_enum plannedgrazingintro combinedherdingintro introherding lstockmgmtintro commnote socdyn_intro followup_combine followup_watercommittee"
local note_fields2 "followup_grazingarea followup_generaldevt request_numbers"
local text_fields1 "deviceid subscriberid simid devicephonenum region enum_id ga_id mgr_firstname mgr_surname mgr_fullname audit farmer_id respondent_firstname respondent_surname language_other relation_manager_other"
local text_fields2 "location_manager graze_location educ_mgr_other educ_owner_other occup_owner occup_owner_other liveswhere relation_owner relation_owner_other grazeplandry_months grazeplandry_writtenshare_oth"
local text_fields3 "grazeplanrain_months grazeplanrain_writtenshare_oth grazeplan_otherlocfreq combherdrain_whynot combherdrain_whynot_other herd_managerherds herd_cashvalue_units_oth herd_inkindvalue_units_oth herd_gear"
local text_fields4 "herd_gear_other herd_paygroup herd_gear_self herd_gear_other_self whynoherd lsmgmt_othvac lsmgmt_othvac_other lsmgmt_whyvac lsmgmt_pay lsmgmt_supplement lsmgmt_supplement_other lsoff_buyers"
local text_fields5 "lsoff_buyers_other lsoff_salereasons lsoff_salereasons_other lsoff_animalreasons lsoff_animalreason_other lsoff_restructure lsoff_restructure_other comm_devt_desc mgr_relation_ta owner_relation_ta"
local text_fields6 "fup_combine_place fup_name_wpsec fup_name_grsec fup_name_othsec comments"
local date_fields1 ""
local datetime_fields1 "starttime endtime date_beginning datetime_end"

disp
disp "Starting import of: `csvfile'"
disp
 
* import data from primary .csv file
insheet using "`csvfile'", names clear
tempfile datetime all
save `all'
gen rank_id = _n
keep rank_id date_beginning datetime_end key
save `datetime'
use `all'

* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\FINAL BEHAVIORAL V1-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
	
	* drop note fields (since they don't contain any real data) 2
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 2
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				foreach stringvar of varlist `svarlist' {
					quietly: replace `ismissingvar'=.
					quietly: cap replace `ismissingvar'=1 if `stringvar'==.
					cap tostring `stringvar', format(%100.0g) replace
					cap replace `stringvar'="" if `ismissingvar'==1
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable date_beginning "Enter date and time"
	note date_beginning: "Enter date and time"

	label variable gpslatitude "ENUMERATOR: Enter your GPS Coordinates (latitude)"
	note gpslatitude: "ENUMERATOR: Enter your GPS Coordinates (latitude)"

	label variable gpslongitude "ENUMERATOR: Enter your GPS Coordinates (longitude)"
	note gpslongitude: "ENUMERATOR: Enter your GPS Coordinates (longitude)"

	label variable gpsaltitude "ENUMERATOR: Enter your GPS Coordinates (altitude)"
	note gpsaltitude: "ENUMERATOR: Enter your GPS Coordinates (altitude)"

	label variable gpsaccuracy "ENUMERATOR: Enter your GPS Coordinates (accuracy)"
	note gpsaccuracy: "ENUMERATOR: Enter your GPS Coordinates (accuracy)"

	label variable region "What regional team are you a part of?"
	note region: "What regional team are you a part of?"

	label variable enum_id "ENUMERATOR: What is your name?"
	note enum_id: "ENUMERATOR: What is your name?"

	label variable ga_id "ENUMERATOR: What is the name of the grazing area?"
	note ga_id: "ENUMERATOR: What is the name of the grazing area?"

	label variable farmer_number "ENUMERATOR: What number was this manager on your listing form?"
	note farmer_number: "ENUMERATOR: What number was this manager on your listing form?"

	label variable mgr_firstname "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"
	note mgr_firstname: "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"

	label variable mgr_surname "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"
	note mgr_surname: "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"

	label variable mgr_gender "ENUMERATOR: Is the manager male or female?"
	note mgr_gender: "ENUMERATOR: Is the manager male or female?"
	label define mgr_gender 1 "Male" 2 "Female"
	label values mgr_gender mgr_gender

	label variable resp_is_mgr "ENUMERATOR: Is the person you are speaking with the manager from the listing she"
	note resp_is_mgr: "ENUMERATOR: Is the person you are speaking with the manager from the listing sheet?"
	label define resp_is_mgr 1 "Yes" 0 "No"
	label values resp_is_mgr resp_is_mgr

	label variable consent "Do you agree to taking the survey?"
	note consent: "Do you agree to taking the survey?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable live_interview "ENUMERATOR: Is this a live interview, or are you entering an interview that was "
	note live_interview: "ENUMERATOR: Is this a live interview, or are you entering an interview that was conducted on paper?"
	label define live_interview 1 "This is a live interview" 2 "This is an interview that was originally conducted on paper"
	label values live_interview live_interview

	label variable respondent_firstname "What is your first name?"
	note respondent_firstname: "What is your first name?"

	label variable respondent_surname "What is your surname?"
	note respondent_surname: "What is your surname?"

	label variable language "What is the primary language spoken in your home?"
	note language: "What is the primary language spoken in your home?"
	label define language 1 "Herero" 2 "Kwanyama" 3 "Ndonga" 4 "Kwambi" 5 "Ngandjera" 6 "Mbalunhu" 7 "Kwaluudhi" 8 "Eunda" 9 "Nkolonkadhi" 10 "Zemba" 11 "Himba" 12 "Kwangali" 13 "Shambyu" 14 "Gciriku" 16 "Mbukushu" -77 "Other: specify"
	label values language language

	label variable language_other "Other: Specify"
	note language_other: "Other: Specify"

	label variable manages_owncattle "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make deci"
	note manages_owncattle: "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_owncattle 1 "Yes" 0 "No"
	label values manages_owncattle manages_owncattle

	label variable manages_othercattle "Do you manage a herd of 10 or more cattle, including cattle that belong to other"
	note manages_othercattle: "Do you manage a herd of 10 or more cattle, including cattle that belong to others? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_othercattle 1 "Yes" 0 "No"
	label values manages_othercattle manages_othercattle

	label variable right_respondent "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr"
	note right_respondent: "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr_fullname} in some way?"
	label define right_respondent 1 "Yes" 0 "No"
	label values right_respondent right_respondent

	label variable relation_manager "What is your relation to \${mgr_fullname}"
	note relation_manager: "What is your relation to \${mgr_fullname}"
	label define relation_manager 1 "The manager is my husband/wife" 2 "The manager is my mother/father" 3 "The manager is my brother/sister" 4 "The manager is my son/daughter" -77 "I am related to the manager in some other way" -78 "I am not related to the manager: specify"
	label values relation_manager relation_manager

	label variable relation_manager_other "Other: Specify"
	note relation_manager_other: "Other: Specify"

	label variable location_manager "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"
	note location_manager: "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"

	label variable return_manager "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	note return_manager: "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	label define return_manager 1 "In just a few minutes" 2 "Later today" 3 "Tomorrow" 4 "Later than tomorrow"
	label values return_manager return_manager

	label variable capable_responding "ENUMERATOR: Do you think this person is capable of answering questions about the"
	note capable_responding: "ENUMERATOR: Do you think this person is capable of answering questions about the cattle managed by What is your relation to \${mgr_fullname}?"
	label define capable_responding 1 "Yes" 0 "No"
	label values capable_responding capable_responding

	label variable graze_location "Where do you currently graze these cattle?"
	note graze_location: "Where do you currently graze these cattle?"

	label variable age_mgr "How old are you?"
	note age_mgr: "How old are you?"

	label variable educ_mgr "What is the highest level of education you have received?"
	note educ_mgr: "What is the highest level of education you have received?"
	label define educ_mgr 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_mgr educ_mgr

	label variable educ_mgr_other "Other: Specify"
	note educ_mgr_other: "Other: Specify"

	label variable years_managed "For how many years have you managed cattle in this kraal?"
	note years_managed: "For how many years have you managed cattle in this kraal?"

	label variable hhs_managed "For how many households do you manage cattle in this kraal?"
	note hhs_managed: "For how many households do you manage cattle in this kraal?"

	label variable age_owner "How old is the owner of the kraal?"
	note age_owner: "How old is the owner of the kraal?"

	label variable educ_owner "What is the highest level of education that the owner of the kraal has received?"
	note educ_owner: "What is the highest level of education that the owner of the kraal has received?"
	label define educ_owner 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_owner educ_owner

	label variable educ_owner_other "Other: Specify"
	note educ_owner_other: "Other: Specify"

	label variable occup_owner "What occupation does the owner of the kraal have?"
	note occup_owner: "What occupation does the owner of the kraal have?"

	label variable occup_owner_other "Other: Specify"
	note occup_owner_other: "Other: Specify"

	label variable livesin_ga "Do you live in \${graze_location}?"
	note livesin_ga: "Do you live in \${graze_location}?"
	label define livesin_ga 1 "Yes" 0 "No"
	label values livesin_ga livesin_ga

	label variable liveswhere "Where do you live?"
	note liveswhere: "Where do you live?"

	label variable relation_owner "How are you related to the owners of the cattle?"
	note relation_owner: "How are you related to the owners of the cattle?"

	label variable relation_owner_other "ENUMERATOR: if the person is related to the owners in any other way, please desc"
	note relation_owner_other: "ENUMERATOR: if the person is related to the owners in any other way, please describe it here"

	label variable cattle_managed "How many cattle in this kraal do you manage?"
	note cattle_managed: "How many cattle in this kraal do you manage?"

	label variable cows_managed "How many cows are in the kraal you manage?"
	note cows_managed: "How many cows are in the kraal you manage?"

	label variable bulls_managed "How many bulls are in the kraal you manage?"
	note bulls_managed: "How many bulls are in the kraal you manage?"

	label variable own_catinherd "Do you also own any cattle that are a part of this herd?"
	note own_catinherd: "Do you also own any cattle that are a part of this herd?"
	label define own_catinherd 1 "Yes" 0 "No"
	label values own_catinherd own_catinherd

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${graze_location} at a"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${graze_location} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${graze_location}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${graze_location}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_grazeplan comprehend_grazeplan

	label variable combherddry_combines "During this year's dry season, did your cattle usually combine with herds from o"
	note combherddry_combines: "During this year's dry season, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherddry_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_combines combherddry_combines

	label variable combherddry_specificherds "Were there particular herds that you intentionally combined with?"
	note combherddry_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherddry_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_specificherds combherddry_specificherds

	label variable combherddry_whynot "Why did you not engage in combined herding during this year's dry season?"
	note combherddry_whynot: "Why did you not engage in combined herding during this year's dry season?"
	label define combherddry_whynot 1 "Not enough grass on the land" 2 "Herders are unwilling" 3 "'Not something our people do'" 4 "I will not pay for herders" 5 "People will not let me in the combined herd" -77 "Other: specify"
	label values combherddry_whynot combherddry_whynot

	label variable combherddry_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during this "
	note combherddry_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during this dry season?"
	label define combherddry_discussmgr 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_discussmgr combherddry_discussmgr

	label variable combherddry_numkraals "How many kraals were usually in this combined herd during this dry season?"
	note combherddry_numkraals: "How many kraals were usually in this combined herd during this dry season?"

	label variable combherddry_numcat "How many total cattle were usually in this combined herd during this dry season?"
	note combherddry_numcat: "How many total cattle were usually in this combined herd during this dry season?"

	label variable combherddry_numbull "How many total bulls were usually in this combined herd during this dry season?"
	note combherddry_numbull: "How many total bulls were usually in this combined herd during this dry season?"

	label variable combherdrain_combines "During the rainy season at the beginning of this year, did your cattle usually c"
	note combherdrain_combines: "During the rainy season at the beginning of this year, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherdrain_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_combines combherdrain_combines

	label variable combherdrain_specificherds "Were there particular herds that you intentionally combined with?"
	note combherdrain_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherdrain_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_specificherds combherdrain_specificherds

	label variable combherdrain_whynot "Why did you not engage in combined herding during the last rainy season?"
	note combherdrain_whynot: "Why did you not engage in combined herding during the last rainy season?"

	label variable combherdrain_whynot_other "Other: Specify"
	note combherdrain_whynot_other: "Other: Specify"

	label variable combherdrain_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during the l"
	note combherdrain_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during the last rainy season?"
	label define combherdrain_discussmgr 1 "Yes" 0 "No"
	label values combherdrain_discussmgr combherdrain_discussmgr

	label variable combherdrain_numkraals "How many kraals were usually in this combined herd during the last rainy season?"
	note combherdrain_numkraals: "How many kraals were usually in this combined herd during the last rainy season?"

	label variable combherdrain_numcat "How many total cattle were usually in this combined herd during the last rainy s"
	note combherdrain_numcat: "How many total cattle were usually in this combined herd during the last rainy season?"

	label variable combherdrain_numbull "How many total bulls were usually in this combined herd during the last rainy se"
	note combherdrain_numbull: "How many total bulls were usually in this combined herd during the last rainy season?"

	label variable plan_combherd "Do you plan to combine your herd with others in this current rainy season?"
	note plan_combherd: "Do you plan to combine your herd with others in this current rainy season?"
	label define plan_combherd 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values plan_combherd plan_combherd

	label variable comprehend_combherd "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_combherd: "ENUMERATOR: How well do you think the respondent understood these questions about combined herding, and do you trust their responses?"
	label define comprehend_combherd 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_combherd comprehend_combherd

	label variable herd_managerherds "Do you herd these cattle, or does someone else?"
	note herd_managerherds: "Do you herd these cattle, or does someone else?"

	label variable herd_freq "How often do you visit this herd?"
	note herd_freq: "How often do you visit this herd?"
	label define herd_freq 1 "Daily or near daily" 2 "Weekly or near weekly" 3 "Monthly or near monthly" 4 "Less frequently than monthly" -88 "Refuses to say"
	label values herd_freq herd_freq

	label variable herd_drynumherders "In this year's dry season, how many herders were usually looking after the cattl"
	note herd_drynumherders: "In this year's dry season, how many herders were usually looking after the cattle?"

	label variable herd_rainnumherders "In the rainy season at the beginning of the year, how many herders were usually "
	note herd_rainnumherders: "In the rainy season at the beginning of the year, how many herders were usually looking after the cattle?"

	label variable comm_herders "How often do you communicate with your herders?"
	note comm_herders: "How often do you communicate with your herders?"
	label define comm_herders 1 "Daily" 2 "Most days (multiple times a week)" 3 "Approximately once a week" 4 "Less than once a week (but more than once a month)" 5 "Once a month or less often" -99 "Don’t know" -88 "Refuses to say"
	label values comm_herders comm_herders

	label variable herd_paycash "Do you pay your herders in cash?"
	note herd_paycash: "Do you pay your herders in cash?"
	label define herd_paycash 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_paycash herd_paycash

	label variable herd_cashvalue "How much do you pay your herders?"
	note herd_cashvalue: "How much do you pay your herders?"

	label variable herd_cashvalue_units "Units"
	note herd_cashvalue_units: "Units"
	label define herd_cashvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_cashvalue_units herd_cashvalue_units

	label variable herd_cashvalue_units_oth "Other: Specify"
	note herd_cashvalue_units_oth: "Other: Specify"

	label variable herd_payinkind "Do you pay your herders in any other form, including in food, calves, or another"
	note herd_payinkind: "Do you pay your herders in any other form, including in food, calves, or another form?"
	label define herd_payinkind 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_payinkind herd_payinkind

	label variable herd_inkindvalue "What is the total value of in-kind payments to herders?"
	note herd_inkindvalue: "What is the total value of in-kind payments to herders?"

	label variable herd_inkindvalue_units "Units"
	note herd_inkindvalue_units: "Units"
	label define herd_inkindvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_inkindvalue_units herd_inkindvalue_units

	label variable herd_inkindvalue_units_oth "Other: Specify"
	note herd_inkindvalue_units_oth: "Other: Specify"

	label variable herd_related "Are you related to your herders?"
	note herd_related: "Are you related to your herders?"
	label define herd_related 1 "Yes" 0 "No"
	label values herd_related herd_related

	label variable herd_gear "In the past 12 months, have you provided any of the following items for a herder"
	note herd_gear: "In the past 12 months, have you provided any of the following items for a herder?"

	label variable herd_gear_other "Other: Specify"
	note herd_gear_other: "Other: Specify"

	label variable herd_paygroup "Do you pay your herders individually, or do you pay your herders with managers f"
	note herd_paygroup: "Do you pay your herders individually, or do you pay your herders with managers from other kraals?"

	label variable herd_gear_self "In the past 12 months, have you acquired any of the following gear to use when y"
	note herd_gear_self: "In the past 12 months, have you acquired any of the following gear to use when you herd?"

	label variable herd_gear_other_self "Other: Specify"
	note herd_gear_other_self: "Other: Specify"

	label variable herd_intensitydry "During the dry season, after you herders take your cattle to water, do they typi"
	note herd_intensitydry: "During the dry season, after you herders take your cattle to water, do they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensitydry 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensitydry herd_intensitydry

	label variable herd_intensityrains "During the rainy season, after you herders take your cattle to water, do they ty"
	note herd_intensityrains: "During the rainy season, after you herders take your cattle to water, do they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensityrains 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensityrains herd_intensityrains

	label variable whynoherd "Why do you just push your animals, instead of remaining with them?"
	note whynoherd: "Why do you just push your animals, instead of remaining with them?"

	label variable herd_typewalk "Which picture best shows the way that your herd walks away from the water point "
	note herd_typewalk: "Which picture best shows the way that your herd walks away from the water point to pasture?"
	label define herd_typewalk 1 "Cattle in a tight bunch" 2 "Cattle in a line" 3 "Cattle scattered" -99 "Don't know"
	label values herd_typewalk herd_typewalk

	label variable herd_typegraze "Which picture best shows the way that your herd is managed when your cattle are "
	note herd_typegraze: "Which picture best shows the way that your herd is managed when your cattle are grazing?"
	label define herd_typegraze 1 "Cattle in a tight bunch" 2 "Cattle scattered" -99 "Don't know"
	label values herd_typegraze herd_typegraze

	label variable herd_animalsmissing "The last time you saw your herd, were any cattle missing?"
	note herd_animalsmissing: "The last time you saw your herd, were any cattle missing?"
	label define herd_animalsmissing 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_animalsmissing herd_animalsmissing

	label variable herd_numbermissing "How many were missing?"
	note herd_numbermissing: "How many were missing?"

	label variable herd_lastsawmissingqty "When was the last time you saw these missing cattle?"
	note herd_lastsawmissingqty: "When was the last time you saw these missing cattle?"

	label variable herd_lastsawmissingunit "Unit"
	note herd_lastsawmissingunit: "Unit"
	label define herd_lastsawmissingunit 1 "days" 2 "weeks" 3 "months"
	label values herd_lastsawmissingunit herd_lastsawmissingunit

	label variable herd_catlost "In the past 12 months, how many of the cattle you manage have been lost, stolen "
	note herd_catlost: "In the past 12 months, how many of the cattle you manage have been lost, stolen or killed by a predator?"

	label variable water_freq "On average, how many times per day do you take your cattle to water?"
	note water_freq: "On average, how many times per day do you take your cattle to water?"
	label define water_freq 1 "Less than once a day" 2 "Once a day" 3 "Sometimes once a day, sometimes twice a day" 4 "Twice a day" 5 "There is a water point at my kraal"
	label values water_freq water_freq

	label variable water_quant "In the last three years, has the quantity of water you have access to increased,"
	note water_quant: "In the last three years, has the quantity of water you have access to increased, decreased, or stayed the same?"
	label define water_quant 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_quant water_quant

	label variable water_qual "In the last three years, has the quality of water you have access to gotten bett"
	note water_qual: "In the last three years, has the quality of water you have access to gotten better, worse, or stayed the same?"
	label define water_qual 1 "Gotten better" 2 "Stayed the same" 3 "Gotten worse" -99 "Don't know"
	label values water_qual water_qual

	label variable water_dist "In the last three years, has the distance you normally travel to get water incre"
	note water_dist: "In the last three years, has the distance you normally travel to get water increased, decreased, or stayed the same?"
	label define water_dist 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_dist water_dist

	label variable water_animals "In the last three years, has the number of animals that use the water point you "
	note water_animals: "In the last three years, has the number of animals that use the water point you normally go to increased significantly, decreased significantly, or stayed about the same?"
	label define water_animals 1 "Increased significantly" 2 "Decreased significantly" 3 "Stayed about the same" -99 "Don't know"
	label values water_animals water_animals

	label variable water_barriers "Are there now barriers to your access to water that did not exist three years ag"
	note water_barriers: "Are there now barriers to your access to water that did not exist three years ago? For example, do you now have to pay for water use (apart from payrments for diesel), or have you lost access to a particular water point?"
	label define water_barriers 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values water_barriers water_barriers

	label variable lsmgmt_dvs "In the past 12 months, did the government vaccinate your cattle?"
	note lsmgmt_dvs: "In the past 12 months, did the government vaccinate your cattle?"
	label define lsmgmt_dvs 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_dvs lsmgmt_dvs

	label variable lsmgmt_othvacyn "Did you vaccinate your cattle for any diseases apart from the vaccinations provi"
	note lsmgmt_othvacyn: "Did you vaccinate your cattle for any diseases apart from the vaccinations provided by the government?"
	label define lsmgmt_othvacyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_othvacyn lsmgmt_othvacyn

	label variable lsmgmt_othvac "Against which diseases did you vaccinate them?"
	note lsmgmt_othvac: "Against which diseases did you vaccinate them?"

	label variable lsmgmt_othvac_other "ENUMERATOR: Record any other vaccines the enumerator mentions"
	note lsmgmt_othvac_other: "ENUMERATOR: Record any other vaccines the enumerator mentions"

	label variable lsmgmt_howmanyvac "Did you vaccinate all of your cattle, or just some of them?"
	note lsmgmt_howmanyvac: "Did you vaccinate all of your cattle, or just some of them?"
	label define lsmgmt_howmanyvac 1 "All of the animals" 2 "Only one, or some of them"
	label values lsmgmt_howmanyvac lsmgmt_howmanyvac

	label variable lsmgmt_whyvac "Why did you vaccinate this/these cattle?"
	note lsmgmt_whyvac: "Why did you vaccinate this/these cattle?"

	label variable lsmgmt_pay "Did the famers owning cattle in this kraal pay for vaccinations with farmers own"
	note lsmgmt_pay: "Did the famers owning cattle in this kraal pay for vaccinations with farmers owning cattle in other kraals?"

	label variable lsmgmt_deworm "In the past 12 months, have you dewormed your cattle?"
	note lsmgmt_deworm: "In the past 12 months, have you dewormed your cattle?"
	label define lsmgmt_deworm 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_deworm lsmgmt_deworm

	label variable lsmgmt_supplement "In the past 12 months, what supplements, if any, have you provided to your cattl"
	note lsmgmt_supplement: "In the past 12 months, what supplements, if any, have you provided to your cattle?"

	label variable lsmgmt_supplement_other "Other: Specify"
	note lsmgmt_supplement_other: "Other: Specify"

	label variable lsmgmt_ticfreq "How often are your cattle checked for ticks?"
	note lsmgmt_ticfreq: "How often are your cattle checked for ticks?"
	label define lsmgmt_ticfreq 1 "Once a week or more frequently" 2 "Every 8 days to every 30 days" 3 "Less than once every 30 days" 4 "Never" -99 "Don't know"
	label values lsmgmt_ticfreq lsmgmt_ticfreq

	label variable lsmgmt_locexpertsick "When you have questions about your cattle when they are sick, including diagnosi"
	note lsmgmt_locexpertsick: "When you have questions about your cattle when they are sick, including diagnosing illnesses or purchasing medicines is there someone in your community that you can ask?"
	label define lsmgmt_locexpertsick 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertsick lsmgmt_locexpertsick

	label variable lsmgmt_locexpertmgmt "When you have general questions about your cattle, including inseminating cows a"
	note lsmgmt_locexpertmgmt: "When you have general questions about your cattle, including inseminating cows and herding, is there someone in your community that you can ask?"
	label define lsmgmt_locexpertmgmt 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertmgmt lsmgmt_locexpertmgmt

	label variable lsmgmt_bullcow "What do you think is the ideal bull to cow ratio?"
	note lsmgmt_bullcow: "What do you think is the ideal bull to cow ratio?"

	label variable comprehend_lsmgmt "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_lsmgmt: "ENUMERATOR: How well do you think the respondent understood these questions about livestock management, and do you trust their responses?"
	label define comprehend_lsmgmt 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_lsmgmt comprehend_lsmgmt

	label variable lsoff_numsold "How many live cattle have you sold in the past 12 months?"
	note lsoff_numsold: "How many live cattle have you sold in the past 12 months?"

	label variable lsoff_valsold "How much money did you receive for these cattle?"
	note lsoff_valsold: "How much money did you receive for these cattle?"

	label variable lsoff_valsoldunits "In total or average"
	note lsoff_valsoldunits: "In total or average"
	label define lsoff_valsoldunits 1 "In total" 2 "Per animal"
	label values lsoff_valsoldunits lsoff_valsoldunits

	label variable lsoff_buyers "To whom have you sold cattle in the past 12 months?"
	note lsoff_buyers: "To whom have you sold cattle in the past 12 months?"

	label variable lsoff_buyers_other "Other: Specify"
	note lsoff_buyers_other: "Other: Specify"

	label variable lsoff_numslaughtfest "In the past 12 months, how many cattle have you slaughtered or gifted for weddin"
	note lsoff_numslaughtfest: "In the past 12 months, how many cattle have you slaughtered or gifted for weddings or funerals?"

	label variable lsoff_numgift "In the past 12 months, how many cattle have you lent or gifted to another househ"
	note lsoff_numgift: "In the past 12 months, how many cattle have you lent or gifted to another household for reasons apart from weddings and funerals?"

	label variable lsoff_numslaughtsale "In the past 12 months, how many cattle have you slaughtered and sold? Do not inc"
	note lsoff_numslaughtsale: "In the past 12 months, how many cattle have you slaughtered and sold? Do not include animals slaughtered and sold for weddings and funerals"

	label variable lsoff_valslaughter "How much did you receive for the cattle you slaughtered and sold?"
	note lsoff_valslaughter: "How much did you receive for the cattle you slaughtered and sold?"

	label variable lsoff_valslaughtunits "In total or average"
	note lsoff_valslaughtunits: "In total or average"
	label define lsoff_valslaughtunits 1 "In total" 2 "Per animal"
	label values lsoff_valslaughtunits lsoff_valslaughtunits

	label variable lsoff_salereasons "For what reasons have you sold cattle in the past 12 months? Check all that appl"
	note lsoff_salereasons: "For what reasons have you sold cattle in the past 12 months? Check all that apply"

	label variable lsoff_salereasons_other "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those "
	note lsoff_salereasons_other: "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those in the list"

	label variable lsoff_animalreasons "When you last decided to sell cattle, how did you decide which cattle to sell?"
	note lsoff_animalreasons: "When you last decided to sell cattle, how did you decide which cattle to sell?"

	label variable lsoff_animalreason_other "Other: Specify"
	note lsoff_animalreason_other: "Other: Specify"

	label variable lsoff_restructure "What kind of herd restructuring did you participate in?"
	note lsoff_restructure: "What kind of herd restructuring did you participate in?"

	label variable lsoff_restructure_other "Other: Specify"
	note lsoff_restructure_other: "Other: Specify"

	label variable comm_wat_yesno "Are you a part of group that makes decisions about how the group manages water? "
	note comm_wat_yesno: "Are you a part of group that makes decisions about how the group manages water? This can include a group of people that decides how to pay for repairs when a borehole/well breaks down"
	label define comm_wat_yesno 1 "Yes" 0 "No"
	label values comm_wat_yesno comm_wat_yesno

	label variable comm_wat_mtgno "In the past 12 months, how many meetings did you attend for this water group?"
	note comm_wat_mtgno: "In the past 12 months, how many meetings did you attend for this water group?"

	label variable comm_wat_mtgunit "Units"
	note comm_wat_mtgunit: "Units"
	label define comm_wat_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_wat_mtgunit comm_wat_mtgunit

	label variable comm_wat_finyn "In the past 12 months, have you contributed financially to this water group?"
	note comm_wat_finyn: "In the past 12 months, have you contributed financially to this water group?"
	label define comm_wat_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_wat_finyn comm_wat_finyn

	label variable comm_graze_yesno "Are you a part of group that makes decisions about how the group manages cattle "
	note comm_graze_yesno: "Are you a part of group that makes decisions about how the group manages cattle and grazing?"
	label define comm_graze_yesno 1 "Yes" 0 "No"
	label values comm_graze_yesno comm_graze_yesno

	label variable comm_graze_mtgno "In the past 12 months, how many grazing meetings did you attend?"
	note comm_graze_mtgno: "In the past 12 months, how many grazing meetings did you attend?"

	label variable comm_graze_mtgunit "Units"
	note comm_graze_mtgunit: "Units"
	label define comm_graze_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_graze_mtgunit comm_graze_mtgunit

	label variable comm_graze_finyn "In the past 12 months, have you contributed financially to a grazing group?"
	note comm_graze_finyn: "In the past 12 months, have you contributed financially to a grazing group?"
	label define comm_graze_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_graze_finyn comm_graze_finyn

	label variable comm_new_yesno "Are you a part of a group that makes a decision when someone new wants to enter "
	note comm_new_yesno: "Are you a part of a group that makes a decision when someone new wants to enter the community?"
	label define comm_new_yesno 1 "Yes" 0 "No"
	label values comm_new_yesno comm_new_yesno

	label variable comm_new_mtgno "In the past 12 months, how many of these meetings did you attend?"
	note comm_new_mtgno: "In the past 12 months, how many of these meetings did you attend?"

	label variable comm_new_mtgunit "Units"
	note comm_new_mtgunit: "Units"
	label define comm_new_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_new_mtgunit comm_new_mtgunit

	label variable comm_devt_yesno "Are you currently a part of a group that makes general development decisions in "
	note comm_devt_yesno: "Are you currently a part of a group that makes general development decisions in your community, for example about local projects?"
	label define comm_devt_yesno 1 "Yes" 0 "No"
	label values comm_devt_yesno comm_devt_yesno

	label variable comm_devt_desc "What is the name of this organization?"
	note comm_devt_desc: "What is the name of this organization?"

	label variable comm_devt_mtgno "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"
	note comm_devt_mtgno: "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"

	label variable comm_devt_mtgunit "Units"
	note comm_devt_mtgunit: "Units"
	label define comm_devt_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_devt_mtgunit comm_devt_mtgunit

	label variable comm_devt_finyn "In the past 12 months, have you contributed financially to a general development"
	note comm_devt_finyn: "In the past 12 months, have you contributed financially to a general development group?"
	label define comm_devt_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_devt_finyn comm_devt_finyn

	label variable socdyn_mobile "Do you have a mobile phone?"
	note socdyn_mobile: "Do you have a mobile phone?"
	label define socdyn_mobile 1 "Yes" 0 "No"
	label values socdyn_mobile socdyn_mobile

	label variable socdyn_radio "Do you have a radio?"
	note socdyn_radio: "Do you have a radio?"
	label define socdyn_radio 1 "Yes" 0 "No"
	label values socdyn_radio socdyn_radio

	label variable socdyn_watch "Do you have a watch?"
	note socdyn_watch: "Do you have a watch?"
	label define socdyn_watch 1 "Yes" 0 "No"
	label values socdyn_watch socdyn_watch

	label variable socdyn_mobneivill "'I would lend my cell phone to a person in a neighboring village and let them ou"
	note socdyn_mobneivill: "'I would lend my cell phone to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_mobneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobneivill socdyn_mobneivill

	label variable socdyn_mobfirstime "'I would lend my cell phone to a person I just met for the first time and let th"
	note socdyn_mobfirstime: "'I would lend my cell phone to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_mobfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobfirstime socdyn_mobfirstime

	label variable socdyn_radneivill "'I would lend my radio to a person in a neighboring village and let them out of "
	note socdyn_radneivill: "'I would lend my radio to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_radneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radneivill socdyn_radneivill

	label variable socdyn_radfirstime "'I would lend my radio to a person I just met for the first time and let them ou"
	note socdyn_radfirstime: "'I would lend my radio to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_radfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radfirstime socdyn_radfirstime

	label variable socdyn_watneivill "'I would lend my watch to a person in a neighboring village.'"
	note socdyn_watneivill: "'I would lend my watch to a person in a neighboring village.'"
	label define socdyn_watneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watneivill socdyn_watneivill

	label variable socdyn_watfirstime "'I would lend my watch to a person I just met for the first time'"
	note socdyn_watfirstime: "'I would lend my watch to a person I just met for the first time'"
	label define socdyn_watfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watfirstime socdyn_watfirstime

	label variable socdyn_trust "'In general, I believe people can be relied on.'"
	note socdyn_trust: "'In general, I believe people can be relied on.'"
	label define socdyn_trust 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_trust socdyn_trust

	label variable mgr_relation_ta "Are you related to the local TAs or headman?"
	note mgr_relation_ta: "Are you related to the local TAs or headman?"

	label variable owner_relation_ta "Are any of the owners related to the local TAs or headman?"
	note owner_relation_ta: "Are any of the owners related to the local TAs or headman?"

	label variable ta_freq "In the last three weeks, how many times have you spoken with someone on the TA?"
	note ta_freq: "In the last three weeks, how many times have you spoken with someone on the TA?"
	label define ta_freq 1 "Every day" 2 "Most days (more than once a week)" 3 "Once a week" 4 "Between once a week and once a month" 5 "Less than once a month"
	label values ta_freq ta_freq

	label variable socdyn_ta "'Even though the traditional authority is working hard, sometimes they do not ma"
	note socdyn_ta: "'Even though the traditional authority is working hard, sometimes they do not make the right decisions.'"
	label define socdyn_ta 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_ta socdyn_ta

	label variable socdyn_fence "'If I could build a fence around \${graze_location}, I would.'"
	note socdyn_fence: "'If I could build a fence around \${graze_location}, I would.'"
	label define socdyn_fence 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_fence socdyn_fence

	label variable socdyn_sharegrass "'If a farmer from the next village has no grass in his village, but there is gra"
	note socdyn_sharegrass: "'If a farmer from the next village has no grass in his village, but there is grass in \${graze_location}, I believe that farmer should be welcomed at \${graze_location}.'"
	label define socdyn_sharegrass 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_sharegrass socdyn_sharegrass

	label variable socdyn_toomanyothers "'The headman and other elders in \${graze_location} let too many outsiders bring"
	note socdyn_toomanyothers: "'The headman and other elders in \${graze_location} let too many outsiders bring their cattle to graze in \${graze_location}.'"
	label define socdyn_toomanyothers 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_toomanyothers socdyn_toomanyothers

	label variable socdyn_locusgen "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	note socdyn_locusgen: "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	label define socdyn_locusgen 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusgen socdyn_locusgen

	label variable socdyn_locuscattle "'I feel as though my actions personally affect the health and value of my cattle"
	note socdyn_locuscattle: "'I feel as though my actions personally affect the health and value of my cattle.'"
	label define socdyn_locuscattle 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locuscattle socdyn_locuscattle

	label variable socdyn_locusrange "'I can personally affect the quality of the rangeland and grass in my community'"
	note socdyn_locusrange: "'I can personally affect the quality of the rangeland and grass in my community'"
	label define socdyn_locusrange 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusrange socdyn_locusrange

	label variable socdyn_inctrust "In the last three years, has the number of people you trust increased, decreased"
	note socdyn_inctrust: "In the last three years, has the number of people you trust increased, decreased, or stayed the same?"
	label define socdyn_inctrust 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_inctrust socdyn_inctrust

	label variable socdyn_incconf "In the last three years, has the number of people you have conflict with increas"
	note socdyn_incconf: "In the last three years, has the number of people you have conflict with increased, decreased, or stayed the same?"
	label define socdyn_incconf 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_incconf socdyn_incconf

	label variable num_auctions "In the last three years, has the number of auctions near you increased, decrease"
	note num_auctions: "In the last three years, has the number of auctions near you increased, decreased, or stayed the same?"
	label define num_auctions 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values num_auctions num_auctions

	label variable gopa_knows "Have you heard of the GOPA project?"
	note gopa_knows: "Have you heard of the GOPA project?"
	label define gopa_knows 1 "Yes" 0 "No"
	label values gopa_knows gopa_knows

	label variable gopa_farmer "Were you a participant in the GOPA project?"
	note gopa_farmer: "Were you a participant in the GOPA project?"
	label define gopa_farmer 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_farmer gopa_farmer

	label variable gopa_offered "Were you offered the chance to participate in the GOPA project?"
	note gopa_offered: "Were you offered the chance to participate in the GOPA project?"
	label define gopa_offered 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_offered gopa_offered

	label variable fup_combine_place "At what water point do your cattle currently take water?"
	note fup_combine_place: "At what water point do your cattle currently take water?"

	label variable fup_combine_hrs "At what time do you take your cattle to water? HOURS"
	note fup_combine_hrs: "At what time do you take your cattle to water? HOURS"

	label variable fup_combine_mins "At what time do you take your cattle to water? MINS"
	note fup_combine_mins: "At what time do you take your cattle to water? MINS"

	label variable fup_name_wpsec "What is the name of the person who takes minutes for the water point committee, "
	note fup_name_wpsec: "What is the name of the person who takes minutes for the water point committee, if anyone does?"

	label variable fup_name_grsec "What is the name of the person who takes minutes for your grazing group, if anyo"
	note fup_name_grsec: "What is the name of the person who takes minutes for your grazing group, if anyone does?"

	label variable fup_name_othsec "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyo"
	note fup_name_othsec: "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyone does?"

	label variable comments "ENUMERATOR: Please offer any comments you have about the survey here (optional)"
	note comments: "ENUMERATOR: Please offer any comments you have about the survey here (optional)"

	label variable datetime_end "Enter date and time"
	note datetime_end: "Enter date and time"
	
	* append old, previously-imported data (if any) 2
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data 2
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	di "`dtafile'"
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 2
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
global v1_run 1

if "`c(username)'"=="pierre-yves" {
	gen rank_id = _n
	drop date_beginning datetime_end
	merge 1:1 key using `datetime'
	gen space = substr(date_beginning, 2, 1)==" "
	gen day = substr(date_beginning, 1,1) if space==1
	replace day=substr(date_beginning, 1, 2) if space==0
	gen month_str=substr(date_beginning, 4, 3) if space==0
	replace month_str=substr(date_beginning, 3, 3) if space==1
	gen month=.
	replace month=10 if month_str=="oct"
	replace month=11 if month_str=="nov"
	replace month=12 if month_str=="dec"
	gen time_beginning = substr(date_beginning, 13, 8) if space==0
	replace time_beginning = substr(date_beginning, 12, 8) if space==1
	gen space_end = substr(datetime_end, 2, 1)==" "
	gen time_end = substr(datetime_end, 13, 8) if space==0
	replace time_end = substr(datetime_end, 12, 8) if space==1
	gen double clock_begin = clock(time_beginning, "hms")
	gen double clock_end = clock(time_end, "hms")
	gen svy_length = (clock_end - clock_begin)/60000
	drop rank_id month_str
	destring day, replace
}	

#delimit ; 

**  Generate a variable to indicate the version of the survey ;
gen v = 1 ;
save `v1', replace ;


********************************************************************************************************** ; 
**  STEP 2C: Imports and aggregates "FINAL BEHAVIORAL V2" (ID: FINAL_BEHAVIORAL_V2) data				** ;
********************************************************************************************************** ;

#delimit cr 

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V2.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL BEHAVIORAL V2.dta"
local corrfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V2_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local note_fields1 "informed_consent enumwait waitformanager note_for_enum plannedgrazingintro combinedherdingintro introherding lstockmgmtintro commnote socdyn_intro followup_combine followup_watercommittee"
local note_fields2 "followup_grazingarea followup_generaldevt request_numbers"
local text_fields1 "deviceid subscriberid simid devicephonenum region enum_id ga_id mgr_firstname mgr_surname audit farmer_id respondent_firstname respondent_surname language_other relation_manager_other location_manager"
local text_fields2 "graze_location educ_mgr_other educ_owner_other occup_owner occup_owner_other liveswhere relation_owner relation_owner_other grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months"
local text_fields3 "grazeplanrain_writtenshare_oth grazeplan_otherlocfreq combherdrain_whynot combherdrain_whynot_other herd_managerherds herd_cashvalue_units_oth herd_inkindvalue_units_oth herd_gear herd_gear_other"
local text_fields4 "herd_paygroup herd_gear_self herd_gear_other_self whynoherd lsmgmt_othvac lsmgmt_othvac_other lsmgmt_whyvac lsmgmt_pay lsmgmt_supplement lsmgmt_supplement_other lsoff_buyers lsoff_buyers_other"
local text_fields5 "lsoff_salereasons lsoff_salereasons_other lsoff_animalreasons lsoff_animalreason_other lsoff_restructure lsoff_restructure_other comm_devt_desc mgr_relation_ta owner_relation_ta fup_combine_place"
local text_fields6 "fup_name_wpsec fup_name_grsec fup_name_othsec comments"
local date_fields1 ""
local datetime_fields1 "starttime endtime date_beginning datetime_end"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear
tempfile datetime all
save `all'
gen rank_id = _n
keep rank_id date_beginning datetime_end key
save `datetime'
use `all'

* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\FINAL BEHAVIORAL V2-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
	
	* drop note fields (since they don't contain any real data) 3
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 3
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				foreach stringvar of varlist `svarlist' {
					quietly: replace `ismissingvar'=.
					quietly: cap replace `ismissingvar'=1 if `stringvar'==.
					cap tostring `stringvar', format(%100.0g) replace
					cap replace `stringvar'="" if `ismissingvar'==1
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable date_beginning "Enter date and time"
	note date_beginning: "Enter date and time"

	label variable gpslatitude "ENUMERATOR: Enter your GPS Coordinates (latitude)"
	note gpslatitude: "ENUMERATOR: Enter your GPS Coordinates (latitude)"

	label variable gpslongitude "ENUMERATOR: Enter your GPS Coordinates (longitude)"
	note gpslongitude: "ENUMERATOR: Enter your GPS Coordinates (longitude)"

	label variable gpsaltitude "ENUMERATOR: Enter your GPS Coordinates (altitude)"
	note gpsaltitude: "ENUMERATOR: Enter your GPS Coordinates (altitude)"

	label variable gpsaccuracy "ENUMERATOR: Enter your GPS Coordinates (accuracy)"
	note gpsaccuracy: "ENUMERATOR: Enter your GPS Coordinates (accuracy)"

	label variable region "What regional team are you a part of?"
	note region: "What regional team are you a part of?"

	label variable enum_id "ENUMERATOR: What is your name?"
	note enum_id: "ENUMERATOR: What is your name?"

	label variable ga_id "ENUMERATOR: What is the name of the grazing area?"
	note ga_id: "ENUMERATOR: What is the name of the grazing area?"

	label variable farmer_number "ENUMERATOR: What number was this manager on your listing form?"
	note farmer_number: "ENUMERATOR: What number was this manager on your listing form?"

	label variable mgr_firstname "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"
	note mgr_firstname: "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"

	label variable mgr_surname "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"
	note mgr_surname: "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"

	label variable mgr_gender "ENUMERATOR: Is the manager male or female?"
	note mgr_gender: "ENUMERATOR: Is the manager male or female?"
	label define mgr_gender 1 "Male" 2 "Female"
	label values mgr_gender mgr_gender

	label variable resp_is_mgr "ENUMERATOR: Is the person you are speaking with the manager from the listing she"
	note resp_is_mgr: "ENUMERATOR: Is the person you are speaking with the manager from the listing sheet?"
	label define resp_is_mgr 1 "Yes" 0 "No"
	label values resp_is_mgr resp_is_mgr

	label variable consent "Do you agree to taking the survey?"
	note consent: "Do you agree to taking the survey?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable live_interview "ENUMERATOR: Is this a live interview, or are you entering an interview that was "
	note live_interview: "ENUMERATOR: Is this a live interview, or are you entering an interview that was conducted on paper?"
	label define live_interview 1 "This is a live interview" 2 "This is an interview that was originally conducted on paper"
	label values live_interview live_interview

	label variable respondent_firstname "What is your first name?"
	note respondent_firstname: "What is your first name?"

	label variable respondent_surname "What is your surname?"
	note respondent_surname: "What is your surname?"

	label variable language "What is the primary language spoken in your home?"
	note language: "What is the primary language spoken in your home?"
	label define language 1 "Herero" 2 "Kwanyama" 3 "Ndonga" 4 "Kwambi" 5 "Ngandjera" 6 "Mbalunhu" 7 "Kwaluudhi" 8 "Eunda" 9 "Nkolonkadhi" 10 "Zemba" 11 "Himba" 12 "Kwangali" 13 "Shambyu" 14 "Gciriku" 16 "Mbukushu" -77 "Other: specify"
	label values language language

	label variable language_other "Other: Specify"
	note language_other: "Other: Specify"

	label variable manages_owncattle "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make deci"
	note manages_owncattle: "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_owncattle 1 "Yes" 0 "No"
	label values manages_owncattle manages_owncattle

	label variable manages_othercattle "Do you manage a herd of 10 or more cattle, including cattle that belong to other"
	note manages_othercattle: "Do you manage a herd of 10 or more cattle, including cattle that belong to others? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_othercattle 1 "Yes" 0 "No"
	label values manages_othercattle manages_othercattle

	label variable right_respondent "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr"
	note right_respondent: "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr_firstname}\${mgr_surname} in some way?"
	label define right_respondent 1 "Yes" 0 "No"
	label values right_respondent right_respondent

	label variable relation_manager "What is your relation to \${mgr_firstname}\${mgr_surname}?"
	note relation_manager: "What is your relation to \${mgr_firstname}\${mgr_surname}?"
	label define relation_manager 1 "The manager is my husband/wife" 2 "The manager is my mother/father" 3 "The manager is my brother/sister" 4 "The manager is my son/daughter" -77 "I am related to the manager in some other way" -78 "I am not related to the manager: specify"
	label values relation_manager relation_manager

	label variable relation_manager_other "Other: Specify"
	note relation_manager_other: "Other: Specify"

	label variable location_manager "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"
	note location_manager: "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"

	label variable return_manager "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	note return_manager: "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	label define return_manager 1 "In just a few minutes" 2 "Later today" 3 "Tomorrow" 4 "Later than tomorrow"
	label values return_manager return_manager

	label variable capable_responding "ENUMERATOR: Do you think this person is capable of answering questions about the"
	note capable_responding: "ENUMERATOR: Do you think this person is capable of answering questions about the cattle managed by \${mgr_firstname}\${mgr_surname}?"
	label define capable_responding 1 "Yes" 0 "No"
	label values capable_responding capable_responding

	label variable graze_location "Where do you currently graze these cattle?"
	note graze_location: "Where do you currently graze these cattle?"

	label variable age_mgr "How old are you?"
	note age_mgr: "How old are you?"

	label variable educ_mgr "What is the highest level of education you have received?"
	note educ_mgr: "What is the highest level of education you have received?"
	label define educ_mgr 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_mgr educ_mgr

	label variable educ_mgr_other "Other: Specify"
	note educ_mgr_other: "Other: Specify"

	label variable years_managed "For how many years have you managed cattle in this kraal?"
	note years_managed: "For how many years have you managed cattle in this kraal?"

	label variable hhs_managed "For how many households do you manage cattle in this kraal?"
	note hhs_managed: "For how many households do you manage cattle in this kraal?"

	label variable age_owner "How old is the owner of the kraal?"
	note age_owner: "How old is the owner of the kraal?"

	label variable educ_owner "What is the highest level of education that the owner of the kraal has received?"
	note educ_owner: "What is the highest level of education that the owner of the kraal has received?"
	label define educ_owner 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_owner educ_owner

	label variable educ_owner_other "Other: Specify"
	note educ_owner_other: "Other: Specify"

	label variable occup_owner "What occupation does the owner of the kraal have?"
	note occup_owner: "What occupation does the owner of the kraal have?"

	label variable occup_owner_other "Other: Specify"
	note occup_owner_other: "Other: Specify"

	label variable livesin_ga "Do you live in \${graze_location}?"
	note livesin_ga: "Do you live in \${graze_location}?"
	label define livesin_ga 1 "Yes" 0 "No"
	label values livesin_ga livesin_ga

	label variable liveswhere "Where do you live?"
	note liveswhere: "Where do you live?"

	label variable relation_owner "How are you related to the owners of the cattle?"
	note relation_owner: "How are you related to the owners of the cattle?"

	label variable relation_owner_other "ENUMERATOR: if the person is related to the owners in any other way, please desc"
	note relation_owner_other: "ENUMERATOR: if the person is related to the owners in any other way, please describe it here"

	label variable cattle_managed "How many cattle in this kraal do you manage?"
	note cattle_managed: "How many cattle in this kraal do you manage?"

	label variable cows_managed "How many cows are in the kraal you manage?"
	note cows_managed: "How many cows are in the kraal you manage?"

	label variable bulls_managed "How many bulls are in the kraal you manage?"
	note bulls_managed: "How many bulls are in the kraal you manage?"

	label variable own_catinherd "Do you also own any cattle that are a part of this herd?"
	note own_catinherd: "Do you also own any cattle that are a part of this herd?"
	label define own_catinherd 1 "Yes" 0 "No"
	label values own_catinherd own_catinherd

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${graze_location} at a"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${graze_location} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${graze_location}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${graze_location}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_grazeplan comprehend_grazeplan

	label variable combherddry_combines "During this year's dry season, did your cattle usually combine with herds from o"
	note combherddry_combines: "During this year's dry season, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherddry_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_combines combherddry_combines

	label variable combherddry_specificherds "Were there particular herds that you intentionally combined with?"
	note combherddry_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherddry_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_specificherds combherddry_specificherds

	label variable combherddry_whynot "Why did you not engage in combined herding during this year's dry season?"
	note combherddry_whynot: "Why did you not engage in combined herding during this year's dry season?"
	label define combherddry_whynot 1 "Not enough grass on the land" 2 "Herders are unwilling" 3 "'Not something our people do'" 4 "I will not pay for herders" 5 "People will not let me in the combined herd" -77 "Other: specify"
	label values combherddry_whynot combherddry_whynot

	label variable combherddry_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during this "
	note combherddry_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during this dry season?"
	label define combherddry_discussmgr 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_discussmgr combherddry_discussmgr

	label variable combherddry_numkraals "How many kraals were usually in this combined herd during this dry season?"
	note combherddry_numkraals: "How many kraals were usually in this combined herd during this dry season?"

	label variable combherddry_numcat "How many total cattle were usually in this combined herd during this dry season?"
	note combherddry_numcat: "How many total cattle were usually in this combined herd during this dry season?"

	label variable combherddry_numbull "How many total bulls were usually in this combined herd during this dry season?"
	note combherddry_numbull: "How many total bulls were usually in this combined herd during this dry season?"

	label variable combherdrain_combines "During the rainy season at the beginning of this year, did your cattle usually c"
	note combherdrain_combines: "During the rainy season at the beginning of this year, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherdrain_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_combines combherdrain_combines

	label variable combherdrain_specificherds "Were there particular herds that you intentionally combined with?"
	note combherdrain_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherdrain_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_specificherds combherdrain_specificherds

	label variable combherdrain_whynot "Why did you not engage in combined herding during the last rainy season?"
	note combherdrain_whynot: "Why did you not engage in combined herding during the last rainy season?"

	label variable combherdrain_whynot_other "Other: Specify"
	note combherdrain_whynot_other: "Other: Specify"

	label variable combherdrain_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during the l"
	note combherdrain_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during the last rainy season?"
	label define combherdrain_discussmgr 1 "Yes" 0 "No"
	label values combherdrain_discussmgr combherdrain_discussmgr

	label variable combherdrain_numkraals "How many kraals were usually in this combined herd during the last rainy season?"
	note combherdrain_numkraals: "How many kraals were usually in this combined herd during the last rainy season?"

	label variable combherdrain_numcat "How many total cattle were usually in this combined herd during the last rainy s"
	note combherdrain_numcat: "How many total cattle were usually in this combined herd during the last rainy season?"

	label variable combherdrain_numbull "How many total bulls were usually in this combined herd during the last rainy se"
	note combherdrain_numbull: "How many total bulls were usually in this combined herd during the last rainy season?"

	label variable plan_combherd "Do you plan to combine your herd with others in this current rainy season?"
	note plan_combherd: "Do you plan to combine your herd with others in this current rainy season?"
	label define plan_combherd 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values plan_combherd plan_combherd

	label variable comprehend_combherd "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_combherd: "ENUMERATOR: How well do you think the respondent understood these questions about combined herding, and do you trust their responses?"
	label define comprehend_combherd 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_combherd comprehend_combherd

	label variable herd_managerherds "Do you herd these cattle, or does someone else?"
	note herd_managerherds: "Do you herd these cattle, or does someone else?"

	label variable herd_freq "How often do you visit this herd?"
	note herd_freq: "How often do you visit this herd?"
	label define herd_freq 1 "Daily or near daily" 2 "Weekly or near weekly" 3 "Monthly or near monthly" 4 "Less frequently than monthly" -88 "Refuses to say"
	label values herd_freq herd_freq

	label variable herd_drynumherders "In this year's dry season, how many herders were usually looking after the cattl"
	note herd_drynumherders: "In this year's dry season, how many herders were usually looking after the cattle?"

	label variable herd_rainnumherders "In the rainy season at the beginning of the year, how many herders were usually "
	note herd_rainnumherders: "In the rainy season at the beginning of the year, how many herders were usually looking after the cattle?"

	label variable comm_herders "How often do you communicate with your herders?"
	note comm_herders: "How often do you communicate with your herders?"
	label define comm_herders 1 "Daily" 2 "Most days (multiple times a week)" 3 "Approximately once a week" 4 "Less than once a week (but more than once a month)" 5 "Once a month or less often" -99 "Don’t know" -88 "Refuses to say"
	label values comm_herders comm_herders

	label variable herd_paycash "Do you pay your herders in cash?"
	note herd_paycash: "Do you pay your herders in cash?"
	label define herd_paycash 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_paycash herd_paycash

	label variable herd_cashvalue "How much do you pay your herders?"
	note herd_cashvalue: "How much do you pay your herders?"

	label variable herd_cashvalue_units "Units"
	note herd_cashvalue_units: "Units"
	label define herd_cashvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_cashvalue_units herd_cashvalue_units

	label variable herd_cashvalue_units_oth "Other: Specify"
	note herd_cashvalue_units_oth: "Other: Specify"

	label variable herd_payinkind "Do you pay your herders in any other form, including in food, calves, or another"
	note herd_payinkind: "Do you pay your herders in any other form, including in food, calves, or another form?"
	label define herd_payinkind 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_payinkind herd_payinkind

	label variable herd_inkindvalue "What is the total value of in-kind payments to herders?"
	note herd_inkindvalue: "What is the total value of in-kind payments to herders?"

	label variable herd_inkindvalue_units "Units"
	note herd_inkindvalue_units: "Units"
	label define herd_inkindvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_inkindvalue_units herd_inkindvalue_units

	label variable herd_inkindvalue_units_oth "Other: Specify"
	note herd_inkindvalue_units_oth: "Other: Specify"

	label variable herd_related "Are you related to your herders?"
	note herd_related: "Are you related to your herders?"
	label define herd_related 1 "Yes" 0 "No"
	label values herd_related herd_related

	label variable herd_gear "In the past 12 months, have you provided any of the following items for a herder"
	note herd_gear: "In the past 12 months, have you provided any of the following items for a herder?"

	label variable herd_gear_other "Other: Specify"
	note herd_gear_other: "Other: Specify"

	label variable herd_paygroup "Do you pay your herders individually, or do you pay your herders with managers f"
	note herd_paygroup: "Do you pay your herders individually, or do you pay your herders with managers from other kraals?"

	label variable herd_gear_self "In the past 12 months, have you acquired any of the following gear to use when y"
	note herd_gear_self: "In the past 12 months, have you acquired any of the following gear to use when you herd?"

	label variable herd_gear_other_self "Other: Specify"
	note herd_gear_other_self: "Other: Specify"

	label variable herd_intensitydry "During the dry season, after you herders take your cattle to water, do they typi"
	note herd_intensitydry: "During the dry season, after you herders take your cattle to water, do they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensitydry 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensitydry herd_intensitydry

	label variable herd_intensityrains "During the rainy season, after you herders take your cattle to water, do they ty"
	note herd_intensityrains: "During the rainy season, after you herders take your cattle to water, do they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensityrains 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensityrains herd_intensityrains

	label variable whynoherd "Why do you just push your animals, instead of remaining with them?"
	note whynoherd: "Why do you just push your animals, instead of remaining with them?"

	label variable herd_typewalk "Which picture best shows the way that your herd walks away from the water point "
	note herd_typewalk: "Which picture best shows the way that your herd walks away from the water point to pasture?"
	label define herd_typewalk 1 "Cattle in a tight bunch" 2 "Cattle in a line" 3 "Cattle scattered" -99 "Don't know"
	label values herd_typewalk herd_typewalk

	label variable herd_typegraze "Which picture best shows the way that your herd is managed when your cattle are "
	note herd_typegraze: "Which picture best shows the way that your herd is managed when your cattle are grazing?"
	label define herd_typegraze 1 "Cattle in a tight bunch" 2 "Cattle scattered" -99 "Don't know"
	label values herd_typegraze herd_typegraze

	label variable herd_animalsmissing "The last time you saw your herd, were any cattle missing?"
	note herd_animalsmissing: "The last time you saw your herd, were any cattle missing?"
	label define herd_animalsmissing 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_animalsmissing herd_animalsmissing

	label variable herd_numbermissing "How many were missing?"
	note herd_numbermissing: "How many were missing?"

	label variable herd_lastsawmissingqty "When was the last time you saw these missing cattle?"
	note herd_lastsawmissingqty: "When was the last time you saw these missing cattle?"

	label variable herd_lastsawmissingunit "Unit"
	note herd_lastsawmissingunit: "Unit"
	label define herd_lastsawmissingunit 1 "days" 2 "weeks" 3 "months"
	label values herd_lastsawmissingunit herd_lastsawmissingunit

	label variable herd_catlost "In the past 12 months, how many of the cattle you manage have been lost, stolen "
	note herd_catlost: "In the past 12 months, how many of the cattle you manage have been lost, stolen or killed by a predator?"

	label variable water_freq "On average, how many times per day do you take your cattle to water?"
	note water_freq: "On average, how many times per day do you take your cattle to water?"
	label define water_freq 1 "Less than once a day" 2 "Once a day" 3 "Sometimes once a day, sometimes twice a day" 4 "Twice a day" 5 "There is a water point at my kraal"
	label values water_freq water_freq

	label variable water_quant "In the last three years, has the quantity of water you have access to increased,"
	note water_quant: "In the last three years, has the quantity of water you have access to increased, decreased, or stayed the same?"
	label define water_quant 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_quant water_quant

	label variable water_qual "In the last three years, has the quality of water you have access to gotten bett"
	note water_qual: "In the last three years, has the quality of water you have access to gotten better, worse, or stayed the same?"
	label define water_qual 1 "Gotten better" 2 "Stayed the same" 3 "Gotten worse" -99 "Don't know"
	label values water_qual water_qual

	label variable water_dist "In the last three years, has the distance you normally travel to get water incre"
	note water_dist: "In the last three years, has the distance you normally travel to get water increased, decreased, or stayed the same?"
	label define water_dist 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_dist water_dist

	label variable water_animals "In the last three years, has the number of animals that use the water point you "
	note water_animals: "In the last three years, has the number of animals that use the water point you normally go to increased significantly, decreased significantly, or stayed about the same?"
	label define water_animals 1 "Increased significantly" 2 "Decreased significantly" 3 "Stayed about the same" -99 "Don't know"
	label values water_animals water_animals

	label variable water_barriers "Are there now barriers to your access to water that did not exist three years ag"
	note water_barriers: "Are there now barriers to your access to water that did not exist three years ago? For example, do you now have to pay for water use (apart from payrments for diesel), or have you lost access to a particular water point?"
	label define water_barriers 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values water_barriers water_barriers

	label variable lsmgmt_dvs "In the past 12 months, did the government vaccinate your cattle?"
	note lsmgmt_dvs: "In the past 12 months, did the government vaccinate your cattle?"
	label define lsmgmt_dvs 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_dvs lsmgmt_dvs

	label variable lsmgmt_othvacyn "Did you vaccinate your cattle for any diseases apart from the vaccinations provi"
	note lsmgmt_othvacyn: "Did you vaccinate your cattle for any diseases apart from the vaccinations provided by the government?"
	label define lsmgmt_othvacyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_othvacyn lsmgmt_othvacyn

	label variable lsmgmt_othvac "Against which diseases did you vaccinate them?"
	note lsmgmt_othvac: "Against which diseases did you vaccinate them?"

	label variable lsmgmt_othvac_other "ENUMERATOR: Record any other vaccines the enumerator mentions"
	note lsmgmt_othvac_other: "ENUMERATOR: Record any other vaccines the enumerator mentions"

	label variable lsmgmt_howmanyvac "Did you vaccinate all of your cattle, or just some of them?"
	note lsmgmt_howmanyvac: "Did you vaccinate all of your cattle, or just some of them?"
	label define lsmgmt_howmanyvac 1 "All of the animals" 2 "Only one, or some of them"
	label values lsmgmt_howmanyvac lsmgmt_howmanyvac

	label variable lsmgmt_whyvac "Why did you vaccinate this/these cattle?"
	note lsmgmt_whyvac: "Why did you vaccinate this/these cattle?"

	label variable lsmgmt_pay "Did the famers owning cattle in this kraal pay for vaccinations with farmers own"
	note lsmgmt_pay: "Did the famers owning cattle in this kraal pay for vaccinations with farmers owning cattle in other kraals?"

	label variable lsmgmt_deworm "In the past 12 months, have you dewormed your cattle?"
	note lsmgmt_deworm: "In the past 12 months, have you dewormed your cattle?"
	label define lsmgmt_deworm 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_deworm lsmgmt_deworm

	label variable lsmgmt_supplement "In the past 12 months, what supplements, if any, have you provided to your cattl"
	note lsmgmt_supplement: "In the past 12 months, what supplements, if any, have you provided to your cattle?"

	label variable lsmgmt_supplement_other "Other: Specify"
	note lsmgmt_supplement_other: "Other: Specify"

	label variable lsmgmt_ticfreq "How often are your cattle checked for ticks?"
	note lsmgmt_ticfreq: "How often are your cattle checked for ticks?"
	label define lsmgmt_ticfreq 1 "Once a week or more frequently" 2 "Every 8 days to every 30 days" 3 "Less than once every 30 days" 4 "Never" -99 "Don't know"
	label values lsmgmt_ticfreq lsmgmt_ticfreq

	label variable lsmgmt_locexpertsick "When you have questions about your cattle when they are sick, including diagnosi"
	note lsmgmt_locexpertsick: "When you have questions about your cattle when they are sick, including diagnosing illnesses or purchasing medicines is there someone in your community that you can ask?"
	label define lsmgmt_locexpertsick 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertsick lsmgmt_locexpertsick

	label variable lsmgmt_locexpertmgmt "When you have general questions about your cattle, including inseminating cows a"
	note lsmgmt_locexpertmgmt: "When you have general questions about your cattle, including inseminating cows and herding, is there someone in your community that you can ask?"
	label define lsmgmt_locexpertmgmt 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertmgmt lsmgmt_locexpertmgmt

	label variable lsmgmt_bullcow "What do you think is the ideal bull to cow ratio?"
	note lsmgmt_bullcow: "What do you think is the ideal bull to cow ratio?"

	label variable comprehend_lsmgmt "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_lsmgmt: "ENUMERATOR: How well do you think the respondent understood these questions about livestock management, and do you trust their responses?"
	label define comprehend_lsmgmt 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_lsmgmt comprehend_lsmgmt

	label variable lsoff_numsold "How many live cattle have you sold in the past 12 months?"
	note lsoff_numsold: "How many live cattle have you sold in the past 12 months?"

	label variable lsoff_valsold "How much money did you receive for these cattle?"
	note lsoff_valsold: "How much money did you receive for these cattle?"

	label variable lsoff_valsoldunits "In total or average"
	note lsoff_valsoldunits: "In total or average"
	label define lsoff_valsoldunits 1 "In total" 2 "Per animal"
	label values lsoff_valsoldunits lsoff_valsoldunits

	label variable lsoff_buyers "To whom have you sold cattle in the past 12 months?"
	note lsoff_buyers: "To whom have you sold cattle in the past 12 months?"

	label variable lsoff_buyers_other "Other: Specify"
	note lsoff_buyers_other: "Other: Specify"

	label variable lsoff_numslaughtfest "In the past 12 months, how many cattle have you slaughtered or gifted for weddin"
	note lsoff_numslaughtfest: "In the past 12 months, how many cattle have you slaughtered or gifted for weddings or funerals?"

	label variable lsoff_numgift "In the past 12 months, how many cattle have you lent or gifted to another househ"
	note lsoff_numgift: "In the past 12 months, how many cattle have you lent or gifted to another household for reasons apart from weddings and funerals?"

	label variable lsoff_numslaughtsale "In the past 12 months, how many cattle have you slaughtered and sold? Do not inc"
	note lsoff_numslaughtsale: "In the past 12 months, how many cattle have you slaughtered and sold? Do not include animals slaughtered and sold for weddings and funerals"

	label variable lsoff_valslaughter "How much did you receive for the cattle you slaughtered and sold?"
	note lsoff_valslaughter: "How much did you receive for the cattle you slaughtered and sold?"

	label variable lsoff_valslaughtunits "In total or average"
	note lsoff_valslaughtunits: "In total or average"
	label define lsoff_valslaughtunits 1 "In total" 2 "Per animal"
	label values lsoff_valslaughtunits lsoff_valslaughtunits

	label variable lsoff_salereasons "For what reasons have you sold cattle in the past 12 months? Check all that appl"
	note lsoff_salereasons: "For what reasons have you sold cattle in the past 12 months? Check all that apply"

	label variable lsoff_salereasons_other "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those "
	note lsoff_salereasons_other: "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those in the list"

	label variable lsoff_animalreasons "When you last decided to sell cattle, how did you decide which cattle to sell?"
	note lsoff_animalreasons: "When you last decided to sell cattle, how did you decide which cattle to sell?"

	label variable lsoff_animalreason_other "Other: Specify"
	note lsoff_animalreason_other: "Other: Specify"

	label variable lsoff_restructure "What kind of herd restructuring did you participate in?"
	note lsoff_restructure: "What kind of herd restructuring did you participate in?"

	label variable lsoff_restructure_other "Other: Specify"
	note lsoff_restructure_other: "Other: Specify"

	label variable comm_wat_yesno "Are you a part of group that makes decisions about how the group manages water? "
	note comm_wat_yesno: "Are you a part of group that makes decisions about how the group manages water? This can include a group of people that decides how to pay for repairs when a borehole/well breaks down"
	label define comm_wat_yesno 1 "Yes" 0 "No"
	label values comm_wat_yesno comm_wat_yesno

	label variable comm_wat_mtgno "In the past 12 months, how many meetings did you attend for this water group?"
	note comm_wat_mtgno: "In the past 12 months, how many meetings did you attend for this water group?"

	label variable comm_wat_mtgunit "Units"
	note comm_wat_mtgunit: "Units"
	label define comm_wat_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_wat_mtgunit comm_wat_mtgunit

	label variable comm_wat_finyn "In the past 12 months, have you contributed financially to this water group?"
	note comm_wat_finyn: "In the past 12 months, have you contributed financially to this water group?"
	label define comm_wat_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_wat_finyn comm_wat_finyn

	label variable comm_graze_yesno "Are you a part of group that makes decisions about how the group manages cattle "
	note comm_graze_yesno: "Are you a part of group that makes decisions about how the group manages cattle and grazing?"
	label define comm_graze_yesno 1 "Yes" 0 "No"
	label values comm_graze_yesno comm_graze_yesno

	label variable comm_graze_mtgno "In the past 12 months, how many grazing meetings did you attend?"
	note comm_graze_mtgno: "In the past 12 months, how many grazing meetings did you attend?"

	label variable comm_graze_mtgunit "Units"
	note comm_graze_mtgunit: "Units"
	label define comm_graze_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_graze_mtgunit comm_graze_mtgunit

	label variable comm_graze_finyn "In the past 12 months, have you contributed financially to a grazing group?"
	note comm_graze_finyn: "In the past 12 months, have you contributed financially to a grazing group?"
	label define comm_graze_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_graze_finyn comm_graze_finyn

	label variable comm_new_yesno "Are you a part of a group that makes a decision when someone new wants to enter "
	note comm_new_yesno: "Are you a part of a group that makes a decision when someone new wants to enter the community?"
	label define comm_new_yesno 1 "Yes" 0 "No"
	label values comm_new_yesno comm_new_yesno

	label variable comm_new_mtgno "In the past 12 months, how many of these meetings did you attend?"
	note comm_new_mtgno: "In the past 12 months, how many of these meetings did you attend?"

	label variable comm_new_mtgunit "Units"
	note comm_new_mtgunit: "Units"
	label define comm_new_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_new_mtgunit comm_new_mtgunit

	label variable comm_devt_yesno "Are you currently a part of a group that makes general development decisions in "
	note comm_devt_yesno: "Are you currently a part of a group that makes general development decisions in your community, for example about local projects?"
	label define comm_devt_yesno 1 "Yes" 0 "No"
	label values comm_devt_yesno comm_devt_yesno

	label variable comm_devt_desc "What is the name of this organization?"
	note comm_devt_desc: "What is the name of this organization?"

	label variable comm_devt_mtgno "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"
	note comm_devt_mtgno: "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"

	label variable comm_devt_mtgunit "Units"
	note comm_devt_mtgunit: "Units"
	label define comm_devt_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_devt_mtgunit comm_devt_mtgunit

	label variable comm_devt_finyn "In the past 12 months, have you contributed financially to a general development"
	note comm_devt_finyn: "In the past 12 months, have you contributed financially to a general development group?"
	label define comm_devt_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_devt_finyn comm_devt_finyn

	label variable socdyn_mobile "Do you have a mobile phone?"
	note socdyn_mobile: "Do you have a mobile phone?"
	label define socdyn_mobile 1 "Yes" 0 "No"
	label values socdyn_mobile socdyn_mobile

	label variable socdyn_radio "Do you have a radio?"
	note socdyn_radio: "Do you have a radio?"
	label define socdyn_radio 1 "Yes" 0 "No"
	label values socdyn_radio socdyn_radio

	label variable socdyn_watch "Do you have a watch?"
	note socdyn_watch: "Do you have a watch?"
	label define socdyn_watch 1 "Yes" 0 "No"
	label values socdyn_watch socdyn_watch

	label variable socdyn_mobneivill "'I would lend my cell phone to a person in a neighboring village and let them ou"
	note socdyn_mobneivill: "'I would lend my cell phone to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_mobneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobneivill socdyn_mobneivill

	label variable socdyn_mobfirstime "'I would lend my cell phone to a person I just met for the first time and let th"
	note socdyn_mobfirstime: "'I would lend my cell phone to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_mobfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobfirstime socdyn_mobfirstime

	label variable socdyn_radneivill "'I would lend my radio to a person in a neighboring village and let them out of "
	note socdyn_radneivill: "'I would lend my radio to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_radneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radneivill socdyn_radneivill

	label variable socdyn_radfirstime "'I would lend my radio to a person I just met for the first time and let them ou"
	note socdyn_radfirstime: "'I would lend my radio to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_radfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radfirstime socdyn_radfirstime

	label variable socdyn_watneivill "'I would lend my watch to a person in a neighboring village.'"
	note socdyn_watneivill: "'I would lend my watch to a person in a neighboring village.'"
	label define socdyn_watneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watneivill socdyn_watneivill

	label variable socdyn_watfirstime "'I would lend my watch to a person I just met for the first time'"
	note socdyn_watfirstime: "'I would lend my watch to a person I just met for the first time'"
	label define socdyn_watfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watfirstime socdyn_watfirstime

	label variable socdyn_trust "'In general, I believe people can be relied on.'"
	note socdyn_trust: "'In general, I believe people can be relied on.'"
	label define socdyn_trust 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_trust socdyn_trust

	label variable mgr_relation_ta "Are you related to the local TAs or headman?"
	note mgr_relation_ta: "Are you related to the local TAs or headman?"

	label variable owner_relation_ta "Are any of the owners related to the local TAs or headman?"
	note owner_relation_ta: "Are any of the owners related to the local TAs or headman?"

	label variable ta_freq "In the last three weeks, how many times have you spoken with someone on the TA?"
	note ta_freq: "In the last three weeks, how many times have you spoken with someone on the TA?"
	label define ta_freq 1 "Every day" 2 "Most days (more than once a week)" 3 "Once a week" 4 "Between once a week and once a month" 5 "Less than once a month" 0 "Never"
	label values ta_freq ta_freq

	label variable socdyn_ta "'Even though the traditional authority is working hard, sometimes they do not ma"
	note socdyn_ta: "'Even though the traditional authority is working hard, sometimes they do not make the right decisions.'"
	label define socdyn_ta 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_ta socdyn_ta

	label variable socdyn_fence "'If I could build a fence around \${graze_location}, I would.'"
	note socdyn_fence: "'If I could build a fence around \${graze_location}, I would.'"
	label define socdyn_fence 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_fence socdyn_fence

	label variable socdyn_sharegrass "'If a farmer from the next village has no grass in his village, but there is gra"
	note socdyn_sharegrass: "'If a farmer from the next village has no grass in his village, but there is grass in \${graze_location}, I believe that farmer should be welcomed at \${graze_location}.'"
	label define socdyn_sharegrass 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_sharegrass socdyn_sharegrass

	label variable socdyn_toomanyothers "'The headman and other elders in \${graze_location} let too many outsiders bring"
	note socdyn_toomanyothers: "'The headman and other elders in \${graze_location} let too many outsiders bring their cattle to graze in \${graze_location}.'"
	label define socdyn_toomanyothers 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_toomanyothers socdyn_toomanyothers

	label variable socdyn_locusgen "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	note socdyn_locusgen: "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	label define socdyn_locusgen 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusgen socdyn_locusgen

	label variable socdyn_locuscattle "'I feel as though my actions personally affect the health and value of my cattle"
	note socdyn_locuscattle: "'I feel as though my actions personally affect the health and value of my cattle.'"
	label define socdyn_locuscattle 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locuscattle socdyn_locuscattle

	label variable socdyn_locusrange "'I can personally affect the quality of the rangeland and grass in my community'"
	note socdyn_locusrange: "'I can personally affect the quality of the rangeland and grass in my community'"
	label define socdyn_locusrange 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusrange socdyn_locusrange

	label variable socdyn_inctrust "In the last three years, has the number of people you trust increased, decreased"
	note socdyn_inctrust: "In the last three years, has the number of people you trust increased, decreased, or stayed the same?"
	label define socdyn_inctrust 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_inctrust socdyn_inctrust

	label variable socdyn_incconf "In the last three years, has the number of people you have conflict with increas"
	note socdyn_incconf: "In the last three years, has the number of people you have conflict with increased, decreased, or stayed the same?"
	label define socdyn_incconf 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_incconf socdyn_incconf

	label variable num_auctions "In the last three years, has the number of auctions near you increased, decrease"
	note num_auctions: "In the last three years, has the number of auctions near you increased, decreased, or stayed the same?"
	label define num_auctions 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values num_auctions num_auctions

	label variable gopa_knows "Have you heard of the GOPA project?"
	note gopa_knows: "Have you heard of the GOPA project?"
	label define gopa_knows 1 "Yes" 0 "No"
	label values gopa_knows gopa_knows

	label variable gopa_farmer "Were you a participant in the GOPA project?"
	note gopa_farmer: "Were you a participant in the GOPA project?"
	label define gopa_farmer 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_farmer gopa_farmer

	label variable gopa_offered "Were you offered the chance to participate in the GOPA project?"
	note gopa_offered: "Were you offered the chance to participate in the GOPA project?"
	label define gopa_offered 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_offered gopa_offered

	label variable fup_combine_place "At what water point do your cattle currently take water?"
	note fup_combine_place: "At what water point do your cattle currently take water?"

	label variable fup_combine_hrs "At what time do you take your cattle to water? HOURS"
	note fup_combine_hrs: "At what time do you take your cattle to water? HOURS"

	label variable fup_combine_mins "At what time do you take your cattle to water? MINS"
	note fup_combine_mins: "At what time do you take your cattle to water? MINS"

	label variable fup_name_wpsec "What is the name of the person who takes minutes for the water point committee, "
	note fup_name_wpsec: "What is the name of the person who takes minutes for the water point committee, if anyone does?"

	label variable fup_name_grsec "What is the name of the person who takes minutes for your grazing group, if anyo"
	note fup_name_grsec: "What is the name of the person who takes minutes for your grazing group, if anyone does?"

	label variable fup_name_othsec "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyo"
	note fup_name_othsec: "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyone does?"

	label variable comments "ENUMERATOR: Please offer any comments you have about the survey here (optional)"
	note comments: "ENUMERATOR: Please offer any comments you have about the survey here (optional)"

	label variable datetime_end "Enter date and time"
	note datetime_end: "Enter date and time"

	* append old, previously-imported data (if any) 3
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data 3
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 3
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
global v2_run 1

if "`c(username)'"=="pierre-yves" {
	gen rank_id = _n
	drop date_beginning datetime_end
	merge 1:1 key using `datetime'
	gen space = substr(date_beginning, 2, 1)==" "
	gen day = substr(date_beginning, 1,1) if space==1
	replace day=substr(date_beginning, 1, 2) if space==0
	gen month_str=substr(date_beginning, 4, 3) if space==0
	replace month_str=substr(date_beginning, 3, 3) if space==1
	gen month=.
	replace month=10 if month_str=="oct"
	replace month=11 if month_str=="nov"
	replace month=12 if month_str=="dec"
	gen time_beginning = substr(date_beginning, 13, 8) if space==0
	replace time_beginning = substr(date_beginning, 12, 8) if space==1
	gen space_end = substr(datetime_end, 2, 1)==" "
	gen time_end = substr(datetime_end, 13, 8) if space==0
	replace time_end = substr(datetime_end, 12, 8) if space==1
	gen double clock_begin = clock(time_beginning, "hms")
	gen double clock_end = clock(time_end, "hms")
	gen svy_length = (clock_end - clock_begin)/60000
	drop rank_id month_str
	destring day, replace
}	

#delimit ; 

**  Generate a variable to indicate the version of the survey ;
gen v = 2 ;
save `v2', replace ;


********************************************************************************************************** ; 
**  STEP 2D: Imports and aggregates "FINAL BEHAVIORAL V3" (ID: FINAL_BEHAVIORAL_V3) data.				** ;
********************************************************************************************************** ;

#delimit cr 

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V3.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL BEHAVIORAL V3.dta"
local corrfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V3_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local note_fields1 "informed_consent enumwait waitformanager note_for_enum note_for_resp plannedgrazingintro combinedherdingintro introherding lstockmgmtintro commnote socdyn_intro followup_combine"
local note_fields2 "followup_watercommittee followup_grazingarea followup_generaldevt request_numbers"
local text_fields1 "deviceid subscriberid simid devicephonenum region enum_id ga_id mgr_firstname mgr_surname audit farmer_id respondent_firstname respondent_surname language_other relation_manager_other location_manager"
local text_fields2 "graze_location educ_mgr_other educ_owner_other occup_owner occup_owner_other liveswhere relation_owner relation_owner_other grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months"
local text_fields3 "grazeplanrain_writtenshare_oth grazeplan_otherlocfreq combherddry_whynot combherddry_whynot_oth combherdrain_whynot combherdrain_whynot_other herd_managerherds herd_cashvalue_units_oth"
local text_fields4 "herd_inkindvalue_units_oth herd_gear herd_gear_other herd_paygroup herd_gear_self herd_gear_other_self whynoherd lsmgmt_othvac lsmgmt_othvac_other lsmgmt_whyvac lsmgmt_pay lsmgmt_supplement"
local text_fields5 "lsmgmt_supplement_other lsoff_buyers lsoff_buyers_other lsoff_salereasons lsoff_salereasons_other lsoff_animalreasons lsoff_animalreason_other lsoff_restructure lsoff_restructure_other comm_devt_desc"
local text_fields6 "mgr_relation_ta owner_relation_ta fup_combine_place fup_name_wpsec fup_name_grsec fup_name_othsec comments"
local date_fields1 ""
local datetime_fields1 "starttime endtime date_beginning datetime_end"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear
tempfile datetime all
save `all'
keep key date_beginning datetime_end
save `datetime'
use `all'
* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\FINAL BEHAVIORAL V3-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
	
	* drop note fields (since they don't contain any real data) 4
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 4
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				foreach stringvar of varlist `svarlist' {
					quietly: replace `ismissingvar'=.
					quietly: cap replace `ismissingvar'=1 if `stringvar'==.
					cap tostring `stringvar', format(%100.0g) replace
					cap replace `stringvar'="" if `ismissingvar'==1
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable date_beginning "Enter date and time"
	note date_beginning: "Enter date and time"

	label variable gpslatitude "ENUMERATOR: Enter your GPS Coordinates (latitude)"
	note gpslatitude: "ENUMERATOR: Enter your GPS Coordinates (latitude)"

	label variable gpslongitude "ENUMERATOR: Enter your GPS Coordinates (longitude)"
	note gpslongitude: "ENUMERATOR: Enter your GPS Coordinates (longitude)"

	label variable gpsaltitude "ENUMERATOR: Enter your GPS Coordinates (altitude)"
	note gpsaltitude: "ENUMERATOR: Enter your GPS Coordinates (altitude)"

	label variable gpsaccuracy "ENUMERATOR: Enter your GPS Coordinates (accuracy)"
	note gpsaccuracy: "ENUMERATOR: Enter your GPS Coordinates (accuracy)"

	label variable region "What regional team are you a part of?"
	note region: "What regional team are you a part of?"

	label variable enum_id "ENUMERATOR: What is your name?"
	note enum_id: "ENUMERATOR: What is your name?"

	label variable ga_id "ENUMERATOR: What is the name of the grazing area?"
	note ga_id: "ENUMERATOR: What is the name of the grazing area?"

	label variable farmer_number "ENUMERATOR: What number was this manager on your listing form?"
	note farmer_number: "ENUMERATOR: What number was this manager on your listing form?"

	label variable mgr_firstname "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"
	note mgr_firstname: "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"

	label variable mgr_surname "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"
	note mgr_surname: "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"

	label variable mgr_gender "ENUMERATOR: Is the manager male or female?"
	note mgr_gender: "ENUMERATOR: Is the manager male or female?"
	label define mgr_gender 1 "Male" 2 "Female"
	label values mgr_gender mgr_gender

	label variable resp_is_mgr "ENUMERATOR: Is the person you are speaking with the manager from the listing she"
	note resp_is_mgr: "ENUMERATOR: Is the person you are speaking with the manager from the listing sheet?"
	label define resp_is_mgr 1 "Yes" 0 "No"
	label values resp_is_mgr resp_is_mgr

	label variable consent "Do you agree to taking the survey?"
	note consent: "Do you agree to taking the survey?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable live_interview "ENUMERATOR: Is this a live interview, or are you entering an interview that was "
	note live_interview: "ENUMERATOR: Is this a live interview, or are you entering an interview that was conducted on paper?"
	label define live_interview 1 "This is a live interview" 2 "This is an interview that was originally conducted on paper"
	label values live_interview live_interview

	label variable respondent_firstname "What is your first name?"
	note respondent_firstname: "What is your first name?"

	label variable respondent_surname "What is your surname?"
	note respondent_surname: "What is your surname?"

	label variable language "What is the primary language spoken in your home?"
	note language: "What is the primary language spoken in your home?"
	label define language 1 "Herero" 2 "Kwanyama" 3 "Ndonga" 4 "Kwambi" 5 "Ngandjera" 6 "Mbalunhu" 7 "Kwaluudhi" 8 "Eunda" 9 "Nkolonkadhi" 10 "Zemba" 11 "Himba" 12 "Kwangali" 13 "Shambyu" 14 "Gciriku" 16 "Mbukushu" -77 "Other: specify"
	label values language language

	label variable language_other "Other: Specify"
	note language_other: "Other: Specify"

	label variable manages_owncattle "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make deci"
	note manages_owncattle: "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_owncattle 1 "Yes" 0 "No"
	label values manages_owncattle manages_owncattle

	label variable manages_othercattle "Do you manage a herd of 10 or more cattle, including cattle that belong to other"
	note manages_othercattle: "Do you manage a herd of 10 or more cattle, including cattle that belong to others? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_othercattle 1 "Yes" 0 "No"
	label values manages_othercattle manages_othercattle

	label variable right_respondent "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr"
	note right_respondent: "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr_firstname}\${mgr_surname} in some way?"
	label define right_respondent 1 "Yes" 0 "No"
	label values right_respondent right_respondent

	label variable relation_manager "What is your relation to \${mgr_firstname}\${mgr_surname}?"
	note relation_manager: "What is your relation to \${mgr_firstname}\${mgr_surname}?"
	label define relation_manager 1 "The manager is my husband/wife" 2 "The manager is my mother/father" 3 "The manager is my brother/sister" 4 "The manager is my son/daughter" -77 "I am related to the manager in some other way" -78 "I am not related to the manager: specify"
	label values relation_manager relation_manager

	label variable relation_manager_other "Other: Specify"
	note relation_manager_other: "Other: Specify"

	label variable location_manager "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"
	note location_manager: "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"

	label variable return_manager "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	note return_manager: "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	label define return_manager 1 "In just a few minutes" 2 "Later today" 3 "Tomorrow" 4 "Later than tomorrow"
	label values return_manager return_manager

	label variable capable_responding "ENUMERATOR: Do you think this person is capable of answering questions about the"
	note capable_responding: "ENUMERATOR: Do you think this person is capable of answering questions about the cattle managed by \${mgr_firstname}\${mgr_surname}?"
	label define capable_responding 1 "Yes" 0 "No"
	label values capable_responding capable_responding

	label variable graze_location "Where do you currently graze these cattle?"
	note graze_location: "Where do you currently graze these cattle?"

	label variable age_mgr "How old are you?"
	note age_mgr: "How old are you?"

	label variable educ_mgr "What is the highest level of education you have received?"
	note educ_mgr: "What is the highest level of education you have received?"
	label define educ_mgr 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_mgr educ_mgr

	label variable educ_mgr_other "Other: Specify"
	note educ_mgr_other: "Other: Specify"

	label variable years_managed "For how many years have you managed cattle in this kraal?"
	note years_managed: "For how many years have you managed cattle in this kraal?"

	label variable hhs_managed "For how many households do you manage cattle in this kraal?"
	note hhs_managed: "For how many households do you manage cattle in this kraal?"

	label variable age_owner "How old is the owner of the kraal?"
	note age_owner: "How old is the owner of the kraal?"

	label variable educ_owner "What is the highest level of education that the owner of the kraal has received?"
	note educ_owner: "What is the highest level of education that the owner of the kraal has received?"
	label define educ_owner 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_owner educ_owner

	label variable educ_owner_other "Other: Specify"
	note educ_owner_other: "Other: Specify"

	label variable occup_owner "What occupation does the owner of the kraal have?"
	note occup_owner: "What occupation does the owner of the kraal have?"

	label variable occup_owner_other "Other: Specify"
	note occup_owner_other: "Other: Specify"

	label variable livesin_ga "Do you live in \${graze_location}?"
	note livesin_ga: "Do you live in \${graze_location}?"
	label define livesin_ga 1 "Yes" 0 "No"
	label values livesin_ga livesin_ga

	label variable liveswhere "Where do you live?"
	note liveswhere: "Where do you live?"

	label variable relation_owner "How are you related to the owners of the cattle?"
	note relation_owner: "How are you related to the owners of the cattle?"

	label variable relation_owner_other "ENUMERATOR: if the person is related to the owners in any other way, please desc"
	note relation_owner_other: "ENUMERATOR: if the person is related to the owners in any other way, please describe it here"

	label variable cattle_managed "How many cattle in this kraal do you manage?"
	note cattle_managed: "How many cattle in this kraal do you manage?"

	label variable cows_managed "How many cows are in the kraal you manage?"
	note cows_managed: "How many cows are in the kraal you manage?"

	label variable bulls_managed "How many bulls are in the kraal you manage?"
	note bulls_managed: "How many bulls are in the kraal you manage?"

	label variable own_catinherd "Do you also own any cattle that are a part of this herd?"
	note own_catinherd: "Do you also own any cattle that are a part of this herd?"
	label define own_catinherd 1 "Yes" 0 "No"
	label values own_catinherd own_catinherd

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${graze_location} at a"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${graze_location} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${graze_location}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${graze_location}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_grazeplan comprehend_grazeplan

	label variable combherddry_combines "During this year's dry season, did your cattle usually combine with herds from o"
	note combherddry_combines: "During this year's dry season, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherddry_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_combines combherddry_combines

	label variable combherddry_specificherds "Were there particular herds that you intentionally combined with?"
	note combherddry_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherddry_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_specificherds combherddry_specificherds

	label variable combherddry_whynot "Why did you not engage in combined herding during this year's dry season?"
	note combherddry_whynot: "Why did you not engage in combined herding during this year's dry season?"

	label variable combherddry_whynot_oth "Other: Specify"
	note combherddry_whynot_oth: "Other: Specify"

	label variable combherddry_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during this "
	note combherddry_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during this dry season?"
	label define combherddry_discussmgr 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_discussmgr combherddry_discussmgr

	label variable combherddry_numkraals "How many kraals were usually in this combined herd during this dry season?"
	note combherddry_numkraals: "How many kraals were usually in this combined herd during this dry season?"

	label variable combherddry_numcat "How many total cattle were usually in this combined herd during this dry season?"
	note combherddry_numcat: "How many total cattle were usually in this combined herd during this dry season?"

	label variable combherddry_numbull "How many total bulls were usually in this combined herd during this dry season?"
	note combherddry_numbull: "How many total bulls were usually in this combined herd during this dry season?"

	label variable combherdrain_combines "During the rainy season at the beginning of this year, did your cattle usually c"
	note combherdrain_combines: "During the rainy season at the beginning of this year, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherdrain_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_combines combherdrain_combines

	label variable combherdrain_specificherds "Were there particular herds that you intentionally combined with?"
	note combherdrain_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherdrain_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_specificherds combherdrain_specificherds

	label variable combherdrain_whynot "Why did you not engage in combined herding during the rainy season at the beginn"
	note combherdrain_whynot: "Why did you not engage in combined herding during the rainy season at the beginning of this year."

	label variable combherdrain_whynot_other "Other: Specify"
	note combherdrain_whynot_other: "Other: Specify"

	label variable combherdrain_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during the r"
	note combherdrain_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during the rainy season at the beginning of this year?"
	label define combherdrain_discussmgr 1 "Yes" 0 "No"
	label values combherdrain_discussmgr combherdrain_discussmgr

	label variable combherdrain_numkraals "How many kraals were usually in this combined herd during the rainy season at th"
	note combherdrain_numkraals: "How many kraals were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable combherdrain_numcat "How many total cattle were usually in this combined herd during the rainy season"
	note combherdrain_numcat: "How many total cattle were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable combherdrain_numbull "How many total bulls were usually in this combined herd during the rainy season "
	note combherdrain_numbull: "How many total bulls were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable plan_combherd "Do you plan to combine your herd with others by the end of this rainy season?"
	note plan_combherd: "Do you plan to combine your herd with others by the end of this rainy season?"
	label define plan_combherd 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values plan_combherd plan_combherd

	label variable comprehend_combherd "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_combherd: "ENUMERATOR: How well do you think the respondent understood these questions about combined herding, and do you trust their responses?"
	label define comprehend_combherd 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_combherd comprehend_combherd

	label variable herd_managerherds "Do you herd these cattle, or does someone else?"
	note herd_managerherds: "Do you herd these cattle, or does someone else?"

	label variable herd_freq "How often do you visit this herd?"
	note herd_freq: "How often do you visit this herd?"
	label define herd_freq 1 "Daily or near daily" 2 "Weekly or near weekly" 3 "Monthly or near monthly" 4 "Less frequently than monthly" -88 "Refuses to say"
	label values herd_freq herd_freq

	label variable herd_drynumherders "In this year's dry season, how many herders were usually looking after the cattl"
	note herd_drynumherders: "In this year's dry season, how many herders were usually looking after the cattle?"

	label variable herd_rainnumherders "In the rainy season at the beginning of the year, how many herders were usually "
	note herd_rainnumherders: "In the rainy season at the beginning of the year, how many herders were usually looking after the cattle?"

	label variable comm_herders "How often do you communicate with your herders?"
	note comm_herders: "How often do you communicate with your herders?"
	label define comm_herders 1 "Daily" 2 "Most days (multiple times a week)" 3 "Approximately once a week" 4 "Less than once a week (but more than once a month)" 5 "Once a month or less often" -99 "Don’t know" -88 "Refuses to say"
	label values comm_herders comm_herders

	label variable herd_paycash "Do you pay your herders in cash?"
	note herd_paycash: "Do you pay your herders in cash?"
	label define herd_paycash 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_paycash herd_paycash

	label variable herd_cashvalue "How much do you pay your herders?"
	note herd_cashvalue: "How much do you pay your herders?"

	label variable herd_cashvalue_units "Units"
	note herd_cashvalue_units: "Units"
	label define herd_cashvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_cashvalue_units herd_cashvalue_units

	label variable herd_cashvalue_units_oth "Other: Specify"
	note herd_cashvalue_units_oth: "Other: Specify"

	label variable herd_payinkind "Do you pay your herders in any other form, including in food, calves, or another"
	note herd_payinkind: "Do you pay your herders in any other form, including in food, calves, or another form?"
	label define herd_payinkind 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_payinkind herd_payinkind

	label variable herd_inkindvalue "What is the total value of in-kind payments to herders?"
	note herd_inkindvalue: "What is the total value of in-kind payments to herders?"

	label variable herd_inkindvalue_units "Units"
	note herd_inkindvalue_units: "Units"
	label define herd_inkindvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_inkindvalue_units herd_inkindvalue_units

	label variable herd_inkindvalue_units_oth "Other: Specify"
	note herd_inkindvalue_units_oth: "Other: Specify"

	label variable herd_related "Are you related to your herders?"
	note herd_related: "Are you related to your herders?"
	label define herd_related 1 "Yes" 0 "No"
	label values herd_related herd_related

	label variable herd_gear "In the past 12 months, have you provided any of the following items for a herder"
	note herd_gear: "In the past 12 months, have you provided any of the following items for a herder?"

	label variable herd_gear_other "Other: Specify"
	note herd_gear_other: "Other: Specify"

	label variable herd_paygroup "Do you pay your herders individually, or do you pay your herders with managers f"
	note herd_paygroup: "Do you pay your herders individually, or do you pay your herders with managers from other kraals?"

	label variable herd_gear_self "In the past 12 months, have you acquired any of the following gear to use when y"
	note herd_gear_self: "In the past 12 months, have you acquired any of the following gear to use when you herd?"

	label variable herd_gear_other_self "Other: Specify"
	note herd_gear_other_self: "Other: Specify"

	label variable herd_intensitydry "During this year’s dry season, after your herders took your cattle to water, did"
	note herd_intensitydry: "During this year’s dry season, after your herders took your cattle to water, did they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensitydry 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensitydry herd_intensitydry

	label variable herd_intensityrains "During the rainy season at the beginning of this year, after your herders took y"
	note herd_intensityrains: "During the rainy season at the beginning of this year, after your herders took your cattle to water, did they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensityrains 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensityrains herd_intensityrains

	label variable whynoherd "Why do you just push your animals, instead of remaining with them?"
	note whynoherd: "Why do you just push your animals, instead of remaining with them?"

	label variable herd_typewalk "Which picture best shows the way that your herd walks away from the water point "
	note herd_typewalk: "Which picture best shows the way that your herd walks away from the water point to pasture?"
	label define herd_typewalk 1 "Cattle in a tight bunch" 2 "Cattle in a line" 3 "Cattle scattered" -99 "Don't know"
	label values herd_typewalk herd_typewalk

	label variable herd_typegraze "Which picture best shows the way that your herd is managed when your cattle are "
	note herd_typegraze: "Which picture best shows the way that your herd is managed when your cattle are grazing?"
	label define herd_typegraze 1 "Cattle in a tight bunch" 2 "Cattle scattered" -99 "Don't know"
	label values herd_typegraze herd_typegraze

	label variable herd_animalsmissing "The last time you saw your herd, were any cattle missing?"
	note herd_animalsmissing: "The last time you saw your herd, were any cattle missing?"
	label define herd_animalsmissing 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_animalsmissing herd_animalsmissing

	label variable herd_numbermissing "How many were missing?"
	note herd_numbermissing: "How many were missing?"

	label variable herd_lastsawmissingqty "When was the last time you saw these missing cattle?"
	note herd_lastsawmissingqty: "When was the last time you saw these missing cattle?"

	label variable herd_lastsawmissingunit "Unit"
	note herd_lastsawmissingunit: "Unit"
	label define herd_lastsawmissingunit 1 "days" 2 "weeks" 3 "months"
	label values herd_lastsawmissingunit herd_lastsawmissingunit

	label variable herd_catlost "In the past 12 months, how many of the cattle you manage have been lost, stolen "
	note herd_catlost: "In the past 12 months, how many of the cattle you manage have been lost, stolen or killed by a predator?"

	label variable water_freq "On average, how many times per day do you take your cattle to water?"
	note water_freq: "On average, how many times per day do you take your cattle to water?"
	label define water_freq 1 "Less than once a day" 2 "Once a day" 3 "Sometimes once a day, sometimes twice a day" 4 "Twice a day" 5 "There is a water point at my kraal"
	label values water_freq water_freq

	label variable water_quant "In the last three years, has the quantity of water you have access to increased,"
	note water_quant: "In the last three years, has the quantity of water you have access to increased, decreased, or stayed the same?"
	label define water_quant 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_quant water_quant

	label variable water_qual "In the last three years, has the quality of water you have access to gotten bett"
	note water_qual: "In the last three years, has the quality of water you have access to gotten better, worse, or stayed the same?"
	label define water_qual 1 "Gotten better" 2 "Stayed the same" 3 "Gotten worse" -99 "Don't know"
	label values water_qual water_qual

	label variable water_dist "In the last three years, has the distance you normally travel to get water incre"
	note water_dist: "In the last three years, has the distance you normally travel to get water increased, decreased, or stayed the same?"
	label define water_dist 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_dist water_dist

	label variable water_animals "In the last three years, has the number of animals that use the water point you "
	note water_animals: "In the last three years, has the number of animals that use the water point you normally go to increased significantly, decreased significantly, or stayed about the same?"
	label define water_animals 1 "Increased significantly" 2 "Decreased significantly" 3 "Stayed about the same" -99 "Don't know"
	label values water_animals water_animals

	label variable water_barriers "Are there now barriers to your access to water that did not exist three years ag"
	note water_barriers: "Are there now barriers to your access to water that did not exist three years ago? For example, do you now have to pay for water use (apart from payments for diesel), or have you lost access to a particular water point?"
	label define water_barriers 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values water_barriers water_barriers

	label variable lsmgmt_dvs "In the past 12 months, did the government vaccinate your cattle?"
	note lsmgmt_dvs: "In the past 12 months, did the government vaccinate your cattle?"
	label define lsmgmt_dvs 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_dvs lsmgmt_dvs

	label variable lsmgmt_othvacyn "Did you vaccinate your cattle for any diseases apart from the vaccinations provi"
	note lsmgmt_othvacyn: "Did you vaccinate your cattle for any diseases apart from the vaccinations provided by the government?"
	label define lsmgmt_othvacyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_othvacyn lsmgmt_othvacyn

	label variable lsmgmt_othvac "Against which diseases did you vaccinate them?"
	note lsmgmt_othvac: "Against which diseases did you vaccinate them?"

	label variable lsmgmt_othvac_other "ENUMERATOR: Record any other vaccines the enumerator mentions"
	note lsmgmt_othvac_other: "ENUMERATOR: Record any other vaccines the enumerator mentions"

	label variable lsmgmt_howmanyvac "Did you vaccinate all of your cattle, or just some of them?"
	note lsmgmt_howmanyvac: "Did you vaccinate all of your cattle, or just some of them?"
	label define lsmgmt_howmanyvac 1 "All of the animals" 2 "Only one, or some of them"
	label values lsmgmt_howmanyvac lsmgmt_howmanyvac

	label variable lsmgmt_whyvac "Why did you vaccinate this/these cattle?"
	note lsmgmt_whyvac: "Why did you vaccinate this/these cattle?"

	label variable lsmgmt_pay "Did the famers owning cattle in this kraal pay for vaccinations with farmers own"
	note lsmgmt_pay: "Did the famers owning cattle in this kraal pay for vaccinations with farmers owning cattle in other kraals?"

	label variable lsmgmt_deworm "In the past 12 months, have you dewormed your cattle?"
	note lsmgmt_deworm: "In the past 12 months, have you dewormed your cattle?"
	label define lsmgmt_deworm 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_deworm lsmgmt_deworm

	label variable lsmgmt_supplement "In the past 12 months, what supplements, if any, have you provided to your cattl"
	note lsmgmt_supplement: "In the past 12 months, what supplements, if any, have you provided to your cattle?"

	label variable lsmgmt_supplement_other "Other: Specify"
	note lsmgmt_supplement_other: "Other: Specify"

	label variable lsmgmt_ticfreq "How often are your cattle checked for ticks?"
	note lsmgmt_ticfreq: "How often are your cattle checked for ticks?"
	label define lsmgmt_ticfreq 1 "Once a week or more frequently" 2 "Every 8 days to every 30 days" 3 "Less than once every 30 days" 4 "Never" -99 "Don't know"
	label values lsmgmt_ticfreq lsmgmt_ticfreq

	label variable lsmgmt_locexpertsick "When you have questions about your cattle when they are sick, including diagnosi"
	note lsmgmt_locexpertsick: "When you have questions about your cattle when they are sick, including diagnosing illnesses or purchasing medicines is there someone in your community that you can ask?"
	label define lsmgmt_locexpertsick 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertsick lsmgmt_locexpertsick

	label variable lsmgmt_locexpertmgmt "When you have general questions about your cattle, including inseminating cows a"
	note lsmgmt_locexpertmgmt: "When you have general questions about your cattle, including inseminating cows and herding, is there someone in your community that you can ask?"
	label define lsmgmt_locexpertmgmt 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertmgmt lsmgmt_locexpertmgmt

	label variable lsmgmt_bullcow "What do you think is the ideal bull to cow ratio?"
	note lsmgmt_bullcow: "What do you think is the ideal bull to cow ratio?"

	label variable comprehend_lsmgmt "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_lsmgmt: "ENUMERATOR: How well do you think the respondent understood these questions about livestock management, and do you trust their responses?"
	label define comprehend_lsmgmt 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all"
	label values comprehend_lsmgmt comprehend_lsmgmt

	label variable lsoff_numsold "How many live cattle have you sold in the past 12 months?"
	note lsoff_numsold: "How many live cattle have you sold in the past 12 months?"

	label variable lsoff_valsold "How much money did you receive for these cattle?"
	note lsoff_valsold: "How much money did you receive for these cattle?"

	label variable lsoff_valsoldunits "In total or average"
	note lsoff_valsoldunits: "In total or average"
	label define lsoff_valsoldunits 1 "In total" 2 "Per animal"
	label values lsoff_valsoldunits lsoff_valsoldunits

	label variable lsoff_buyers "To whom have you sold cattle in the past 12 months?"
	note lsoff_buyers: "To whom have you sold cattle in the past 12 months?"

	label variable lsoff_buyers_other "Other: Specify"
	note lsoff_buyers_other: "Other: Specify"

	label variable lsoff_numslaughtfest "In the past 12 months, how many cattle have you slaughtered or gifted for weddin"
	note lsoff_numslaughtfest: "In the past 12 months, how many cattle have you slaughtered or gifted for weddings or funerals?"

	label variable lsoff_numgift "In the past 12 months, how many cattle have you lent or gifted to another househ"
	note lsoff_numgift: "In the past 12 months, how many cattle have you lent or gifted to another household for reasons apart from weddings and funerals?"

	label variable lsoff_numslaughtsale "In the past 12 months, how many cattle have you slaughtered and sold? Do not inc"
	note lsoff_numslaughtsale: "In the past 12 months, how many cattle have you slaughtered and sold? Do not include animals slaughtered and sold for weddings and funerals"

	label variable lsoff_valslaughter "How much did you receive for the cattle you slaughtered and sold?"
	note lsoff_valslaughter: "How much did you receive for the cattle you slaughtered and sold?"

	label variable lsoff_valslaughtunits "In total or average"
	note lsoff_valslaughtunits: "In total or average"
	label define lsoff_valslaughtunits 1 "In total" 2 "Per animal"
	label values lsoff_valslaughtunits lsoff_valslaughtunits

	label variable lsoff_salereasons "For what reasons have you sold cattle in the past 12 months? Check all that appl"
	note lsoff_salereasons: "For what reasons have you sold cattle in the past 12 months? Check all that apply"

	label variable lsoff_salereasons_other "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those "
	note lsoff_salereasons_other: "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those in the list"

	label variable lsoff_animalreasons "When you last decided to sell cattle, how did you decide which cattle to sell?"
	note lsoff_animalreasons: "When you last decided to sell cattle, how did you decide which cattle to sell?"

	label variable lsoff_animalreason_other "Other: Specify"
	note lsoff_animalreason_other: "Other: Specify"

	label variable lsoff_restructure "What kind of herd restructuring did you participate in?"
	note lsoff_restructure: "What kind of herd restructuring did you participate in?"

	label variable lsoff_restructure_other "Other: Specify"
	note lsoff_restructure_other: "Other: Specify"

	label variable comm_wat_yesno "Are you a part of group that makes decisions about how the group manages water? "
	note comm_wat_yesno: "Are you a part of group that makes decisions about how the group manages water? This can include a group of people that decides how to pay for repairs when a borehole/well breaks down"
	label define comm_wat_yesno 1 "Yes" 0 "No"
	label values comm_wat_yesno comm_wat_yesno

	label variable comm_wat_mtgno "In the past 12 months, how many meetings did you attend for this water group?"
	note comm_wat_mtgno: "In the past 12 months, how many meetings did you attend for this water group?"

	label variable comm_wat_mtgunit "Units"
	note comm_wat_mtgunit: "Units"
	label define comm_wat_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_wat_mtgunit comm_wat_mtgunit

	label variable comm_wat_finyn "In the past 12 months, have you contributed financially to this water group?"
	note comm_wat_finyn: "In the past 12 months, have you contributed financially to this water group?"
	label define comm_wat_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_wat_finyn comm_wat_finyn

	label variable comm_graze_yesno "Are you a part of group that makes decisions about how the group manages cattle "
	note comm_graze_yesno: "Are you a part of group that makes decisions about how the group manages cattle and grazing?"
	label define comm_graze_yesno 1 "Yes" 0 "No"
	label values comm_graze_yesno comm_graze_yesno

	label variable comm_graze_mtgno "In the past 12 months, how many grazing meetings did you attend?"
	note comm_graze_mtgno: "In the past 12 months, how many grazing meetings did you attend?"

	label variable comm_graze_mtgunit "Units"
	note comm_graze_mtgunit: "Units"
	label define comm_graze_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_graze_mtgunit comm_graze_mtgunit

	label variable comm_graze_finyn "In the past 12 months, have you contributed financially to a grazing group?"
	note comm_graze_finyn: "In the past 12 months, have you contributed financially to a grazing group?"
	label define comm_graze_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_graze_finyn comm_graze_finyn

	label variable comm_new_yesno "Are you a part of a group that makes a decision when someone new wants to enter "
	note comm_new_yesno: "Are you a part of a group that makes a decision when someone new wants to enter the community?"
	label define comm_new_yesno 1 "Yes" 0 "No"
	label values comm_new_yesno comm_new_yesno

	label variable comm_new_mtgno "In the past 12 months, how many of these meetings did you attend?"
	note comm_new_mtgno: "In the past 12 months, how many of these meetings did you attend?"

	label variable comm_new_mtgunit "Units"
	note comm_new_mtgunit: "Units"
	label define comm_new_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_new_mtgunit comm_new_mtgunit

	label variable comm_devt_yesno "Are you currently a part of a group that makes general development decisions in "
	note comm_devt_yesno: "Are you currently a part of a group that makes general development decisions in your community, for example about local projects?"
	label define comm_devt_yesno 1 "Yes" 0 "No"
	label values comm_devt_yesno comm_devt_yesno

	label variable comm_devt_desc "What is the name of this organization?"
	note comm_devt_desc: "What is the name of this organization?"

	label variable comm_devt_mtgno "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"
	note comm_devt_mtgno: "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"

	label variable comm_devt_mtgunit "Units"
	note comm_devt_mtgunit: "Units"
	label define comm_devt_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_devt_mtgunit comm_devt_mtgunit

	label variable comm_devt_finyn "In the past 12 months, have you contributed financially to a general development"
	note comm_devt_finyn: "In the past 12 months, have you contributed financially to a general development group?"
	label define comm_devt_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_devt_finyn comm_devt_finyn

	label variable socdyn_mobile "Do you have a mobile phone?"
	note socdyn_mobile: "Do you have a mobile phone?"
	label define socdyn_mobile 1 "Yes" 0 "No"
	label values socdyn_mobile socdyn_mobile

	label variable socdyn_radio "Do you have a radio?"
	note socdyn_radio: "Do you have a radio?"
	label define socdyn_radio 1 "Yes" 0 "No"
	label values socdyn_radio socdyn_radio

	label variable socdyn_watch "Do you have a watch?"
	note socdyn_watch: "Do you have a watch?"
	label define socdyn_watch 1 "Yes" 0 "No"
	label values socdyn_watch socdyn_watch

	label variable socdyn_mobneivill "'I would lend my cell phone to a person in a neighboring village and let them ou"
	note socdyn_mobneivill: "'I would lend my cell phone to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_mobneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobneivill socdyn_mobneivill

	label variable socdyn_mobfirstime "'I would lend my cell phone to a person I just met for the first time and let th"
	note socdyn_mobfirstime: "'I would lend my cell phone to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_mobfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobfirstime socdyn_mobfirstime

	label variable socdyn_radneivill "'I would lend my radio to a person in a neighboring village and let them out of "
	note socdyn_radneivill: "'I would lend my radio to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_radneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radneivill socdyn_radneivill

	label variable socdyn_radfirstime "'I would lend my radio to a person I just met for the first time and let them ou"
	note socdyn_radfirstime: "'I would lend my radio to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_radfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radfirstime socdyn_radfirstime

	label variable socdyn_watneivill "'I would lend my watch to a person in a neighboring village.'"
	note socdyn_watneivill: "'I would lend my watch to a person in a neighboring village.'"
	label define socdyn_watneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watneivill socdyn_watneivill

	label variable socdyn_watfirstime "'I would lend my watch to a person I just met for the first time'"
	note socdyn_watfirstime: "'I would lend my watch to a person I just met for the first time'"
	label define socdyn_watfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watfirstime socdyn_watfirstime

	label variable socdyn_trust "'In general, I believe people can be relied on.'"
	note socdyn_trust: "'In general, I believe people can be relied on.'"
	label define socdyn_trust 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_trust socdyn_trust

	label variable mgr_relation_ta "Are you related to the local TAs or headman?"
	note mgr_relation_ta: "Are you related to the local TAs or headman?"

	label variable owner_relation_ta "Are any of the owners related to the local TAs or headman?"
	note owner_relation_ta: "Are any of the owners related to the local TAs or headman?"

	label variable ta_freq "In the last three weeks, how many times have you spoken with someone on the TA?"
	note ta_freq: "In the last three weeks, how many times have you spoken with someone on the TA?"
	label define ta_freq 1 "Every day" 2 "Most days (more than once a week)" 3 "Once a week" 4 "Between once a week and once a month" 5 "Less than once a month" 0 "Never"
	label values ta_freq ta_freq

	label variable socdyn_ta "'Even though the traditional authority is working hard, sometimes they do not ma"
	note socdyn_ta: "'Even though the traditional authority is working hard, sometimes they do not make the right decisions.'"
	label define socdyn_ta 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_ta socdyn_ta

	label variable socdyn_fence "'If I could build a fence around \${graze_location}, I would.'"
	note socdyn_fence: "'If I could build a fence around \${graze_location}, I would.'"
	label define socdyn_fence 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_fence socdyn_fence

	label variable socdyn_sharegrass "'If a farmer from the next village has no grass in his village, but there is gra"
	note socdyn_sharegrass: "'If a farmer from the next village has no grass in his village, but there is grass in \${graze_location}, I believe that farmer should be welcomed at \${graze_location}.'"
	label define socdyn_sharegrass 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_sharegrass socdyn_sharegrass

	label variable socdyn_toomanyothers "'The headman and other elders in \${graze_location} let too many outsiders bring"
	note socdyn_toomanyothers: "'The headman and other elders in \${graze_location} let too many outsiders bring their cattle to graze in \${graze_location}.'"
	label define socdyn_toomanyothers 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_toomanyothers socdyn_toomanyothers

	label variable socdyn_locusgen "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	note socdyn_locusgen: "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	label define socdyn_locusgen 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusgen socdyn_locusgen

	label variable socdyn_locuscattle "'I feel as though my actions personally affect the health and value of my cattle"
	note socdyn_locuscattle: "'I feel as though my actions personally affect the health and value of my cattle.'"
	label define socdyn_locuscattle 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locuscattle socdyn_locuscattle

	label variable socdyn_locusrange "'I can personally affect the quality of the rangeland and grass in my community'"
	note socdyn_locusrange: "'I can personally affect the quality of the rangeland and grass in my community'"
	label define socdyn_locusrange 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusrange socdyn_locusrange

	label variable socdyn_inctrust "In the last three years, has the number of people you trust increased, decreased"
	note socdyn_inctrust: "In the last three years, has the number of people you trust increased, decreased, or stayed the same?"
	label define socdyn_inctrust 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_inctrust socdyn_inctrust

	label variable socdyn_incconf "In the last three years, has the number of people you have conflict with increas"
	note socdyn_incconf: "In the last three years, has the number of people you have conflict with increased, decreased, or stayed the same?"
	label define socdyn_incconf 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_incconf socdyn_incconf

	label variable num_auctions "In the last three years, has the number of auctions near you increased, decrease"
	note num_auctions: "In the last three years, has the number of auctions near you increased, decreased, or stayed the same?"
	label define num_auctions 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values num_auctions num_auctions

	label variable gopa_knows "Have you heard of the GOPA project?"
	note gopa_knows: "Have you heard of the GOPA project?"
	label define gopa_knows 1 "Yes" 0 "No"
	label values gopa_knows gopa_knows

	label variable gopa_farmer "Were you a participant in the GOPA project?"
	note gopa_farmer: "Were you a participant in the GOPA project?"
	label define gopa_farmer 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_farmer gopa_farmer

	label variable gopa_offered "Were you offered the chance to participate in the GOPA project?"
	note gopa_offered: "Were you offered the chance to participate in the GOPA project?"
	label define gopa_offered 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_offered gopa_offered

	label variable fup_combine_place "At what water point do your cattle currently take water?"
	note fup_combine_place: "At what water point do your cattle currently take water?"

	label variable fup_combine_hrs "At what time do you take your cattle to water? HOURS"
	note fup_combine_hrs: "At what time do you take your cattle to water? HOURS"

	label variable fup_combine_mins "At what time do you take your cattle to water? MINS"
	note fup_combine_mins: "At what time do you take your cattle to water? MINS"

	label variable fup_name_wpsec "What is the name of the person who takes minutes for the water point committee, "
	note fup_name_wpsec: "What is the name of the person who takes minutes for the water point committee, if anyone does?"

	label variable fup_name_grsec "What is the name of the person who takes minutes for your grazing group, if anyo"
	note fup_name_grsec: "What is the name of the person who takes minutes for your grazing group, if anyone does?"

	label variable fup_name_othsec "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyo"
	note fup_name_othsec: "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyone does?"

	label variable comments "ENUMERATOR: Please offer any comments you have about the survey here (optional)"
	note comments: "ENUMERATOR: Please offer any comments you have about the survey here (optional)"

	label variable datetime_end "Enter date and time"
	note datetime_end: "Enter date and time"

	* append old, previously-imported data (if any) 4
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 4
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
global v3_run 1


if "`c(username)'"=="pierre-yves" {
	drop date_beginning datetime_end
	merge 1:1 key using `datetime'
	gen space = substr(date_beginning, 2, 1)==" "
	gen day = substr(date_beginning, 1,1) if space==1
	replace day=substr(date_beginning, 1, 2) if space==0
	gen month_str=substr(date_beginning, 4, 3) if space==0
	replace month_str=substr(date_beginning, 3, 3) if space==1
	gen month=.
	replace month=10 if month_str=="oct"
	replace month=11 if month_str=="nov"
	replace month=12 if month_str=="dec"
	gen time_beginning = substr(date_beginning, 13, 8) if space==0
	replace time_beginning = substr(date_beginning, 12, 8) if space==1
	gen space_end = substr(datetime_end, 2, 1)==" "
	gen time_end = substr(datetime_end, 13, 8) if space==0
	replace time_end = substr(datetime_end, 12, 8) if space==1
	gen double clock_begin = clock(time_beginning, "hms")
	gen double clock_end = clock(time_end, "hms")
	gen svy_length = (clock_end - clock_begin)/60000
	drop month_str
	destring day, replace
}	

#delimit ; 

**  Generate a variable to indicate the version of the survey ;
gen v = 3 ;
save `v3', replace ;


********************************************************************************************************** ; 
**  STEP 2E: Imports and aggregates "FINAL BEHAVIORAL V5" (ID: FINAL_BEHAVIORAL_V5) data.				** ;
********************************************************************************************************** ;

#delimit cr 

* initialize Stata
clear all
set more off
set mem 100m


* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V5.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL BEHAVIORAL V5.dta"
local corrfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V5_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local note_fields1 "informed_consent enumwait waitformanager note_for_enum note_for_resp plannedgrazingintro combinedherdingintro introherding lstockmgmtintro commnote socdyn_intro followup_combine"
local note_fields2 "followup_watercommittee followup_grazingarea followup_generaldevt request_numbers"
local text_fields1 "deviceid subscriberid simid devicephonenum region enum_id ga_id mgr_firstname mgr_surname audit farmer_id respondent_firstname respondent_surname language_other relation_manager_other location_manager"
local text_fields2 "graze_location educ_mgr_other educ_owner_other occup_owner occup_owner_other liveswhere relation_owner relation_owner_other grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months"
local text_fields3 "grazeplanrain_writtenshare_oth grazeplan_otherlocfreq combherddry_whynot combherddry_whynot_oth combherdrain_whynot combherdrain_whynot_other herd_managerherds herd_cashvalue_units_oth"
local text_fields4 "herd_inkindvalue_units_oth herd_gear herd_gear_other herd_paygroup herd_gear_self herd_gear_other_self whynoherd_dry whynoherd_rains lsmgmt_othvac lsmgmt_othvac_other lsmgmt_whyvac lsmgmt_pay"
local text_fields5 "lsmgmt_supplement lsmgmt_supplement_other lsoff_buyers lsoff_buyers_other lsoff_salereasons lsoff_salereasons_other lsoff_animalreasons lsoff_animalreason_other lsoff_restructure"
local text_fields6 "lsoff_restructure_other comm_devt_desc mgr_relation_ta owner_relation_ta fup_combine_place fup_name_wpsec fup_name_grsec fup_name_othsec comments"
local date_fields1 ""
local datetime_fields1 "starttime endtime date_beginning datetime_end"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear
tempfile datetime all
save `all'
keep date_beginning datetime_end key
save `datetime'
use `all'
* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\FINAL BEHAVIORAL V5-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
	
	* drop note fields (since they don't contain any real data) 5
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 5
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				foreach stringvar of varlist `svarlist' {
					quietly: replace `ismissingvar'=.
					quietly: cap replace `ismissingvar'=1 if `stringvar'==.
					cap tostring `stringvar', format(%100.0g) replace
					cap replace `stringvar'="" if `ismissingvar'==1
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable date_beginning "Enter date and time"
	note date_beginning: "Enter date and time"

	label variable gpslatitude "ENUMERATOR: Enter your GPS Coordinates (latitude)"
	note gpslatitude: "ENUMERATOR: Enter your GPS Coordinates (latitude)"

	label variable gpslongitude "ENUMERATOR: Enter your GPS Coordinates (longitude)"
	note gpslongitude: "ENUMERATOR: Enter your GPS Coordinates (longitude)"

	label variable gpsaltitude "ENUMERATOR: Enter your GPS Coordinates (altitude)"
	note gpsaltitude: "ENUMERATOR: Enter your GPS Coordinates (altitude)"

	label variable gpsaccuracy "ENUMERATOR: Enter your GPS Coordinates (accuracy)"
	note gpsaccuracy: "ENUMERATOR: Enter your GPS Coordinates (accuracy)"

	label variable region "What regional team are you a part of?"
	note region: "What regional team are you a part of?"

	label variable enum_id "ENUMERATOR: What is your name?"
	note enum_id: "ENUMERATOR: What is your name?"

	label variable ga_id "ENUMERATOR: What is the name of the grazing area?"
	note ga_id: "ENUMERATOR: What is the name of the grazing area?"

	label variable farmer_number "ENUMERATOR: What number was this manager on your listing form?"
	note farmer_number: "ENUMERATOR: What number was this manager on your listing form?"

	label variable consent "Do you agree to taking the survey?"
	note consent: "Do you agree to taking the survey?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable mgr_firstname "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"
	note mgr_firstname: "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"

	label variable mgr_surname "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"
	note mgr_surname: "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"

	label variable mgr_gender "ENUMERATOR: Is the manager male or female?"
	note mgr_gender: "ENUMERATOR: Is the manager male or female?"
	label define mgr_gender 1 "Male" 2 "Female"
	label values mgr_gender mgr_gender

	label variable resp_is_mgr "ENUMERATOR: Is the person you are speaking with the manager from the listing she"
	note resp_is_mgr: "ENUMERATOR: Is the person you are speaking with the manager from the listing sheet?"
	label define resp_is_mgr 1 "Yes" 0 "No"
	label values resp_is_mgr resp_is_mgr

	label variable live_interview "ENUMERATOR: Is this a live interview, or are you entering an interview that was "
	note live_interview: "ENUMERATOR: Is this a live interview, or are you entering an interview that was conducted on paper?"
	label define live_interview 1 "This is a live interview" 2 "This is an interview that was originally conducted on paper"
	label values live_interview live_interview

	label variable respondent_firstname "What is your first name?"
	note respondent_firstname: "What is your first name?"

	label variable respondent_surname "What is your surname?"
	note respondent_surname: "What is your surname?"

	label variable language "What is the primary language spoken in your home?"
	note language: "What is the primary language spoken in your home?"
	label define language 1 "Herero" 2 "Kwanyama" 3 "Ndonga" 4 "Kwambi" 5 "Ngandjera" 6 "Mbalunhu" 7 "Kwaluudhi" 8 "Eunda" 9 "Nkolonkadhi" 10 "Zemba" 11 "Himba" 12 "Kwangali" 13 "Shambyu" 14 "Gciriku" 16 "Mbukushu" -77 "Other: specify"
	label values language language

	label variable language_other "Other: Specify"
	note language_other: "Other: Specify"

	label variable manages_owncattle "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make deci"
	note manages_owncattle: "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_owncattle 1 "Yes" 0 "No"
	label values manages_owncattle manages_owncattle

	label variable manages_othercattle "Do you manage a herd of 10 or more cattle, including cattle that belong to other"
	note manages_othercattle: "Do you manage a herd of 10 or more cattle, including cattle that belong to others? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_othercattle 1 "Yes" 0 "No"
	label values manages_othercattle manages_othercattle

	label variable right_respondent "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr"
	note right_respondent: "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr_firstname}\${mgr_surname} in some way?"
	label define right_respondent 1 "Yes" 0 "No"
	label values right_respondent right_respondent

	label variable relation_manager "What is your relation to \${mgr_firstname}\${mgr_surname}?"
	note relation_manager: "What is your relation to \${mgr_firstname}\${mgr_surname}?"
	label define relation_manager 1 "The manager is my husband/wife" 2 "The manager is my mother/father" 3 "The manager is my brother/sister" 4 "The manager is my son/daughter" -77 "I am related to the manager in some other way" -78 "I am not related to the manager: specify"
	label values relation_manager relation_manager

	label variable relation_manager_other "Other: Specify"
	note relation_manager_other: "Other: Specify"

	label variable location_manager "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"
	note location_manager: "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"

	label variable return_manager "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	note return_manager: "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	label define return_manager 1 "In just a few minutes" 2 "Later today" 3 "Tomorrow" 4 "Later than tomorrow"
	label values return_manager return_manager

	label variable capable_responding "ENUMERATOR: Do you think this person is capable of answering questions about the"
	note capable_responding: "ENUMERATOR: Do you think this person is capable of answering questions about the cattle managed by \${mgr_firstname}\${mgr_surname}?"
	label define capable_responding 1 "Yes" 0 "No"
	label values capable_responding capable_responding

	label variable graze_location "Where do you currently graze these cattle?"
	note graze_location: "Where do you currently graze these cattle?"

	label variable age_mgr "How old are you?"
	note age_mgr: "How old are you?"

	label variable educ_mgr "What is the highest level of education you have received?"
	note educ_mgr: "What is the highest level of education you have received?"
	label define educ_mgr 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_mgr educ_mgr

	label variable educ_mgr_other "Other: Specify"
	note educ_mgr_other: "Other: Specify"

	label variable years_managed "For how many years have you managed cattle in this kraal?"
	note years_managed: "For how many years have you managed cattle in this kraal?"

	label variable hhs_managed "For how many households do you manage cattle in this kraal?"
	note hhs_managed: "For how many households do you manage cattle in this kraal?"

	label variable age_owner "How old is the owner of the kraal?"
	note age_owner: "How old is the owner of the kraal?"

	label variable educ_owner "What is the highest level of education that the owner of the kraal has received?"
	note educ_owner: "What is the highest level of education that the owner of the kraal has received?"
	label define educ_owner 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_owner educ_owner

	label variable educ_owner_other "Other: Specify"
	note educ_owner_other: "Other: Specify"

	label variable occup_owner "What occupation does the owner of the kraal have?"
	note occup_owner: "What occupation does the owner of the kraal have?"

	label variable occup_owner_other "Other: Specify"
	note occup_owner_other: "Other: Specify"

	label variable livesin_ga "Do you live in \${graze_location}?"
	note livesin_ga: "Do you live in \${graze_location}?"
	label define livesin_ga 1 "Yes" 0 "No"
	label values livesin_ga livesin_ga

	label variable liveswhere "Where do you live?"
	note liveswhere: "Where do you live?"

	label variable relation_owner "How are you related to the owners of the cattle?"
	note relation_owner: "How are you related to the owners of the cattle?"

	label variable relation_owner_other "ENUMERATOR: if the person is related to the owners in any other way, please desc"
	note relation_owner_other: "ENUMERATOR: if the person is related to the owners in any other way, please describe it here"

	label variable cattle_managed "How many cattle in this kraal do you manage?"
	note cattle_managed: "How many cattle in this kraal do you manage?"

	label variable cows_managed "How many cows are in the kraal you manage?"
	note cows_managed: "How many cows are in the kraal you manage?"

	label variable bulls_managed "How many bulls are in the kraal you manage?"
	note bulls_managed: "How many bulls are in the kraal you manage?"

	label variable own_catinherd "Do you also own any cattle that are a part of this herd?"
	note own_catinherd: "Do you also own any cattle that are a part of this herd?"
	label define own_catinherd 1 "Yes" 0 "No"
	label values own_catinherd own_catinherd

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${graze_location} at a"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${graze_location} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${graze_location}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${graze_location}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_grazeplan comprehend_grazeplan

	label variable combherddry_combines "During this year's dry season, did your cattle usually combine with herds from o"
	note combherddry_combines: "During this year's dry season, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherddry_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_combines combherddry_combines

	label variable combherddry_specificherds "Were there particular herds that you intentionally combined with?"
	note combherddry_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherddry_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_specificherds combherddry_specificherds

	label variable combherddry_whynot "Why did you not engage in combined herding during this year's dry season?"
	note combherddry_whynot: "Why did you not engage in combined herding during this year's dry season?"

	label variable combherddry_whynot_oth "Other: Specify"
	note combherddry_whynot_oth: "Other: Specify"

	label variable combherddry_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during this "
	note combherddry_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during this dry season?"
	label define combherddry_discussmgr 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_discussmgr combherddry_discussmgr

	label variable combherddry_numkraals "How many kraals were usually in this combined herd during this dry season?"
	note combherddry_numkraals: "How many kraals were usually in this combined herd during this dry season?"

	label variable combherddry_numcat "How many total cattle were usually in this combined herd during this dry season?"
	note combherddry_numcat: "How many total cattle were usually in this combined herd during this dry season?"

	label variable combherddry_numbull "How many total bulls were usually in this combined herd during this dry season?"
	note combherddry_numbull: "How many total bulls were usually in this combined herd during this dry season?"

	label variable combherdrain_combines "During the rainy season at the beginning of this year, did your cattle usually c"
	note combherdrain_combines: "During the rainy season at the beginning of this year, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherdrain_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_combines combherdrain_combines

	label variable combherdrain_specificherds "Were there particular herds that you intentionally combined with?"
	note combherdrain_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherdrain_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_specificherds combherdrain_specificherds

	label variable combherdrain_whynot "Why did you not engage in combined herding during the rainy season at the beginn"
	note combherdrain_whynot: "Why did you not engage in combined herding during the rainy season at the beginning of this year."

	label variable combherdrain_whynot_other "Other: Specify"
	note combherdrain_whynot_other: "Other: Specify"

	label variable combherdrain_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during the r"
	note combherdrain_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during the rainy season at the beginning of this year?"
	label define combherdrain_discussmgr 1 "Yes" 0 "No"
	label values combherdrain_discussmgr combherdrain_discussmgr

	label variable combherdrain_numkraals "How many kraals were usually in this combined herd during the rainy season at th"
	note combherdrain_numkraals: "How many kraals were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable combherdrain_numcat "How many total cattle were usually in this combined herd during the rainy season"
	note combherdrain_numcat: "How many total cattle were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable combherdrain_numbull "How many total bulls were usually in this combined herd during the rainy season "
	note combherdrain_numbull: "How many total bulls were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable plan_combherd "Do you plan to combine your herd with others by the end of this rainy season?"
	note plan_combherd: "Do you plan to combine your herd with others by the end of this rainy season?"
	label define plan_combherd 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values plan_combherd plan_combherd

	label variable comprehend_combherd "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_combherd: "ENUMERATOR: How well do you think the respondent understood these questions about combined herding, and do you trust their responses?"
	label define comprehend_combherd 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_combherd comprehend_combherd

	label variable herd_managerherds "Do you herd these cattle, or does someone else?"
	note herd_managerherds: "Do you herd these cattle, or does someone else?"

	label variable herd_freq "How often do you visit this herd?"
	note herd_freq: "How often do you visit this herd?"
	label define herd_freq 1 "Daily or near daily" 2 "Weekly or near weekly" 3 "Monthly or near monthly" 4 "Less frequently than monthly" -88 "Refuses to say"
	label values herd_freq herd_freq

	label variable herd_drynumherders "In this year's dry season, how many herders were usually looking after the cattl"
	note herd_drynumherders: "In this year's dry season, how many herders were usually looking after the cattle?"

	label variable herd_rainnumherders "In the rainy season at the beginning of the year, how many herders were usually "
	note herd_rainnumherders: "In the rainy season at the beginning of the year, how many herders were usually looking after the cattle?"

	label variable comm_herders "How often do you communicate with your herders?"
	note comm_herders: "How often do you communicate with your herders?"
	label define comm_herders 1 "Daily" 2 "Most days (multiple times a week)" 3 "Approximately once a week" 4 "Less than once a week (but more than once a month)" 5 "Once a month or less often" -99 "Don’t know" -88 "Refuses to say"
	label values comm_herders comm_herders

	label variable herd_paycash "Do you pay your herders in cash?"
	note herd_paycash: "Do you pay your herders in cash?"
	label define herd_paycash 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_paycash herd_paycash

	label variable herd_cashvalue "How much do you pay your herders?"
	note herd_cashvalue: "How much do you pay your herders?"

	label variable herd_cashvalue_units "Units"
	note herd_cashvalue_units: "Units"
	label define herd_cashvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_cashvalue_units herd_cashvalue_units

	label variable herd_cashvalue_units_oth "Other: Specify"
	note herd_cashvalue_units_oth: "Other: Specify"

	label variable herd_payinkind "Do you pay your herders in any other form, including in food, calves, or another"
	note herd_payinkind: "Do you pay your herders in any other form, including in food, calves, or another form?"
	label define herd_payinkind 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_payinkind herd_payinkind

	label variable herd_inkindvalue "What is the total value of in-kind payments to herders?"
	note herd_inkindvalue: "What is the total value of in-kind payments to herders?"

	label variable herd_inkindvalue_units "Units"
	note herd_inkindvalue_units: "Units"
	label define herd_inkindvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_inkindvalue_units herd_inkindvalue_units

	label variable herd_inkindvalue_units_oth "Other: Specify"
	note herd_inkindvalue_units_oth: "Other: Specify"

	label variable herd_related "Are you related to your herders?"
	note herd_related: "Are you related to your herders?"
	label define herd_related 1 "Yes" 0 "No"
	label values herd_related herd_related

	label variable herd_gear "In the past 12 months, have you provided any of the following items for a herder"
	note herd_gear: "In the past 12 months, have you provided any of the following items for a herder?"

	label variable herd_gear_other "Other: Specify"
	note herd_gear_other: "Other: Specify"

	label variable herd_paygroup "Do you pay your herders individually, or do you pay your herders with managers f"
	note herd_paygroup: "Do you pay your herders individually, or do you pay your herders with managers from other kraals?"

	label variable herd_gear_self "In the past 12 months, have you acquired any of the following gear to use when y"
	note herd_gear_self: "In the past 12 months, have you acquired any of the following gear to use when you herd?"

	label variable herd_gear_other_self "Other: Specify"
	note herd_gear_other_self: "Other: Specify"

	label variable herd_intensitydry "During this year’s dry season, after your herders took your cattle to water, did"
	note herd_intensitydry: "During this year’s dry season, after your herders took your cattle to water, did they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensitydry 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensitydry herd_intensitydry

	label variable whynoherd_dry "Why do you just push your animals during the dry season, instead of remaining wi"
	note whynoherd_dry: "Why do you just push your animals during the dry season, instead of remaining with them?"

	label variable herd_intensityrains "During the rainy season at the beginning of this year, after your herders took y"
	note herd_intensityrains: "During the rainy season at the beginning of this year, after your herders took your cattle to water, did they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensityrains 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensityrains herd_intensityrains

	label variable whynoherd_rains "Why do you just push your animals during the rainy season, instead of remaining "
	note whynoherd_rains: "Why do you just push your animals during the rainy season, instead of remaining with them?"

	label variable herd_typewalk "Which picture best shows the way that your herd walks away from the water point "
	note herd_typewalk: "Which picture best shows the way that your herd walks away from the water point to pasture?"
	label define herd_typewalk 1 "Cattle in a tight bunch" 2 "Cattle in a line" 3 "Cattle scattered" -99 "Don't know"
	label values herd_typewalk herd_typewalk

	label variable herd_typegraze "Which picture best shows the way that your herd is managed when your cattle are "
	note herd_typegraze: "Which picture best shows the way that your herd is managed when your cattle are grazing?"
	label define herd_typegraze 1 "Cattle in a tight bunch" 2 "Cattle scattered" -99 "Don't know"
	label values herd_typegraze herd_typegraze

	label variable herd_animalsmissing "The last time you saw your herd, were any cattle missing?"
	note herd_animalsmissing: "The last time you saw your herd, were any cattle missing?"
	label define herd_animalsmissing 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_animalsmissing herd_animalsmissing

	label variable herd_numbermissing "How many were missing?"
	note herd_numbermissing: "How many were missing?"

	label variable herd_lastsawmissingqty "When was the last time you saw these missing cattle?"
	note herd_lastsawmissingqty: "When was the last time you saw these missing cattle?"

	label variable herd_lastsawmissingunit "Unit"
	note herd_lastsawmissingunit: "Unit"
	label define herd_lastsawmissingunit 1 "days" 2 "weeks" 3 "months"
	label values herd_lastsawmissingunit herd_lastsawmissingunit

	label variable herd_catlost "In the past 12 months, how many of the cattle you manage have been lost, stolen "
	note herd_catlost: "In the past 12 months, how many of the cattle you manage have been lost, stolen or killed by a predator?"

	label variable water_freq "On average, how many times per day do you take your cattle to water?"
	note water_freq: "On average, how many times per day do you take your cattle to water?"
	label define water_freq 1 "Less than once a day" 2 "Once a day" 3 "Sometimes once a day, sometimes twice a day" 4 "Twice a day" 5 "There is a water point at my kraal"
	label values water_freq water_freq

	label variable water_quant "In the last three years, has the quantity of water you have access to increased,"
	note water_quant: "In the last three years, has the quantity of water you have access to increased, decreased, or stayed the same?"
	label define water_quant 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_quant water_quant

	label variable water_qual "In the last three years, has the quality of water you have access to gotten bett"
	note water_qual: "In the last three years, has the quality of water you have access to gotten better, worse, or stayed the same?"
	label define water_qual 1 "Gotten better" 2 "Stayed the same" 3 "Gotten worse" -99 "Don't know"
	label values water_qual water_qual

	label variable water_dist "In the last three years, has the distance you normally travel to get water incre"
	note water_dist: "In the last three years, has the distance you normally travel to get water increased, decreased, or stayed the same?"
	label define water_dist 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_dist water_dist

	label variable water_animals "In the last three years, has the number of animals that use the water point you "
	note water_animals: "In the last three years, has the number of animals that use the water point you normally go to increased significantly, decreased significantly, or stayed about the same?"
	label define water_animals 1 "Increased significantly" 2 "Decreased significantly" 3 "Stayed about the same" -99 "Don't know"
	label values water_animals water_animals

	label variable water_barriers "Are there now barriers to your access to water that did not exist three years ag"
	note water_barriers: "Are there now barriers to your access to water that did not exist three years ago? For example, do you now have to pay for water use (apart from payments for diesel), or have you lost access to a particular water point?"
	label define water_barriers 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values water_barriers water_barriers

	label variable lsmgmt_dvs "In the past 12 months, did the government vaccinate your cattle?"
	note lsmgmt_dvs: "In the past 12 months, did the government vaccinate your cattle?"
	label define lsmgmt_dvs 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_dvs lsmgmt_dvs

	label variable lsmgmt_othvacyn "Did you vaccinate your cattle for any diseases apart from the vaccinations provi"
	note lsmgmt_othvacyn: "Did you vaccinate your cattle for any diseases apart from the vaccinations provided by the government?"
	label define lsmgmt_othvacyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_othvacyn lsmgmt_othvacyn

	label variable lsmgmt_othvac "Against which diseases did you vaccinate them?"
	note lsmgmt_othvac: "Against which diseases did you vaccinate them?"

	label variable lsmgmt_othvac_other "ENUMERATOR: Record any other vaccines the enumerator mentions"
	note lsmgmt_othvac_other: "ENUMERATOR: Record any other vaccines the enumerator mentions"

	label variable lsmgmt_howmanyvac "Did you vaccinate all of your cattle, or just some of them?"
	note lsmgmt_howmanyvac: "Did you vaccinate all of your cattle, or just some of them?"
	label define lsmgmt_howmanyvac 1 "All of the animals" 2 "Only one, or some of them"
	label values lsmgmt_howmanyvac lsmgmt_howmanyvac

	label variable lsmgmt_whyvac "Why did you vaccinate this/these cattle?"
	note lsmgmt_whyvac: "Why did you vaccinate this/these cattle?"

	label variable lsmgmt_pay "Did the famers owning cattle in this kraal pay for vaccinations with farmers own"
	note lsmgmt_pay: "Did the famers owning cattle in this kraal pay for vaccinations with farmers owning cattle in other kraals?"

	label variable lsmgmt_deworm "In the past 12 months, have you dewormed your cattle?"
	note lsmgmt_deworm: "In the past 12 months, have you dewormed your cattle?"
	label define lsmgmt_deworm 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_deworm lsmgmt_deworm

	label variable lsmgmt_supplement "In the past 12 months, what supplements, if any, have you provided to your cattl"
	note lsmgmt_supplement: "In the past 12 months, what supplements, if any, have you provided to your cattle?"

	label variable lsmgmt_supplement_other "Other: Specify"
	note lsmgmt_supplement_other: "Other: Specify"

	label variable lsmgmt_ticfreq "How often are your cattle checked for ticks?"
	note lsmgmt_ticfreq: "How often are your cattle checked for ticks?"
	label define lsmgmt_ticfreq 1 "Once a week or more frequently" 2 "Every 8 days to every 30 days" 3 "Less than once every 30 days" 4 "Never" 5 "Never, but cattle in my area never get ticks" -99 "Don't know"
	label values lsmgmt_ticfreq lsmgmt_ticfreq

	label variable lsmgmt_locexpertsick "When you have questions about your cattle when they are sick, including diagnosi"
	note lsmgmt_locexpertsick: "When you have questions about your cattle when they are sick, including diagnosing illnesses or purchasing medicines is there someone in your community that you can ask?"
	label define lsmgmt_locexpertsick 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertsick lsmgmt_locexpertsick

	label variable lsmgmt_locexpertmgmt "When you have general questions about your cattle, including inseminating cows a"
	note lsmgmt_locexpertmgmt: "When you have general questions about your cattle, including inseminating cows and herding, is there someone in your community that you can ask?"
	label define lsmgmt_locexpertmgmt 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertmgmt lsmgmt_locexpertmgmt

	label variable lsmgmt_bullcow "What do you think is the ideal bull to cow ratio?"
	note lsmgmt_bullcow: "What do you think is the ideal bull to cow ratio?"

	label variable comprehend_lsmgmt "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_lsmgmt: "ENUMERATOR: How well do you think the respondent understood these questions about livestock management, and do you trust their responses?"
	label define comprehend_lsmgmt 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_lsmgmt comprehend_lsmgmt

	label variable lsoff_numsold "How many live cattle have you sold in the past 12 months?"
	note lsoff_numsold: "How many live cattle have you sold in the past 12 months?"

	label variable lsoff_valsold "How much money did you receive for these cattle?"
	note lsoff_valsold: "How much money did you receive for these cattle?"

	label variable lsoff_valsoldunits "In total or average"
	note lsoff_valsoldunits: "In total or average"
	label define lsoff_valsoldunits 1 "In total" 2 "Per animal"
	label values lsoff_valsoldunits lsoff_valsoldunits

	label variable lsoff_buyers "To whom have you sold cattle in the past 12 months?"
	note lsoff_buyers: "To whom have you sold cattle in the past 12 months?"

	label variable lsoff_buyers_other "Other: Specify"
	note lsoff_buyers_other: "Other: Specify"

	label variable lsoff_numslaughtfest "In the past 12 months, how many cattle have you slaughtered or gifted for weddin"
	note lsoff_numslaughtfest: "In the past 12 months, how many cattle have you slaughtered or gifted for weddings or funerals?"

	label variable lsoff_numgift "In the past 12 months, how many cattle have you lent or gifted to another househ"
	note lsoff_numgift: "In the past 12 months, how many cattle have you lent or gifted to another household for reasons apart from weddings and funerals?"

	label variable lsoff_numslaughtsale "In the past 12 months, how many cattle have you slaughtered and sold? Do not inc"
	note lsoff_numslaughtsale: "In the past 12 months, how many cattle have you slaughtered and sold? Do not include animals slaughtered and sold for weddings and funerals"

	label variable lsoff_valslaughter "How much did you receive for the cattle you slaughtered and sold?"
	note lsoff_valslaughter: "How much did you receive for the cattle you slaughtered and sold?"

	label variable lsoff_valslaughtunits "In total or average"
	note lsoff_valslaughtunits: "In total or average"
	label define lsoff_valslaughtunits 1 "In total" 2 "Per animal"
	label values lsoff_valslaughtunits lsoff_valslaughtunits

	label variable lsoff_salereasons "For what reasons have you sold cattle in the past 12 months? Check all that appl"
	note lsoff_salereasons: "For what reasons have you sold cattle in the past 12 months? Check all that apply"

	label variable lsoff_salereasons_other "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those "
	note lsoff_salereasons_other: "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those in the list"

	label variable lsoff_animalreasons "When you last decided to sell cattle, how did you decide which cattle to sell?"
	note lsoff_animalreasons: "When you last decided to sell cattle, how did you decide which cattle to sell?"

	label variable lsoff_animalreason_other "Other: Specify"
	note lsoff_animalreason_other: "Other: Specify"

	label variable lsoff_restructure "What kind of herd restructuring did you participate in?"
	note lsoff_restructure: "What kind of herd restructuring did you participate in?"

	label variable lsoff_restructure_other "Other: Specify"
	note lsoff_restructure_other: "Other: Specify"

	label variable comm_wat_yesno "Are you a part of group that makes decisions about how the group manages water? "
	note comm_wat_yesno: "Are you a part of group that makes decisions about how the group manages water? This can include a group of people that decides how to pay for repairs when a borehole/well breaks down"
	label define comm_wat_yesno 1 "Yes" 0 "No"
	label values comm_wat_yesno comm_wat_yesno

	label variable comm_wat_mtgno "In the past 12 months, how many meetings did you attend for this water group?"
	note comm_wat_mtgno: "In the past 12 months, how many meetings did you attend for this water group?"

	label variable comm_wat_mtgunit "Units"
	note comm_wat_mtgunit: "Units"
	label define comm_wat_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_wat_mtgunit comm_wat_mtgunit

	label variable comm_wat_finyn "In the past 12 months, have you contributed financially to this water group?"
	note comm_wat_finyn: "In the past 12 months, have you contributed financially to this water group?"
	label define comm_wat_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_wat_finyn comm_wat_finyn

	label variable comm_graze_yesno "Are you a part of group that makes decisions about how the group manages cattle "
	note comm_graze_yesno: "Are you a part of group that makes decisions about how the group manages cattle and grazing?"
	label define comm_graze_yesno 1 "Yes" 0 "No"
	label values comm_graze_yesno comm_graze_yesno

	label variable comm_graze_mtgno "In the past 12 months, how many grazing meetings did you attend?"
	note comm_graze_mtgno: "In the past 12 months, how many grazing meetings did you attend?"

	label variable comm_graze_mtgunit "Units"
	note comm_graze_mtgunit: "Units"
	label define comm_graze_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_graze_mtgunit comm_graze_mtgunit

	label variable comm_graze_finyn "In the past 12 months, have you contributed financially to a grazing group?"
	note comm_graze_finyn: "In the past 12 months, have you contributed financially to a grazing group?"
	label define comm_graze_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_graze_finyn comm_graze_finyn

	label variable comm_new_yesno "Are you a part of a group that makes a decision when someone new wants to enter "
	note comm_new_yesno: "Are you a part of a group that makes a decision when someone new wants to enter the community?"
	label define comm_new_yesno 1 "Yes" 0 "No"
	label values comm_new_yesno comm_new_yesno

	label variable comm_new_mtgno "In the past 12 months, how many of these meetings did you attend?"
	note comm_new_mtgno: "In the past 12 months, how many of these meetings did you attend?"

	label variable comm_new_mtgunit "Units"
	note comm_new_mtgunit: "Units"
	label define comm_new_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_new_mtgunit comm_new_mtgunit

	label variable comm_devt_yesno "Are you currently a part of a group that makes general development decisions in "
	note comm_devt_yesno: "Are you currently a part of a group that makes general development decisions in your community, for example about local projects?"
	label define comm_devt_yesno 1 "Yes" 0 "No"
	label values comm_devt_yesno comm_devt_yesno

	label variable comm_devt_desc "What is the name of this organization?"
	note comm_devt_desc: "What is the name of this organization?"

	label variable comm_devt_mtgno "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"
	note comm_devt_mtgno: "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"

	label variable comm_devt_mtgunit "Units"
	note comm_devt_mtgunit: "Units"
	label define comm_devt_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_devt_mtgunit comm_devt_mtgunit

	label variable comm_devt_finyn "In the past 12 months, have you contributed financially to a general development"
	note comm_devt_finyn: "In the past 12 months, have you contributed financially to a general development group?"
	label define comm_devt_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_devt_finyn comm_devt_finyn

	label variable socdyn_mobile "Do you have a mobile phone?"
	note socdyn_mobile: "Do you have a mobile phone?"
	label define socdyn_mobile 1 "Yes" 0 "No"
	label values socdyn_mobile socdyn_mobile

	label variable socdyn_radio "Do you have a radio?"
	note socdyn_radio: "Do you have a radio?"
	label define socdyn_radio 1 "Yes" 0 "No"
	label values socdyn_radio socdyn_radio

	label variable socdyn_watch "Do you have a watch?"
	note socdyn_watch: "Do you have a watch?"
	label define socdyn_watch 1 "Yes" 0 "No"
	label values socdyn_watch socdyn_watch

	label variable socdyn_mobneivill "'I would lend my cell phone to a person in a neighboring village and let them ou"
	note socdyn_mobneivill: "'I would lend my cell phone to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_mobneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobneivill socdyn_mobneivill

	label variable socdyn_mobfirstime "'I would lend my cell phone to a person I just met for the first time and let th"
	note socdyn_mobfirstime: "'I would lend my cell phone to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_mobfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobfirstime socdyn_mobfirstime

	label variable socdyn_radneivill "'I would lend my radio to a person in a neighboring village and let them out of "
	note socdyn_radneivill: "'I would lend my radio to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_radneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radneivill socdyn_radneivill

	label variable socdyn_radfirstime "'I would lend my radio to a person I just met for the first time and let them ou"
	note socdyn_radfirstime: "'I would lend my radio to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_radfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radfirstime socdyn_radfirstime

	label variable socdyn_watneivill "'I would lend my watch to a person in a neighboring village.'"
	note socdyn_watneivill: "'I would lend my watch to a person in a neighboring village.'"
	label define socdyn_watneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watneivill socdyn_watneivill

	label variable socdyn_watfirstime "'I would lend my watch to a person I just met for the first time'"
	note socdyn_watfirstime: "'I would lend my watch to a person I just met for the first time'"
	label define socdyn_watfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watfirstime socdyn_watfirstime

	label variable socdyn_trust "'In general, I believe people can be relied on.'"
	note socdyn_trust: "'In general, I believe people can be relied on.'"
	label define socdyn_trust 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_trust socdyn_trust

	label variable mgr_relation_ta "Are you related to the local TAs or headman?"
	note mgr_relation_ta: "Are you related to the local TAs or headman?"

	label variable owner_relation_ta "Are any of the owners related to the local TAs or headman?"
	note owner_relation_ta: "Are any of the owners related to the local TAs or headman?"

	label variable ta_freq "In the last three weeks, how many times have you spoken with someone on the TA?"
	note ta_freq: "In the last three weeks, how many times have you spoken with someone on the TA?"
	label define ta_freq 1 "Every day" 2 "Most days (more than once a week)" 3 "Once a week" 4 "Between once a week and once a month" 5 "Less than once a month" 0 "Never"
	label values ta_freq ta_freq

	label variable socdyn_ta "'Even though the traditional authority is working hard, sometimes they do not ma"
	note socdyn_ta: "'Even though the traditional authority is working hard, sometimes they do not make the right decisions.'"
	label define socdyn_ta 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_ta socdyn_ta

	label variable socdyn_fence "'If I could build a fence around \${graze_location}, I would.'"
	note socdyn_fence: "'If I could build a fence around \${graze_location}, I would.'"
	label define socdyn_fence 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_fence socdyn_fence

	label variable socdyn_sharegrass "'If a farmer from the next village has no grass in his village, but there is gra"
	note socdyn_sharegrass: "'If a farmer from the next village has no grass in his village, but there is grass in \${graze_location}, I believe that farmer should be welcomed at \${graze_location}.'"
	label define socdyn_sharegrass 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_sharegrass socdyn_sharegrass

	label variable socdyn_toomanyothers "'The headman and other elders in \${graze_location} let too many outsiders bring"
	note socdyn_toomanyothers: "'The headman and other elders in \${graze_location} let too many outsiders bring their cattle to graze in \${graze_location}.'"
	label define socdyn_toomanyothers 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_toomanyothers socdyn_toomanyothers

	label variable socdyn_locusgen "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	note socdyn_locusgen: "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	label define socdyn_locusgen 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusgen socdyn_locusgen

	label variable socdyn_locuscattle "'I feel as though my actions personally affect the health and value of my cattle"
	note socdyn_locuscattle: "'I feel as though my actions personally affect the health and value of my cattle.'"
	label define socdyn_locuscattle 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locuscattle socdyn_locuscattle

	label variable socdyn_locusrange "'I can personally affect the quality of the rangeland and grass in my community'"
	note socdyn_locusrange: "'I can personally affect the quality of the rangeland and grass in my community'"
	label define socdyn_locusrange 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusrange socdyn_locusrange

	label variable socdyn_inctrust "In the last three years, has the number of people you trust increased, decreased"
	note socdyn_inctrust: "In the last three years, has the number of people you trust increased, decreased, or stayed the same?"
	label define socdyn_inctrust 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_inctrust socdyn_inctrust

	label variable socdyn_incconf "In the last three years, has the number of people you have conflict with increas"
	note socdyn_incconf: "In the last three years, has the number of people you have conflict with increased, decreased, or stayed the same?"
	label define socdyn_incconf 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_incconf socdyn_incconf

	label variable num_auctions "In the last three years, has the number of auctions near you increased, decrease"
	note num_auctions: "In the last three years, has the number of auctions near you increased, decreased, or stayed the same?"
	label define num_auctions 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values num_auctions num_auctions

	label variable gopa_knows "Have you heard of the GOPA project?"
	note gopa_knows: "Have you heard of the GOPA project?"
	label define gopa_knows 1 "Yes" 0 "No"
	label values gopa_knows gopa_knows

	label variable gopa_farmer "Were you a participant in the GOPA project?"
	note gopa_farmer: "Were you a participant in the GOPA project?"
	label define gopa_farmer 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_farmer gopa_farmer

	label variable gopa_offered "Were you offered the chance to participate in the GOPA project?"
	note gopa_offered: "Were you offered the chance to participate in the GOPA project?"
	label define gopa_offered 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_offered gopa_offered

	label variable fup_combine_place "At what water point do your cattle currently take water?"
	note fup_combine_place: "At what water point do your cattle currently take water?"

	label variable fup_combine_hrs "At what time do you take your cattle to water? HOURS"
	note fup_combine_hrs: "At what time do you take your cattle to water? HOURS"

	label variable fup_combine_mins "At what time do you take your cattle to water? MINS"
	note fup_combine_mins: "At what time do you take your cattle to water? MINS"

	label variable fup_name_wpsec "What is the name of the person who takes minutes for the water point committee, "
	note fup_name_wpsec: "What is the name of the person who takes minutes for the water point committee, if anyone does?"

	label variable fup_name_grsec "What is the name of the person who takes minutes for your grazing group, if anyo"
	note fup_name_grsec: "What is the name of the person who takes minutes for your grazing group, if anyone does?"

	label variable fup_name_othsec "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyo"
	note fup_name_othsec: "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyone does?"

	label variable comments "ENUMERATOR: Please offer any comments you have about the survey here (optional)"
	note comments: "ENUMERATOR: Please offer any comments you have about the survey here (optional)"

	label variable datetime_end "Enter date and time"
	note datetime_end: "Enter date and time"

	* append old, previously-imported data (if any) 5
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 5
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
global v5_run 1

if "`c(username)'"=="pierre-yves" {
	drop date_beginning datetime_end
	merge 1:1 key using `datetime'
	gen space = substr(date_beginning, 2, 1)==" "
	gen day = substr(date_beginning, 1,1) if space==1
	replace day=substr(date_beginning, 1, 2) if space==0
	gen month_str=substr(date_beginning, 4, 3) if space==0
	replace month_str=substr(date_beginning, 3, 3) if space==1
	gen month=.
	replace month=10 if month_str=="oct"
	replace month=11 if month_str=="nov"
	replace month=12 if month_str=="dec"
	gen time_beginning = substr(date_beginning, 13, 8) if space==0
	replace time_beginning = substr(date_beginning, 12, 8) if space==1
	gen space_end = substr(datetime_end, 2, 1)==" "
	gen time_end = substr(datetime_end, 13, 8) if space==0
	replace time_end = substr(datetime_end, 12, 8) if space==1
	gen double clock_begin = clock(time_beginning, "hms")
	gen double clock_end = clock(time_end, "hms")
	gen svy_length = (clock_end - clock_begin)/60000
	drop month_str
	destring day, replace
}		


#delimit ; 

**  Generate a variable to indicate the version of the survey ;
gen v = 5 ;
save `v5', replace ;


********************************************************************************************************** ; 
**  STEP 2F: Imports and aggregates "FINAL BEHAVIORAL V6" (ID: FINAL_BEHAVIORAL_V6) data.				** ;
********************************************************************************************************** ;

#delimit cr 

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V6.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL BEHAVIORAL V6.dta"
local corrfile "$stata\rawdata\behavioral\FINAL BEHAVIORAL V6_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local note_fields1 "informed_consent enumwait waitformanager note_for_enum note_for_resp note_inconsistency plannedgrazingintro combinedherdingintro introherding lstockmgmtintro commnote socdyn_intro followup_combine"
local text_fields1 "deviceid subscriberid simid devicephonenum region enum_id ga_id mgr_firstname mgr_surname audit farmer_id respondent_firstname respondent_surname language_other relation_manager_other location_manager"
local text_fields2 "graze_location educ_mgr_other relation_owner relation_owner_other educ_owner_other occup_owner occup_owner_other liveswhere grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months"
local text_fields3 "grazeplanrain_writtenshare_oth grazeplan_otherlocfreq combherddry_whynot combherddry_whynot_oth combherdrain_whynot combherdrain_whynot_other herd_managerherds herd_cashvalue_units_oth"
local text_fields4 "herd_inkindvalue_units_oth herd_gear herd_gear_other herd_paygroup herd_gear_self herd_gear_other_self whynoherd_dry whynoherd_rains lsmgmt_othvac lsmgmt_othvac_other lsmgmt_whyvac lsmgmt_pay"
local text_fields5 "lsmgmt_supplement lsmgmt_supplement_other lsoff_buyers lsoff_buyers_other lsoff_salereasons lsoff_salereasons_other lsoff_animalreasons lsoff_animalreason_other lsoff_restructure"
local text_fields6 "lsoff_restructure_other comm_devt_desc mgr_relation_ta owner_relation_ta fup_combine_place fup_name_wpsec fup_name_grsec fup_name_othsec comments"
local date_fields1 ""
local datetime_fields1 "starttime endtime date_beginning datetime_end"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear
tempfile datetime all
save `all'
keep date_beginning datetime_end key
save `datetime'
use `all'
* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\FINAL BEHAVIORAL V6-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
	
	* drop note fields (since they don't contain any real data) 6
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 6
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				foreach stringvar of varlist `svarlist' {
					quietly: replace `ismissingvar'=.
					quietly: cap replace `ismissingvar'=1 if `stringvar'==.
					cap tostring `stringvar', format(%100.0g) replace
					cap replace `stringvar'="" if `ismissingvar'==1
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable date_beginning "Enter date and time"
	note date_beginning: "Enter date and time"

	label variable gpslatitude "ENUMERATOR: Enter your GPS Coordinates (latitude)"
	note gpslatitude: "ENUMERATOR: Enter your GPS Coordinates (latitude)"

	label variable gpslongitude "ENUMERATOR: Enter your GPS Coordinates (longitude)"
	note gpslongitude: "ENUMERATOR: Enter your GPS Coordinates (longitude)"

	label variable gpsaltitude "ENUMERATOR: Enter your GPS Coordinates (altitude)"
	note gpsaltitude: "ENUMERATOR: Enter your GPS Coordinates (altitude)"

	label variable gpsaccuracy "ENUMERATOR: Enter your GPS Coordinates (accuracy)"
	note gpsaccuracy: "ENUMERATOR: Enter your GPS Coordinates (accuracy)"

	label variable region "What regional team are you a part of?"
	note region: "What regional team are you a part of?"

	label variable enum_id "ENUMERATOR: What is your name?"
	note enum_id: "ENUMERATOR: What is your name?"

	label variable ga_id "ENUMERATOR: What is the name of the grazing area?"
	note ga_id: "ENUMERATOR: What is the name of the grazing area?"

	label variable farmer_number "ENUMERATOR: What number was this manager on your listing form?"
	note farmer_number: "ENUMERATOR: What number was this manager on your listing form?"

	label variable consent "Do you agree to taking the survey?"
	note consent: "Do you agree to taking the survey?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable mgr_firstname "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"
	note mgr_firstname: "ENUMERATOR: What is the given name of the manager of kraal \${farmer_number}?"

	label variable mgr_surname "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"
	note mgr_surname: "ENUMERATOR: What is the surname of the manager of kraal \${farmer_number}?"

	label variable mgr_gender "ENUMERATOR: Is the manager male or female?"
	note mgr_gender: "ENUMERATOR: Is the manager male or female?"
	label define mgr_gender 1 "Male" 2 "Female"
	label values mgr_gender mgr_gender

	label variable resp_is_mgr "ENUMERATOR: Is the person you are speaking with the manager from the listing she"
	note resp_is_mgr: "ENUMERATOR: Is the person you are speaking with the manager from the listing sheet?"
	label define resp_is_mgr 1 "Yes" 0 "No"
	label values resp_is_mgr resp_is_mgr

	label variable live_interview "ENUMERATOR: Is this a live interview, or are you entering an interview that was "
	note live_interview: "ENUMERATOR: Is this a live interview, or are you entering an interview that was conducted on paper?"
	label define live_interview 1 "This is a live interview" 2 "This is an interview that was originally conducted on paper"
	label values live_interview live_interview

	label variable respondent_firstname "What is your first name?"
	note respondent_firstname: "What is your first name?"

	label variable respondent_surname "What is your surname?"
	note respondent_surname: "What is your surname?"

	label variable language "What is the primary language spoken in your home?"
	note language: "What is the primary language spoken in your home?"
	label define language 1 "Herero" 2 "Kwanyama" 3 "Ndonga" 4 "Kwambi" 5 "Ngandjera" 6 "Mbalunhu" 7 "Kwaluudhi" 8 "Eunda" 9 "Nkolonkadhi" 10 "Zemba" 11 "Himba" 12 "Kwangali" 13 "Shambyu" 14 "Gciriku" 16 "Mbukushu" -77 "Other: specify"
	label values language language

	label variable language_other "Other: Specify"
	note language_other: "Other: Specify"

	label variable manages_owncattle "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make deci"
	note manages_owncattle: "Do you own and manage a herd of 10 or more cattle? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_owncattle 1 "Yes" 0 "No"
	label values manages_owncattle manages_owncattle

	label variable manages_othercattle "Do you manage a herd of 10 or more cattle, including cattle that belong to other"
	note manages_othercattle: "Do you manage a herd of 10 or more cattle, including cattle that belong to others? By 'manage', I mean make decisions about which vaccinations and treatment the cattle receive, how many herders attend to the cattle, or make decisions when there are problems with the cattle?"
	label define manages_othercattle 1 "Yes" 0 "No"
	label values manages_othercattle manages_othercattle

	label variable right_respondent "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr"
	note right_respondent: "ENUMERATOR: Are you confident the person you are talking to is related to \${mgr_firstname}\${mgr_surname} in some way?"
	label define right_respondent 1 "Yes" 0 "No"
	label values right_respondent right_respondent

	label variable relation_manager "What is your relation to \${mgr_firstname}\${mgr_surname}?"
	note relation_manager: "What is your relation to \${mgr_firstname}\${mgr_surname}?"
	label define relation_manager 1 "The manager is my husband/wife" 2 "The manager is my mother/father" 3 "The manager is my brother/sister" 4 "The manager is my son/daughter" -77 "I am related to the manager in some other way" -78 "I am not related to the manager: specify"
	label values relation_manager relation_manager

	label variable relation_manager_other "Other: Specify"
	note relation_manager_other: "Other: Specify"

	label variable location_manager "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"
	note location_manager: "ENUMERATOR Where is the manager of kraal \${farmer_number} currently?"

	label variable return_manager "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	note return_manager: "ENUMERATOR: When do you expect the manager of kraal \${farmer_number} to return?"
	label define return_manager 1 "In just a few minutes" 2 "Later today" 3 "Tomorrow" 4 "Later than tomorrow"
	label values return_manager return_manager

	label variable capable_responding "ENUMERATOR: Do you think this person is capable of answering questions about the"
	note capable_responding: "ENUMERATOR: Do you think this person is capable of answering questions about the cattle managed by \${mgr_firstname}\${mgr_surname}?"
	label define capable_responding 1 "Yes" 0 "No"
	label values capable_responding capable_responding

	label variable graze_location "Where do you currently graze these cattle?"
	note graze_location: "Where do you currently graze these cattle?"

	label variable age_mgr "How old are you?"
	note age_mgr: "How old are you?"

	label variable educ_mgr "What is the highest level of education you have received?"
	note educ_mgr: "What is the highest level of education you have received?"
	label define educ_mgr 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_mgr educ_mgr

	label variable educ_mgr_other "Other: Specify"
	note educ_mgr_other: "Other: Specify"

	label variable years_managed "For how many years have you managed cattle in this kraal?"
	note years_managed: "For how many years have you managed cattle in this kraal?"

	label variable hhs_managed "For how many households do you manage cattle in this kraal?"
	note hhs_managed: "For how many households do you manage cattle in this kraal?"

	label variable relation_owner "How are you related to the owners of the cattle?"
	note relation_owner: "How are you related to the owners of the cattle?"

	label variable relation_owner_other "ENUMERATOR: if the person is related to the owners in any other way, please desc"
	note relation_owner_other: "ENUMERATOR: if the person is related to the owners in any other way, please describe it here"

	label variable age_owner "How old is the owner of the kraal?"
	note age_owner: "How old is the owner of the kraal?"

	label variable educ_owner "What is the highest level of education that the owner of the kraal has received?"
	note educ_owner: "What is the highest level of education that the owner of the kraal has received?"
	label define educ_owner 0 "Received no education" 1 "Some primary education" 2 "Completed primary education" 3 "Some secondary education" 4 "Completed secondary education" 5 "Some college, no degree or diploma" 6 "Diploma" 7 "Degree" 8 "Technical school" 9 "Masters" -77 "Other: specify" -99 "Don't know" -88 "Refuses to say"
	label values educ_owner educ_owner

	label variable educ_owner_other "Other: Specify"
	note educ_owner_other: "Other: Specify"

	label variable occup_owner "What occupation does the owner of the kraal have?"
	note occup_owner: "What occupation does the owner of the kraal have?"

	label variable occup_owner_other "Other: Specify"
	note occup_owner_other: "Other: Specify"

	label variable livesin_ga "Do you live in \${graze_location}?"
	note livesin_ga: "Do you live in \${graze_location}?"
	label define livesin_ga 1 "Yes" 0 "No"
	label values livesin_ga livesin_ga

	label variable liveswhere "Where do you live?"
	note liveswhere: "Where do you live?"

	label variable cattle_managed "How many cattle in this kraal do you manage?"
	note cattle_managed: "How many cattle in this kraal do you manage?"

	label variable cows_managed "How many cows are in the kraal you manage?"
	note cows_managed: "How many cows are in the kraal you manage?"

	label variable bulls_managed "How many bulls are in the kraal you manage?"
	note bulls_managed: "How many bulls are in the kraal you manage?"

	label variable own_catinherd "Do you also own any cattle that are a part of this herd?"
	note own_catinherd: "Do you also own any cattle that are a part of this herd?"
	label define own_catinherd 1 "Yes" 0 "No"
	label values own_catinherd own_catinherd

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${graze_lo"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${graze_location} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${graze_location} at a"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${graze_location} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${graze_location}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${graze_location}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_grazeplan comprehend_grazeplan

	label variable combherddry_combines "During this year's dry season, did your cattle usually combine with herds from o"
	note combherddry_combines: "During this year's dry season, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherddry_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_combines combherddry_combines

	label variable combherddry_specificherds "Were there particular herds that you intentionally combined with?"
	note combherddry_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherddry_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_specificherds combherddry_specificherds

	label variable combherddry_whynot "Why did you not engage in combined herding during this year's dry season?"
	note combherddry_whynot: "Why did you not engage in combined herding during this year's dry season?"

	label variable combherddry_whynot_oth "Other: Specify"
	note combherddry_whynot_oth: "Other: Specify"

	label variable combherddry_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during this "
	note combherddry_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during this dry season?"
	label define combherddry_discussmgr 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherddry_discussmgr combherddry_discussmgr

	label variable combherddry_numkraals "How many kraals were usually in this combined herd during this dry season?"
	note combherddry_numkraals: "How many kraals were usually in this combined herd during this dry season?"

	label variable combherddry_numcat "How many total cattle were usually in this combined herd during this dry season?"
	note combherddry_numcat: "How many total cattle were usually in this combined herd during this dry season?"

	label variable combherddry_numbull "How many total bulls were usually in this combined herd during this dry season?"
	note combherddry_numbull: "How many total bulls were usually in this combined herd during this dry season?"

	label variable combherdrain_combines "During the rainy season at the beginning of this year, did your cattle usually c"
	note combherdrain_combines: "During the rainy season at the beginning of this year, did your cattle usually combine with herds from other kraals when grazing?"
	label define combherdrain_combines 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_combines combherdrain_combines

	label variable combherdrain_specificherds "Were there particular herds that you intentionally combined with?"
	note combherdrain_specificherds: "Were there particular herds that you intentionally combined with?"
	label define combherdrain_specificherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values combherdrain_specificherds combherdrain_specificherds

	label variable combherdrain_whynot "Why did you not engage in combined herding during the rainy season at the beginn"
	note combherdrain_whynot: "Why did you not engage in combined herding during the rainy season at the beginning of this year."

	label variable combherdrain_whynot_other "Other: Specify"
	note combherdrain_whynot_other: "Other: Specify"

	label variable combherdrain_discussmgr "Did you make this decision with the manager(s) of the other herd(s) during the r"
	note combherdrain_discussmgr: "Did you make this decision with the manager(s) of the other herd(s) during the rainy season at the beginning of this year?"
	label define combherdrain_discussmgr 1 "Yes" 0 "No"
	label values combherdrain_discussmgr combherdrain_discussmgr

	label variable combherdrain_numkraals "How many kraals were usually in this combined herd during the rainy season at th"
	note combherdrain_numkraals: "How many kraals were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable combherdrain_numcat "How many total cattle were usually in this combined herd during the rainy season"
	note combherdrain_numcat: "How many total cattle were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable combherdrain_numbull "How many total bulls were usually in this combined herd during the rainy season "
	note combherdrain_numbull: "How many total bulls were usually in this combined herd during the rainy season at the beginning of this year?"

	label variable plan_combherd "Do you plan to combine your herd with others by the end of this rainy season?"
	note plan_combherd: "Do you plan to combine your herd with others by the end of this rainy season?"
	label define plan_combherd 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values plan_combherd plan_combherd

	label variable comprehend_combherd "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_combherd: "ENUMERATOR: How well do you think the respondent understood these questions about combined herding, and do you trust their responses?"
	label define comprehend_combherd 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_combherd comprehend_combherd

	label variable herd_managerherds "Do you herd these cattle, or does someone else?"
	note herd_managerherds: "Do you herd these cattle, or does someone else?"

	label variable herd_freq "How often do you visit this herd?"
	note herd_freq: "How often do you visit this herd?"
	label define herd_freq 1 "Daily or near daily" 2 "Weekly or near weekly" 3 "Monthly or near monthly" 4 "Less frequently than monthly" -88 "Refuses to say"
	label values herd_freq herd_freq

	label variable herd_drynumherders "In this year's dry season, how many herders were usually looking after the cattl"
	note herd_drynumherders: "In this year's dry season, how many herders were usually looking after the cattle?"

	label variable herd_rainnumherders "In the rainy season at the beginning of the year, how many herders were usually "
	note herd_rainnumherders: "In the rainy season at the beginning of the year, how many herders were usually looking after the cattle?"

	label variable comm_herders "How often do you communicate with your herders?"
	note comm_herders: "How often do you communicate with your herders?"
	label define comm_herders 1 "Daily" 2 "Most days (multiple times a week)" 3 "Approximately once a week" 4 "Less than once a week (but more than once a month)" 5 "Once a month or less often" -99 "Don’t know" -88 "Refuses to say"
	label values comm_herders comm_herders

	label variable herd_paycash "Do you pay your herders in cash?"
	note herd_paycash: "Do you pay your herders in cash?"
	label define herd_paycash 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_paycash herd_paycash

	label variable herd_cashvalue "How much do you pay your herders?"
	note herd_cashvalue: "How much do you pay your herders?"

	label variable herd_cashvalue_units "Units"
	note herd_cashvalue_units: "Units"
	label define herd_cashvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_cashvalue_units herd_cashvalue_units

	label variable herd_cashvalue_units_oth "Other: Specify"
	note herd_cashvalue_units_oth: "Other: Specify"

	label variable herd_payinkind "Do you pay your herders in any other form, including in food, calves, or another"
	note herd_payinkind: "Do you pay your herders in any other form, including in food, calves, or another form?"
	label define herd_payinkind 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_payinkind herd_payinkind

	label variable herd_inkindvalue "What is the total value of in-kind payments to herders?"
	note herd_inkindvalue: "What is the total value of in-kind payments to herders?"

	label variable herd_inkindvalue_units "Units"
	note herd_inkindvalue_units: "Units"
	label define herd_inkindvalue_units 1 "Per week" 2 "Per month" 3 "Per year" -77 "Other: specify"
	label values herd_inkindvalue_units herd_inkindvalue_units

	label variable herd_inkindvalue_units_oth "Other: Specify"
	note herd_inkindvalue_units_oth: "Other: Specify"

	label variable herd_related "Are you related to your herders?"
	note herd_related: "Are you related to your herders?"
	label define herd_related 1 "Yes" 0 "No"
	label values herd_related herd_related

	label variable herd_gear "In the past 12 months, have you provided any of the following items for a herder"
	note herd_gear: "In the past 12 months, have you provided any of the following items for a herder?"

	label variable herd_gear_other "Other: Specify"
	note herd_gear_other: "Other: Specify"

	label variable herd_paygroup "Do you pay your herders individually, or do you pay your herders with managers f"
	note herd_paygroup: "Do you pay your herders individually, or do you pay your herders with managers from other kraals?"

	label variable herd_gear_self "In the past 12 months, have you acquired any of the following gear to use when y"
	note herd_gear_self: "In the past 12 months, have you acquired any of the following gear to use when you herd?"

	label variable herd_gear_other_self "Other: Specify"
	note herd_gear_other_self: "Other: Specify"

	label variable herd_intensitydry "During this year’s dry season, after your herders took your cattle to water, did"
	note herd_intensitydry: "During this year’s dry season, after your herders took your cattle to water, did they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensitydry 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensitydry herd_intensitydry

	label variable whynoherd_dry "Why do you just push your animals during the dry season, instead of remaining wi"
	note whynoherd_dry: "Why do you just push your animals during the dry season, instead of remaining with them?"

	label variable herd_intensityrains "During the rainy season at the beginning of this year, after your herders took y"
	note herd_intensityrains: "During the rainy season at the beginning of this year, after your herders took your cattle to water, did they typically push the cattle out and leave them to graze, remain with them for part of the day, or remain with them throughout the whole day?"
	label define herd_intensityrains 1 "Push the animals out and leave them" 2 "Remain with the animals throughout part of the day" 3 "Remain with the animals throughout the whole day" -99 "Don't know"
	label values herd_intensityrains herd_intensityrains

	label variable whynoherd_rains "Why do you just push your animals during the rainy season, instead of remaining "
	note whynoherd_rains: "Why do you just push your animals during the rainy season, instead of remaining with them?"

	label variable herd_typewalk "Which picture best shows the way that your herd walks away from the water point "
	note herd_typewalk: "Which picture best shows the way that your herd walks away from the water point to pasture?"
	label define herd_typewalk 1 "Cattle in a tight bunch" 2 "Cattle in a line" 3 "Cattle scattered" -99 "Don't know"
	label values herd_typewalk herd_typewalk

	label variable herd_typegraze "Which picture best shows the way that your herd is managed when your cattle are "
	note herd_typegraze: "Which picture best shows the way that your herd is managed when your cattle are grazing?"
	label define herd_typegraze 1 "Cattle in a tight bunch" 2 "Cattle scattered" -99 "Don't know"
	label values herd_typegraze herd_typegraze

	label variable herd_animalsmissing "The last time you saw your herd, were any cattle missing?"
	note herd_animalsmissing: "The last time you saw your herd, were any cattle missing?"
	label define herd_animalsmissing 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values herd_animalsmissing herd_animalsmissing

	label variable herd_numbermissing "How many were missing?"
	note herd_numbermissing: "How many were missing?"

	label variable herd_lastsawmissingqty "When was the last time you saw these missing cattle?"
	note herd_lastsawmissingqty: "When was the last time you saw these missing cattle?"

	label variable herd_lastsawmissingunit "Unit"
	note herd_lastsawmissingunit: "Unit"
	label define herd_lastsawmissingunit 1 "days" 2 "weeks" 3 "months"
	label values herd_lastsawmissingunit herd_lastsawmissingunit

	label variable herd_catlost "In the past 12 months, how many of the cattle you manage have been lost, stolen "
	note herd_catlost: "In the past 12 months, how many of the cattle you manage have been lost, stolen or killed by a predator?"

	label variable water_freq "On average, how many times per day do you take your cattle to water?"
	note water_freq: "On average, how many times per day do you take your cattle to water?"
	label define water_freq 1 "Less than once a day" 2 "Once a day" 3 "Sometimes once a day, sometimes twice a day" 4 "Twice a day" 5 "There is a water point at my kraal"
	label values water_freq water_freq

	label variable water_quant "In the last three years, has the quantity of water you have access to increased,"
	note water_quant: "In the last three years, has the quantity of water you have access to increased, decreased, or stayed the same?"
	label define water_quant 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_quant water_quant

	label variable water_qual "In the last three years, has the quality of water you have access to gotten bett"
	note water_qual: "In the last three years, has the quality of water you have access to gotten better, worse, or stayed the same?"
	label define water_qual 1 "Gotten better" 2 "Stayed the same" 3 "Gotten worse" -99 "Don't know"
	label values water_qual water_qual

	label variable water_dist "In the last three years, has the distance you normally travel to get water incre"
	note water_dist: "In the last three years, has the distance you normally travel to get water increased, decreased, or stayed the same?"
	label define water_dist 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values water_dist water_dist

	label variable water_animals "In the last three years, has the number of animals that use the water point you "
	note water_animals: "In the last three years, has the number of animals that use the water point you normally go to increased significantly, decreased significantly, or stayed about the same?"
	label define water_animals 1 "Increased significantly" 2 "Decreased significantly" 3 "Stayed about the same" -99 "Don't know"
	label values water_animals water_animals

	label variable water_barriers "Are there now barriers to your access to water that did not exist three years ag"
	note water_barriers: "Are there now barriers to your access to water that did not exist three years ago? For example, do you now have to pay for water use (apart from payments for diesel), or have you lost access to a particular water point?"
	label define water_barriers 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values water_barriers water_barriers

	label variable lsmgmt_dvs "In the past 12 months, did the government vaccinate your cattle?"
	note lsmgmt_dvs: "In the past 12 months, did the government vaccinate your cattle?"
	label define lsmgmt_dvs 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_dvs lsmgmt_dvs

	label variable lsmgmt_othvacyn "Did you vaccinate your cattle for any diseases apart from the vaccinations provi"
	note lsmgmt_othvacyn: "Did you vaccinate your cattle for any diseases apart from the vaccinations provided by the government?"
	label define lsmgmt_othvacyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_othvacyn lsmgmt_othvacyn

	label variable lsmgmt_othvac "Against which diseases did you vaccinate them?"
	note lsmgmt_othvac: "Against which diseases did you vaccinate them?"

	label variable lsmgmt_othvac_other "ENUMERATOR: Record any other vaccines the enumerator mentions"
	note lsmgmt_othvac_other: "ENUMERATOR: Record any other vaccines the enumerator mentions"

	label variable lsmgmt_howmanyvac "Did you vaccinate all of your cattle, or just some of them?"
	note lsmgmt_howmanyvac: "Did you vaccinate all of your cattle, or just some of them?"
	label define lsmgmt_howmanyvac 1 "All of the animals" 2 "Only one, or some of them"
	label values lsmgmt_howmanyvac lsmgmt_howmanyvac

	label variable lsmgmt_whyvac "Why did you vaccinate this/these cattle?"
	note lsmgmt_whyvac: "Why did you vaccinate this/these cattle?"

	label variable lsmgmt_pay "Did the famers owning cattle in this kraal pay for vaccinations with farmers own"
	note lsmgmt_pay: "Did the famers owning cattle in this kraal pay for vaccinations with farmers owning cattle in other kraals?"

	label variable lsmgmt_deworm "In the past 12 months, have you dewormed your cattle?"
	note lsmgmt_deworm: "In the past 12 months, have you dewormed your cattle?"
	label define lsmgmt_deworm 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values lsmgmt_deworm lsmgmt_deworm

	label variable lsmgmt_supplement "In the past 12 months, what supplements, if any, have you provided to your cattl"
	note lsmgmt_supplement: "In the past 12 months, what supplements, if any, have you provided to your cattle?"

	label variable lsmgmt_supplement_other "Other: Specify"
	note lsmgmt_supplement_other: "Other: Specify"

	label variable lsmgmt_ticfreq "How often are your cattle checked for ticks?"
	note lsmgmt_ticfreq: "How often are your cattle checked for ticks?"
	label define lsmgmt_ticfreq 1 "Once a week or more frequently" 2 "Every 8 days to every 30 days" 3 "Less than once every 30 days" 4 "Never" 5 "Never, but cattle in my area never get ticks" -99 "Don't know"
	label values lsmgmt_ticfreq lsmgmt_ticfreq

	label variable lsmgmt_locexpertsick "When you have questions about your cattle when they are sick, including diagnosi"
	note lsmgmt_locexpertsick: "When you have questions about your cattle when they are sick, including diagnosing illnesses or purchasing medicines is there someone in your community that you can ask?"
	label define lsmgmt_locexpertsick 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertsick lsmgmt_locexpertsick

	label variable lsmgmt_locexpertmgmt "When you have general questions about your cattle, including inseminating cows a"
	note lsmgmt_locexpertmgmt: "When you have general questions about your cattle, including inseminating cows and herding, is there someone in your community that you can ask?"
	label define lsmgmt_locexpertmgmt 1 "No" 2 "Yes, I am able to answer those questions myself" 3 "Yes, DVS/DEES" 4 "Yes, someone else in my community" -99 "Don't know"
	label values lsmgmt_locexpertmgmt lsmgmt_locexpertmgmt

	label variable lsmgmt_bullcow "What do you think is the ideal bull to cow ratio?"
	note lsmgmt_bullcow: "What do you think is the ideal bull to cow ratio?"

	label variable comprehend_lsmgmt "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_lsmgmt: "ENUMERATOR: How well do you think the respondent understood these questions about livestock management, and do you trust their responses?"
	label define comprehend_lsmgmt 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_lsmgmt comprehend_lsmgmt

	label variable lsoff_numsold "How many live cattle have you sold in the past 12 months?"
	note lsoff_numsold: "How many live cattle have you sold in the past 12 months?"

	label variable lsoff_valsold "How much money did you receive for these cattle?"
	note lsoff_valsold: "How much money did you receive for these cattle?"

	label variable lsoff_valsoldunits "In total or average"
	note lsoff_valsoldunits: "In total or average"
	label define lsoff_valsoldunits 1 "In total" 2 "Per animal"
	label values lsoff_valsoldunits lsoff_valsoldunits

	label variable lsoff_buyers "To whom have you sold cattle in the past 12 months?"
	note lsoff_buyers: "To whom have you sold cattle in the past 12 months?"

	label variable lsoff_buyers_other "Other: Specify"
	note lsoff_buyers_other: "Other: Specify"

	label variable lsoff_numslaughtfest "In the past 12 months, how many cattle have you slaughtered or gifted for weddin"
	note lsoff_numslaughtfest: "In the past 12 months, how many cattle have you slaughtered or gifted for weddings or funerals?"

	label variable lsoff_numgift "In the past 12 months, how many cattle have you lent or gifted to another househ"
	note lsoff_numgift: "In the past 12 months, how many cattle have you lent or gifted to another household for reasons apart from weddings and funerals?"

	label variable lsoff_numslaughtsale "In the past 12 months, how many cattle have you slaughtered and sold? Do not inc"
	note lsoff_numslaughtsale: "In the past 12 months, how many cattle have you slaughtered and sold? Do not include animals slaughtered and sold for weddings and funerals"

	label variable lsoff_valslaughter "How much did you receive for the cattle you slaughtered and sold?"
	note lsoff_valslaughter: "How much did you receive for the cattle you slaughtered and sold?"

	label variable lsoff_valslaughtunits "In total or average"
	note lsoff_valslaughtunits: "In total or average"
	label define lsoff_valslaughtunits 1 "In total" 2 "Per animal"
	label values lsoff_valslaughtunits lsoff_valslaughtunits

	label variable lsoff_salereasons "For what reasons have you sold cattle in the past 12 months? Check all that appl"
	note lsoff_salereasons: "For what reasons have you sold cattle in the past 12 months? Check all that apply"

	label variable lsoff_salereasons_other "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those "
	note lsoff_salereasons_other: "ENUMERATOR: Record any other reasons that the farmer mentioned apart from those in the list"

	label variable lsoff_animalreasons "When you last decided to sell cattle, how did you decide which cattle to sell?"
	note lsoff_animalreasons: "When you last decided to sell cattle, how did you decide which cattle to sell?"

	label variable lsoff_animalreason_other "Other: Specify"
	note lsoff_animalreason_other: "Other: Specify"

	label variable lsoff_restructure "What kind of herd restructuring did you participate in?"
	note lsoff_restructure: "What kind of herd restructuring did you participate in?"

	label variable lsoff_restructure_other "Other: Specify"
	note lsoff_restructure_other: "Other: Specify"

	label variable comm_wat_yesno "Are you a part of group that makes decisions about how the group manages water? "
	note comm_wat_yesno: "Are you a part of group that makes decisions about how the group manages water? This can include a group of people that decides how to pay for repairs when a borehole/well breaks down"
	label define comm_wat_yesno 1 "Yes" 0 "No"
	label values comm_wat_yesno comm_wat_yesno

	label variable comm_wat_mtgno "In the past 12 months, how many meetings did you attend for this water group?"
	note comm_wat_mtgno: "In the past 12 months, how many meetings did you attend for this water group?"

	label variable comm_wat_mtgunit "Units"
	note comm_wat_mtgunit: "Units"
	label define comm_wat_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_wat_mtgunit comm_wat_mtgunit

	label variable comm_wat_finyn "In the past 12 months, have you contributed financially to this water group?"
	note comm_wat_finyn: "In the past 12 months, have you contributed financially to this water group?"
	label define comm_wat_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_wat_finyn comm_wat_finyn

	label variable comm_graze_yesno "Are you a part of group that makes decisions about how the group manages cattle "
	note comm_graze_yesno: "Are you a part of group that makes decisions about how the group manages cattle and grazing?"
	label define comm_graze_yesno 1 "Yes" 0 "No"
	label values comm_graze_yesno comm_graze_yesno

	label variable comm_graze_mtgno "In the past 12 months, how many grazing meetings did you attend?"
	note comm_graze_mtgno: "In the past 12 months, how many grazing meetings did you attend?"

	label variable comm_graze_mtgunit "Units"
	note comm_graze_mtgunit: "Units"
	label define comm_graze_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_graze_mtgunit comm_graze_mtgunit

	label variable comm_graze_finyn "In the past 12 months, have you contributed financially to a grazing group?"
	note comm_graze_finyn: "In the past 12 months, have you contributed financially to a grazing group?"
	label define comm_graze_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_graze_finyn comm_graze_finyn

	label variable comm_new_yesno "Are you a part of a group that makes a decision when someone new wants to enter "
	note comm_new_yesno: "Are you a part of a group that makes a decision when someone new wants to enter the community?"
	label define comm_new_yesno 1 "Yes" 0 "No"
	label values comm_new_yesno comm_new_yesno

	label variable comm_new_mtgno "In the past 12 months, how many of these meetings did you attend?"
	note comm_new_mtgno: "In the past 12 months, how many of these meetings did you attend?"

	label variable comm_new_mtgunit "Units"
	note comm_new_mtgunit: "Units"
	label define comm_new_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_new_mtgunit comm_new_mtgunit

	label variable comm_devt_yesno "Are you currently a part of a group that makes general development decisions in "
	note comm_devt_yesno: "Are you currently a part of a group that makes general development decisions in your community, for example about local projects?"
	label define comm_devt_yesno 1 "Yes" 0 "No"
	label values comm_devt_yesno comm_devt_yesno

	label variable comm_devt_desc "What is the name of this organization?"
	note comm_devt_desc: "What is the name of this organization?"

	label variable comm_devt_mtgno "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"
	note comm_devt_mtgno: "In the past 12 months, how many \${comm_devt_desc} meetings did you attend?"

	label variable comm_devt_mtgunit "Units"
	note comm_devt_mtgunit: "Units"
	label define comm_devt_mtgunit 1 "Total times" 2 "Monthly" 3 "Weekly or near weekly"
	label values comm_devt_mtgunit comm_devt_mtgunit

	label variable comm_devt_finyn "In the past 12 months, have you contributed financially to a general development"
	note comm_devt_finyn: "In the past 12 months, have you contributed financially to a general development group?"
	label define comm_devt_finyn 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values comm_devt_finyn comm_devt_finyn

	label variable socdyn_mobile "Do you have a mobile phone?"
	note socdyn_mobile: "Do you have a mobile phone?"
	label define socdyn_mobile 1 "Yes" 0 "No"
	label values socdyn_mobile socdyn_mobile

	label variable socdyn_radio "Do you have a radio?"
	note socdyn_radio: "Do you have a radio?"
	label define socdyn_radio 1 "Yes" 0 "No"
	label values socdyn_radio socdyn_radio

	label variable socdyn_watch "Do you have a watch?"
	note socdyn_watch: "Do you have a watch?"
	label define socdyn_watch 1 "Yes" 0 "No"
	label values socdyn_watch socdyn_watch

	label variable socdyn_mobneivill "'I would lend my cell phone to a person in a neighboring village and let them ou"
	note socdyn_mobneivill: "'I would lend my cell phone to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_mobneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobneivill socdyn_mobneivill

	label variable socdyn_mobfirstime "'I would lend my cell phone to a person I just met for the first time and let th"
	note socdyn_mobfirstime: "'I would lend my cell phone to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_mobfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_mobfirstime socdyn_mobfirstime

	label variable socdyn_radneivill "'I would lend my radio to a person in a neighboring village and let them out of "
	note socdyn_radneivill: "'I would lend my radio to a person in a neighboring village and let them out of my sight to use it.'"
	label define socdyn_radneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radneivill socdyn_radneivill

	label variable socdyn_radfirstime "'I would lend my radio to a person I just met for the first time and let them ou"
	note socdyn_radfirstime: "'I would lend my radio to a person I just met for the first time and let them out of my sight to use it.'"
	label define socdyn_radfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_radfirstime socdyn_radfirstime

	label variable socdyn_watneivill "'I would lend my watch to a person in a neighboring village.'"
	note socdyn_watneivill: "'I would lend my watch to a person in a neighboring village.'"
	label define socdyn_watneivill 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watneivill socdyn_watneivill

	label variable socdyn_watfirstime "'I would lend my watch to a person I just met for the first time'"
	note socdyn_watfirstime: "'I would lend my watch to a person I just met for the first time'"
	label define socdyn_watfirstime 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_watfirstime socdyn_watfirstime

	label variable socdyn_trust "'In general, I believe people can be relied on.'"
	note socdyn_trust: "'In general, I believe people can be relied on.'"
	label define socdyn_trust 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_trust socdyn_trust

	label variable mgr_relation_ta "Are you related to the local TAs or headman?"
	note mgr_relation_ta: "Are you related to the local TAs or headman?"

	label variable owner_relation_ta "Are any of the owners related to the local TAs or headman?"
	note owner_relation_ta: "Are any of the owners related to the local TAs or headman?"

	label variable ta_freq "In the last three weeks, how many times have you spoken with someone on the TA?"
	note ta_freq: "In the last three weeks, how many times have you spoken with someone on the TA?"
	label define ta_freq 1 "Every day" 2 "Most days (more than once a week)" 3 "Once a week" 4 "Between once a week and once a month" 5 "Less than once a month" 0 "Never"
	label values ta_freq ta_freq

	label variable socdyn_ta "'Even though the traditional authority is working hard, sometimes they do not ma"
	note socdyn_ta: "'Even though the traditional authority is working hard, sometimes they do not make the right decisions.'"
	label define socdyn_ta 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_ta socdyn_ta

	label variable socdyn_fence "'If I could build a fence around \${graze_location}, I would.'"
	note socdyn_fence: "'If I could build a fence around \${graze_location}, I would.'"
	label define socdyn_fence 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_fence socdyn_fence

	label variable socdyn_sharegrass "'If a farmer from the next village has no grass in his village, but there is gra"
	note socdyn_sharegrass: "'If a farmer from the next village has no grass in his village, but there is grass in \${graze_location}, I believe that farmer should be welcomed at \${graze_location}.'"
	label define socdyn_sharegrass 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_sharegrass socdyn_sharegrass

	label variable socdyn_toomanyothers "'The headman and other elders in \${graze_location} let too many outsiders bring"
	note socdyn_toomanyothers: "'The headman and other elders in \${graze_location} let too many outsiders bring their cattle to graze in \${graze_location}.'"
	label define socdyn_toomanyothers 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_toomanyothers socdyn_toomanyothers

	label variable socdyn_locusgen "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	note socdyn_locusgen: "'Many of the unhappy things in people's lives are partly due to bad luck.'"
	label define socdyn_locusgen 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusgen socdyn_locusgen

	label variable socdyn_locuscattle "'I feel as though my actions personally affect the health and value of my cattle"
	note socdyn_locuscattle: "'I feel as though my actions personally affect the health and value of my cattle.'"
	label define socdyn_locuscattle 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locuscattle socdyn_locuscattle

	label variable socdyn_locusrange "'I can personally affect the quality of the rangeland and grass in my community'"
	note socdyn_locusrange: "'I can personally affect the quality of the rangeland and grass in my community'"
	label define socdyn_locusrange 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" -99 "Don't know" -88 "Refuses to say"
	label values socdyn_locusrange socdyn_locusrange

	label variable socdyn_inctrust "In the last three years, has the number of people you trust increased, decreased"
	note socdyn_inctrust: "In the last three years, has the number of people you trust increased, decreased, or stayed the same?"
	label define socdyn_inctrust 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_inctrust socdyn_inctrust

	label variable socdyn_incconf "In the last three years, has the number of people you have conflict with increas"
	note socdyn_incconf: "In the last three years, has the number of people you have conflict with increased, decreased, or stayed the same?"
	label define socdyn_incconf 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values socdyn_incconf socdyn_incconf

	label variable num_auctions "In the last three years, has the number of auctions near you increased, decrease"
	note num_auctions: "In the last three years, has the number of auctions near you increased, decreased, or stayed the same?"
	label define num_auctions 1 "Increased" 2 "Decreased" 3 "Stayed the same" -99 "Don't know"
	label values num_auctions num_auctions

	label variable gopa_knows "Have you heard of the GOPA project?"
	note gopa_knows: "Have you heard of the GOPA project?"
	label define gopa_knows 1 "Yes" 0 "No"
	label values gopa_knows gopa_knows

	label variable gopa_farmer "Were you a participant in the GOPA project?"
	note gopa_farmer: "Were you a participant in the GOPA project?"
	label define gopa_farmer 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_farmer gopa_farmer

	label variable gopa_offered "Were you offered the chance to participate in the GOPA project?"
	note gopa_offered: "Were you offered the chance to participate in the GOPA project?"
	label define gopa_offered 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values gopa_offered gopa_offered

	label variable fup_combine_place "At what water point do your cattle currently take water?"
	note fup_combine_place: "At what water point do your cattle currently take water?"

	label variable fup_combine_hrs "At what time do you take your cattle to water? HOURS"
	note fup_combine_hrs: "At what time do you take your cattle to water? HOURS"

	label variable fup_combine_mins "At what time do you take your cattle to water? MINS"
	note fup_combine_mins: "At what time do you take your cattle to water? MINS"

	label variable fup_name_wpsec "What is the name of the person who takes minutes for the water point committee, "
	note fup_name_wpsec: "What is the name of the person who takes minutes for the water point committee, if anyone does?"

	label variable fup_name_grsec "What is the name of the person who takes minutes for your grazing group, if anyo"
	note fup_name_grsec: "What is the name of the person who takes minutes for your grazing group, if anyone does?"

	label variable fup_name_othsec "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyo"
	note fup_name_othsec: "What is the name of the person who takes minutes for \${comm_devt_desc}, if anyone does?"

	label variable comments "ENUMERATOR: Please offer any comments you have about the survey here (optional)"
	note comments: "ENUMERATOR: Please offer any comments you have about the survey here (optional)"

	label variable datetime_end "Enter date and time"
	note datetime_end: "Enter date and time"

	* append old, previously-imported data (if any) 6
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 6
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}

if "`c(username)'"=="pierre-yves" {
	drop date_beginning datetime_end
	merge 1:1 key using `datetime'
	gen space = substr(date_beginning, 2, 1)==" "
	gen day = substr(date_beginning, 1,1) if space==1
	replace day=substr(date_beginning, 1, 2) if space==0
	gen month_str=substr(date_beginning, 4, 3) if space==0
	replace month_str=substr(date_beginning, 3, 3) if space==1
	gen month=.
	replace month=10 if month_str=="oct"
	replace month=11 if month_str=="nov"
	replace month=12 if month_str=="dec"
	gen time_beginning = substr(date_beginning, 13, 8) if space==0
	replace time_beginning = substr(date_beginning, 12, 8) if space==1
	gen space_end = substr(datetime_end, 2, 1)==" "
	gen time_end = substr(datetime_end, 13, 8) if space==0
	replace time_end = substr(datetime_end, 12, 8) if space==1
	gen double clock_begin = clock(time_beginning, "hms")
	gen double clock_end = clock(time_end, "hms")
	gen svy_length = (clock_end - clock_begin)/60000
	drop month_str
	destring day, replace
}

#delimit ; 

**  Generate a variable to indicate the version of the survey ;
gen v = 6 ;
save `v6', replace ;


********************************************************************************************************** ;
********************************************************************************************************** ;
**  STEP 3: PREPARE FOR ADDITION OF REDO DATA  															** ;
********************************************************************************************************** ;
********************************************************************************************************** ;

********************************************************************************************************** ;
**  STEP 3A: Append dtafiles created by SurveyCTO Client  												** ;
********************************************************************************************************** ;

use `v1', clear ;
append using `v2', force ;
append using `v3', force ;
append using `v5', force ;
append using `v6', force ;
append using `v17', force ;

destring farmer_id ga_id, replace ;


********************************************************************************************************** ;
**  STEP 3B: Create farmer unique_id to merge the data set with the redo 								** ;
********************************************************************************************************** ;

tempvar farms id_s id_n ;
tostring farmer_id, gen(`farms') ;

**  Quick clean: Add the number for Justencia's early surveys ;
gen `id_s' = substr(`farms', 6, 1) if v == 17 ;
destring `id_s', gen(`id_n') ;
replace farmer_number = `id_n' if v == 17 ;

duplicates tag ga_id farmer_number, gen(ident_dup) ;
*bysort ga_id farmer_number: gen rank = _n ; // Dylan, I think this is problematic. You need to use parentheticals in this command (e.g., bysort ga_id farmer_number (key): gen rank = _n) otherwise different observations will get different values for "rank" each time you run it.
bysort ga_id farmer_number (key): gen rank = _n ;
isid ga_id farmer_number rank ;

tostring ga_id, gen(ga_id_string) ;
label variable ga_id_string "Name of Grazing Area (string)" ;
tostring farmer_number, gen(farmer_number_string) ;
label variable farmer_number_string "Number of manager on listing form (string)" ;
tostring rank, gen(rank_string) ;
gen unique_id = ga_id_string + farmer_number_string + rank_string ;

drop __00* ident_dup rank ;

save "$stata\dtafiles\behavioral\MCC-Nam_CBRLM_B1_`date_b1_data'.dta", replace ;

********************************************************************************************************** ;
********************************************************************************************************** ;
**  STEP 4: ADD IN REDO DATA, I.E., RESPONDENTS WE CAME BACK TO, PARTICULARLY FOR PLANNED GRAZING INFO  ** ;
********************************************************************************************************** ;
********************************************************************************************************** ;

********************************************************************************************************** ; 
**  STEP 4A: Imports and aggregates "FINAL_Behavioral_redo_v4" (ID: FINAL_Behavioral_redo_v4) data. 	** ;
********************************************************************************************************** ;

#delimit cr

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v4.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL_Behavioral_redo_v4.dta"
local corrfile "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v4_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum ga_id ga_id_other unique_id kraal_other mgr_firstname_pl mgr_surname_pl grazeplandry_grazesherd_pl grazeplanrain_grazesherd_pl new_resp_name"
local text_fields2 "grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months grazeplanrain_writtenshare_oth grazeplan_otherlocfreq"
local date_fields1 ""
local datetime_fields1 "starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "C:/Users/pierre-yves/Documents/Namibia_project/FINAL_Behavioral_redo_v4-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
		
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 7
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	if "`text_fields1'" ~= "" {
		foreach svarlistx in `text_fields1' {
			foreach stringvar of varlist `svarlistx' {
				quietly: replace `ismissingvar'=.
				quietly: cap replace `ismissingvar'=1 if `stringvar'==.
				cap tostring `stringvar', format(%100.0g) replace
				cap replace `stringvar'="" if `ismissingvar'==1
			}
		}
	}
	if "`text_fields2'" ~= "" {
		foreach svarlistx in `text_fields2' {
			foreach stringvar of varlist `svarlistx' {
				quietly: replace `ismissingvar'=.
				quietly: cap replace `ismissingvar'=1 if `stringvar'==.
				cap tostring `stringvar', format(%100.0g) replace
				cap replace `stringvar'="" if `ismissingvar'==1
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable ga_id "Please select the name of the GA the respondent belongs to?"
	note ga_id: "Please select the name of the GA the respondent belongs to?"

	label variable ga_id_other "Please enter the name of the GA the respondent belongs to?"
	note ga_id_other: "Please enter the name of the GA the respondent belongs to?"

	label variable unique_id "Please select the kraal number of the respondent in this GA."
	note unique_id: "Please select the kraal number of the respondent in this GA."

	label variable kraal_other "Please enter the name of the GA the respondent belongs to?"
	note kraal_other: "Please enter the name of the GA the respondent belongs to?"

	label variable correct_respondent "You are now talking with \${mgr_firstname_pl}_\${mgr_surname_pl}. Is this correc"
	note correct_respondent: "You are now talking with \${mgr_firstname_pl}_\${mgr_surname_pl}. Is this correct?"
	label define correct_respondent 1 "Yes" 0 "No"
	label values correct_respondent correct_respondent

	label variable confirm_resp "Can you confirm you are talking with someone related to the kraal of \${mgr_firs"
	note confirm_resp: "Can you confirm you are talking with someone related to the kraal of \${mgr_firstname_pl}_\${mgr_surname_pl}"
	label define confirm_resp 1 "Yes" 0 "No"
	label values confirm_resp confirm_resp

	label variable new_resp_name "What is the name of the new respondent?"
	note new_resp_name: "What is the name of the new respondent?"

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${ga_id} d"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${ga_id} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${ga_id} d"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${ga_id} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${ga_id} at any point?"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${ga_id} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${ga_id}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${ga_id}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_grazeplan comprehend_grazeplan

	* append old, previously-imported data (if any) 7
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 7
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}

#delimit ;

**  Quick cleaning ;
drop if key == "uuid:08a6f00d-dbba-4d07-9495-d141f22c316c" ; //  Test survey done by Pierre

**  Generate a variable to indicate the version of the survey ;
gen v = 4 ;
save `vredo4', replace ;


********************************************************************************************************** ; 
**  STEP 4B: Imports and aggregates "FINAL_Behavioral_redo_v5" (ID: FINAL_Behavioral_redo_v5) data.		** ;
********************************************************************************************************** ;

#delimit cr

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v5.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL_Behavioral_redo_v5.dta"
local corrfile "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v5_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum ga_id ga_id_other unique_id kraal_other mgr_firstname_pl mgr_surname_pl grazeplandry_grazesherd_pl grazeplanrain_grazesherd_pl new_resp_name"
local text_fields2 "grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months grazeplanrain_writtenshare_oth grazeplan_otherlocfreq"
local date_fields1 ""
local datetime_fields1 "starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v5-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
		
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 8
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	if "`text_fields1'" ~= "" {
		foreach svarlist in `text_fields1' {
			foreach stringvar of varlist `svarlist' {
				quietly: replace `ismissingvar'=.
				quietly: cap replace `ismissingvar'=1 if `stringvar'==.
				cap tostring `stringvar', format(%100.0g) replace
				cap replace `stringvar'="" if `ismissingvar'==1
			}
		}
	}
	if "`text_fields2'" ~= "" {
		foreach svarlist in `text_fields2' {
			foreach stringvar of varlist `svarlist' {
				quietly: replace `ismissingvar'=.
				quietly: cap replace `ismissingvar'=1 if `stringvar'==.
				cap tostring `stringvar', format(%100.0g) replace
				cap replace `stringvar'="" if `ismissingvar'==1
			}
		}
	}
	quietly: drop `ismissingvar'

	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable ga_id "Please select the name of the GA the respondent belongs to?"
	note ga_id: "Please select the name of the GA the respondent belongs to?"

	label variable ga_id_other "Please enter the name of the GA the respondent belongs to?"
	note ga_id_other: "Please enter the name of the GA the respondent belongs to?"

	label variable unique_id "Please select the kraal number of the respondent in this GA."
	note unique_id: "Please select the kraal number of the respondent in this GA."

	label variable kraal_other "Please enter the number of the kraam the respondent belongs to?"
	note kraal_other: "Please enter the number of the kraam the respondent belongs to?"

	label variable correct_respondent "You are now talking with \${mgr_firstname_pl}_\${mgr_surname_pl}. Is this correc"
	note correct_respondent: "You are now talking with \${mgr_firstname_pl}_\${mgr_surname_pl}. Is this correct?"
	label define correct_respondent 1 "Yes" 0 "No"
	label values correct_respondent correct_respondent

	label variable confirm_resp "Can you confirm you are talking with someone related to the kraal of \${mgr_firs"
	note confirm_resp: "Can you confirm you are talking with someone related to the kraal of \${mgr_firstname_pl}_\${mgr_surname_pl}"
	label define confirm_resp 1 "Yes" 0 "No"
	label values confirm_resp confirm_resp

	label variable new_resp_name "What is the name of the new respondent?"
	note new_resp_name: "What is the name of the new respondent?"

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${ga_id} d"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${ga_id} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${ga_id} d"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${ga_id} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${ga_id} at any point?"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${ga_id} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${ga_id}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${ga_id}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_grazeplan comprehend_grazeplan

	* append old, previously-imported data (if any) 8
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 8
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}

#delimit ;

** Quick cleaning ;
drop if key == "uuid:08a6f00d-dbba-4d07-9495-d141f22c316c" ; // Test survey done by Pierre

**  Generate a variable to indicate the version of the survey ;
generate v = 5 ;
save `vredo5', replace ;


********************************************************************************************************** ; 
**  STEP 4C: Imports and aggregates "FINAL_behavioral_redo_v7" (ID: FINAL_behavioral_redo_v7) data.		** ;
********************************************************************************************************** ;

#delimit cr

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v7.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL_Behavioral_redo_v7.dta"
local corrfile "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v7_corrections.csv"
local repeat_groups_csv1 "grp_resp_absent-repeat_absent"
local repeat_groups_stata1 "repeat_absent"
local repeat_groups_short_stata1 "repeat_absent"
local note_fields1 "informed_consent repeat_absent_count"
local text_fields1 "deviceid subscriberid simid devicephonenum region enum_id ga_id ga_id_other unique_id kraal_other mgr_firstname_pl mgr_surname_pl grazeplandry_grazesherd_pl grazeplanrain_grazesherd_pl new_resp_name"
local text_fields2 "grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months grazeplanrain_writtenshare_oth grazeplan_otherlocfreq unique_id_absent* kraal_other2* comment*"
local date_fields1 ""
local datetime_fields1 "starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\FINAL_behavioral_redo_v7-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
	
	* drop note fields (since they don't contain any real data) 9
	if "`note_fields1'" ~= "" {
		drop `note_fields1'
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 9
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	if "`text_fields1'" ~= "" {
		foreach svarlist in `text_fields1' {
			foreach stringvar of varlist `svarlist' {
				quietly: replace `ismissingvar'=.
				quietly: cap replace `ismissingvar'=1 if `stringvar'==.
				cap tostring `stringvar', format(%100.0g) replace
				cap replace `stringvar'="" if `ismissingvar'==1
			}
		}
	}
	if "`text_fields2'" ~= "" {
		foreach svarlist in `text_fields2' {
			foreach stringvar of varlist `svarlist' {
				quietly: replace `ismissingvar'=.
				quietly: cap replace `ismissingvar'=1 if `stringvar'==.
				cap tostring `stringvar', format(%100.0g) replace
				cap replace `stringvar'="" if `ismissingvar'==1
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"


	label variable region "What regional team are you a part of?"
	note region: "What regional team are you a part of?"

	label variable enum_id "ENUMERATOR: What is your name?"
	note enum_id: "ENUMERATOR: What is your name?"

	label variable resp_present "Are you doing a survey with the respondent or is it a case where you cannot find"
	note resp_present: "Are you doing a survey with the respondent or is it a case where you cannot find the respondent?"
	label define resp_present 0 "absent" 1 "cannot find the respondent"
	label values resp_present resp_present

	label variable ga_id "Please select the name of the GA the respondent belongs to"
	note ga_id: "Please select the name of the GA the respondent belongs to"

	label variable ga_id_other "Please enter the name of the GA the respondent belongs to"
	note ga_id_other: "Please enter the name of the GA the respondent belongs to"

	label variable unique_id "Please select the kraal number of the respondent in this GA."
	note unique_id: "Please select the kraal number of the respondent in this GA."

	label variable kraal_other "Please enter the number of the kraal the respondent belongs to"
	note kraal_other: "Please enter the number of the kraal the respondent belongs to"

	label variable correct_respondent "You are now talking with \${mgr_firstname_pl}_\${mgr_surname_pl}. Is this correc"
	note correct_respondent: "You are now talking with \${mgr_firstname_pl}_\${mgr_surname_pl}. Is this correct?"
	label define correct_respondent 1 "Yes" 0 "No"
	label values correct_respondent correct_respondent

	label variable confirm_resp "Can you confirm you are talking with someone related to the kraal of \${mgr_firs"
	note confirm_resp: "Can you confirm you are talking with someone related to the kraal of \${mgr_firstname_pl}_\${mgr_surname_pl}"
	label define confirm_resp 1 "Yes" 0 "No"
	label values confirm_resp confirm_resp

	label variable new_resp_name "What is the name of the new respondent?"
	note new_resp_name: "What is the name of the new respondent?"

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${ga_id} d"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${ga_id} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${ga_id} d"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${ga_id} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${ga_id} at any point?"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${ga_id} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${ga_id}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${ga_id}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_grazeplan comprehend_grazeplan

	label variable nb_absent "How many respondents are missing in this GA?"
	note nb_absent: "How many respondents are missing in this GA?"

	capture {
		foreach rgvar of varlist unique_id_absent* {
			label variable `rgvar' "Please select the kraal number of the respondent in this GA."
			note `rgvar': "Please select the kraal number of the respondent in this GA."
		}
	}

	capture {
		foreach rgvar of varlist kraal_other2* {
			label variable `rgvar' "Please enter the number of the kraal the respondent belongs to"
			note `rgvar': "Please enter the number of the kraal the respondent belongs to"
		}
	}

	capture {
		foreach rgvar of varlist comment* {
			label variable `rgvar' "Please comment why you could not find the respondent"
			note `rgvar': "Please comment why you could not find the respondent"
		}
	}

	* append old, previously-imported data (if any) 9
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 9
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}

#delimit ;

** Quick cleaning ;
drop if key == "uuid:08a6f00d-dbba-4d07-9495-d141f22c316c" ; // Test survey done by Pierre

**  Generate a variable to indicate the version of the survey ;
generate v = 7 ;
save `vredo7', replace ;


********************************************************************************************************** ; 
**  STEP 4D: Imports and aggregates "FINAL_behavioral_redo_v8" (ID: FINAL_behavioral_redo_v8) data.		** ;
********************************************************************************************************** ;

#delimit cr

* initialize Stata
clear all
set more off
set mem 100m

* initialize form-specific parameters
local csvfile "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v8.csv"
local dtafile "$stata\dtafiles\behavioral\cto_dtafiles\MCC-Nam_CBRLM_FINAL_Behavioral_redo_v8.dta"
local corrfile "$stata\rawdata\behavioral\FINAL_Behavioral_redo_v8_corrections.csv"
local repeat_groups_csv1 ""
local repeat_groups_stata1 ""
local repeat_groups_short_stata1 ""
local note_fields1 "informed_consent"
local text_fields1 "deviceid subscriberid simid devicephonenum region enum_id ga_id ga_id_other unique_id kraal_other mgr_firstname_pl mgr_surname_pl grazeplandry_grazesherd_pl grazeplanrain_grazesherd_pl new_resp_name"
local text_fields2 "grazeplandry_months grazeplandry_writtenshare_oth grazeplanrain_months grazeplanrain_writtenshare_oth grazeplan_otherlocfreq kraal_other2 comment"
local date_fields1 ""
local datetime_fields1 "starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* continue only if there's at least one row of data to import
if _N>0 {
	* merge in any data from repeat groups (which get saved into additional .csv files)
	forvalues i = 1/100 {
		if "`repeat_groups_csv`i''" ~= "" {
			foreach repeatgroup in `repeat_groups_csv`i'' {
				* save primary data in memory
				preserve
				
				* load data for repeat group
				insheet using "$stata\rawdata\behavioral\FINAL_behavioral_redo_v8-`repeatgroup'.csv", names clear
		
				* drop extra repeat-group fields
				forvalues j = 1/100 {
					if "`repeat_groups_short_stata`j''" ~= "" {
						foreach innergroup in `repeat_groups_short_stata`j'' {
							cap drop setof`innergroup'
						}
					}
				}
					
				* if there's data in the group, sort and reshape it
				if _N>0 {
					* sort, number, and prepare for merge
					sort parent_key, stable
					by parent_key: gen rownum=_n
					drop key
					rename parent_key key
					sort key rownum
			
					* reshape the data
					ds key rownum, not
					local allvars "`r(varlist)'"
					reshape wide `allvars', i(key) j(rownum)
				}
				else {
					* otherwise, just fix the key to be a string for merging in the fields
					tostring key, replace
				}
				
				* save to temporary file
				tempfile rgfile
				save "`rgfile'", replace
						
				* restore primary data		
				restore
				
				* merge in repeat-group data
				merge 1:1 key using "`rgfile'", nogen
			}
		}
	}
	
	* drop extra repeat-group fields (if any)
	forvalues j = 1/100 {
		if "`repeat_groups_stata`j''" ~= "" {
			foreach repeatgroup in `repeat_groups_stata`j'' {
				drop setof`repeatgroup'
			}
		}
	}
	
	* drop note fields (since they don't contain any real data) 10
	if "`note_fields1'" ~= "" {
		drop `note_fields1'
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
					* automatically try without seconds, just in case
					cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
					format %tc `dtvar'
					drop `tempdtvar'
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				foreach dtvar of varlist `dtvarlist' {
					tempvar tempdtvar
					rename `dtvar' `tempdtvar'
					gen double `dtvar'=.
					cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
					format %td `dtvar'
					drop `tempdtvar'
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish) 10
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	if "`text_fields1'" ~= "" {
		foreach svarlist in `text_fields1' {
			foreach stringvar of varlist `svarlist' {
				quietly: replace `ismissingvar'=.
				quietly: cap replace `ismissingvar'=1 if `stringvar'==.
				cap tostring `stringvar', format(%100.0g) replace
				cap replace `stringvar'="" if `ismissingvar'==1
			}
		}
	}
	if "`text_fields2'" ~= "" {
		foreach svarlist in `text_fields2' {
			foreach stringvar of varlist `svarlist' {
				quietly: replace `ismissingvar'=.
				quietly: cap replace `ismissingvar'=1 if `stringvar'==.
				cap tostring `stringvar', format(%100.0g) replace
				cap replace `stringvar'="" if `ismissingvar'==1
			}
		}
	}
	quietly: drop `ismissingvar'

	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid

	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"

	label variable region "What regional team are you a part of?"
	note region: "What regional team are you a part of?"

	label variable enum_id "ENUMERATOR: What is your name?"
	note enum_id: "ENUMERATOR: What is your name?"

	label variable resp_present "Are you doing a survey with the respondent or is it a case where you cannot find"
	note resp_present: "Are you doing a survey with the respondent or is it a case where you cannot find the respondent?"
	label define resp_present 0 "absent" 1 "interview with the respondent"
	label values resp_present resp_present

	label variable ga_id "Please select the name of the GA the respondent belongs to"
	note ga_id: "Please select the name of the GA the respondent belongs to"

	label variable ga_id_other "Please enter the name of the GA the respondent belongs to"
	note ga_id_other: "Please enter the name of the GA the respondent belongs to"

	label variable unique_id "Please select the kraal number of the respondent in this GA."
	note unique_id: "Please select the kraal number of the respondent in this GA."

	label variable kraal_other "Please enter the number of the kraal the respondent belongs to"
	note kraal_other: "Please enter the number of the kraal the respondent belongs to"

	label variable correct_respondent "You are now talking with \${mgr_firstname_pl}_\${mgr_surname_pl}. Is this correc"
	note correct_respondent: "You are now talking with \${mgr_firstname_pl}_\${mgr_surname_pl}. Is this correct?"
	label define correct_respondent 1 "Yes" 0 "No"
	label values correct_respondent correct_respondent

	label variable confirm_resp "Can you confirm you are talking with someone related to the kraal of \${mgr_firs"
	note confirm_resp: "Can you confirm you are talking with someone related to the kraal of \${mgr_firstname_pl}_\${mgr_surname_pl}"
	label define confirm_resp 1 "Yes" 0 "No"
	label values confirm_resp confirm_resp

	label variable new_resp_name "What is the name of the new respondent?"
	note new_resp_name: "What is the name of the new respondent?"

	label variable grazeplandry_basicplan "Did you have a plan for where you wanted your cattle to graze within \${ga_id} d"
	note grazeplandry_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${ga_id} during this year's dry season?"
	label define grazeplandry_basicplan 1 "Yes" 0 "No"
	label values grazeplandry_basicplan grazeplandry_basicplan

	label variable grazeplandry_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplandry_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplandry_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplandry_grazesherd grazeplandry_grazesherd

	label variable grazeplandry_months "For which months of the dry season did you follow a plan?"
	note grazeplandry_months: "For which months of the dry season did you follow a plan?"

	label variable grazeplandry_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplandry_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplandry_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_freq grazeplandry_freq

	label variable grazeplandry_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplandry_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplandry_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_otherherds grazeplandry_otherherds

	label variable grazeplandry_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplandry_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplandry_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplandry_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplandry_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_groupplan grazeplandry_groupplan

	label variable grazeplandry_numplan "How many farmers agreed upon this plan?"
	note grazeplandry_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplandry_responsible "Was there someone who was personally responsible for making sure the plan is fol"
	note grazeplandry_responsible: "Was there someone who was personally responsible for making sure the plan is followed?"
	label define grazeplandry_responsible 1 "Yes" 0 "No"
	label values grazeplandry_responsible grazeplandry_responsible

	label variable grazeplandry_write "Was this plan written?"
	note grazeplandry_write: "Was this plan written?"
	label define grazeplandry_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplandry_write grazeplandry_write

	label variable grazeplandry_writtenshare "Can we see it?"
	note grazeplandry_writtenshare: "Can we see it?"
	label define grazeplandry_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplandry_writtenshare grazeplandry_writtenshare

	label variable grazeplandry_writtenshare_oth "Other: Specify"
	note grazeplandry_writtenshare_oth: "Other: Specify"

	label variable grazeplanrain_basicplan "Did you have a plan for where you wanted your cattle to graze within \${ga_id} d"
	note grazeplanrain_basicplan: "Did you have a plan for where you wanted your cattle to graze within \${ga_id} during the rainy season from the beginning of this year?"
	label define grazeplanrain_basicplan 1 "Yes" 0 "No"
	label values grazeplanrain_basicplan grazeplanrain_basicplan

	label variable grazeplanrain_grazesherd "When you were following this plan, did you usually push your cattle in the direc"
	note grazeplanrain_grazesherd: "When you were following this plan, did you usually push your cattle in the direction where you wanted them to go, or did you usually herd them to the location where you wanted them to graze?"
	label define grazeplanrain_grazesherd 1 "I push them in the direction I want them to go" 2 "I lead my animals all the way to the location where I want them to graze" 3 "I never followed this plan"
	label values grazeplanrain_grazesherd grazeplanrain_grazesherd

	label variable grazeplanrain_months "For which months of the rainy season did you follow a plan?"
	note grazeplanrain_months: "For which months of the rainy season did you follow a plan?"

	label variable grazeplanrain_freq "In a month when you were following a plan, how often did you adhere to this plan"
	note grazeplanrain_freq: "In a month when you were following a plan, how often did you adhere to this plan?"
	label define grazeplanrain_freq 1 "Almost always" 2 "Most days" 3 "Some days" 4 "Rarely" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_freq grazeplanrain_freq

	label variable grazeplanrain_otherherds "Did other farmers follow the same general plan for where to graze their herds?"
	note grazeplanrain_otherherds: "Did other farmers follow the same general plan for where to graze their herds?"
	label define grazeplanrain_otherherds 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_otherherds grazeplanrain_otherherds

	label variable grazeplanrain_numkraal "How many other kraals followed the same plan for where to graze cattle?"
	note grazeplanrain_numkraal: "How many other kraals followed the same plan for where to graze cattle?"

	label variable grazeplanrain_groupplan "Was this plan for where to graze cattle decided as a group?"
	note grazeplanrain_groupplan: "Was this plan for where to graze cattle decided as a group?"
	label define grazeplanrain_groupplan 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_groupplan grazeplanrain_groupplan

	label variable grazeplanrain_numplan "How many farmers agreed upon this plan?"
	note grazeplanrain_numplan: "How many farmers agreed upon this plan?"

	label variable grazeplanrain_responsible "Was there someone who was personally responsible for making sure the grazing pla"
	note grazeplanrain_responsible: "Was there someone who was personally responsible for making sure the grazing plan was followed?"
	label define grazeplanrain_responsible 1 "Yes" 0 "No"
	label values grazeplanrain_responsible grazeplanrain_responsible

	label variable grazeplanrain_write "Was this plan written?"
	note grazeplanrain_write: "Was this plan written?"
	label define grazeplanrain_write 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplanrain_write grazeplanrain_write

	label variable grazeplanrain_writtenshare "Can we see it?"
	note grazeplanrain_writtenshare: "Can we see it?"
	label define grazeplanrain_writtenshare 1 "Respondent is willing to share the plan" 2 "Respondent says they are not sure where the plan currently is" 3 "Respondent says they are unwilling to share the plan" -77 "Other: specify"
	label values grazeplanrain_writtenshare grazeplanrain_writtenshare

	label variable grazeplanrain_writtenshare_oth "Other: Specify"
	note grazeplanrain_writtenshare_oth: "Other: Specify"

	label variable grazeplan_lastweek "Have you followed a pre-planned grazing schedule at any point in the last 7 days"
	note grazeplan_lastweek: "Have you followed a pre-planned grazing schedule at any point in the last 7 days?"
	label define grazeplan_lastweek 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_lastweek grazeplan_lastweek

	label variable grazeplan_postrains "Do you have a plan for where your cattle will graze after the rainy season?"
	note grazeplan_postrains: "Do you have a plan for where your cattle will graze after the rainy season?"
	label define grazeplan_postrains 1 "Yes" 0 "No" 2 "Yes, but only if the rains are good" -99 "Don't know"
	label values grazeplan_postrains grazeplan_postrains

	label variable grazeplan_postrainshare "Will herds from other kraals also follow this plan?"
	note grazeplan_postrainshare: "Will herds from other kraals also follow this plan?"
	label define grazeplan_postrainshare 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_postrainshare grazeplan_postrainshare

	label variable grazeplan_gafullyear "In the past 12 months, did the entire herd graze outside \${ga_id} at any point?"
	note grazeplan_gafullyear: "In the past 12 months, did the entire herd graze outside \${ga_id} at any point?"
	label define grazeplan_gafullyear 1 "Yes" 0 "No" -99 "Don't know" -88 "Refuses to say"
	label values grazeplan_gafullyear grazeplan_gafullyear

	label variable grazeplan_otherlocfreq "For which seasons did the entire herd graze outside of \${ga_id}?"
	note grazeplan_otherlocfreq: "For which seasons did the entire herd graze outside of \${ga_id}?"

	label variable comprehend_grazeplan "ENUMERATOR: How well do you think the respondent understood these questions abou"
	note comprehend_grazeplan: "ENUMERATOR: How well do you think the respondent understood these questions about planned grazing, and do you trust their responses?"
	label define comprehend_grazeplan 1 "The respondent understood well and I have confidence in their responses" 2 "The respondent understood well, but I'm not sure I believe their responses" 3 "The respondent mostly understood this section, but there were some areas where t" 4 "The respondent did not understand this section at all" 5 "The respondent understood, but for a few questions I am not sure I believe them"
	label values comprehend_grazeplan comprehend_grazeplan

	label variable kraal_other2 "Please enter the number of the kraal the respondent belongs to"
	note kraal_other2: "Please enter the number of the kraal the respondent belongs to"

	label variable comment "Please comment why you could not find the respondent"
	note comment: "Please comment why you could not find the respondent"

	* append old, previously-imported data (if any) 10
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & new_data_row == 1
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes 10
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					gen origvalue=value
					replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					* allow for cases where seconds haven't been specified
					replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
					drop origvalue
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}

#delimit ;

** Quick cleaning ;
drop if key == "uuid:08a6f00d-dbba-4d07-9495-d141f22c316c" ; // Test survey done by Pierre

**  Generate a variable to indicate the version of the survey ;
generate v = 8 ;
save `vredo8', replace ;


********************************************************************************************************** ;
**  STEP 4E: Append redo dtafiles created by SurveyCTO Client  											** ;
********************************************************************************************************** ;

use `vredo4', clear ;
append using `vredo5' ;
append using `vredo7' ;
append using `vredo8' ;

********************************************************************************************************** ;
**  STEP 4F: Prepare Redo For Merge with Main Data  													** ;
********************************************************************************************************** ;

********************************************* 	;
**  Rename Redo-Specific Variables For Merge	;
*********************************************	;

rename new_resp_name 							newres_namere ; 
rename deviceid 								device_idre ;
rename subscriberid 							subsri_idre  ;
rename simid 									sim_idre ;
rename devicephonenum 							device_phonre; 
rename region 									region_namere ;
rename enum_id 									enumer_idre ;
rename resp_present 							rspdnt_prstre; 
rename ga_id 									ga_idre ;
rename ga_id_other 								ga_idotre; 
rename kraal_other 								farmer_stotre; 
rename mgr_firstname_pl 						poomgr_1stnre ;
rename mgr_surname_pl 							poomgr_surnre  ;
rename correct_respondent 						correc_respre ;
rename confirm_resp 							cright_respre ;
rename kraal_other2 							farmer_stmire ;
rename comment 									commen_notfre ;
rename key 										key ;
rename v 										svform_versre ;
rename starttime 								survey_strtre  ;
rename endtime 									survey_endtre ;
rename grazeplandry_grazesherd_pl 				gzplnd_poolre ;
rename grazeplanrain_grazesherd_pl				gzplnr_poolre ;

*********************************************	;
**  Drop Uneeded Variables						;
*********************************************	;
**  NOTE: Explanations for drops in MCC-Nam_CBRLM_Behavioral_Redo Cleaning Notes_2015.07.18	;

drop nb_absent 				;
drop unique_id_absent1 ;
drop kraal_other21 ;
drop comment1 ;
drop unique_id_absent2 ;
drop kraal_other22 ;
drop comment2;
drop unique_id_absent3  ;
drop kraal_other23 ;
drop comment3 ;
drop unique_id_absent4 ;
drop kraal_other24 ;
drop comment4 ;
drop survey_strtre ; 		
drop survey_endtre  ;	
*drop gzplnD_shwplO  ; 	
*drop gzplnR_shwplO  ;	
drop gzplnd_poolre 	;
drop gzplnr_poolre  ;

********************************************* 	;
**  Drop Uneeded Surveys						;
*********************************************	;
**  NOTE: Explanations for drops in MCC-Nam_CBRLM_Behavioral_Redo Cleaning Notes_2015.07.18	;

replace unique_id="4100581" if key== "uuid:26a6dea4-732a-471f-965d-4880b3e5f74c"	;
replace unique_id="2370772" if key== "uuid:850a3646-dc0f-456f-b7b6-78140ab4da69" 	;
replace unique_id="1140262" if key== "uuid:0e9178ea-d511-44c6-9242-7ff50776f0fc"  	;	 
replace unique_id="10304101" if key== "uuid:746dc43f-53f4-4ba1-9d09-90fe6a525ab9" 	;	
replace unique_id="1030461" if key== "uuid:a9b0f7a3-3dae-43cb-8f1e-1437a5887033"	;
replace unique_id="1030721" if key== "uuid:f946df71-f1c1-428e-992f-7c2d0af2d36b" 	;
replace unique_id="1220421" if key== "uuid:a3efff0e-4da2-4f4c-a88c-2d1546823b95" 	;
replace unique_id="41008112" if key== "uuid:cb012e26-e214-471e-83df-926de3c85a93"	;
replace unique_id="2271342" if key== "uuid:1fd51802-07c0-4936-b9ee-ec95caed1f1e" 	;
replace unique_id="2300541" if key== "uuid:c4b9a912-4628-4567-a564-45179e67183c" 	;
replace unique_id="2300531" if key== "uuid:e2b1e0e5-4706-4747-9e84-e6d0a07e86b6" 	;
replace unique_id="23718101" if key== "uuid:d77d06f9-4c7b-4bc7-ac52-13248c77b411" 	;
replace unique_id="11402111" if key== "uuid:4bca5e01-8207-439c-9585-0087729d20ed" 	;
replace unique_id="1140211" if key== "uuid:0e023560-b6e8-4c67-84bc-3b18403e6b8a" 	;
replace unique_id="1140221" if key== "uuid:a10c224e-3fb2-4666-9b83-7828cf921621" 	;									
replace unique_id="1140281" if key== "uuid:bda64fc0-96ac-4cbc-b149-99a477cf5925" 	;
replace unique_id="1140291" if key== "uuid:8c132264-84ff-40f8-9fb5-76b97ebd9d24" 	;
replace unique_id="11402101" if key== "uuid:723fd024-49ee-4c0c-bd61-86e8e0034e9e" 	;
replace unique_id="23806141" if key== "uuid:096e354a-ac9b-4562-a245-ad114929650e" 	;
replace unique_id="23806171" if key== "uuid:c3425ff0-f360-43cc-a31a-b2a1639b17ab" 	;
replace unique_id="23806231" if key== "uuid:ed6754b1-0cb7-4751-a43c-ba4efe46967f" 	;
replace unique_id="23806251" if key== "uuid:c1879915-afd6-4b00-90b4-22e1f0ec2b3f" 	;
replace unique_id="23806421" if key== "uuid:ff21b6ea-6eef-4c9a-9e4d-a0dfaef33222" 	;
replace unique_id="23806531" if key== "uuid:e4b697ac-a12c-43ba-a590-980b621d7f73" 	;
replace unique_id="23806571" if key== "uuid:e78899ec-6df7-4bf3-b276-871f251115de" 	;
replace unique_id="23806581" if key== "uuid:5c6d4850-182e-489b-91ff-c06e6837887d" 	;
replace unique_id="2380741" if key== "uuid:407ac62d-ab60-4198-b9de-5cf2b5fee11f" 	;
replace unique_id="2380761" if key== "uuid:5c4c2bb8-5007-4a85-91f9-7c0c350f4759" 	;
replace unique_id="2380781" if key== "uuid:cbe5bd5a-badc-4803-af14-53365eb75a93" 	;
replace unique_id="2380791" if key== "uuid:7d91f1df-92e7-40b4-9212-0e61e45c032a" 	;
replace unique_id="23807131" if key== "uuid:d420dcbb-1cc8-48f8-8bbc-f6ff47242061" 	;
replace unique_id="23807181" if key== "uuid:36ba9746-5ed6-46d5-8eb1-16f05ba95e4f" 	;
replace unique_id="23807191" if key== "uuid:945fbb63-7ca7-45f1-a10f-d7db522931a8" 	;
replace unique_id="2271361" if key== "uuid:6942966f-49ea-487b-9fa5-c473eabe58b8" 	;
replace unique_id="22713131" if key== "uuid:fa0a5c22-8e39-46cc-ab3c-1e89f17c9776" 	;
replace unique_id="1221261" if key== "uuid:f0216c5d-f12f-4a07-ad76-a63306c0a42c" 	;
replace unique_id="23010211" if key== "uuid:b25a6fd9-8f60-4c39-b311-742b70a319eb" 	;	
replace unique_id="32509491" if key== "uuid:d818d770-4484-4b47-a3a2-751a5ef4ce8f" 	;
replace unique_id="2271011" if key== "uuid:9cdfac6d-e78b-4c9a-8e92-5856c246d5a2" 	;	
replace unique_id="2271031" if key== "uuid:47109c52-b085-4e3f-85d0-6e8cf43f9924" 	;
replace unique_id="2271061" if key== "uuid:e2c140d1-54cf-4620-bf7c-3ad9d6cb5234" 	;
replace unique_id="1220911" if key== "uuid:157453b4-62ed-44b3-b5ca-525722d334e1" 	;
replace unique_id="1220931" if key== "uuid:4c41fa65-2aa9-4584-b5cc-2b89b8c36cb4" 	;
replace unique_id="1220951" if key== "uuid:69ea03bd-2465-44b4-9cd3-0f97e86f5766" 	;
replace unique_id="1320351" if key== "uuid:ad940edf-0fc3-4278-8be3-17e40c1a1831" 	;
replace unique_id="13203111" if key== "uuid:4f7d4bdc-8f0c-42b1-88f2-c44bd2cecd16" 	;
replace unique_id="13207101" if key== "uuid:5d9c3934-ba7f-4b20-97f9-ebc8756deff9" 	;
replace unique_id="2260691" if key== "uuid:b352b0db-a704-44c7-9b1d-61ae1082bcf4" 	;
replace unique_id="22606161" if key== "uuid:6fbff6c0-718e-4833-9945-ecea3d4394b8" 	;
replace unique_id="22606191" if key== "uuid:575c5cbd-767b-4d04-804a-a1e24e723ef3"	;
replace unique_id="12212111" if key== "uuid:2c13e8bb-956c-4085-a763-d2f92e0e47c3" 	;
replace unique_id="2260621" if key== "uuid:7e96e3bd-d189-46a0-9d61-168a62fe13ca" 	;

replace unique_id="1221241" if unique_id== "1221242" ;
replace unique_id="1220672" if unique_id== "1220671" ;

replace ga_idre="Omisema" if key== "uuid:f946df71-f1c1-428e-992f-7c2d0af2d36b" 			;
replace ga_idre="Outokotorua" if key== "uuid:746dc43f-53f4-4ba1-9d09-90fe6a525ab9" 		; 
replace ga_idre="Outokotorua" if key== "uuid:a9b0f7a3-3dae-43cb-8f1e-1437a5887033" 		;
replace ga_idre="Uuthawambwalala" if key== "uuid:7e96e3bd-d189-46a0-9d61-168a62fe13ca" 	;

replace farmer_stotre="2" if key== "uuid:7e96e3bd-d189-46a0-9d61-168a62fe13ca" ;
 
drop if unique_id== "4091111" & enumer_idre== "3"  			;					
drop if unique_id== "41601101" & correc_respre==0 			;	
drop if unique_id == "1221261"								;

drop if key== "uuid:7f62309d-d24b-463f-9405-7b994524754b" 	;
drop if key== "uuid:4f1e6d09-9fff-406a-903a-ca07f7209107" 	;							
drop if key== "uuid:5e6b9619-7b60-47ec-8e22-c925a9eaf31a" 	;	
drop if key== "uuid:7a63fb9e-7578-46c9-bc75-d8354028568f" 	;	
drop if key== "uuid:a1e93fa8-d532-4d22-b41d-1285dffac11c" 	;
drop if key== "uuid:22b4c520-0d6e-4be8-b13c-c105bc0e7ec0" 	;
drop if key== "uuid:a9050dfc-da10-48df-94d1-d5b186f66b92" 	;
drop if key== "uuid:c45b8640-64c5-41ad-9213-477cf8cb01b3"  	;
drop if key== "uuid:5820e791-c975-4203-9e7b-5f1275d76a1a"	;
drop if key== "uuid:53818eed-e797-4032-a7b8-0eb92e8c446d" 	;
drop if key== "uuid:82f7238f-50bd-49a7-afda-10957bb29151" 	;							
drop if key== "uuid:51f14f10-cad5-4b3b-8d33-c44096548ec0" 	;
drop if key== "uuid:0aa317cd-9d5c-4e4a-9349-b1cc812b1d47"  	;
drop if key== "uuid:61542d19-8ff5-4d87-a683-80c20005cbe1"	;

replace unique_id ="1320352" if 				unique_id == "13203101" ;
replace unique_id ="13203101" if 				unique_id == "13203111" ; 
replace unique_id ="23806102" if				unique_id == "23806421" ;
replace unique_id ="23806261" if 				unique_id == "23806251" ;
replace unique_id ="12408101" if 				unique_id == "11402101" ;
replace unique_id ="23601211" if 				unique_id == "23010211" ;
replace unique_id ="12207501" if 				unique_id == "1220821"	;
replace unique_id ="1221242" if					unique_id == "1221221"	;
replace unique_id="2371872" if					unique_id == "2370772"	;
replace unique_id="1240851" if					unique_id == "1140251"	; 
replace unique_id="1140251" if 					unique_id == "1140262"	;
replace unique_id="1290341" if 					unique_id == "1221141"	;
replace unique_id="2210191" if					unique_id == "22101201"	;
replace unique_id="1220121" if					unique_id == "1220421" 	;
replace unique_id="1221111" if 					unique_id == "1221251"	;
replace unique_id="13202132" if 				unique_id == "1320221"	;
replace unique_id="1220781" if					unique_id == "1221281"	;
replace unique_id="4160231" if					unique_id == "4160131"	;
replace unique_id="41602101" if					unique_id == "41601101"	;
replace unique_id="1320301" if					unique_id == "1320311"	;
replace unique_id="1320241" if					unique_id == "13202131"	;
replace unique_id="13202131" if					unique_id == "1320281"	;
replace unique_id="1240831" if					unique_id == "1140231"	;
replace unique_id="12212571" if					unique_id == "1221211"	;
replace unique_id="1290351" if					unique_id == "1221151"	;
replace unique_id="4160241" if					unique_id == "4160141"	;
replace unique_id="1320211" if					unique_id == "13202101"	;
replace unique_id="4160291" if					unique_id == "4160191"	;
replace unique_id="2380742" if					unique_id == "2271342"	;

save "$stata\dtafiles\behavioral\MCC-Nam_CBRLM_B1_`date_b1_data'_redo.dta", replace ;

********************************************************************************************************** ;
**  STEP 4G: Merge Redo and Main Data				 													** ;
********************************************************************************************************** ;

use "$stata\dtafiles\behavioral\MCC-Nam_CBRLM_B1_`date_b1_data'_redo.dta", clear ;

use "$stata\dtafiles\behavioral\MCC-Nam_CBRLM_B1_`date_b1_data'.dta", clear ;

merge 1:1 unique_id using "$stata\dtafiles\behavioral\MCC-Nam_CBRLM_B1_`date_b1_data'_redo.dta", replace update ;
rename _merge mergin_mnredo ;
label variable mergin_mnredo "Merging indicator ofmain survey and redos"  ;

save "$stata\dtafiles\behavioral\MCC-Nam_CBRLM_B1_`date_b1_data'.dta", replace ;

#d, cr
	








