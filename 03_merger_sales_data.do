use "product_info.dta", clear 

*Product Name MST is NA for "Merger" indicator in merger file.  
*Not using product_name_mst in merge -> not completely accurate. Esp for conglomerates who are in multiple industries.
*Subset only sales data from companies who acquired or were acquired: 
merge m:1 company_name year using "merger_company_list.dta"
drop if _merge ==2
drop _merge 

sort company_name 

replace product_name_mst = "NA" if product_name_mst =="."
replace product_name_mst = "NA" if product_name_mst ==""

*merge m:1 company_name year using "acquirer_co.dta"
*drop if _merge ==2 
*drop _merge 
*replace acquirer ="NA" if merge_ind ==0

*gen month =substr(string(prod_date,"%12.0g"),5,2)
*destring month, replace 

bys company_name product_name_mst: gen n_prods = _n ==1 
bys company_name: egen N_prod = total(n_prods)

gen multi_prod_ind = 0
replace multi_prod_ind =1 if N_prod > 1 

ren products_product_code product_code

*qty/revenue collapsed on year 
collapse (sum) sales_qty sales_value (max) merge_ind multi_prod_ind, by(company_name product_name_mst product_code year)   

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
*bys company_name product_name_mst: egen sales_qty_post = total(sales_qty) if post_merge_ind ==1
*bys company_name product_name_mst: egen sales_qty_pre = total(sales_qty) if pre_merge_ind ==1 

//SALES VALUE 
*bys company_name product_name_mst: egen sales_val_post = total(sales_value) if post_merge_ind ==1
*bys company_name product_name_mst: egen sales_val_pre = total(sales_value) if pre_merge_ind ==1
drop multi_prod_ind pre_merge_ind post_merge_ind merge_ind multi_prod_ind
 
save "ay_merger_sales_data.dta", replace 

*keep if pre_merge_ind ==1 | merge_ind ==1 
keep company_name product_name_mst year sales_value
*drop if product_name_mst =="NA" 
collapse (sum) sales_value, by(company_name product_name_mst) 
replace sales_value = . if product_name_mst =="NA" 
bys company_name: egen product_rank = rank(-sales_value)  
sort company_name product_rank
drop sales_value
save "company_product_sales_rank.dta", replace



