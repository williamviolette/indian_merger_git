use "product_info.dta", clear 
  
//ID Acquired Companies whose sales did/did not drop off 
merge m:1 company_name year using "acquired_co.dta"
*Why are we getting merge ==2 ?
drop if _merge==2 
drop _merge 
replace merge_ind = 0 if merge_ind ==. 

keep co_code company_name year prod_date product_name_mst sales_qty sales_value merge_ind 

bys company_name: egen ay_merge = max(merge_ind) 
keep if ay_merge ==1 
duplicates drop 

gen month =substr(string(prod_date,"%12.0g"),5,2)
destring month, replace 

sort company_name product_name_mst year month 

bys company_name product_name_mst: gen n_minus_3_sales = sales_qty[_n-1] + sales_qty[_n-2] + sales_qty[_n-3] if merge_ind ==1 
bys company_name product_name_mst: gen pct_chg_minus_3_sales = ((sales_qty[_n-3] - sales_qty[_n-1]) / sales_qty[_n-1])*100 if merge_ind ==1 


bys company_name product_name_mst: gen n_plus_3_sales = sales_qty[_n+1] + sales_qty[_n+2] + sales_qty[_n+3] if merge_ind ==1 
bys company_name product_name_mst: gen pct_chg_plus_3_sales = ((sales_qty[_n+3] - sales_qty[_n+1]) / sales_qty[_n+1])*100 if merge_ind ==1 

gen qty_drop = 0
replace qty_drop =1 if pct_chg_n_3_sales <= -50
/* 
ID Service Companies / Products 
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
*/ 

//Calculate HHI 
collapse (sum) sales_qty sales_val, by(co_code company_name product_name_mst year) 
 
*this table includes companies with zero sales (remove?) 
drop if sales_qty ==0 & sales_val ==0 
drop if sales_qty ==0  
 
bys year company_name product_name_mst: gen n_man = _n == 1  

*sales_val total sales or unit sales? Unsure. Assumging total sales.

*need to update exchange rates for each year, currently just using 2019
gen exchange_rate = .014 
gen sales_val_dol = sales_val * exchange_rate 
gen revenue = sales_val_dol  
bys year product_name_mst : egen sales_total = total(revenue) 
bys year product_name_mst : gen mkt_sh = (revenue / sales_total) * 100 
 
save "product_hhi.dta", replace 
 
collapse (sum) n_man sales_qty sales_val (mean) avg_sales_val = sales_val, by(product_name_mst year)  
 
save "ay_product_man_totals.dta", replace  