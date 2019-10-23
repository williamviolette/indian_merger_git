//Graphs Do File 
use "merger_indicators.dta", clear 
gen diff_product = 0 
replace diff_product = 1 if same_product ==0

gen external_purchase_ind = 0 
replace external_purchase_ind = 1 if internal_purchase_ind ==0


	preserve 
	keep if year <= 2015
	collapse (sum) merge_ind, by(year) fast 
	ren merge_ind n_merge 
	graph bar n_merge, over(year) xsize(10) title("Number of Mergers") legend(label(1 "Total Number of Mergers and Acquisitions")) //saving(1, replace)
	graph export "$gpath\n_merge_graph.pdf", replace 
	restore 

	preserve 
	keep if year <= 2015
	collapse (sum) merge_ind same_product diff_product, by(year) fast 
	ren merge_ind n_merge 
	graph bar same_product diff_product, over(year)  xsize(10) stack title("Number of Mergers") subtitle("Similar Products") legend(label(1 "Same Product") label(2 "Different Product")) //saving(2, replace)
	graph export "$gpath\n_merge_sameprod_graph.pdf", replace 
	restore 

	preserve 
	keep if year <= 2015
	collapse (sum) merge_ind internal_purchase_ind external_purchase_ind, by(year) fast 
	ren merge_ind n_merge 
	graph bar internal_purchase_ind external_purchase_ind, over(year)  xsize(10) stack title("Number of Mergers") subtitle("Internal Acquisitions") legend(label(1 "Internal Purchase") label(2 "External Purchase")) //saving(3, replace)
	graph export "$gpath\n_merge_int_graph.pdf", replace 
	restore 
	
	preserve 
	keep if same_product==1 
	keep if year <= 2015
	collapse (sum) merge_ind same_product diff_product, by(year) fast 
	ren merge_ind n_merge 
	graph bar same_product, over(year)  xsize(10) stack title("Number of Mergers") subtitle("Similar Products") legend(label(1 "Same Product"))
	graph export "$gpath\n_merge_sameprod_graph1.pdf", replace 
	restore 
	
	*gr combine 1.gph 2.gph 3.gph, ycommon xcommon xsize(10) 
	*gr export Desired_figure.pdf,replace

//Product Sales Data 
	use "ay_merger_sales_data.dta", clear
	
	merge m:1 product_name_mst using "product_sales_ranking.dta" 
	drop _merge 
	
	merge m:1 company_name year using "merger_company_list.dta"
	drop _merge 
	
	bys company_name: egen merge_indicator = max(merge_ind) 
	keep if merge_indicator ==1 
	
	collapse (sum) sales_value, by(product_name_mst rank) fast
	sort rank
	ren sales_value sales_value_m_firms 
	
	merge 1:1 product_name_mst using "product_sales_ranking.dta" 
	keep if _merge ==3
	drop _merge 
	
	gen pct_m_of_tot = (sales_value_m_firms / sales_value_all_firms) * 100
	format pct_m_of_tot %3.0f
	gsort -pct_m_of_tot
	
	histogram pct_m_of_tot, frequency title("Sales of Products from Merged Firms") subtitle("Distribution of % sales") 
	graph export "$gpath\product_percent_hist.pdf", replace 
	
//Number of Merges by Product Grouping 
	use "n_merge.dta", clear 
	preserve 
	collapse (sum) n_merge, by(year) fast 
	twoway(bar n_merge year, sort)
	graph export "$gpath\n_merge_graph.pdf", replace 
	restore 

	preserve 
	drop if product_name_mst =="NA" 
	collapse (sum) n_merge, by(year) fast 
	twoway(bar n_merge year, sort)
	graph export "$gpath\n_merge_graph_NA.pdf", replace 
	restore 
	
	//Number of mergers by product 
	/*
	levelsof product_id, local(levels)
	foreach l of local levels {
	twoway(bar n_merge year if product_id == `l', sort)
	graph export "$gpath\n_`l'_merge.pdf", replace 
	}
	*/ 
	
	use "ay_n_merge_industry.dta",clear 
	egen n_rank = rank(-n_merge)
	keep if n_rank <= 50 
	keep product_name_mst 
	merge 1:m product_name_mst using "y_n_merge_industry.dta"
	keep if _merge ==3 
	drop _merge 
	sort product_name_mst year
	egen product_id = group(product_name_mst) 

	
	
	use "y_n_merge_industry.dta",clear 
	bys product_name_mst: egen n_years = count(year) 
	*keep if n_years > 3 
	egen product_id = group(product_name_mst)
	levelsof product_id, local(levels)
	foreach l of local levels {
	twoway(bar n_merge year if product_id == `l', sort)
	graph export "$gpath\n_mergers_`l'_industry.pdf", replace 
	}
