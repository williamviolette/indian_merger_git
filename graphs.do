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
