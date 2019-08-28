use "annual_financials.dta", clear 

	*validate sales/prod numbers w/ annual statements
	keep if co_code == 221166
	
	
use "product_info.dta", clear 

	*validate sales/prod numbers w/ annual statements
	keep if co_code == 221166
	collapse (sum) production sales_qty purchase_qty ///
	purchase_val sales_value, by(products_product_code year)

	sort products_product_code year
