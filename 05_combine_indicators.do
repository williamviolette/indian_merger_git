//This script is not right at the moment 
use "merger_data.dta", clear 

keep acquirer target_co year internal_purchase_ind n_merge
sort acquirer target_co year 
drop if n_merge ==0 
drop n_merge 

merge m:1 acquirer target_co using "same_product_id.dta"
drop _merge

gen merge_ind = 1 
replace same_product = 0 if same_product ==.
sort acquirer target_co year 

save "merger_indicators.dta", replace 

//Combine indicator with product sales data? Unsure. Some companies have zero sales history -> large gaps when merging 
/*
ren acquirer company_name
merge m:m company_name using "ay_merger_sales_data.dta"
*We are getting merge ==1, no product sales for acquiring company?  
drop if _merge ==2 
drop _merge

ren (company_name sales_qty sales_value) (acquirer acq_sales_qty acq_sales_value)
ren target_co company_name 

merge m:m company_name product_code year using "ay_merger_sales_data.dta"
*Similar to prev. comment--we could have target companies with NO sales history for any product (?) 
drop if _merge ==2 
drop _merge

ren (company_name sales_qty sales_value) (target_co targ_sales_qty targ_sales_value)
sort acquirer target_co year 

save "merger_sales_indicators.dta", replace
*/ 
