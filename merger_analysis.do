use "merger_events.dta", clear

keep co_code mr_info_full_name entity_name_mst acquirer owner_gp_name product_name_mst year
sort product_name_mst co_code year
ren entity_name_mst target_co
order co_code acquirer owner_gp_name target_co

egen product_id = group(product_name_mst)

*drop if product_name_mst =="NA"

duplicates drop

bys year product_name_mst target_co: gen n_merge = _n ==1 

preserve
collapse (sum) n_merge, by(product_name_mst year) fast
save "ay_n_merge.dta", replace 
restore 

drop if owner_gp_name == "Private (Indian)" | owner_gp_name == "NA" ///
| owner_gp_name == "Private (Foreign)"
