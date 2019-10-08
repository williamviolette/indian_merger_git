use "merger_data.dta", clear 

preserve
*drop if internal_purchase_ind ==1 
keep acquirer year n_merge
sort acquirer year 
drop if n_merge ==0 

//If multiple merger years, set earliest as merge year 
*bys target_co: gen n_years = _n 
*keep if n_years ==1 
*drop n_years 

drop n_merge year
ren (acquirer) (company_name)
duplicates drop 
save "acquirer_co.dta", replace 
restore 

preserve
keep target_co year n_merge internal_purchase_ind
sort target_co year 
drop if n_merge ==0 

//If multiple merger years with same acquirer and target company, set earliest year as merge year 
**Big assumption
*bys target_co: gen n_years = _n 
*keep if n_years ==1 
*drop n_years

drop n_merge internal_purchase_ind
ren (target_co) (company_name)
gen merge_ind =1 
duplicates drop 
save "acquired_co.dta", replace 
restore 

preserve
use "acquirer_co.dta", clear 
append using "acquired_co.dta"
duplicates drop
save "merger_company_list.dta", replace
restore 

preserve
use "acquirer_co.dta", clear 
append using "acquired_co.dta"
keep company_name
duplicates drop
egen co_id = group(company_name)
save "company_crosswalk.dta", replace 
restore 

//Add Company Codes to Acquirer / Target Company Pairs (acq_code, targ_code) 
preserve
keep acquirer target_co year n_merge 
drop if n_merge ==0 
drop n_merge year
duplicates drop 
save "acquirer_target_pairs.dta", replace 

sort acquirer
ren acquirer company_name 
//Merge with company crosswalk to get company id 
merge m:1 company_name using "company_crosswalk.dta"
drop if _merge ==2 
drop _merge 
ren (company_name co_id)(acquirer acquirer_code)
ren target_co company_name 
merge m:1 company_name using "company_crosswalk.dta"
drop if _merge ==2 
drop _merge 
ren (company_name co_id)(target_co target_code)
save "merge_pairs.dta", replace 
restore 


preserve
keep target_co year n_merge
sort target_co year 
drop if n_merge ==0 

*If multiple merger years, set earliest as merge year 
*bys target_co: gen n_years = _n 
*keep if n_years ==1 
*drop n_years 

drop n_merge 
replace target_co = subinstr(target_co, " [MERGED]", "",.) 
replace target_co = subinstr(target_co, "[MERGED]", "",.) 
ren (target_co year) (company_name merge_year)
bys company_name: gen n_years = _n 
drop if n_years ==2 
drop n_years 
save "acquired_co_2.dta", replace 
restore 


//Product Keys 
use "product_info.dta", clear 
preserve
keep company_name product_name_mst products_product_code 
ren products_product_code product_code 
duplicates drop 
replace product_name_mst ="NA" if product_name_mst =="."
sort company_name
save "company_product_list1.dta", replace 
restore 

//Create FIRST YEAR product list for each company  
keep company_name product_name_mst products_product_code year 
duplicates drop
sort company_name year
bys company_name: egen min_year = min(year) 
keep if min_year == year
replace product_name_mst ="NA" if product_name_mst =="."
drop min_year year
save "company_product_list2.dta", replace
 



