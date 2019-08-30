use product_info.dta, clear  
 
merge m:1 co_code using "company_list.dta" 
keep if _merge ==3 //keep companies of interest  
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

collapse (sum) sales_qty sales_val, by(co_code company_name product_name_mst year)

//this table includes companies with zero sales (remove?)
drop if sales_qty ==0 & sales_val ==0
drop if sales_qty ==0 

bys year company_name product_name_mst: gen n_man = _n == 1 

gen revenue = sales_qty * sales_val 
bys year product_name_mst : egen sales_total = total(revenue)
bys year product_name_mst : gen mkt_sh = (revenue / sales_total) * 100

save "product_hhi.dta", replace

collapse (sum) n_man sales_qty sales_val, by(product_name_mst year) 

save "ay_product_man_totals.dta", replace 
