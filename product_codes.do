use "product_info.dta", clear 
ssc install fs

preserve
keep company_name product_name_mst products_product_code 
ren products_product_code product_code 
duplicates drop 
drop if product_name_mst =="."
sort company_name
merge m:1 company_name product_name_mst using "company_product_sales_rank.dta"
keep if _merge ==3 
drop _merge 
drop if product_name_mst =="NA"
sort company_name product_rank
save "company_product_list.dta", replace 
restore 

preserve
keep company_name product_name_mst products_product_code 
ren products_product_code product_code 
duplicates drop 
drop if product_name_mst =="."
sort company_name
merge m:1 company_name product_name_mst using "company_product_sales_rank.dta"
keep if _merge ==3 
drop _merge 
drop if product_name_mst =="NA"
merge m:1 company_name using "company_crosswalk.dta"
keep if _merge ==3 
drop _merge sales_value 
sort company_name product_rank
save "acquired_company_product_list.dta", replace 
restore  

use "company_product_list.dta", clear 
egen product_id = group(product_name_mst)
drop product_name_mst sales_val product_code
ren product_rank product_
reshape wide product_, i(company_name) j(product_id)
save "company_product_rank_matrix.dta", replace 


use "acquirer_co.dta", clear 
drop year
sort acquirer
ren acquirer company_name 
merge m:1 company_name using "company_crosswalk.dta"
drop if _merge ==2 
drop _merge 
ren (company_name co_id)(acquirer acquirer_code)
ren target_co company_name 
merge m:1 company_name using "company_crosswalk.dta"
drop if _merge ==2 
drop _merge 
ren (company_name co_id)(target_co target_code)
save "merge_pairs.dta", replace 

use "merge_pairs.dta"
levelsof acquirer_code, local(levels1)
foreach l of local levels1 {
preserve 
	keep if acquirer_code ==`l'
	levelsof target_code, local(levels2) 
		foreach m of local levels2 {
			use "acquired_company_product_list.dta", clear
			keep if co_id ==`l' | co_id ==`m'
			if r(N) == 0 continue 
			bys product_name_mst: gen n_product = _N
			capture noisily keep if n_product >1 
			gen target_code = `m'
			keep if co_id ==`l'
			drop product_rank
			ren company_name acquirer 
			order acquirer target_co 
			gen same_product = 1 
			save "$ppath\prod_`l'_`m'.dta", replace 
	}
restore 
}

cd "$ppath"
clear
fs prod_*.dta
append using `r(files)'

cd "K:\BE\1255\Projects\Indian Mergers\work\data\original"

drop n_product 
ren co_id acq_co 
ren target_code co_id 
merge m:1 co_id using "company_crosswalk.dta"
drop _merge 
ren (company_name co_id) (target_co targ_co)
order acquirer acq_co target_co targ_co
save "same_product_id.dta", replace 