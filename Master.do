version 14.0 
set more off 

cd "K:\BE\1255\Projects\Indian Mergers\work\data\original"
global sa "K:\BE\1255\Projects\Indian Mergers\work\data\original\Annual Financials"
global gpath "K:\BE\1255\Projects\Indian Mergers\work\results\graphs" 
global ppath "K:\BE\1255\Projects\Indian Mergers\work\data\temp" 
global programs "K:\BE\1255\Projects\Indian Mergers\work\programs\indian_merger_git" 
ssc install fs

//User Variables - WILL IMPLEMENT LATER 
*Exclude/Include services, banks, private/foreign companies? 
*global exclude_banks = "1" 

//Do Files
do "$programs\00_import_data.do"
do "$programs\01_merger_data.do"
do "$programs\02_merger_product_crosswalks.do"
do "$programs\03_merger_sales_data.do"
*do "$programs\04_hhi.do"
do "$programs\04_merge_identical_products.do"
*do "$programs\04_partial_merger_identification.do"
do "$programs\05_combine_indicators.do"
do "$programs\05_graphs.do"



