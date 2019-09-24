use "product_info.dta", clear 

*Product Name MST is NA for "Merger" indicator in merger file. 
*Not using product_name_mst in merge -> not completely accurate. Esp for conglomerates who are in multiple industries. 
merge m:1 company_name using "acquired_co.dta"
sort company_name 

*Why are we getting merge ==2? 
preserve
keep if _merge ==2 
drop _merge 
merge m:1 company_name using "acquired_co_2.dta"
save "matched_acquired.dta", replace 
restore 

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


save "ay_merge_product.dta", replace 




//Other Merger Analysis - Partial Mergers (?) 

//Subset Acquired Companies - ID acquired companies whose sales did/did not drop off, potentially not a merge (?) 
bys company_name: egen ay_merge = max(merge_ind) 
keep if ay_merge ==1 

gen date = ym(year,month)

order company_name product_name_mst year month 
sort company_name product_name_mst year month 

*Save tables for aggregate statistics (number of mergers by industry) 
*not 100% accurate due to product_name_mst NA's and merge issues 
preserve
keep if merge_ind ==1 
collapse (sum) n_merge = merge_ind sales_qty sales_value, by(product_name_mst year)  
sort product_name_mst year 
save "y_n_merge_industry.dta", replace 
collapse (sum) n_merge sales_qty sales_value, by(product_name_mst) 
gsort -n_merge
save "ay_n_merge_industry.dta", replace 
restore

//Start Separating Maybe Mergers and Definite Mergers

	//Company Product Groupings with multiple mergers over time or NO merger for that product 
	bys company_name product_name_mst: egen N_mergers = total(merge_ind) 
	bys company_name product_name_mst: gen multi_merge_ind = 1 if N_mergers > 1 | N_mergers == 0 
	
	preserve 
	keep if multi_merge_ind ==1 
	keep company_name product_name_mst N_mergers
	duplicates drop
	gen merge_ID = 0
	save "unknown_mergers.dta", replace 
	restore
	
	drop if multi_merge_ind ==1 
	drop multi_merge_ind 
	
	//ID Company Product Groupings who were acquired then dropped out of sample 
	bys company_name product_name_mst: gen last_yr_ind = 1 if merge_ind[_N] == 1 
	
		//Create table with definitely merged companies. 
		preserve
		keep if last_yr_ind ==1 
		keep company_name product_name_mst
		duplicates drop
		gen merge_ID = 1
		save "merged_final_list.dta", replace 
		restore 
	
	drop if last_yr_ind ==1 
	drop last_yr_ind 
	drop if product_name_mst =="." 
	
	egen group_ID = group(company_name product_name_mst) 

	tsset group_ID date 


