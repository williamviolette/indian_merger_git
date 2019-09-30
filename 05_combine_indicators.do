use "merger_data.dta", clear 
keep acquirer target_co year conglom_ind internal_purchase_ind 
duplicates drop

merge m:1 acquirer target_co using "same_product_id.dta" 
drop if _merge ==2
drop _merge 
replace same_product = 0 if same_product ==.

sort acquirer target_co year 
