use "merger_events.dta", clear 

gen month =substr(string(me_date_of_info,"%12.0g"),5,2)
destring month, replace 
order year month 

sort company_name year month

*assign conglomerate name and co_code from earliest year in sample to entire time period. (Implications?). At the moment, multiple co_code by company name 

replace owner_gp_name = company_name if owner_gp_name == "NA" 

gen merge_ind =1 if mr_info_full_name == "Merger" 
keep if merge_ind ==1 

*kicks out financial services companies 
*merge m:1 co_code using "company_list.dta"  
*keep if _merge ==3 
*drop _merge   

keep co_code mr_info_full_name entity_name_mst acquirer owner_gp_name product_name_mst year month 
ren entity_name_mst target_co 
order co_code acquirer target_co year month owner_gp_name target_co 

//This is kicking out all mergers post 2009. 
*drop if product_name_mst =="NA" 

egen product_id = group(product_name_mst) 

duplicates drop 

gen na_check = 0
replace na_check =1 if product_name_mst =="NA" 

bys acquirer target_co year month: gen multi_month_ind1 = _n ==1 
bys acquirer target_co year: egen multi_month_ind = total(multi_month_ind1) 
drop multi_month_ind1

bys acquirer target_co year month product_name_mst: gen n_prods = _n ==1 
bys acquirer target_co year month: egen N_prod = total(n_prods) 

drop n_prods 

bys acquirer target_co year product_name_mst: gen n_merge = _n ==1 
replace n_merge =0 if N_prod>1 & n_merge != 0 & na_check ==1 

sort acquirer target_co year month


save "n_merge.dta", replace 
*issues: company codes are different for same company name. Owner GP name not consistent with same company name. 

preserve 
collapse (sum) n_merge, by(acquirer product_name_mst product_id year) fast 
sort acquirer year 
save "acquirer_stats.dta", replace 
restore 

preserve 
*product_name_mst are all NA when filtering out "Acquisition of Shares" 
collapse (sum) n_merge, by(product_name_mst product_id year) fast 
sort product_name_mst year 
save "y_n_merge_industry.dta", replace 
collapse (sum) n_merge, by(product_name_mst product_id) fast 
save "ay_n_merge_industry.dta", replace 
restore 

preserve
keep target_co year n_merge 
sort target_co year 
drop if n_merge ==0 
sort target_co year
bys target_co: gen n_years = _n 
keep if n_years ==1 
duplicates drop
ren (target_co year) (company_name merge_year)
keep company_name merge_year 
save "acquired_co.dta", replace 
restore 

preserve 
keep owner_gp_name target_co product_name_mst year n_merge 
sort target_co year 
duplicates drop
drop if n_merge ==0
ren (n_merge) (merge_ind) 
order owner_gp_name  
sort owner_gp_name target_co product_name_mst year 
save "conglomerate_co_purchases.dta", replace 

restore 
