use "merger_events.dta", clear 

*kicks out financial services companies 
*merge m:1 co_code using "company_list.dta"  
*keep if _merge ==3 
*drop _merge   

gen month =substr(string(me_date_of_info,"%12.0g"),5,2)
destring month, replace 
order year month 

keep co_code mr_info_full_name entity_name_mst acquirer owner_gp_name product_name_mst year month 
ren entity_name_mst target_co 
order co_code acquirer target_co year month owner_gp_name target_co 

//This is kicking out all mergers post 2009. 
//Cant calculate HHI without knowing product market
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
collapse (sum) n_merge, by(product_name_mst product_id year) fast 
sort product_name_mst year 
save "product_merge_stats.dta", replace 
restore 

preserve 
collapse (sum) n_merge, by(year) fast 
twoway(bar n_merge year, sort)
graph export "$gpath\n_merge_graph.pdf", replace 
restore 

preserve 
drop if product_name_mst =="NA" 
collapse (sum) n_merge, by(year) fast 
twoway(bar n_merge year, sort)
graph export "$gpath\n_merge_graph_NA.pdf", replace 
restore 

preserve
keep target_co product_name_mst year n_merge 
sort target_co year 
duplicates drop
drop if n_merge ==0
ren (n_merge target_co) (merge_ind company_name)  
save "acquired_co.dta", replace 
restore 
/*
levelsof product_id, local(levels)
foreach l of local levels {
twoway(bar n_merge year if product_id == `l', sort)
graph export "$gpath\n_`l'_merge.pdf", replace 
}
*/ 

drop if owner_gp_name == "Private (Indian)" | owner_gp_name == "NA" /// 
| owner_gp_name == "Private (Foreign)" 