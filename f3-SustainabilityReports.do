********************
*** INTRODUCTION ***
********************
// This script prepares the data on sustainability reports
cd "C:\Users\WB514665\OneDrive - WBG\DECDG\SDG Atlas 2022\Ch12\playground-sdg-12"

// Loads a subset of all SDG12 data from SDG database 
import excel "Input data/Goal12.xlsx", sheet("Sheet1") firstrow clear
keep if Indicator=="12.6.1"
keep if inlist(Activity,"TOTAL","")
keep GeoArea* TimePeriod Value*
// Convert to iso code
preserve
import excel "Input data\Regional Groupings and Compositions.xlsx", sheet("Group Composition (List View)") firstrow clear
keep if M49Coderegion==1
keep M49Code ISOCode
rename M49Code GeoAreaCode
rename ISOCode code
tempfile conversion
save    `conversion'
restore
merge m:1 GeoAreaCode using `conversion', nogen keep(3)
drop Geo*
// Merge on income group
preserve
use "Input data/CLASS.dta", clear
keep code incgroup_current
duplicates drop
tempfile class
save    `class'
restore
merge m:1 code using `class', nogen keep(3)
destring Value, replace

rename TimePeriod year
rename Value number
lab var year "Year"
lab var incgroup_current "Latest income group"
lab var code "Country code"
lab var number "Number of sustainability reports"
compress

export delimited using "Output data/sustainability.csv", replace