* clean up raw data
* group variables into categories
* re-do summary stats

clear all
set more off
set showbaselevels on

cd "H:\apps\xp\desktop\HAC-pop-health-survey"

capture log close
log using HAC-pop-health-survey_data_cleaning_log.log, replace
import delimited "raw_data\KEF__HAC Population Health Survey 2017-07-26 - responses downloaded 2017-08-21 .csv", clear

*** cleaning data
* make string vars lower case
foreach var in datecollected village interviewername language ///
gender yearsofresidency monthsawayyn monthsawaywhich monthsawaylocations ///
monthsawayreasons monthsawayreasonsother maritalstatus multiplewiveshusband ///
multiplewiveswife educationlevel incomesources ///
incomesourcesother newssource watersource watersourceother healthcareaccessed ///
healthcarechildren healthcarelocation healthcarelocationfrequent ///
healthcarelocationfrequentreason healthcaremissed healthcaremissedreason ///
healthcarelast healthcarelastlocation healthcarelasttransport ///
healthcarelasttransporttime familyplanningyn ///
familyplanningwhynot familyplanninguse familyplanningpreferred familyplanningpreferredyn ///
familyplanningpreferredwhynot hivdiscussyn hivtestyn hivtestwhynot hivtestlast ///
hivtestlastlocation hivtestresults artstartyn artstartwhynot artstartlocation ///
artcurrent artcurrentwhynot artlocation artlocationtype artlocationreason artmissedyn ///
artmissedreason viralloadyn viralloadlast viralloadlocation viralloadresults viralloadtime ///
viralloadexplain hivtreatments eqmobility eqselfcare eqactivities eqpain eqanxiety {
	replace `var'=lower(`var')
}
.

count //353 obs in total
foreach var of varlist datecollected-eqscale { // switch var names and labels
	local lab: var label `var'
	rename `var' `lab'
	label var `lab' "`var'"
}
.

* convert some string vars to numeric values
* the one that may be of analytical interest later
tab Gender //create new dummy var female
gen female=(Gender=="female")
replace female=0 if missing(female)
tab female Gender

tab YearsOfRes //create new categorical var
replace YearsOfResidency="1" if YearsOfResidency=="<1 year"
replace YearsOfResidency="2" if YearsOfResidency=="1-4 years"
replace YearsOfResidency="3" if YearsOfResidency=="5-9 years"
replace YearsOfResidency="4" if YearsOfResidency=="10+ years"
replace YearsOfResidency="99" if YearsOfResidency=="don't know"
destring YearsOfRes, replace
label define residency 1 "<1 year" 2 "1-4 years" 3 "5-9 years" 4 "10+ years" 99 "dont know", replace
label values YearsOfRes residency

replace MonthsAwayYN="1" if MonthsAwayYN=="yes"
replace MonthsAwayYN="0" if MonthsAwayYN=="no"
destring MonthsAwayYN, replace

tab MonthsAwayWhich
gen MonthsAwayJan=1 if strmatch(MonthsAwayWhich, "*jan*")
gen MonthsAwayFeb=1 if strmatch(MonthsAwayWhich, "*feb*")
gen MonthsAwayMar=1 if strmatch(MonthsAwayWhich, "*mar*")
gen MonthsAwayApr=1 if strmatch(MonthsAwayWhich, "*apr*")
gen MonthsAwayMay=1 if strmatch(MonthsAwayWhich, "*may*")
gen MonthsAwayJune=1 if strmatch(MonthsAwayWhich, "*jun*")
gen MonthsAwayJuly=1 if strmatch(MonthsAwayWhich, "*jul*")
gen MonthsAwayAug=1 if strmatch(MonthsAwayWhich, "*aug*")
gen MonthsAwaySep=1 if strmatch(MonthsAwayWhich, "*sep*")
gen MonthsAwayOct=1 if strmatch(MonthsAwayWhich, "*oct*")
gen MonthsAwayNov=1 if strmatch(MonthsAwayWhich, "*nov*")
gen MonthsAwayDec=1 if strmatch(MonthsAwayWhich, "*dec*")
foreach month in Jan Feb Mar Apr May June July Aug Sep Oct Nov Dec {
	replace MonthsAway`month'=0 if missing(MonthsAway`month')|MonthsAwayYN==0
}
.

* reasons why villagers were away
tab MonthsAwayReasons // fishing, friends/family/social, farm, other work, Healthcare
tab MonthsAwayReasonsOther // religious
gen MonthsAwayFishing=1 if strmatch(MonthsAwayReasons, "*fish*")|strmatch(MonthsAwayReasonsOther, "*fish*")
gen MonthsAwaySocial=1 if strmatch(MonthsAwayReasons, "*family*")|strmatch(MonthsAwayReasonsOther, "*marriage*") ///
	|strmatch(MonthsAwayReasonsOther, "*husband*")|strmatch(MonthsAwayReasonsOther, "*family*") ///
	|strmatch(MonthsAwayReasonsOther, "*burrial*")|strmatch(MonthsAwayReasonsOther, "*wedding*") ///
	|strmatch(MonthsAwayReasonsOther, "*home*")
gen MonthsAwayFarming=1 if strmatch(MonthsAwayReasons, "*farm*")|strmatch(MonthsAwayReasonsOther, "*palm*")
gen MonthsAwayOtherWork=1 if strmatch(MonthsAwayReasons, "*other work*") ///
	|strmatch(MonthsAwayReasonsOther, "*hotel*")|strmatch(MonthsAwayReasonsOther, "*driver*") ///
	|strmatch(MonthsAwayReasonsOther, "*building*")
gen MonthsAwayHealth=1 if strmatch(MonthsAwayReasons, "*health*")|strmatch(MonthsAwayReasonsOther, "*birth*")
gen MonthsAwayReligion=1 if strmatch(MonthsAwayReasonsOther, "*god*")|strmatch(MonthsAwayReasonsOther, "*religion*")
foreach reason in Fishing Social Farming OtherWork Health Religion {
	replace MonthsAway`reason'=0 if missing(MonthsAway`reason')
}
.

* multiple wives
foreach var in Husband Wife {
	replace MultipleWives`var'="1" if MultipleWives`var'=="yes"
	replace MultipleWives`var'="0" if MultipleWives`var'=="no"
	destring MultipleWives`var', replace
}
.

*** july 30
* edu level
tab EducationLevel // primary-->o level-->a level-->tech sch-->uni/above
replace EducationLevel="1" if EducationLevel=="none"
replace EducationLevel="2" if EducationLevel=="primary"
replace EducationLevel="3" if EducationLevel=="secondary ordinary"
replace EducationLevel="4" if EducationLevel=="secondary advanced"
replace EducationLevel="5" if EducationLevel=="technical school"|EducationLevel=="nursing college"
destring EducationLevel, replace

* income source
* combine "fish" and "fish processing"
tab IncomeSources // farming, fishing related, small business, cooking, burning charcoal, govt, casual labor, retired
tab IncomeSourcesOther // driving, other manual labor, other income sources, unemployed, housewife, 
gen IncomeFarm=(strmatch(IncomeSources, "*farm*"))
gen IncomeFish=(strmatch(IncomeSources, "*fishing*")|strmatch(IncomeSources, "*processing*") ///
	|strmatch(IncomeSources, "*selling fish*"))
gen IncomeSB=(strmatch(IncomeSources, "*run*")|strmatch(IncomeSources, "*market*") ///
	|strmatch(IncomeSourcesOther, "*barber*")|strmatch(IncomeSourcesOther, "*carpenter*") ///
	|strmatch(IncomeSourcesOther, "*drug*")|strmatch(IncomeSourcesOther, "*retail*") ///
	|strmatch(IncomeSourcesOther, "*market*")|strmatch(IncomeSourcesOther, "*mobile money*") ///
	|strmatch(IncomeSourcesOther, "*tailor*")|strmatch(IncomeSourcesOther, "*selling clothes*"))
gen IncomeCasual=(strmatch(IncomeSources, "*cook*")|strmatch(IncomeSourcesOther, "*firewood*") ///
	|strmatch(IncomeSourcesOther, "*driving*")|strmatch(IncomeSourcesOther, "*brooms*") ///
	|strmatch(IncomeSourcesOther, "*cook*")|strmatch(IncomeSourcesOther, "*washing*"))
gen IncomeCharcoal=(strmatch(IncomeSources, "*charcoal*")|strmatch(IncomeSourcesOther, "*charcoal*"))
gen IncomeGovt=(strmatch(IncomeSources, "*goverment*"))
gen IncomeNW=(strmatch(IncomeSources, "*retired*")|strmatch(IncomeSources, "*housewife*") ///
	|strmatch(IncomeSourcesOther, "*gambling*"))
foreach var in Farm Fish SB Casual Charcoal Govt NW {
	replace Income`var'=0 if missing(Income`var')
}
.
label var IncomeSB "small business"
label var IncomeNW "not working (retired, unemployed, housewife)"

* NewsSource/WaterSource: not of analytical interest for now

*Healthcare
tab HealthcareAcc
tab HealthcareChildren

replace HealthcareAcc="0" if HealthcareAcc=="0 times"
replace HealthcareAcc="1" if HealthcareAcc=="1-4 times"
replace HealthcareAcc="2" if HealthcareAcc=="5-9 times"
replace HealthcareAcc="3" if HealthcareAcc=="10 or more times"
replace HealthcareAcc="99" if HealthcareAcc=="don't know"
destring HealthcareAcc, replace
label define health 0 "0 times" 1 "1-4 times" 2 "5-9 times" 3 "10 or more" 99 "don't know", replace
label values HealthcareAcc health

replace HealthcareChildren="0" if HealthcareChildren=="0 times"
replace HealthcareChildren="1" if HealthcareChildren=="1-4 times"
replace HealthcareChildren="2" if HealthcareChildren=="5-9 times"
replace HealthcareChildren="3" if HealthcareChildren=="10 or more times"
replace HealthcareChildren="99" if strmatch(HealthcareChildren, "*know*")
replace HealthcareChildren="98" if strmatch(HealthcareChildren, "*no children*")
destring HealthcareChildren, replace
label define health 0 "0 times" 1 "1-4 times" 2 "5-9 times" 3 "10 or more" 99 "don't know" 98 "no children in household", replace
label values HealthcareChildren health

* Healthcare location
tab HealthcareLocation //leave alone for now; health center, hospital, healer, drug shop/clinic, self-medicate, mobile, VHT, birth attendant
tab HealthcareLocationFrequent 
tab HealthcareLocationFrequentReason 

replace HealthcareLocationFrequent="health center" if strmatch(HealthcareLocationFrequent, "* h/c*") ///
	|strmatch(HealthcareLocationFrequent, "* hc*")|strmatch(HealthcareLocationFrequent, "*health ce*") ///
	|strmatch(HealthcareLocationFrequent, "hc")|strmatch(HealthcareLocationFrequent, "*healthcentre*") ///
	|strmatch(HealthcareLocationFrequent, "*mugoye*")
replace HealthcareLocationFrequent="clinic/drug shop" if strmatch(HealthcareLocationFrequent, "*clinic*") ///
	|strmatch(HealthcareLocationFrequent, "*clnic*")|strmatch(HealthcareLocationFrequent, "*drug shop*")
replace HealthcareLocationFrequent="hospital" if strmatch(HealthcareLocationFrequent, "*hospital*")
replace HealthcareLocationFrequent="VHT" if strmatch(HealthcareLocationFrequent, "*vht*")
replace HealthcareLocationFrequent="n/a" if strmatch(HealthcareLocationFrequent, "*get sick*") ///
	|strmatch(HealthcareLocationFrequent, "*treatment*") //need input from HAC staff

gen HealthcareLocReason1=(strmatch(HealthcareLocationFrequentReason, "*friendly*"))
gen HealthcareLocReason2=(strmatch(HealthcareLocationFrequentReason, "*free*"))
gen HealthcareLocReason3=(strmatch(HealthcareLocationFrequentReason, "*better*"))
gen HealthcareLocReason4=(strmatch(HealthcareLocationFrequentReason, "*close*"))
gen HealthcareLocReason5=(strmatch(HealthcareLocationFrequentReason, "*specify*"))
label var HealthcareLocReason1 "staff are friendly"
label var HealthcareLocReason2 "free/low cost services"
label var HealthcareLocReason3 "better services"
label var HealthcareLocReason4 "close to home"
label var HealthcareLocReason5 "other reason"
forvalues i=1/5 {
	replace HealthcareLocReason`i'=0 if HealthcareLocReason`i'==.
}
.

* missed Healthcare
tab HealthcareMissed 
tab HealthcareLast
replace HealthcareMissed="1" if HealthcareMissed=="yes"
replace HealthcareMissed="0" if HealthcareMissed=="no"

tab HealthcareMissedReason
gen MissHealthcareCost=(strmatch(HealthcareMissedReason, "*expensive*"))
gen MissHealthcareClinic=(strmatch(HealthcareMissedReason, "*out of stock*"))
gen MissHealthcareSelf=(strmatch(HealthcareMissedReason, "*ignorance*")|strmatch(HealthcareMissedReason, "*caretaker*") ///
	|strmatch(HealthcareMissedReason, "*fear*")|strmatch(HealthcareMissedReason, "*mild*") ///
	|strmatch(HealthcareMissedReason, "*self medi*")|strmatch(HealthcareMissedReason, "*weak*"))
gen MissHealthcareTransport=(strmatch(HealthcareMissedReason, "*transportation*"))
label var MissHealthcareClinic "supplies out of stock"
label var MissHealthcareSelf "reasons with patient him/herself: fear of meds, caretaker not home, etc."

replace HealthcareLast="1" if HealthcareLast=="last month"
replace HealthcareLast="2" if HealthcareLast=="1-3 months ago"
replace HealthcareLast="3" if HealthcareLast=="more than 4 months ago"
replace HealthcareLast="99" if HealthcareLast=="don't know"
replace HealthcareLast="98" if HealthcareLast=="never received services"
destring HealthcareLast, replace
label var HealthcareLast "last time he/she missed Healthcare"
label define health 1 "last month" 2 "1-3 months ago" 3 "more than 4 months ago" 98 "never received services" 99 "don't know", replace
label values HealthcareLast health

tab HealthcareLastLocation 
replace HealthcareLastLocation ="drug shop/clinic" if strmatch(HealthcareLastLocation, "*drug shop*")
replace HealthcareLastLocation ="health center" if strmatch(HealthcareLastLocation, "*health cent*")
replace HealthcareLastLocation ="mobile outreach" if strmatch(HealthcareLastLocation, "*ground*") ///
	|strmatch(HealthcareLastLocation, "*mobile*")
replace HealthcareLastLocation ="hospital" if strmatch(HealthcareLastLocation, "*hospital*")
replace HealthcareLastLocation ="self medicate" if strmatch(HealthcareLastLocation, "*self*")

* transportation
tab HealthcareLastTransport 
tab HealthcareLastTransportTime 
tab HealthcareLastTransportCost 
replace HealthcareLastTransport="1" if strmatch(HealthcareLastTransport, "*boat*")
replace HealthcareLastTransport="2" if strmatch(HealthcareLastTransport, "*taxi*")
replace HealthcareLastTransport="3" if strmatch(HealthcareLastTransport, "*motorcycle*")
replace HealthcareLastTransport="4" if strmatch(HealthcareLastTransport, "*foot*")
replace HealthcareLastTransport="98" if strmatch(HealthcareLastTransport, "*other*")
destring HealthcareLastTransport, replace
label define transport 1 "boat" 2 "taxi" 3 "motorcycle/bike" 4 "on foot" 98 "other"
label values HealthcareLastTransport transport

replace HealthcareLastTransportTime="1" if strmatch(HealthcareLastTransportTime, "*less than*")
replace HealthcareLastTransportTime="2" if strmatch(HealthcareLastTransportTime, "*to 1 hour*")
replace HealthcareLastTransportTime="3" if strmatch(HealthcareLastTransportTime, "*1 hour to*")
replace HealthcareLastTransportTime="4" if strmatch(HealthcareLastTransportTime, "*2 hours or*")
replace HealthcareLastTransportTime="99" if strmatch(HealthcareLastTransportTime, "*don't know*")
destring HealthcareLastTransportTime, replace
label define time 1 "<0.5 hr" 2 "0.5-1 hr" 3 "1-1.5 hrs" 4 ">2 hrs" 99 "don't know", replace
label values HealthcareLastTransportTime time

* family planning
tab FamilyPlanningYN 
tab FamilyPlanningWhyNot
replace FamilyPlanningYN="1" if FamilyPlanningYN=="yes"
replace FamilyPlanningYN="0" if FamilyPlanningYN=="no"
replace FamilyPlanningYN="99" if FamilyPlanningYN=="don't know/not sure"
destring FamilyPlanningYN, replace
label var FamilyPlanningYN "use family planning methods"
label define planning 1 "yes" 2 "no" 99 "don't know/not sure", replace
label values FamilyPlanningYN planning

replace FamilyPlanningWhyNot="" if strmatch(FamilyPlanningWhyNot, "*baby*") ///
	|strmatch(FamilyPlanningWhyNot, "*menopause*")|strmatch(FamilyPlanningWhyNot, "*pregnant*") ///
	|strmatch(FamilyPlanningWhyNot, "*produce a child*")

* differentiate implant(impl&iud&tubal ligation) vs. injection(inj&pills)
* test statistical sig, short term v. long term
tab FamilyPlanningUse 
tab FamilyPlanningPreferred 
gen FamilyPlanNatural=(strmatch(FamilyPlanningUse, "*moon*")|strmatch(FamilyPlanningUse, "*tradit*")) ///
	|strmatch(FamilyPlanningUse, "*withdrawal*")
gen FamilyPlanCondom=(strmatch(FamilyPlanningUse, "*condom*"))
gen FamilyPlanInj=(strmatch(FamilyPlanningUse, "*injec*")|strmatch(FamilyPlanningUse, "*pill*"))
gen FamilyPlanMed=(strmatch(FamilyPlanningUse, "*implant*")|strmatch(FamilyPlanningUse, "*iud*") ///
	|strmatch(FamilyPlanningUse, "*tubal ligation*"))

gen FamilyPlanPrefer=1 if strmatch(FamilyPlanningPreferred, "*condoms*")
replace FamilyPlanPrefer=2 if strmatch(FamilyPlanningPreferred, "*implant*") ///
	|strmatch(FamilyPlanningPreferred, "*iud*")|strmatch(FamilyPlanningPreferred, "*tubal*") ///
	|strmatch(FamilyPlanningPreferred, "*vasect*")
replace FamilyPlanPrefer=3 if strmatch(FamilyPlanningPreferred, "*inject*") ///
	|strmatch(FamilyPlanningPreferred, "*pill*")
replace FamilyPlanPrefer=4 if strmatch(FamilyPlanningPreferred, "*moon*") ///
	|strmatch(FamilyPlanningPreferred, "*withdrawal*")
label var FamilyPlanPrefer "preferred method of family Planning"
label define Plan 1 "condoms" 2 "long-term method" 3 "short-term method" 4 "natural method", replace
label values FamilyPlanPrefer Plan

tab FamilyPlanningPreferredYN
tab FamilyPlanningPreferredWhyNot //only 19 ppl answered
replace FamilyPlanningPreferredYN="1" if FamilyPlanningPreferredYN=="yes"
replace FamilyPlanningPreferredYN="0" if FamilyPlanningPreferredYN=="no"
replace FamilyPlanningPreferredYN="99" if FamilyPlanningPreferredYN=="don't know"
destring FamilyPlanningPreferredYN, replace
label var FamilyPlanningPreferredYN "use family planning methods"
label values FamilyPlanningPreferredYN planning

*** HIV testing
tab HIVDiscussYN //baseline question, no need to recode
tab HIVTestYN 
replace HIVTestYN="0" if HIVTestYN=="no" // 15 ppl answered no
replace HIVTestYN="1" if HIVTestYN=="yes"
replace HIVTestYN="99" if HIVTestYN=="don't know"
destring HIVTestYN, replace
label var HIVTestYN "had HIV tested"
label define test 1 "yes" 0 "no" 99 "don't know"
label values HIVTestYN test

tab HIVTestWhyNot //only 11 data pts, sample too small?

tab HIVTestLast
replace HIVTestLast="1" if HIVTestLast=="last month"
replace HIVTestLast="2" if HIVTestLast=="in the last 6 months"
replace HIVTestLast="3" if HIVTestLast=="more than 6 months ago"
replace HIVTestLast="98" if strmatch(HIVTestLast, "*never*")
destring HIVTestLast, replace
label var HIVTestLast "last time had HIV tested"
label define test_time 1 "last month" 2 "in the last 6 months" 3 "more than 6 months ago" 98 "never tested", replace
label values HIVTestLast test_time

tab HIVTestLastLocation //whats ekirala, menya?
replace HIVTestLastLocation="1" if HIVTestLastLocation=="health centre"
replace HIVTestLastLocation="2" if HIVTestLastLocation=="home based test"
replace HIVTestLastLocation="3" if HIVTestLastLocation=="mobile outreach"

tab HIVTestResults
replace HIVTestResults="0" if HIVTestResults=="negative"
replace HIVTestResults="1" if HIVTestResults=="positive"
replace HIVTestResults="99" if HIVTestResults=="don't know"
destring HIVTestResults, replace
label define test 1 "positive" 0 "negative" 99 "don't know", replace
label values HIVTestResults test

*** ARV
tab ARTStartYN
tab ARTStartWhyNot //only 4 ppl answered; sample too small
tab ARTStartLocation
replace ARTStartYN="1" if ARTStartYN=="yes"
replace ARTStartYN="0" if ARTStartYN=="no"
destring ARTStartYN, replace
label var ARTStartYN "have you ever started ARV"

replace ARTStartLocation="1" if ARTStartLocation=="health centre"
replace ARTStartLocation="2" if ARTStartLocation=="mobile outreach"
destring ARTStartLocation, replace
label define loc 1 "health center" 2 "mobile outreach", replace
label values ARTStartLocation loc

tab ARTCurrent
tab ARTCurrentWhyNot //only 1 person answered
tab ARTLocation 
replace ARTCurrent="0" if ARTCurrent=="no"
replace ARTCurrent="1" if ARTCurrent=="yes"
destring ARTCurrent, replace
label var ARTCurrent "are you currently on ARV"

replace ARTLocation="health center" if strmatch(ARTLocation, "*hc*")
replace ARTLocation="hospital" if strmatch(ARTLocation, "*hospital*")

tab ARTLocationType
tab ARTLocationReason
gen ARVLocReasonStaff=(strmatch(ARTLocationReason, "*friendly*"))
gen ARVLocReasonDist=(strmatch(ARTLocationReason, "*close to*"))
gen ARVLocReasonCost=(strmatch(ARTLocationReason, "*free ot low*"))
gen ARVLocReasonPrivacy=(strmatch(ARTLocationReason, "*privacy*"))
gen ARVLocReasonService=(strmatch(ARTLocationReason, "*better than*"))
gen ARVLocReasonOther=(strmatch(ARTLocationReason, "*refused*")|strmatch(ARTLocationReason, "*started treatment*"))
label var ARVLocReasonStaff "staff are friendly and welcoming"
label var ARVLocReasonDist "close to home"
label var ARVLocReasonCost "treatment is free or low cost"
label var ARVLocReasonPrivacy "I don't want people to see me"
label var ARVLocReasonService "services are better"
label var ARVLocReasonOther "other reasons"

tab ARTMissedYN
tab ARTMissedReason //only 44 data pts; sample too small
replace ARTMissedYN="1" if ARTMissedYN=="yes"
replace ARTMissedYN="0" if ARTMissedYN=="no"
destring ARTMissedYN, replace

*** viral load
tab ViralLoadYN
replace ViralLoadYN="1" if ViralLoadYN =="yes"
replace ViralLoadYN ="0" if ViralLoadYN =="no"
replace ViralLoadYN ="99" if ViralLoadYN =="don't know"
destring ViralLoadYN, replace
label define load 1 "yes" 0 "no" 99 "don't know", replace
label values ViralLoadYN load

tab ViralLoadLast
label var ViralLoadLast "last time you tested viral load"
replace ViralLoadLast="1" if ViralLoadLast=="in the last 6 months"
replace ViralLoadLast="2" if ViralLoadLast=="6 months to 1 year ago"
replace ViralLoadLast="3" if ViralLoadLast=="more than 1 year ago"
destring ViralLoadLast, replace
label define testing 1 "in the last 6 months" 2 "6 months or 1 year ago" 3 "more than 1 year ago", replace
label values ViralLoadLast testing 

tab ViralLoadLocation //looks pretty clean
tab ViralLoadResults
replace ViralLoadResults="1" if ViralLoadResults=="yes"
replace ViralLoadResults="0" if ViralLoadResults=="no"
destring ViralLoadResults, replace
label var ViralLoadResults "did you receive the results from viral load test"

tab ViralLoadTime
label var ViralLoadTime "how long did it take to get the results back"
replace ViralLoadTime="1" if ViralLoadTime=="same day"
replace ViralLoadTime="2" if ViralLoadTime=="1 to 2 weeks"
replace ViralLoadTime="3" if ViralLoadTime=="3 to 4 weeks"
replace ViralLoadTime="4" if ViralLoadTime=="1 to 3 months"
replace ViralLoadTime="5" if ViralLoadTime=="over 3 months"
destring ViralLoadTime, replace
label define time 1 "same day" 2 "1 to 2 weeks" 3 "3 to 4 weeks" 4 "1 to 3 months" ///
	5 "over 3 months", replace
label values ViralLoadTime time

tab ViralLoadExplain 
label var ViralLoadExplain "Did the health worker explain the results of the viral load test well"
replace ViralLoadExplain="1" if ViralLoadExplain=="yes"
replace ViralLoadExplain="0" if ViralLoadExplain=="no"
destring ViralLoadExplain, replace

tab HIVTreatments //this question is not of analytical interest

*** EQ-5D-3L self-assessed health
tab EQMobility
tab EQSelfCare
tab EQActivities
tab EQPain
tab EQAnxiety
tab EQScale

label var EQSelfCare "able to wash or dress myself"
label var EQActivities "able to do usual activities"
label var EQScale "overall health"

label define scale 1 "with great difficulty" 2 "with some difficulty" 3 "no difficulty", replace
foreach var in Mobility SelfCare Activities {
	replace EQ`var'="3" if strmatch(EQ`var', "*no prob*")
	replace EQ`var'="2" if strmatch(EQ`var', "*some prob*")
	replace EQ`var'="1" if strmatch(EQ`var', "*unable to*")|strmatch(EQ`var', "*confined*")
	destring EQ`var', replace
	label values EQ`var' scale
}
.
label define scale2 1 "extremely" 2 "somewhat" 3 "no", replace
foreach var in Pain Anxiety {
	replace EQ`var'="3" if strmatch(EQ`var', "* no*")
	replace EQ`var'="2" if strmatch(EQ`var', "*moderate*")
	replace EQ`var'="1" if strmatch(EQ`var', "*extreme*")
	destring EQ`var', replace
	label values EQ`var' scale2
}
.

gen EQ=(EQScale<20)
replace EQ=2 if EQScale<40 & EQScale>=20
replace EQ=3 if EQScale<60 & EQScale>=40
replace EQ=4 if EQScale<80 & EQScale>=60
replace EQ=5 if EQScale<100 & EQScale>=80
label var EQ "EQ scale self assessment in quintiles"

compress
save HAC-pop-health-survey_clean.dta, replace
export delimited HAC-pop-health-survey_clean.csv, replace

*** part 2 
* merge which villages had access to HAC
import delimited raw_data\villages_hasHAC.csv, clear
rename village Village
merge 1:m Village using HAC-pop-health-survey_clean.dta
drop if _mer!=3
drop _merge
drop Gender MonthsAwayWhich MonthsAwayReasons MonthsAwayReasonsOther ///
	IncomeSources IncomeSourcesOther HealthcareLocationFrequentReason ///
	HealthcareMissedReason FamilyPlanningPreferred FamilyPlanningUse ///
	ARTLocationReason //drop the vars already recoded

compress
save HAC-pop-health-survey_analytical.dta, replace
export delimited HAC-pop-health-survey_analytical.csv, replace

log close
