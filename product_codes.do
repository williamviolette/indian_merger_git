use "product_info.dta", clear 

preserve
keep product_name_mst 
egen product_id = group(product_name_mst)
duplicates drop 
sort product_id 
sort product_name_mst
drop if product_name_mst =="."
save "product_codes_list.dta", replace 
restore 

preserve
keep product_name_mst products_product_code
duplicates drop
bys product_name_mst: gen n_codes = _n 
save "product_codes_adj.dta", replace 
restore 