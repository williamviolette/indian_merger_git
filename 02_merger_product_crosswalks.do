use "merger_data.dta", clear 

preserve
keep target_co year n_merge internal_purchase_ind
sort target_co year 
drop if n_merge ==0 
*If multiple merger years with same acquirer and target company, set earliest year as merge year 
**Big assumption
bys target_co: gen n_years = _n 
keep if n_years ==1 
drop n_years n_merge
ren (target_co year) (company_name merge_year)
save "acquired_co.dta", replace 
restore 

preserve
keep target_co year n_merge
sort target_co year 
drop if n_merge ==0 
*If multiple merger years, set earliest as merge year 
bys target_co: gen n_years = _n 
keep if n_years ==1 
drop n_years n_merge 
replace target_co = subinstr(target_co, " [MERGED]", "",.) 
replace target_co = subinstr(target_co, "[MERGED]", "",.) 
ren (target_co year) (company_name merge_year)
bys company_name: gen n_years = _n 
drop if n_years ==2 
drop n_years 
save "acquired_co_2.dta", replace 
restore 

preserve
drop if internal_purchase_ind ==1 
keep acquirer target_co year n_merge
sort acquirer target_co year 
drop if n_merge ==0 
*If multiple merger years, set earliest as merge year 
bys target_co: gen n_years = _n 
keep if n_years ==1 
drop n_years n_merge 
save "acquirer_co.dta", replace 
restore 

use "acquirer_co.dta", clear 
keep acquirer
duplicates drop
ren acquirer company_name 
save "acq_list.dta", replace

use "acquirer_co.dta", clear 
keep target_co
duplicates drop
ren target_co company_name 
save "targ_list.dta", replace

use acq_list.dta, clear 
append using "targ_list.dta" 
duplicates drop
egen co_id = group(company_name)
save "company_crosswalk.dta", replace 

use "product_info.dta", clear 

preserve
keep company_name product_name_mst products_product_code 
ren products_product_code product_code 
duplicates drop 
drop if product_name_mst =="."
sort company_name
merge m:1 company_name product_name_mst using "company_product_sales_rank.dta"
keep if _merge ==3 
drop _merge 
drop if product_name_mst =="NA"
sort company_name product_rank
save "company_product_list.dta", replace 
restore 
