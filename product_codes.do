use "product_info.dta", clear 

preserve
keep product_name_mst 
egen product_id = group(product_name_mst)
duplicates drop 
sort product_id 
sort product_name_mst
drop if product_name_mst =="."
save "product_codes.dta", replace 
restore 
