
********************
*** INTRODUCTION ***
********************
// This script prepares the Changing Wealth of Nations (CWON) data
cd "C:\Users\WB514665\OneDrive - WBG\DECDG\SDG Atlas 2022\Ch12\playground-sdg-12"

************************************
*** INCOME GROUP AND GLOBAL DATA ***
************************************
// Income group averages and global average from separate excel file (not in WDI)
import excel "Input data\CWON2021 Country Tool - Full Dataset.xlsx", sheet("income_bal") cellrange(A2:AF153) firstrow clear
keep wb_income year nk pop
drop if wb_income=="0"
expand 2 if wb_income=="High income: OECD", gen(HighIncome)
replace wb_income="High income" if HighIncome==1
drop HighIncome
bysort year (wb_income): replace nk   = nk[2]+nk[3] if _n==1
bysort year (wb_income): replace pop = pop[2]+pop[3] if _n==1
bysort year (wb_income): drop if inlist(_n,2,3)
gen nw_nca_pc = nk/pop
drop nk pop
gen     countrycode="WLD" if wb_income=="World"
replace countrycode="HIC" if wb_income=="High income"
replace countrycode="UMC" if wb_income=="Upper middle income"
replace countrycode="LMC" if wb_income=="Lower middle income"
replace countrycode="LIC" if wb_income=="Low income"
drop wb_income
tempfile excel
save    `excel'

***********************
*** COUNTY DATA WDI ***
***********************
// WDI
wbopendata, indicator(NW.NCA.PC;NY.GDP.PCAP.PP.CD) long clear
drop reg* admin* inc* lend*

// Merge with excel 
merge 1:1 countrycode year using `excel', replace update nogen

*************
*** CLEAN ***
*************
drop if missing(nw,ny)
rename countrycode code
bysort code (year): gen growth_gdp = (ny/ny[1]-1)*100
bysort code (year): gen growth_nca = (nw/nw[1]-1)*100
bysort code (year): gen loggrowth_gdp = log10(ny/ny[1])
bysort code (year): gen loggrowth_nca = log10(nw/nw[1])

rename nw_nca_pc nca
rename ny_gdp_pcap_pp_cd gdp
lab var code "Country code"
lab var countryname "Country name"
lab var gdp "GDP per capita (2017 USD PPP)"
lab var nca "Natural capital per capita (constant 2018 US$)"
lab var growth_gdp "Growth in real GDP per capita since first year in dataset"
lab var growth_nca "Growth in natrual capital per capita since first year in dataset"
lab var loggrowth_gdp "Log10 growth in real GDP per capita since first year in dataset"
lab var loggrowth_nca "Log10 growth in natural capital per capita since first year in dataset"
compress
export delimited using "Output data/cwon.csv", replace

// Globe
keep if year==2018
keep countryname code growth_nca
sort growth
export delimited using "Output data/globe.csv", replace