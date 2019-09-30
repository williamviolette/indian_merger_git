
//Company names in MERGER data file that do not match ANY company names in product file (?) 
use "product_info.dta", clear 

*Product Name MST is NA for "Merger" indicator in merger file. 
*Not using product_name_mst in merge -> not completely accurate. Esp for conglomerates who are in multiple industries. 
merge m:1 company_name using "acquired_co.dta"
sort company_name 

*Why are we getting merge ==2? 
keep if _merge ==2 
drop _merge 


//Partial Merger Identification

	use "ay_merger_sales_data.dta", clear 

	//Other Merger Analysis - Partial Mergers (?) 

	//Subset Acquired Companies - ID acquired companies whose sales did/did not drop off, potentially not a merge (?) 
	bys company_name: egen ay_merge = max(merge_ind) 
	keep if ay_merge ==1 )

	order company_name product_name_mst year 
	sort company_name product_name_mst year 
	
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
