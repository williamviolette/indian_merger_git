
//Product List 1 -> All Products for All Companies Across All Years 
*use "company_product_list1.dta", clear 
//Product List 2 -> Only includes a companies products from first year in product sales table 
use "company_product_list2.dta", clear 
merge m:1 company_name product_name_mst using "company_product_sales_rank.dta"
keep if _merge ==3 
drop _merge 
sort company_name product_rank

preserve
keep company_name product_name_mst products_product_code 
ren products_product_code product_code 
drop if product_name_mst =="NA" 
duplicates drop 
//Merge with cross walk to get company id -> using numeric instead of strings 
merge m:1 company_name using "company_crosswalk.dta"
keep if _merge ==3 
drop _merge
sort company_name
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
//Merge with company crosswalk to get company id 
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

cd "K:\BE\1255\Projects\Indian Mergers\work\data\original"
use "merge_pairs.dta", clear 
sort acquirer_code 
levelsof acquirer_code, local(levels1)
foreach l of local levels1 {
preserve
	keep if acquirer_code ==`l'
		levelsof target_code, local(levels2) 
			foreach m of local levels2 {
				use "acquired_company_product_list.dta", clear
				keep if co_id ==`l' | co_id ==`m'
				if r(N) == 0 break 
				save "$ppath\prod_`l'_`m'.dta", replace 
				bys product_name_mst: gen n_product = _N
				capture noisily keep if n_product >1 
				gen target_code = `m'
				keep if co_id ==`l'
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
drop if _merge ==2 
drop _merge 
ren (company_name co_id) (target_co target_code)
order acquirer acq_co target_co target_code 

merge m:1 acquirer target_co using "acquirer_co.dta"
drop _merge 

replace same_product =0 if same_product ==.
order acquirer acq_co target_co target_code

collapse (sum) same_product, by(acquirer target_co)

save "same_product_id.dta", replace 
