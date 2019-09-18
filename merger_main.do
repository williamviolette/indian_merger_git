use "merger_events.dta", clear 

ren (entity_name_mst owner_gp_name) (target_co co_group_name) 

merge m:1 company_name using "company_list.dta" 
keep if _merge ==3 
drop _merge 

replace co_group_name = owner_gp_name if co_group_name != owner_gp_name

gen month =substr(string(me_date_of_info,"%12.0g"),5,2)
destring month, replace 

keep acquirer target_co co_code mr_info_full_name company_name co_group_name product_name_mst year month conglom_ind 
order co_code company_name acquirer target_co year month 
sort company_name year month 

gen name1 =regexs(1) if regexm(company_name,"^([A-Z0-9]+) ")
gen name2 =regexs(1) if regexm(acquirer,"^([A-Z0-9]+) ")
gen name3 =regexs(1) if regexm(target_co,"^([A-Z0-9]+) ")

gen trans_p_ind = 0
replace trans_p_ind =1 if name1 == name3 | name2 == name3
//ADD CONGLOM MATCH LOGIC ^  

*gen merge_ind =1 if mr_info_full_name == "Merger" 
*keep if merge_ind ==1 
*drop merge_ind 

egen product_id = group(product_name_mst) 
duplicates drop 

gen na_check = 0
replace na_check =1 if product_name_mst =="NA" 

//Gen indicators for multi product merges or mergers that occur in diff. times 
bys company_name target_co year month: gen multi_month_ind1 = _n ==1 
bys company_name target_co year: egen multi_month_ind = total(multi_month_ind1) 
drop multi_month_ind1

bys company_name target_co year month product_name_mst: gen n_prods = _n ==1 
bys company_name target_co year month: egen N_prod = total(n_prods) 

drop n_prods name1 name2 name3

bys company_name target_co year product_name_mst: gen n_merge = _n ==1 
replace n_merge =0 if N_prod>1 & n_merge != 0 & na_check ==1 

sort company_name target_co year month

save "n_merge.dta", replace 

preserve 
collapse (sum) n_merge, by(company_name product_name_mst product_id year) fast 
sort company_name year 
save "acquirer_stats.dta", replace 
restore 

preserve
keep target_co year n_merge 
sort target_co year 
drop if n_merge ==0 
sort target_co year
*If multiple merger years, set earliest as merge year 
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