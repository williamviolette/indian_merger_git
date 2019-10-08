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

ren acquirer company_name
merge m:m company_name using "ay_merger_sales_data.dta"
drop if _merge ==2 
drop _merge

ren (product_code product_name_mst sales_qty sales_value) (acq_product_code acq_product_name_mst acq_sales_qty acq_sales_value)
ren company_name acquirer
ren target_co company_name 

merge m:m company_name year using "ay_merger_sales_data.dta"
drop if _merge ==2 
drop _merge

ren (product_code product_name_mst sales_qty sales_value) (targ_product_code targ_product_name_mst targ_sales_qty targ_sales_value)

sort acquirer acq_product_name_mst target_co targ_product_name_mst year 

save "merger_sales_indicators.dta", replace
