use "product_info.dta", clear 
 
 *Co_Code not consistent with Company Name 
 
//Calculate HHI 
collapse (sum) sales_qty sales_val, by(company_name product_name_mst year) 
 
*this table includes companies with zero sales (remove?) 
drop if sales_qty ==0 & sales_val ==0 

bys year company_name product_name_mst: gen n_man = _n == 1  

*sales_val total sales or unit sales? Unsure. Assumging total sales.

*need to update exchange rates for each year, currently just using 2019
*gen exchange_rate = .014 
*gen sales_val_dol = sales_val * exchange_rate 
drop if product_name_mst =="."

gen revenue = sales_value 
bys product_name_mst year: egen industry_sales_total = total(revenue) 
bys company_name product_name_mst year: gen mkt_sh = (revenue / industry_sales_total) * 100 
bys company_name product_name_mst year: gen hhi = (mkt_sh)^2

sort product_name_mst company_name year 

save "product_hhi.dta", replace 
 
collapse (sum) n_man sales_qty sales_val (mean) avg_sales_val = sales_val, by(product_name_mst year)  

save "ay_product_man_totals.dta", replace  
