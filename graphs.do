//Graphs Do File 

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
