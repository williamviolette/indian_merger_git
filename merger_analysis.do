use "merger_events.dta", clear 

*kicks out financial services companies 
merge m:1 co_code using "company_list.dta"  
keep if _merge ==3 
drop _merge   

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

bys acquirer target_co year product_name_mst: gen n_merge = _n ==1  
bys acquirer target_co year month: egen N_merge = total(n_merge)

 
sort acquirer target_co year 

*issues: company codes are different for same company name. Owner GP name not consistent with same company name. 

preserve 
collapse (sum) n_merge, by(product_name_mst product_id year) fast 

sort product_name_mst year
twoway(bar n_merge year, sort)
graph export "n_merge_graph.pdf", replace 

/*levelsof product_id, local(levels)
foreach l of local levels {
twoway(bar n_merge year if product_id == `l', sort)
graph export "n_`l'_merge.pdf", replace 
}
*/ 

save "ay_n_merge.dta", replace  
restore  

drop if owner_gp_name == "Private (Indian)" | owner_gp_name == "NA" /// 
| owner_gp_name == "Private (Foreign)" 