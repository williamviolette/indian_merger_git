
version 14.0 
set more off 

cd "K:\BE\1255\Projects\Indian Mergers\work\data\original"
global sa "K:\BE\1255\Projects\Indian Mergers\work\data\original\Annual Financials"
global gpath "K:\BE\1255\Projects\Indian Mergers\work\results\graphs" 

//User Variables 

global exclude_banks = "1" 

//Do Files
do import_data 
do merger_analysis
do product_analysis 
do graphs 


