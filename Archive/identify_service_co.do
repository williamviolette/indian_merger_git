use "product_info.dta", clear 
merge m:1 co_code using "company_list.dta"  
keep if _merge ==3 
drop _merge   
  
sort product_name_mst year co_code  
  
drop if product_name =="OTHERS" & product_name_mst =="."   
  
	gen service_ind1 = 0  
		  
		replace service_ind1 = 1 if(regexm(lower(product_name_mst), "service"))  
	  
	gen service_ind2 = 0		  
	  
		replace service_ind2 = 1 if(regexm(lower(product_name), "service"))  
		  
*drop services -- check product_name_mst field in data dictionary   
drop if service_ind1 ==1   
drop if service_ind2 ==1 & product_name_mst =="."   
drop if product_name_mst =="." 
 
 
sort product_name_mst product_name  
duplicates tag year product_name_mst co_code, gen(d_ind)  
	tab d_ind  
bys year product_name_mst: gen n_man = _n ==1  
