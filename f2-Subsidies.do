********************
*** INTRODUCTION ***
********************
// This script prepares the data on fossil fuel subsidies
cd "C:\Users\WB514665\OneDrive - WBG\DECDG\SDG Atlas 2022\Ch12\playground-sdg-12"


// Loads all data from SDG database 
import excel "Inputdata/Goal12.xlsx", sheet("data") firstrow clear
drop AE-AZ
compress
keep if Indicator=="12.c.1"
keep if SeriesCode=="ER_FFS_CMPT_GDP"
keep if TimePeriod==2019
keep Geo* Value
destring Value, replace
// Convert to iso code
preserve
import excel "Inputdata\Regional Groupings and Compositions.xlsx", sheet("Group Composition (List View)") firstrow clear
keep if M49Coderegion==1
keep M49Code ISOCode
rename M49Code GeoAreaCode
rename ISOCode code
tempfile conversion
save    `conversion'
restore
merge m:1 GeoAreaCode using `conversion', nogen keep(3)
keep code Value
drop if missing(Value)

rename Value subsidies 
lab var code "Country code"
lab var subsidies "Fossil-fuel subsidies as share of GDP (%)"

export delimited using "Outputdata/Subsidies.csv", replace
