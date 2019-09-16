use "annual_financials.dta", clear 

	keep co_code company_name sa_finance1_year sa_total_income sa_sales  ///
	sa_industrial_sales sa_sale_of_goods sa_sale_of_scrap sa_sale_of_rawmat_stores ///
	sa_job_work_inc sa_repairs_maintenance_inc sa_construction_inc ///
	sa_sale_of_electricity_gas_water sa_oth_industrial_sales sa_non_fin_services_inc ///
	sa_inc_fin_serv sa_gain_sale_of_ast sa_inc_frm_discont_operations sa_inc_prof_sale_long_term_inv_s ///
	sa_sales_n_chg_in_stk sa_net_sales sa_sales_net_fixed_assets 

	gen year = substr(string(sa_finance1_year,"%12.0g"),1,4)
	destring year, replace 
/*

total income = all income including investment income 
total income = sales + income from fin. services + other income + prior period & extra income 

sales = industrial sales + income from non-fin. services 

industrial sales = sale of scrap + sale of raw mats + income from job/work done
+ income from repairs & maint + construction & utilities 

gain_sale_of_ast = sale of fixed asset. Not part of main business activity 

*/  

	*validate sales/prod numbers w/ annual statements
	keep if co_code == 221166
	
	
use "product_info.dta", clear 

	*validate sales/prod numbers w/ annual statements
	keep if co_code == 221166

	collapse (sum) production sales_qty purchase_qty ///
	purchase_val sales_value, by(products_product_code year) fast

	sort products_product_code year
