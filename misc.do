//Misc Do File for Investigating Random Data Issues 

*Investigate Acquired Companies with No Product File Match 
use "merger_events.dta", clear 

gen month =substr(string(me_date_of_info,"%12.0g"),5,2)
destring month, replace 
order year month 

sort company_name year month

merge m:1 company_name year using "unknown_co.dta"
keep if _merge ==3
drop _merge 

preserve
keep co_code company_name 
duplicates drop 
merge 1:m co_code company_name using "product_info.dta"
keep if _merge ==3
sort company_name year
bys company_name: gen n_years = _n 
bys company_name: gen N_years = _N
keep if n_years == N_years 
keep company_name year 
gen merge_ind =1
save "acq1_cos.dta", replace 
restore 
