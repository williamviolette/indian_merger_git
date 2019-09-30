use "product_info.dta", clear 

*Product Name MST is NA for "Merger" indicator in merger file. 
*Not using product_name_mst in merge -> not completely accurate. Esp for conglomerates who are in multiple industries. 
merge m:1 company_name using "acquired_co.dta"
sort company_name 

//Why are we getting merge ==2? 
*preserve
*keep if _merge ==2 
*drop _merge 
*merge m:1 company_name merge_year using "acquired_co_2.dta"
*replace product_name_mst = "NA" if _merge == 1
*drop if _merge ==2
*drop _merge 
*save "matched_acquired.dta", replace 
*restore 

*append using "matched_acquired.dta"

replace product_name_mst = "NA" if _merge == 1
drop if _merge ==2 
drop _merge 

gen merge_ind =0
replace merge_ind =1 if year == merge_year 

*merge m:1 company_name year using "acquirer_co.dta"
*drop if _merge ==2 
*drop _merge 
*replace acquirer ="NA" if merge_ind ==0

replace product_name_mst = "NA" if product_name_mst =="."
replace internal_purchase_ind = 0 if internal_purchase_ind ==.

gen month =substr(string(prod_date,"%12.0g"),5,2)
destring month, replace 

gen int_purchase_ind =0
replace int_purchase_ind =1 if year == merge_year & internal_purchase_ind ==1 

bys company_name product_name_mst: gen n_prods = _n ==1 
bys company_name: egen N_prod = total(n_prods)

gen multi_prod_ind = 0
replace multi_prod_ind =1 if N_prod > 1 

ren products_product_code product_code

collapse (sum) sales_qty sales_value (max) merge_ind int_purchase_ind multi_prod_ind, by(company_name product_name_mst product_code year)   

sort company_name product_name_mst year 

//ID Number of Years from Merge to Last Year in Sample 
	bys company_name product_name_mst: gen n_years = _n 
	gen merge_year_ind = n_years * merge_ind 
	bys company_name product_name_mst: egen max_n_years = max(n_years)
	bys company_name product_name_mst: gen n_years_post = max_n_years - merge_year_ind if merge_year_ind != 0
	bys company_name product_name_mst: replace n_years_post = n_years_post[_n-1] if n_years_post[_n-1] !=.
	replace n_years_post = . if merge_ind ==1 
	gen post_merge_ind = 1 if n_years_post !=. 
	gen pre_merge_ind = 1 if n_years_post ==. & merge_ind ==0
	
	drop n_years merge_year_ind max_n_years n_years_post 
	
//SALES QTY 
bys company_name product_name_mst: egen sales_qty_post = total(sales_qty) if post_merge_ind ==1
bys company_name product_name_mst: egen sales_qty_pre = total(sales_qty) if pre_merge_ind ==1 

//SALES VALUE 
bys company_name product_name_mst: egen sales_val_post = total(sales_value) if post_merge_ind ==1
bys company_name product_name_mst: egen sales_val_pre = total(sales_value) if pre_merge_ind ==1

save "ay_merger_sales_data.dta", replace 

keep if pre_merge_ind ==1 | merge_ind ==1 
keep company_name product_name_mst year sales_value
drop if product_name_mst =="NA" 
collapse (sum) sales_value, by(company_name product_name_mst) 
bys company_name: egen product_rank = rank(-sales_value)  
sort company_name product_rank
save "company_product_sales_rank.dta", replace



