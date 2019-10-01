use "merger_events.dta", clear 

*Issues with Company Name, Company Code, and Company Group Name -> Does not seem to line up with acquirer field (!!!)

ren (entity_name_mst owner_gp_name) (target_co co_group_name) 

*add conglom indicator 
merge m:1 company_name using "company_list.dta" 
keep if _merge ==3 
drop _merge 

*add conglomerate name field based on target_company 
*trying to match companies with [MERGED] in name field and without
merge m:1 target_co using "acq_co_list.dta"
drop if _merge ==2 
drop _merge 

replace targ_gp = "NA" if targ_gp ==""
replace co_group_name = owner_gp_name if co_group_name != owner_gp_name

keep acquirer target_co mr_info_full_name co_group_name product_name_mst year targ_gp conglom_ind 
order acquirer target_co year 
sort acquirer year  

//Match first name of acquirer to target company to ID companies who were buying themselves. 
	*gen name1 =regexs(1) if regexm(company_name,"^([A-Z0-9]+) ")
	gen name2 =regexs(1) if regexm(acquirer,"^([A-Z0-9]+) ")
	gen name3 =regexs(1) if regexm(target_co,"^([A-Z0-9]+) ")

//Identify Companies who purchased other companies with the same ownership 
	gen internal_purchase_ind = 0
	*replace internal_purchase_ind =1 if name1 == name3
	replace internal_purchase_ind =1 if name2 == name3

	*Companies in same conglomerate may not share same first name. Match conglomerate fields from acquirer and target company 
	replace internal_purchase_ind =1 if co_group_name == targ_gp & targ_gp != "NA" & targ_gp != "Private (Indian)" & targ_gp != "Private (Foreign)"
	drop name*

//Keep observations tagged as "Merger" 
	*gen merge_ind =1 if mr_info_full_name == "Merger" 
	*keep if merge_ind ==1 
	*drop merge_ind 

gen na_check = 0
replace na_check =1 if product_name_mst =="NA" 

//Gen indicators for mergers that occur in diff. times 
	sort acquirer target_co year  
	bys acquirer target_co: gen multi_year_ind1 = _n ==1 
	keep if multi_year_ind1 ==1
	drop multi_year_ind1

	bys acquirer target_co year product_name_mst: gen n_merge = _n ==1 
	
sort acquirer target_co year

save "merger_data.dta", replace 


