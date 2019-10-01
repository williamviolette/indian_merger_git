use "merger_data.dta", clear 
keep acquirer target_co year conglom_ind internal_purchase_ind 
duplicates drop

merge m:1 acquirer target_co using "same_product_id.dta" 
drop if _merge ==2
drop _merge 

replace same_product = 0 if same_product ==.

rename year merge_year 

//There are multiple years with the same target_company. Choose earliest year (?).
sort target_co merge_year 
bys target_co: gen n_years = _n ==1 
keep if n_years ==1 
drop n_years 

save "merger_indicators.dta", replace 




use "ay_merger_sales_data.dta", clear 
keep company_name product_code product_name_mst year sales_qty sales_value ///
merge_ind int_purchase_ind multi_prod_ind post_merge_ind pre_merge_ind





