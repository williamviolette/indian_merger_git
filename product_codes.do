use "product_info.dta", clear 

preserve
keep company_name product_name_mst products_product_code 
ren products_product_code product_code 
duplicates drop 
drop if product_name_mst =="."
sort company_name
merge m:1 company_name product_name_mst using "company_product_sales_rank.dta"
drop _merge 
drop if product_rank ==.
drop if product_name_mst =="NA"
sort company_name product_rank
save "company_product_list.dta", replace 
restore 

preserve
keep product_name_mst products_product_code
duplicates drop
bys product_name_mst: gen n_codes = _n 
save "product_codes_adj.dta", replace 
restore 